#!/usr/bin/env python3
import argparse
import html
import json
import re
from pathlib import Path
from typing import Optional


LABEL_RE = re.compile(r"^([A-Za-z_][A-Za-z0-9_]*):\s*$")
BYTE_RE = re.compile(r"\.byte\s+(.+)$")
IMPORT_RE = re.compile(r'^#import\s+"([^"]+)"\s*$')

C64_COLORS = {
    0: "#000000",
    1: "#ffffff",
    2: "#813338",
    3: "#75cec8",
    4: "#8e3c97",
    5: "#56ac4d",
    6: "#2e2c9b",
    7: "#edf171",
    8: "#8e5029",
    9: "#553800",
    10: "#c46c71",
    11: "#4a4a4a",
    12: "#7b7b7b",
    13: "#a9ff9f",
    14: "#706deb",
    15: "#b2b2b2",
}

DEFAULT_ENEMY_LABELS = [
    "flagship_sprite_frame0",
    "flagship_sprite_frame1",
    "flagship_sprite_frame2",
    "escort_sprite_frame0",
    "escort_sprite_frame1",
    "escort_sprite_frame2",
    "grunt_sprite_frame0",
    "grunt_sprite_frame1",
    "grunt_sprite_frame2",
]


def parse_value(token: str) -> int:
    token = token.strip()
    if token.startswith("$"):
        return int(token[1:], 16)
    if token.startswith("%"):
        return int(token[1:], 2)
    return int(token, 10)


def parse_color(value: str) -> int:
    color = parse_value(value)
    if color < 0 or color > 15:
        raise argparse.ArgumentTypeError(f"C64 colors must be in the range 0-15, got {value!r}")
    return color


def load_source(path: Path, seen: Optional[set[Path]] = None) -> str:
    if seen is None:
        seen = set()

    resolved = path.resolve()
    if resolved in seen:
        return ""
    seen.add(resolved)

    output: list[str] = []
    for raw_line in path.read_text(encoding="utf-8").splitlines():
        match = IMPORT_RE.match(raw_line.strip())
        if match:
            output.append(load_source((path.parent / match.group(1)).resolve(), seen))
            continue
        output.append(raw_line)
    return "\n".join(output)


def parse_asm_sprites(text: str, allowed_labels: Optional[set[str]]) -> list[tuple[str, list[int]]]:
    sprites: list[tuple[str, list[int]]] = []
    current_label: str | None = None
    current_bytes: list[int] = []

    def flush() -> None:
        nonlocal current_label, current_bytes
        if not current_label or not current_bytes:
            current_label = None
            current_bytes = []
            return
        if allowed_labels is None:
            if len(current_bytes) == 64:
                sprites.append((current_label, current_bytes))
        elif current_label in allowed_labels:
            sprites.append((current_label, current_bytes))
        current_label = None
        current_bytes = []

    for raw_line in text.splitlines():
        line = raw_line.strip()
        if not line:
            continue
        if line.startswith("* = "):
            flush()
            continue

        label_match = LABEL_RE.match(line)
        if label_match:
            flush()
            next_label = label_match.group(1)
            current_label = next_label if allowed_labels is None or next_label in allowed_labels else None
            continue

        byte_match = BYTE_RE.search(line)
        if byte_match and current_label:
            values = [part.strip() for part in byte_match.group(1).split(",")]
            current_bytes.extend(parse_value(value) for value in values)

    flush()

    if allowed_labels is None:
        return sprites

    lookup = {label: data for label, data in sprites}
    missing = [label for label in allowed_labels if label not in lookup]
    if missing:
        raise SystemExit(f"Missing sprite labels: {', '.join(sorted(missing))}")
    return [(label, lookup[label]) for label in allowed_labels if label in lookup]


def load_binary_sprites(path: Path, labels: Optional[list[str]]) -> list[tuple[str, list[int]]]:
    payload = path.read_bytes()
    if len(payload) % 64 != 0:
        raise SystemExit(f"{path} is {len(payload)} bytes; expected a multiple of 64 for raw C64 sprites")

    sprite_count = len(payload) // 64
    if labels and len(labels) != sprite_count:
        raise SystemExit(f"{path} contains {sprite_count} sprites but {len(labels)} labels were provided")

    if labels:
        names = labels
    elif sprite_count == len(DEFAULT_ENEMY_LABELS):
        names = DEFAULT_ENEMY_LABELS
    else:
        names = [f"sprite_{index}" for index in range(sprite_count)]
    return [
        (names[index], list(payload[index * 64 : (index + 1) * 64]))
        for index in range(sprite_count)
    ]


