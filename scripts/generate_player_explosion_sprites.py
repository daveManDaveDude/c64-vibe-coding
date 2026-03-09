#!/usr/bin/env python3
import argparse
from pathlib import Path

from generate_arcade_enemy_sprites import (
    BLACK,
    decode_png_rgba,
    format_byte_rows,
    pack_multicolor_sprite_bytes,
)


FRAME_COUNT = 4
FRAME_SIZE = 32
FRAME_STRIDE = 33
QUADRANT_SIZE = 16
TARGET_WIDTH = 12
TARGET_HEIGHT = 21
ACTIVE_WIDTH = 8
ACTIVE_HEIGHT = 16
MULTICOLOR0 = 7
SPRITE_COLOR = 2
MULTICOLOR1 = 4

FRAME_LABELS = ("frame0", "frame1", "frame2", "frame3")
QUADRANT_LABELS = ("tl", "tr", "bl", "br")
COLOR_PRIORITY = (MULTICOLOR0, SPRITE_COLOR, MULTICOLOR1)

VICE_PALETTE = {
    0: (0x00, 0x00, 0x00),
    2: (0xBC, 0x52, 0x41),
    4: (0xB9, 0x56, 0xEB),
    7: (0xFF, 0xFF, 0x77),
}


def nearest_explosion_color(pixel: tuple[int, int, int, int]) -> int:
    if pixel == BLACK:
        return 0

    red, green, blue, _ = pixel
    best_color = 0
    best_distance = None
    for color_index, (pr, pg, pb) in VICE_PALETTE.items():
        distance = (red - pr) ** 2 + (green - pg) ** 2 + (blue - pb) ** 2
        if best_distance is None or distance < best_distance:
            best_distance = distance
            best_color = color_index
    return best_color


def palette_index_to_code(color_index: int) -> int:
    if color_index == 0:
        return 0
    if color_index == MULTICOLOR0:
        return 1
    if color_index == SPRITE_COLOR:
        return 2
    if color_index == MULTICOLOR1:
        return 3
    raise ValueError(f"Unsupported explosion color index {color_index}")


def collapse_pair(left: tuple[int, int, int, int], right: tuple[int, int, int, int]) -> int:
    left_color = nearest_explosion_color(left)
    right_color = nearest_explosion_color(right)

    if left_color == right_color:
        return palette_index_to_code(left_color)
    if left_color == 0:
        return palette_index_to_code(right_color)
    if right_color == 0:
        return palette_index_to_code(left_color)

    for preferred in COLOR_PRIORITY:
        if left_color == preferred or right_color == preferred:
            return palette_index_to_code(preferred)
    return palette_index_to_code(left_color)


def extract_frame(
    rows: list[list[tuple[int, int, int, int]]],
    frame_index: int,
) -> list[list[tuple[int, int, int, int]]]:
    x_start = frame_index * FRAME_STRIDE
    return [row[x_start : x_start + FRAME_SIZE] for row in rows[:FRAME_SIZE]]


def quadrant_pixels(
    frame_rows: list[list[tuple[int, int, int, int]]],
    quadrant_index: int,
) -> list[list[tuple[int, int, int, int]]]:
    x_start = 0 if quadrant_index % 2 == 0 else QUADRANT_SIZE
    y_start = 0 if quadrant_index < 2 else QUADRANT_SIZE
    return [
        row[x_start : x_start + QUADRANT_SIZE]
        for row in frame_rows[y_start : y_start + QUADRANT_SIZE]
    ]


def quadrant_to_color_rows(
    pixels: list[list[tuple[int, int, int, int]]],
) -> list[list[int]]:
    fitted = [[0 for _ in range(TARGET_WIDTH)] for _ in range(TARGET_HEIGHT)]
    for y in range(ACTIVE_HEIGHT):
        source_row = pixels[y]
        target_row = fitted[y]
        for pair_index in range(ACTIVE_WIDTH):
            x = pair_index * 2
            target_row[pair_index] = collapse_pair(source_row[x], source_row[x + 1])
    return fitted


def generate_sprite_rows(
    png_path: Path,
) -> list[tuple[str, str, list[int]]]:
    width, height, rows = decode_png_rgba(png_path)
    expected_width = FRAME_COUNT * FRAME_SIZE + (FRAME_COUNT - 1)
    if width != expected_width or height != FRAME_SIZE:
        raise ValueError(
            f"Expected {png_path} to be {expected_width}x{FRAME_SIZE}, got {width}x{height}"
        )

    sprite_rows: list[tuple[str, str, list[int]]] = []
    for frame_index, frame_label in enumerate(FRAME_LABELS):
        frame_rows = extract_frame(rows, frame_index)
        for quadrant_index, quadrant_label in enumerate(QUADRANT_LABELS):
            pixels = quadrant_pixels(frame_rows, quadrant_index)
            color_rows = quadrant_to_color_rows(pixels)
            packed = pack_multicolor_sprite_bytes(color_rows)
            title = f"Player Explosion {frame_index} {quadrant_label.upper()}"
            label = f"player_explosion_{frame_label}_{quadrant_label}"
            sprite_rows.append((title, label, packed))
    return sprite_rows


def generate_source(png_path: Path) -> str:
    blocks = [
        f"// Generated from {png_path.name} by scripts/generate_player_explosion_sprites.py.",
        "// Do not edit by hand.",
        "",
    ]

    base_address = 0x3680
    for sprite_index, (title, label, packed) in enumerate(generate_sprite_rows(png_path)):
        address = base_address + sprite_index * 0x40
        blocks.extend([f'* = ${address:04x} "{title}"', "", f"{label}:"])
        blocks.extend(format_byte_rows(packed))
        blocks.append("")

    return "\n".join(blocks).rstrip() + "\n"


def generate_binary(png_path: Path) -> bytes:
    payload = bytearray()
    for _, _, packed in generate_sprite_rows(png_path):
        payload.extend(packed)
    return bytes(payload)


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Generate a 4-frame 2x2 multicolor player explosion metasprite bank."
    )
    parser.add_argument(
        "--png",
        default="ArcadeGalaxianSprites explosions.png",
        help="Input explosion PNG",
    )
    parser.add_argument(
        "--out",
        default="src/generated_player_explosion.asm",
        help="Generated KickAssembler source file",
    )
    parser.add_argument(
        "--out-bin",
        default="src/generated_player_explosion.bin",
        help="Generated raw C64 sprite bank (64 bytes per sprite)",
    )
    args = parser.parse_args()

    png_path = Path(args.png)
    output_path = Path(args.out)
    output_path.write_text(generate_source(png_path), encoding="utf-8")
    print(f"Wrote {output_path}")

    output_bin_path = Path(args.out_bin)
    output_bin_path.write_bytes(generate_binary(png_path))
    print(f"Wrote {output_bin_path}")
    print("Exported 4 frames as 16 sprite layers")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
