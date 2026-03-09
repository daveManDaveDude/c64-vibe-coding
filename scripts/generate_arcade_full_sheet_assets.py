#!/usr/bin/env python3
import argparse
import json
from pathlib import Path

from generate_arcade_enemy_sprites import (
    BLACK,
    GRAY_SEPARATOR,
    ROW_LABELS,
    decode_png_rgba,
    format_byte_rows,
    full_sheet_segments,
    generate_sprite_rows,
    pack_multicolor_sprite_bytes,
)


VICE_PALETTE = {
    0: (0x00, 0x00, 0x00),
    1: (0xFF, 0xFF, 0xFF),
    2: (0xBC, 0x52, 0x41),
    3: (0x8F, 0xEF, 0xFB),
    4: (0xB9, 0x56, 0xEB),
    5: (0x7E, 0xDB, 0x40),
    6: (0x55, 0x3F, 0xE4),
    7: (0xFF, 0xFF, 0x77),
    8: (0xC1, 0x7B, 0x1D),
    9: (0x82, 0x63, 0x00),
    10: (0xF4, 0x94, 0x86),
    11: (0x72, 0x72, 0x72),
    12: (0xA4, 0xA4, 0xA4),
    13: (0xCD, 0xFF, 0x98),
    14: (0x9E, 0x8D, 0xFF),
    15: (0xD5, 0xD5, 0xD5),
}

ENEMY_COLOR_TRIPLES = (
    (6, 7, 2),
    (6, 4, 2),
    (6, 3, 2),
)


def nearest_c64_color(pixel: tuple[int, int, int, int]) -> int:
    red, green, blue, _ = pixel
    best_index = 0
    best_distance = None
    for index, (pr, pg, pb) in VICE_PALETTE.items():
        distance = (red - pr) ** 2 + (green - pg) ** 2 + (blue - pb) ** 2
        if best_distance is None or distance < best_distance:
            best_distance = distance
            best_index = index
    return best_index


def sprite_block(address: int, title: str, label: str, data: list[int]) -> str:
    lines = [f'* = ${address:04x} "{title}"', "", f"{label}:"]
    lines.extend(format_byte_rows(data))
    return "\n".join(lines)


def visible_pixels(
    pixels: list[list[tuple[int, int, int, int]]],
) -> list[tuple[int, int, int, int]]:
    values = []
    for row in pixels:
        for pixel in row:
            if pixel in (BLACK, GRAY_SEPARATOR):
                continue
            values.append(pixel)
    return values


def content_width(
    pixels: list[list[tuple[int, int, int, int]]],
) -> int:
    min_x = len(pixels[0])
    max_x = -1
    for row in pixels:
        for x, pixel in enumerate(row):
            if pixel in (BLACK, GRAY_SEPARATOR):
                continue
            min_x = min(min_x, x)
            max_x = max(max_x, x)
    if max_x < 0:
        return 0
    return max_x - min_x + 1


def fit_singlecolor_rows_to_sprite_grid(
    bit_rows: list[list[int]],
    target_width: int = 24,
    target_height: int = 21,
) -> list[list[int]]:
    source_height = len(bit_rows)
    source_width = len(bit_rows[0])
    if source_width > target_width or source_height > target_height:
        raise ValueError(
            f"Singlecolor layer {source_width}x{source_height} exceeds C64 sprite grid {target_width}x{target_height}"
        )

    target_x_start = (target_width - source_width) // 2
    fitted = [[0 for _ in range(target_width)] for _ in range(target_height)]
    for y in range(source_height):
        for x in range(source_width):
            fitted[y][target_x_start + x] = bit_rows[y][x]
    return fitted


def fit_fullsheet_multicolor_rows_to_sprite_grid(
    color_rows: list[list[int]],
    target_width: int = 12,
    target_height: int = 21,
) -> list[list[int]]:
    source_height = len(color_rows)
    source_width = len(color_rows[0])

    if source_height > target_height:
        raise ValueError(
            f"Source sprite height {source_height} exceeds C64 multicolor sprite height {target_height}"
        )

    min_x = source_width
    max_x = -1
    for row in color_rows:
        for x, code in enumerate(row):
            if code == 0:
                continue
            min_x = min(min_x, x)
            max_x = max(max_x, x)

    fitted = [[0 for _ in range(target_width)] for _ in range(target_height)]
    if max_x < 0:
        return fitted

    if source_width <= target_width:
        source_x_start = 0
        copy_width = source_width
    else:
        content_width = max_x - min_x + 1
        if content_width > target_width:
            raise ValueError(
                f"Source sprite content width {content_width} exceeds C64 multicolor sprite width {target_width}"
            )
        source_x_start = min_x
        copy_width = content_width

    target_x_start = (target_width - copy_width) // 2
    for y in range(source_height):
        for x in range(copy_width):
            fitted[y][target_x_start + x] = color_rows[y][source_x_start + x]

    return fitted


