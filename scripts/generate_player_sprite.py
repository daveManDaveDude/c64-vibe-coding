#!/usr/bin/env python3
import argparse
import json
from pathlib import Path

from generate_arcade_enemy_sprites import format_byte_rows


PLAYER_ASSET_LABEL = "arcade_b4_s0"
PLAYER_RED_COLOR = 2
PLAYER_WHITE_COLOR = 15
PLAYER_CYAN_COLOR = 3


def load_player_asset(metadata_path: Path, sprite_bank_path: Path, asset_label: str) -> tuple[dict, dict[int, list[int]]]:
    metadata = json.loads(metadata_path.read_text(encoding="utf-8"))
    asset = next((item for item in metadata["assets"] if item["label"] == asset_label), None)
    if asset is None:
        raise ValueError(f"Missing player asset {asset_label!r} in {metadata_path}")

    sprite_bank = sprite_bank_path.read_bytes()
    layers: dict[int, list[int]] = {}
    for layer in asset["layers"]:
        sprite_index = layer["sprite_index"]
        start = sprite_index * 64
        end = start + 64
        chunk = list(sprite_bank[start:end])
        if len(chunk) != 64:
            raise ValueError(
                f"Sprite bank {sprite_bank_path} is truncated for {layer['label']} at index {sprite_index}"
            )
        layers[layer["sprite_color"]] = chunk
    return asset, layers


def write_asm(path: Path, white_packed: list[int], red_packed: list[int], cyan_packed: list[int], asset_label: str) -> None:
    lines = [
        f"// Generated from {asset_label} in generated_arcade_sprites.bin by scripts/generate_player_sprite.py.",
        "// Do not edit by hand.",
        "",
        '* = $31c0 "Player White Sprite"',
        "",
        "player_white_sprite_png:",
    ]
    lines.extend(format_byte_rows(white_packed))
    lines.extend(
        [
            "",
            '* = $3200 "Player Red Sprite"',
            "",
            "player_red_sprite_png:",
        ]
    )
    lines.extend(format_byte_rows(red_packed))
    lines.extend(
        [
            "",
            '* = $3240 "Player Cyan Sprite"',
            "",
            "player_cyan_sprite_png:",
        ]
    )
    lines.extend(format_byte_rows(cyan_packed))
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Extract the exact player sprite layers from arcade_b4_s0 in the full sprite bank."
    )
    parser.add_argument("--asset-label", default=PLAYER_ASSET_LABEL, help="Arcade asset label to use for the player")
    parser.add_argument(
        "--sprite-bank",
        default="src/generated_arcade_sprites.bin",
        help="Raw sprite bank generated from ArcadeGalaxianSprites.png",
    )
    parser.add_argument(
        "--metadata",
        default="src/generated_arcade_sprites.json",
        help="Sprite metadata generated from ArcadeGalaxianSprites.png",
    )
    parser.add_argument("--out-asm", default="src/generated_player_sprite.asm", help="Output ASM file")
    parser.add_argument("--out-red-bin", default="src/generated_player_sprite.bin", help="Output red sprite file")
    parser.add_argument("--out-white-bin", default="src/generated_player_overlay.bin", help="Output white sprite file")
    parser.add_argument("--out-cyan-bin", default="src/generated_player_extra.bin", help="Output cyan sprite file")
    args = parser.parse_args()

    asset, layer_bytes = load_player_asset(Path(args.metadata), Path(args.sprite_bank), args.asset_label)
    try:
        red_packed = layer_bytes[PLAYER_RED_COLOR]
        white_packed = layer_bytes[PLAYER_WHITE_COLOR]
        cyan_packed = layer_bytes[PLAYER_CYAN_COLOR]
    except KeyError as exc:
        raise ValueError(
            f"{args.asset_label} must expose red={PLAYER_RED_COLOR}, white={PLAYER_WHITE_COLOR}, cyan={PLAYER_CYAN_COLOR} layers"
        ) from exc

    out_asm = Path(args.out_asm)
    out_red_bin = Path(args.out_red_bin)
    out_white_bin = Path(args.out_white_bin)
    out_cyan_bin = Path(args.out_cyan_bin)
    write_asm(out_asm, white_packed, red_packed, cyan_packed, asset["label"])
    out_red_bin.write_bytes(bytes(red_packed))
    out_white_bin.write_bytes(bytes(white_packed))
    out_cyan_bin.write_bytes(bytes(cyan_packed))

    print(f"Wrote {out_asm}")
    print(f"Wrote {out_red_bin}")
    print(f"Wrote {out_white_bin}")
    print(f"Wrote {out_cyan_bin}")
    print(f"Source asset: {asset['label']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
