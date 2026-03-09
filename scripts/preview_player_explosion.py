#!/usr/bin/env python3
import argparse
from pathlib import Path

from preview_c64_sprites import C64_COLORS, decode_multicolor, load_binary_sprite_chunks


FRAME_COUNT = 4
SPRITES_PER_FRAME = 4
SPRITE_WIDTH = 24
SPRITE_HEIGHT = 21
FRAME_WIDTH = 40
FRAME_HEIGHT = 37
MULTICOLOR0 = 7
SPRITE_COLOR = 2
MULTICOLOR1 = 4


def render_frame(
    lines: list[str],
    sprite_chunks: list[list[int]],
    origin_x: int,
    origin_y: int,
    scale: int,
) -> None:
    offsets = ((0, 0), (16, 0), (0, 16), (16, 16))
    palette = {
        1: C64_COLORS[MULTICOLOR0],
        2: C64_COLORS[SPRITE_COLOR],
        3: C64_COLORS[MULTICOLOR1],
    }
    for sprite_bytes, (offset_x, offset_y) in zip(sprite_chunks, offsets):
        decoded = decode_multicolor(sprite_bytes)
        for y, row in enumerate(decoded):
            for x, code in enumerate(row):
                if code == 0:
                    continue
                lines.append(
                    f'    <rect x="{origin_x + (offset_x + x * 2) * scale}" '
                    f'y="{origin_y + (offset_y + y) * scale}" width="{scale * 2}" '
                    f'height="{scale}" fill="{palette[code]}"/>'
                )


def render_preview(output_path: Path, sprite_chunks: list[list[int]], scale: int) -> None:
    frame_gap = scale * 3
    padding = scale * 2
    title_height = scale * 3
    total_width = FRAME_COUNT * FRAME_WIDTH * scale + (FRAME_COUNT - 1) * frame_gap + padding * 2
    total_height = FRAME_HEIGHT * scale + title_height + padding * 2

    lines = [
        '<?xml version="1.0" encoding="UTF-8"?>',
        (
            f'<svg xmlns="http://www.w3.org/2000/svg" width="{total_width}" '
            f'height="{total_height}" viewBox="0 0 {total_width} {total_height}">'
        ),
        '  <rect width="100%" height="100%" fill="#0f1115"/>',
        '  <g transform="translate(0,0)">',
        (
            f'    <rect x="0" y="0" width="{total_width}" height="{total_height}" '
            'rx="8" fill="#171b22" stroke="#2b3340"/>'
        ),
        (
            f'    <text x="{padding}" y="{padding + scale}" fill="#d8dee9" '
            f'font-family="Menlo, Monaco, monospace" font-size="{scale * 1.25}">player_explosion_composite</text>'
        ),
    ]

    for frame_index in range(FRAME_COUNT):
        frame_x = padding + frame_index * (FRAME_WIDTH * scale + frame_gap)
        frame_y = padding + title_height
        lines.append(
            f'    <rect x="{frame_x}" y="{frame_y}" width="{FRAME_WIDTH * scale}" '
            f'height="{FRAME_HEIGHT * scale}" fill="#050607" stroke="#222833"/>'
        )
        lines.append(
            f'    <text x="{frame_x}" y="{frame_y - scale}" fill="#d8dee9" '
            f'font-family="Menlo, Monaco, monospace" font-size="{scale}">frame {frame_index}</text>'
        )
        start = frame_index * SPRITES_PER_FRAME
        render_frame(lines, sprite_chunks[start : start + SPRITES_PER_FRAME], frame_x, frame_y, scale)

    lines.extend(["  </g>", "</svg>"])
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description="Render the 4-frame player explosion metasprite as an SVG.")
    parser.add_argument("source", nargs="?", default="src/generated_player_explosion.bin")
    parser.add_argument("--out", default="artifacts/player-explosion-preview.svg")
    parser.add_argument("--scale", type=int, default=8)
    args = parser.parse_args()

    sprite_chunks = load_binary_sprite_chunks(Path(args.source))
    expected_sprites = FRAME_COUNT * SPRITES_PER_FRAME
    if len(sprite_chunks) != expected_sprites:
        raise SystemExit(
            f"{args.source} contains {len(sprite_chunks)} sprites; expected {expected_sprites}"
        )

    render_preview(Path(args.out), sprite_chunks, args.scale)
    print(f"Wrote {args.out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