def pack_singlecolor_sprite_bytes(bit_rows: list[list[int]]) -> list[int]:
    packed: list[int] = []
    for row in bit_rows:
        row_value = 0
        for bit in row:
            row_value = (row_value << 1) | (bit & 0x01)
        packed.extend(((row_value >> 16) & 0xFF, (row_value >> 8) & 0xFF, row_value & 0xFF))
    packed.append(0)
    return packed


def assign_multicolor_slots(color_indices: list[int]) -> tuple[int, int, int]:
    remaining = list(dict.fromkeys(color_indices))
    d025 = 6 if 6 in remaining else None
    if d025 is not None:
        remaining.remove(6)

    d026 = 2 if 2 in remaining else None
    if d026 is not None:
        remaining.remove(2)

    preferred_sprite_colors = [7, 4, 3, 8, 15, 14, 10, 1, 13, 12, 11, 9, 5]
    sprite_color = None
    for color in preferred_sprite_colors:
        if color in remaining:
            sprite_color = color
            remaining.remove(color)
            break

    for color in list(remaining):
        if d025 is None:
            d025 = color
            remaining.remove(color)
            continue
        if sprite_color is None:
            sprite_color = color
            remaining.remove(color)
            continue
        if d026 is None:
            d026 = color
            remaining.remove(color)
            continue

    if d025 is None:
        d025 = 0
    if sprite_color is None:
        sprite_color = d025
    if d026 is None:
        d026 = d025
    return d025, sprite_color, d026


def build_multicolor_layer(
    label: str,
    title: str,
    pixels: list[list[tuple[int, int, int, int]]],
) -> tuple[list[int], dict]:
    color_indices = sorted({nearest_c64_color(pixel) for pixel in visible_pixels(pixels)})
    d025, sprite_color, d026 = assign_multicolor_slots(color_indices)
    slot_for_color = {d025: 1, sprite_color: 2, d026: 3}

    color_rows: list[list[int]] = []
    for row in pixels:
        codes = []
        for pixel in row:
            if pixel in (BLACK, GRAY_SEPARATOR):
                codes.append(0)
                continue
            codes.append(slot_for_color[nearest_c64_color(pixel)])
        color_rows.append(codes)

    fitted = fit_fullsheet_multicolor_rows_to_sprite_grid(color_rows)
    packed = pack_multicolor_sprite_bytes(fitted)
    layer = {
        "label": label,
        "mode": "multicolor",
        "d025": d025,
        "sprite_color": sprite_color,
        "d026": d026,
        "title": title,
    }
    return packed, layer


def build_singlecolor_layers(
    asset_label: str,
    asset_title: str,
    pixels: list[list[tuple[int, int, int, int]]],
) -> tuple[list[list[int]], list[dict]]:
    source_colors = []
    for pixel in visible_pixels(pixels):
        if pixel not in source_colors:
            source_colors.append(pixel)

    packed_layers: list[list[int]] = []
    metadata_layers: list[dict] = []
    for layer_index, source_color in enumerate(source_colors):
        bit_rows = []
        for row in pixels:
            bits = []
            for pixel in row:
                bits.append(1 if pixel == source_color else 0)
            bit_rows.append(bits)
        fitted = fit_singlecolor_rows_to_sprite_grid(bit_rows)
        packed_layers.append(pack_singlecolor_sprite_bytes(fitted))
        metadata_layers.append(
            {
                "label": f"{asset_label}_layer{layer_index}",
                "mode": "singlecolor",
                "sprite_color": nearest_c64_color(source_color),
                "title": f"{asset_title} Layer {layer_index}",
            }
        )
    return packed_layers, metadata_layers


