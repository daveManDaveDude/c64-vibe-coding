#!/usr/bin/env python3
import argparse
from pathlib import Path

from preview_c64_sprites import (
    C64_COLORS,
    decode_singlecolor,
    load_source,
    parse_asm_sprites,
)

def render_composite(
    output_path: Path,
    red_bytes: list[int],
    white_bytes: list[int],
    cyan_bytes: list[int],
    scale: int,
) -> None:
    sprite_width = 24
    sprite_height = 21
    title_height = scale * 3
    padding = scale * 2
    total_width = sprite_width * scale + padding * 2
    total_height = sprite_height * scale + title_height + padding * 2

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
            f'font-family="Menlo, Monaco, monospace" font-size="{scale * 1.25}">player_sprite_composite</text>'
        ),
        (
            f'    <rect x="{padding}" y="{padding + title_height}" width="{sprite_width * scale}" '
            f'height="{sprite_height * scale}" fill="#050607" stroke="#222833"/>'
        ),
    ]

    for rows, color in (
        (decode_singlecolor(cyan_bytes), C64_COLORS[3]),
        (decode_singlecolor(red_bytes), C64_COLORS[2]),
        (decode_singlecolor(white_bytes), C64_COLORS[15]),
    ):
        for y, row in enumerate(rows):
            for x, bit in enumerate(row):
                if bit:
                    lines.append(
                        f'    <rect x="{padding + x * scale}" y="{padding + title_height + y * scale}" '
                        f'width="{scale}" height="{scale}" fill="{color}"/>'
                    )

    lines.extend(["  </g>", "</svg>"])
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description="Render the layered player sprite as a composite SVG.")
    parser.add_argument("source", nargs="?", default="src/generated_player_sprite.asm")
    parser.add_argument("--out", default="artifacts/player-sprite-preview.svg")
    parser.add_argument("--scale", type=int, default=12)
    args = parser.parse_args()

    sprites = dict(
        parse_asm_sprites(
            load_source(Path(args.source)),
            {"player_red_sprite_png", "player_white_sprite_png", "player_cyan_sprite_png"},
        )
    )
    render_composite(
        Path(args.out),
        sprites["player_red_sprite_png"],
        sprites["player_white_sprite_png"],
        sprites["player_cyan_sprite_png"],
        args.scale,
    )
    print(f"Wrote {args.out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
