#!/usr/bin/env python3
import argparse
import re
from pathlib import Path
from typing import Optional


LABEL_RE = re.compile(r"^([A-Za-z_][A-Za-z0-9_]*):\s*$")
BYTE_RE = re.compile(r"\.byte\s+(.+)$")
IMPORT_RE = re.compile(r'^#import\s+"([^"]+)"\s*$')


def parse_value(token: str) -> int:
    token = token.strip()
    if token.startswith("$"):
        return int(token[1:], 16)
    if token.startswith("%"):
        return int(token[1:], 2)
    return int(token, 10)


def parse_sprites(text: str, allowed_labels: set[str]) -> dict[str, list[int]]:
    sprites: dict[str, list[int]] = {}
    current_label: str | None = None
    current_bytes: list[int] = []

    def flush() -> None:
        nonlocal current_label, current_bytes
        if current_label and current_bytes:
            sprites[current_label] = current_bytes
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
            current_label = next_label if next_label in allowed_labels else None
            continue

        byte_match = BYTE_RE.search(line)
        if byte_match and current_label:
            values = [part.strip() for part in byte_match.group(1).split(",")]
            current_bytes.extend(parse_value(value) for value in values)

    flush()
    return sprites


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
            imported_path = (path.parent / match.group(1)).resolve()
            output.append(load_source(imported_path, seen))
            continue
        output.append(raw_line)
    return "\n".join(output)


def render_singlecolor_sprite(sprite_bytes: list[int]) -> list[str]:
    data = sprite_bytes[:63]
    rows: list[str] = []
    for row_start in range(0, min(len(data), 63), 3):
        row_bytes = data[row_start : row_start + 3]
        if len(row_bytes) < 3:
            break
        bits = "".join(f"{byte:08b}" for byte in row_bytes)
        rows.append(bits.replace("0", ".").replace("1", "#"))
    return rows


def render_multicolor_sprite(sprite_bytes: list[int]) -> list[str]:
    data = sprite_bytes[:63]
    rows: list[str] = []
    glyphs = {
        0: "..",
        1: "11",
        2: "22",
        3: "33",
    }
    for row_start in range(0, min(len(data), 63), 3):
        row_bytes = data[row_start : row_start + 3]
        if len(row_bytes) < 3:
            break
        value = (row_bytes[0] << 16) | (row_bytes[1] << 8) | row_bytes[2]
        cells = []
        for shift in range(22, -2, -2):
            cells.append(glyphs[(value >> shift) & 0b11])
        rows.append("".join(cells))
    return rows


def render_sprite(sprite_bytes: list[int], mode: str) -> list[str]:
    if mode == "multicolor":
        return render_multicolor_sprite(sprite_bytes)
    return render_singlecolor_sprite(sprite_bytes)


def print_grouped_sprites(
    group_name: str,
    labels: list[str],
    sprites: dict[str, list[int]],
    mode: str,
) -> None:
    rendered = [render_sprite(sprites[label], mode) for label in labels]
    width = max(len(label) for label in labels)

    print(group_name)
    print("-" * len(group_name))
    print("  ".join(label.ljust(width) for label in labels))
    for row_index in range(len(rendered[0])):
        print("  ".join(sprite[row_index] for sprite in rendered))


def main() -> int:
    parser = argparse.ArgumentParser(description="Print C64 sprite frames as ASCII art.")
    parser.add_argument(
        "asm_file",
        nargs="?",
        default="src/generated_enemy_sprites.asm",
        help="Assembly file to inspect",
    )
    parser.add_argument(
        "--labels",
        nargs="*",
        default=[
            "flagship_sprite_frame0",
            "flagship_sprite_frame1",
            "flagship_sprite_frame2",
            "escort_sprite_frame0",
            "escort_sprite_frame1",
            "escort_sprite_frame2",
            "grunt_sprite_frame0",
            "grunt_sprite_frame1",
            "grunt_sprite_frame2",
        ],
        help="Sprite labels to print",
    )
    parser.add_argument(
        "--grouped",
        action="store_true",
        help="Print related animation frames side by side",
    )
    parser.add_argument(
        "--mode",
        choices=("singlecolor", "multicolor"),
        default="singlecolor",
        help="How to decode the sprite bytes",
    )
    args = parser.parse_args()

    asm_path = Path(args.asm_file)
    allowed_labels = set(args.labels)
    sprites = parse_sprites(load_source(asm_path), allowed_labels)

    missing = [label for label in args.labels if label not in sprites]
    if missing:
        raise SystemExit(f"Missing sprite labels: {', '.join(missing)}")

    if args.grouped:
        groups = {
            "flagship": [label for label in args.labels if label.startswith("flagship_")],
            "escort": [label for label in args.labels if label.startswith("escort_")],
            "grunt": [label for label in args.labels if label.startswith("grunt_")],
        }
        printed = False
        for group_name, labels in groups.items():
            if not labels:
                continue
            if printed:
                print()
            print_grouped_sprites(group_name, labels, sprites, args.mode)
            printed = True
        return 0

    for index, label in enumerate(args.labels):
        if index:
            print()
        print(label)
        print("-" * len(label))
        for row in render_sprite(sprites[label], args.mode):
            print(row)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
