#!/usr/bin/env python3
import argparse
import struct
import zlib
from pathlib import Path
from typing import Optional

from generate_arcade_enemy_sprites import (
    ROW_LABELS,
    ROW_COLOR_CODES,
    cell_pixels,
    decode_png_rgba,
    fit_color_rows_to_sprite_grid,
    find_separators,
    pixels_to_color_codes,
    split_ranges,
)


PNG_SIGNATURE = b"\x89PNG\r\n\x1a\n"

TARGET_SPRITE_WIDTH = 24
TARGET_SPRITE_HEIGHT = 21
LOGICAL_WIDTH = TARGET_SPRITE_WIDTH // 2

TRANSPARENT = (0, 0, 0, 255)
SHARED_MULTI0 = (0x55, 0x3F, 0xE4, 0xFF)
SHARED_MULTI1 = (0xBC, 0x52, 0x41, 0xFF)
ROW_SPECIFIC_COLORS = (
    (0xFF, 0xFF, 0x77, 0xFF),
    (0xB9, 0x56, 0xEB, 0xFF),
    (0x8F, 0xEF, 0xFB, 0xFF),
)


def png_chunk(chunk_type: bytes, payload: bytes) -> bytes:
    return (
        struct.pack(">I", len(payload))
        + chunk_type
        + payload
        + struct.pack(">I", zlib.crc32(chunk_type + payload) & 0xFFFFFFFF)
    )


def write_rgba_png(path: Path, rows: list[list[tuple[int, int, int, int]]]) -> None:
    height = len(rows)
    width = len(rows[0])

    raw = bytearray()
    for row in rows:
        raw.append(0)
        for red, green, blue, alpha in row:
            raw.extend((red, green, blue, alpha))

    ihdr = struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0)
    idat = zlib.compress(bytes(raw))

    payload = bytearray(PNG_SIGNATURE)
    payload.extend(png_chunk(b"IHDR", ihdr))
    payload.extend(png_chunk(b"IDAT", idat))
    payload.extend(png_chunk(b"IEND", b""))

    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(payload)


def expand_multicolor_row(color_row: list[int], row_specific_color: tuple[int, int, int, int]) -> list[tuple[int, int, int, int]]:
    palette = {
        0: TRANSPARENT,
        1: SHARED_MULTI0,
        2: row_specific_color,
        3: SHARED_MULTI1,
    }
    expanded: list[tuple[int, int, int, int]] = []
    for code in color_row:
        pixel = palette[code]
        expanded.append(pixel)
        expanded.append(pixel)
    return expanded


def build_sprite_sheet_rows(
    png_path: Path,
    row_indices: Optional[list[int]] = None,
) -> list[list[tuple[int, int, int, int]]]:
    _, _, rows = decode_png_rgba(png_path)
    separator_rows, separator_cols, background = find_separators(rows)

    x_ranges = split_ranges(len(rows[0]), separator_cols)
    y_ranges = split_ranges(len(rows), separator_rows)

    if len(x_ranges) != 3 or len(y_ranges) != 3:
        raise ValueError(f"Expected a 3x3 grid, got x={x_ranges} y={y_ranges}")

    selected_rows = row_indices if row_indices is not None else list(range(len(ROW_LABELS)))

    output_rows: list[list[tuple[int, int, int, int]]] = []
    for row_index in selected_rows:
        row_specific_color = ROW_SPECIFIC_COLORS[row_index]
        sprite_row_buffers = [[] for _ in range(TARGET_SPRITE_HEIGHT)]
        for frame_index in range(3):
            pixels = cell_pixels(rows, x_ranges[frame_index], y_ranges[row_index], background)
            codes = pixels_to_color_codes(pixels, ROW_COLOR_CODES[row_index])
            fitted = fit_color_rows_to_sprite_grid(
                codes,
                target_width=LOGICAL_WIDTH,
                target_height=TARGET_SPRITE_HEIGHT,
            )
            for y, code_row in enumerate(fitted):
                sprite_row_buffers[y].extend(expand_multicolor_row(code_row, row_specific_color))
        output_rows.extend(sprite_row_buffers)
    return output_rows


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Build a 72x63 multicolor sprite sheet that png2prg can convert as 9 C64 sprites."
    )
    parser.add_argument(
        "--png",
        default="ArcadeGalaxian3ships.png",
        help="Input 3x3 source PNG",
    )
    parser.add_argument(
        "--out",
        default="artifacts/png2prg_enemy_sprites.png",
        help="Output normalized PNG for png2prg",
    )
    parser.add_argument(
        "--row",
        type=int,
        choices=range(len(ROW_LABELS)),
        help="Optional row index to export on its own (0=flagship, 1=escort, 2=grunt)",
    )
    args = parser.parse_args()

    row_indices = None if args.row is None else [args.row]
    output_rows = build_sprite_sheet_rows(Path(args.png), row_indices=row_indices)
    write_rgba_png(Path(args.out), output_rows)
    print(f"Wrote {args.out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
