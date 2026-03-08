#!/usr/bin/env python3
import argparse
from pathlib import Path

from generate_arcade_enemy_sprites import BLACK, decode_png_rgba, format_byte_rows


SOURCE_CYAN = (0, 195, 217, 255)
SOURCE_RED = (224, 0, 0, 255)


def pack_singlecolor_sprite_bytes(bit_rows: list[list[int]]) -> list[int]:
    packed: list[int] = []
    for row in bit_rows:
        row_value = 0
        for bit in row:
            row_value = (row_value << 1) | (bit & 0x01)
        packed.extend(((row_value >> 16) & 0xFF, (row_value >> 8) & 0xFF, row_value & 0xFF))
    packed.append(0)
    return packed


def pack_multicolor_sprite_bytes(code_rows: list[list[int]]) -> list[int]:
    packed: list[int] = []
    for row in code_rows:
        row_value = 0
        for code in row:
            row_value = (row_value << 2) | (code & 0x03)
        packed.extend(((row_value >> 16) & 0xFF, (row_value >> 8) & 0xFF, row_value & 0xFF))
    packed.append(0)
    return packed


def load_centered_canvas(png_path: Path) -> list[list[tuple[int, int, int, int]]]:
    width, height, rows = decode_png_rgba(png_path)
    if width > 24 or height > 21:
        raise ValueError(f"{png_path} is {width}x{height}; expected at most 24x21")

    offset_x = (24 - width) // 2
    canvas = [[BLACK for _ in range(24)] for _ in range(21)]
    for y in range(height):
        for x in range(width):
            canvas[y][offset_x + x] = rows[y][x]
    return canvas


def generate_base_rows(png_path: Path) -> list[list[int]]:
    canvas = load_centered_canvas(png_path)
    rows = [[0 for _ in range(24)] for _ in range(21)]
    for y in range(21):
        for x in range(24):
            if canvas[y][x] != BLACK:
                rows[y][x] = 1
    return rows


def generate_overlay_rows(png_path: Path) -> list[list[int]]:
    canvas = load_centered_canvas(png_path)
    rows = [[0 for _ in range(12)] for _ in range(21)]
    for y in range(21):
        for cell_x in range(12):
            left = canvas[y][cell_x * 2]
            right = canvas[y][cell_x * 2 + 1]
            pair = {left, right}
            if SOURCE_RED in pair:
                rows[y][cell_x] = 3
            elif SOURCE_CYAN in pair:
                rows[y][cell_x] = 2
    return rows


def write_asm(path: Path, base_packed: list[int], overlay_packed: list[int]) -> None:
    lines = [
        "// Generated from playership.png by scripts/generate_player_sprite.py.",
        "// Do not edit by hand.",
        "",
        '* = $31c0 "Player Overlay Sprite"',
        "",
        "player_overlay_sprite_png:",
    ]
    lines.extend(format_byte_rows(overlay_packed))
    lines.extend(
        [
            "",
            '* = $3200 "Player Sprite"',
            "",
            "player_sprite_png:",
        ]
    )
    lines.extend(format_byte_rows(base_packed))
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description="Convert playership.png into layered C64 player sprites.")
    parser.add_argument("--png", default="playership.png", help="Input PNG")
    parser.add_argument("--out-asm", default="src/generated_player_sprite.asm", help="Output ASM file")
    parser.add_argument("--out-base-bin", default="src/generated_player_sprite.bin", help="Output base sprite file")
    parser.add_argument("--out-overlay-bin", default="src/generated_player_overlay.bin", help="Output overlay sprite file")
    args = parser.parse_args()

    base_packed = pack_singlecolor_sprite_bytes(generate_base_rows(Path(args.png)))
    overlay_packed = pack_multicolor_sprite_bytes(generate_overlay_rows(Path(args.png)))

    out_asm = Path(args.out_asm)
    out_base_bin = Path(args.out_base_bin)
    out_overlay_bin = Path(args.out_overlay_bin)
    write_asm(out_asm, base_packed, overlay_packed)
    out_base_bin.write_bytes(bytes(base_packed))
    out_overlay_bin.write_bytes(bytes(overlay_packed))

    print(f"Wrote {out_asm}")
    print(f"Wrote {out_base_bin}")
    print(f"Wrote {out_overlay_bin}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