def load_binary_sprite_chunks(path: Path) -> list[list[int]]:
    payload = path.read_bytes()
    if len(payload) % 64 != 0:
        raise SystemExit(f"{path} is {len(payload)} bytes; expected a multiple of 64 for raw C64 sprites")
    return [list(payload[index : index + 64]) for index in range(0, len(payload), 64)]


def load_metadata(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def infer_sprite_color(label: str) -> int:
    if label.startswith("flagship_"):
        return 7
    if label.startswith("escort_"):
        return 4
    if label.startswith("grunt_"):
        return 3
    if "player" in label:
        return 15
    if "shot" in label:
        return 1
    return 7


def expand_individual_colors(
    value: Optional[str],
    labels: list[str],
) -> list[int]:
    if not value:
        return [infer_sprite_color(label) for label in labels]

    colors = [parse_color(token) for token in value.split(",") if token.strip()]
    if len(colors) == 1:
        return colors * len(labels)
    if len(colors) != len(labels):
        raise SystemExit(
            f"--individual-colors requires 1 value or {len(labels)} values, got {len(colors)}"
        )
    return colors


def decode_singlecolor(sprite_bytes: list[int]) -> list[list[int]]:
    rows: list[list[int]] = []
    data = sprite_bytes[:63]
    for offset in range(0, 63, 3):
        row_bytes = data[offset : offset + 3]
        bits = "".join(f"{byte:08b}" for byte in row_bytes)
        rows.append([int(bit) for bit in bits])
    return rows


def decode_multicolor(sprite_bytes: list[int]) -> list[list[int]]:
    rows: list[list[int]] = []
    data = sprite_bytes[:63]
    for offset in range(0, 63, 3):
        row_bytes = data[offset : offset + 3]
        value = (row_bytes[0] << 16) | (row_bytes[1] << 8) | row_bytes[2]
        row: list[int] = []
        for shift in range(22, -2, -2):
            row.append((value >> shift) & 0b11)
        rows.append(row)
    return rows


def render_svg(
    sprites: list[tuple[str, list[int]]],
    output_path: Path,
    mode: str,
    columns: int,
    scale: int,
    multicolor0: int,
    multicolor1: int,
    individual_colors: list[int],
) -> None:
    columns = max(1, columns)
    sprite_width = 24
    sprite_height = 21
    title_height = scale * 3
    padding = scale * 2
    tile_width = sprite_width * scale + padding * 2
    tile_height = sprite_height * scale + title_height + padding * 2
    total_width = tile_width * min(columns, len(sprites))
    total_rows = (len(sprites) + columns - 1) // columns
    total_height = tile_height * total_rows

    lines = [
        '<?xml version="1.0" encoding="UTF-8"?>',
        (
            f'<svg xmlns="http://www.w3.org/2000/svg" width="{total_width}" '
            f'height="{total_height}" viewBox="0 0 {total_width} {total_height}">'
        ),
        '  <rect width="100%" height="100%" fill="#0f1115"/>',
    ]

    for index, ((label, sprite_bytes), specific_color) in enumerate(zip(sprites, individual_colors)):
        column = index % columns
        row = index // columns
        origin_x = column * tile_width
        origin_y = row * tile_height
        pixel_origin_x = origin_x + padding
        pixel_origin_y = origin_y + padding + title_height

        lines.append(
            f'  <g transform="translate({origin_x},{origin_y})">'
        )
        lines.append(
            f'    <rect x="0" y="0" width="{tile_width}" height="{tile_height}" '
            'rx="8" fill="#171b22" stroke="#2b3340"/>'
        )
        lines.append(
            f'    <text x="{padding}" y="{padding + scale}" fill="#d8dee9" '
            f'font-family="Menlo, Monaco, monospace" font-size="{scale * 1.25}">{html.escape(label)}</text>'
        )
        lines.append(
            f'    <rect x="{pixel_origin_x - origin_x}" y="{pixel_origin_y - origin_y}" '
            f'width="{sprite_width * scale}" height="{sprite_height * scale}" fill="#050607" stroke="#222833"/>'
        )

        if mode == "singlecolor":
            decoded_rows = decode_singlecolor(sprite_bytes)
            for y, decoded_row in enumerate(decoded_rows):
                for x, bit in enumerate(decoded_row):
                    if not bit:
                        continue
                    lines.append(
                        f'    <rect x="{padding + x * scale}" y="{padding + title_height + y * scale}" '
                        f'width="{scale}" height="{scale}" fill="{C64_COLORS[specific_color]}"/>'
                    )
        else:
            decoded_rows = decode_multicolor(sprite_bytes)
            color_map = {
                1: C64_COLORS[multicolor0],
                2: C64_COLORS[specific_color],
                3: C64_COLORS[multicolor1],
            }
            for y, decoded_row in enumerate(decoded_rows):
                for x, code in enumerate(decoded_row):
                    fill = color_map.get(code)
                    if not fill:
                        continue
                    lines.append(
                        f'    <rect x="{padding + x * scale * 2}" y="{padding + title_height + y * scale}" '
                        f'width="{scale * 2}" height="{scale}" fill="{fill}"/>'
                    )

        lines.append("  </g>")

    lines.append("</svg>")
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def render_assets_svg(
    assets: list[dict],
    sprite_chunks: list[list[int]],
    output_path: Path,
    columns: int,
    scale: int,
) -> None:
    sprite_width = 24
    sprite_height = 21
    title_height = scale * 3
    padding = scale * 2
    tile_width = sprite_width * scale + padding * 2
    tile_height = sprite_height * scale + title_height + padding * 2
    positioned = all("band" in asset and "segment" in asset for asset in assets)

    if positioned and assets:
        columns = max(asset["segment"] for asset in assets) + 1
        total_rows = max(asset["band"] for asset in assets) + 1
        origin_for_asset = lambda index, asset: (asset["segment"] * tile_width, asset["band"] * tile_height)
    else:
        columns = max(1, columns)
        total_rows = (len(assets) + columns - 1) // columns
        origin_for_asset = lambda index, asset: ((index % columns) * tile_width, (index // columns) * tile_height)

    total_width = tile_width * columns
    total_height = tile_height * total_rows

    lines = [
        '<?xml version="1.0" encoding="UTF-8"?>',
        (
            f'<svg xmlns="http://www.w3.org/2000/svg" width="{total_width}" '
            f'height="{total_height}" viewBox="0 0 {total_width} {total_height}">'
        ),
        '  <rect width="100%" height="100%" fill="#0f1115"/>',
    ]

    if positioned:
        occupied = {(asset["band"], asset["segment"]) for asset in assets}
        for band in range(total_rows):
            for segment in range(columns):
                if (band, segment) in occupied:
                    continue
                origin_x = segment * tile_width
                origin_y = band * tile_height
                lines.append(f'  <g transform="translate({origin_x},{origin_y})">')
                lines.append(
                    f'    <rect x="0" y="0" width="{tile_width}" height="{tile_height}" '
                    'rx="8" fill="#12161d" stroke="#252c37" stroke-dasharray="8 6"/>'
                )
                lines.append(
                    f'    <text x="{padding}" y="{padding + scale}" fill="#5d6776" '
                    f'font-family="Menlo, Monaco, monospace" font-size="{scale * 1.25}">empty</text>'
                )
                lines.append("  </g>")

    for index, asset in enumerate(assets):
        origin_x, origin_y = origin_for_asset(index, asset)
        label = asset.get("label", asset.get("title", f"asset_{index}"))
        title = asset.get("title", label)

        lines.append(f'  <g transform="translate({origin_x},{origin_y})">')
        lines.append(
            f'    <rect x="0" y="0" width="{tile_width}" height="{tile_height}" '
            'rx="8" fill="#171b22" stroke="#2b3340"/>'
        )
        lines.append(
            f'    <text x="{padding}" y="{padding + scale}" fill="#d8dee9" '
            f'font-family="Menlo, Monaco, monospace" font-size="{scale * 1.25}">{html.escape(label)}</text>'
        )
        lines.append(
            f'    <rect x="{padding}" y="{padding + title_height}" width="{sprite_width * scale}" '
            f'height="{sprite_height * scale}" fill="#050607" stroke="#222833"/>'
        )

        for layer in asset.get("layers", []):
            sprite_index = layer.get("sprite_index")
            if sprite_index is None or sprite_index >= len(sprite_chunks):
                raise SystemExit(f"Metadata for {label} references missing sprite index {sprite_index}")
            sprite_bytes = sprite_chunks[sprite_index]

            if layer.get("mode") == "singlecolor":
                decoded_rows = decode_singlecolor(sprite_bytes)
                fill = C64_COLORS[layer["sprite_color"]]
                for y, decoded_row in enumerate(decoded_rows):
                    for x, bit in enumerate(decoded_row):
                        if not bit:
                            continue
                        lines.append(
                            f'    <rect x="{padding + x * scale}" y="{padding + title_height + y * scale}" '
                            f'width="{scale}" height="{scale}" fill="{fill}"/>'
                        )
            else:
                decoded_rows = decode_multicolor(sprite_bytes)
                color_map = {
                    1: C64_COLORS[layer["d025"]],
                    2: C64_COLORS[layer["sprite_color"]],
                    3: C64_COLORS[layer["d026"]],
                }
                for y, decoded_row in enumerate(decoded_rows):
                    for x, code in enumerate(decoded_row):
                        fill = color_map.get(code)
                        if not fill:
                            continue
                        lines.append(
                            f'    <rect x="{padding + x * scale * 2}" y="{padding + title_height + y * scale}" '
                            f'width="{scale * 2}" height="{scale}" fill="{fill}"/>'
                        )

        lines.append("  </g>")

    lines.append("</svg>")
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description="Render raw C64 sprite data as an SVG preview sheet.")
    parser.add_argument(
        "source",
        nargs="?",
        default="src/generated_enemy_sprites.bin",
        help="Sprite source file (.bin or .asm)",
    )
    parser.add_argument(
        "--out",
        default="artifacts/enemy-sprites-preview.svg",
        help="Output SVG file",
    )
    parser.add_argument(
        "--labels",
        nargs="*",
        help="Optional labels. For .bin input this must match the sprite count.",
    )
    parser.add_argument(
        "--mode",
        choices=("singlecolor", "multicolor"),
        default="multicolor",
        help="How to decode the sprite bytes",
    )
    parser.add_argument(
        "--columns",
        type=int,
        default=3,
        help="Number of sprite columns in the preview sheet",
    )
    parser.add_argument(
        "--scale",
        type=int,
        default=8,
        help="Preview pixel scale",
    )
    parser.add_argument(
        "--multicolor0",
        type=parse_color,
        default=6,
        help="Shared multicolor 0 C64 color index",
    )
    parser.add_argument(
        "--multicolor1",
        type=parse_color,
        default=2,
        help="Shared multicolor 1 C64 color index",
    )
    parser.add_argument(
        "--individual-colors",
        help="Comma-separated sprite-specific C64 color indices. One value repeats to all sprites.",
    )
    parser.add_argument(
        "--metadata",
        help="Optional metadata JSON for composite asset previews",
    )
    args = parser.parse_args()

    source_path = Path(args.source)
    metadata_path = Path(args.metadata) if args.metadata else None
    if metadata_path is None and source_path.suffix.lower() == ".bin":
        auto_metadata_path = source_path.with_suffix(".json")
        if auto_metadata_path.exists():
            metadata_path = auto_metadata_path

    if source_path.suffix.lower() == ".bin" and metadata_path and metadata_path.exists() and not args.labels:
        metadata = load_metadata(metadata_path)
        sprite_chunks = load_binary_sprite_chunks(source_path)
        assets = metadata.get("assets", [])
        if assets:
            output_path = Path(args.out)
            render_assets_svg(assets, sprite_chunks, output_path, args.columns, args.scale)
            print(f"Wrote {output_path}")
            return 0

    if source_path.suffix.lower() == ".bin":
        sprites = load_binary_sprites(source_path, args.labels)
    else:
        allowed_labels = None if not args.labels else set(args.labels)
        sprites = parse_asm_sprites(load_source(source_path), allowed_labels)
        if args.labels:
            lookup = {label: data for label, data in sprites}
            sprites = [(label, lookup[label]) for label in args.labels]

    if not sprites:
        raise SystemExit(f"No sprite data found in {source_path}")

    labels = [label for label, _ in sprites]
    individual_colors = expand_individual_colors(args.individual_colors, labels)

    output_path = Path(args.out)
    render_svg(
        sprites,
        output_path,
        args.mode,
        args.columns,
        args.scale,
        args.multicolor0,
        args.multicolor1,
        individual_colors,
    )
    print(f"Wrote {output_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