def build_full_assets(png_path: Path) -> tuple[list[dict], list[tuple[str, str, list[int]]]]:
    _, _, rows = decode_png_rgba(png_path)
    segments = full_sheet_segments(rows)

    enemy_rows = generate_sprite_rows(png_path)
    assets: list[dict] = []
    layers: list[tuple[str, str, list[int]]] = []

    enemy_segment_keys = {(band, segment) for band in range(3) for segment in range(3)}

    for enemy_index, (title, label, packed) in enumerate(enemy_rows):
        d025, sprite_color, d026 = ENEMY_COLOR_TRIPLES[enemy_index // 3]
        asset = {
            "label": label,
            "title": title,
            "band": enemy_index // 3,
            "segment": enemy_index % 3,
            "layers": [
                {
                    "label": label,
                    "mode": "multicolor",
                    "d025": d025,
                    "sprite_color": sprite_color,
                    "d026": d026,
                    "title": title,
                }
            ],
        }
        assets.append(asset)
        layers.append((title, label, packed))

    extra_index = 0
    for band_index, segment_index, x_range, y_range, pixels in segments:
        if (band_index, segment_index) in enemy_segment_keys:
            continue

        asset_label = f"arcade_b{band_index}_s{segment_index}"
        asset_title = f"Arcade Band {band_index} Segment {segment_index}"
        width = content_width(pixels)
        source_colors = {nearest_c64_color(pixel) for pixel in visible_pixels(pixels)}

        asset = {
            "label": asset_label,
            "title": asset_title,
            "band": band_index,
            "segment": segment_index,
            "source_width": len(x_range),
            "source_height": len(y_range),
            "content_width": width,
            "layers": [],
        }

        if width <= 12 and len(source_colors) <= 3:
            layer_label = f"{asset_label}_mc"
            packed, layer = build_multicolor_layer(layer_label, asset_title, pixels)
            asset["layers"].append(layer)
            layers.append((asset_title, layer_label, packed))
        else:
            packed_layers, metadata_layers = build_singlecolor_layers(asset_label, asset_title, pixels)
            asset["layers"].extend(metadata_layers)
            for layer, packed in zip(metadata_layers, packed_layers):
                layers.append((layer["title"], layer["label"], packed))

        assets.append(asset)
        extra_index += 1

    for sprite_index, asset in enumerate(assets):
        for layer in asset["layers"]:
            for layer_index, (_, label, _) in enumerate(layers):
                if label == layer["label"]:
                    layer["sprite_index"] = layer_index
                    break

    return assets, layers


def write_asm(path: Path, layers: list[tuple[str, str, list[int]]]) -> None:
    blocks = [
        "// Generated from ArcadeGalaxianSprites.png by scripts/generate_arcade_full_sheet_assets.py.",
        "// Do not edit by hand.",
        "",
    ]
    base_address = 0x2000
    for index, (title, label, packed) in enumerate(layers):
        blocks.append(sprite_block(base_address + index * 0x40, title, label, packed))
        blocks.append("")
    path.write_text("\n".join(blocks).rstrip() + "\n", encoding="utf-8")


def write_bin(path: Path, layers: list[tuple[str, str, list[int]]]) -> None:
    payload = bytearray()
    for _, _, packed in layers:
        payload.extend(packed)
    path.write_bytes(payload)


def write_metadata(path: Path, png_path: Path, assets: list[dict]) -> None:
    path.write_text(
        json.dumps(
            {
                "source_png": png_path.name,
                "assets": assets,
            },
            indent=2,
        )
        + "\n",
        encoding="utf-8",
    )


def main() -> int:
    parser = argparse.ArgumentParser(description="Generate full-sheet C64 sprite assets from ArcadeGalaxianSprites.png.")
    parser.add_argument("--png", default="ArcadeGalaxianSprites.png", help="Input full sprite sheet")
    parser.add_argument("--out-asm", default="src/generated_arcade_sprites.asm", help="Output ASM file")
    parser.add_argument("--out-bin", default="src/generated_arcade_sprites.bin", help="Output raw sprite bank")
    parser.add_argument("--out-json", default="src/generated_arcade_sprites.json", help="Output metadata JSON")
    args = parser.parse_args()

    assets, layers = build_full_assets(Path(args.png))

    out_asm = Path(args.out_asm)
    out_bin = Path(args.out_bin)
    out_json = Path(args.out_json)
    write_asm(out_asm, layers)
    write_bin(out_bin, layers)
    write_metadata(out_json, Path(args.png), assets)

    print(f"Wrote {out_asm}")
    print(f"Wrote {out_bin}")
    print(f"Wrote {out_json}")
    print(f"Exported {len(assets)} assets as {len(layers)} sprite layers")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
