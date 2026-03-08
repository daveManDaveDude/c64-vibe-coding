#!/usr/bin/env python3
import argparse
import json
from pathlib import Path

from generate_arcade_enemy_sprites import format_byte_rows


PLAYER_ASSET_LABEL = "arcade_b4_s0"
PLAYER_BASE_COLOR = 3
PLAYER_OVERLAY_COLOR = 15
PLAYER_RED_COLOR = 2


def decode_singlecolor_sprite_bytes(sprite_bytes: list[int]) -> list[list[int]]:
    rows: list[list[int]] = []
    for offset in range(0, 63, 3):
        row_bytes = sprite_bytes[offset : offset + 3]
        bits = "".join(f"{byte:08b}" for byte in row_bytes)
        rows.append([int(bit) for bit in bits])
    return rows


def pack_multicolor_sprite_bytes(code_rows: list[list[int]]) -> list[int]:
    packed: list[int] = []
    for row in code_rows:
        row_value = 0
        for code in row:
            row_value = (row_value << 2) | (code & 0x03)
        packed.extend(((row_value >> 16) & 0xFF, (row_value >> 8) & 0xFF, row_value & 0xFF))
    packed.append(0)
    return packed


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


def build_overlay_rows(red_layer: list[int], overlay_layer: list[int]) -> tuple[list[list[int]], int]:
    red_rows = decode_singlecolor_sprite_bytes(red_layer)
    overlay_rows_source = decode_singlecolor_sprite_bytes(overlay_layer)

    overlay_rows = [[0 for _ in range(12)] for _ in range(21)]
    conflict_count = 0
    for y in range(21):
        for cell_x in range(12):
            left = cell_x * 2
            red_present = red_rows[y][left] or red_rows[y][left + 1]
            overlay_present = overlay_rows_source[y][left] or overlay_rows_source[y][left + 1]

            if red_present and overlay_present:
                conflict_count += 1

            if red_present:
                overlay_rows[y][cell_x] = 3
            elif overlay_present:
                overlay_rows[y][cell_x] = 2
    return overlay_rows, conflict_count


def write_asm(path: Path, base_packed: list[int], overlay_packed: list[int], asset_label: str, conflict_count: int) -> None:
    lines = [
        f"// Generated from {asset_label} in generated_arcade_sprites.bin by scripts/generate_player_sprite.py.",
        "// Do not edit by hand.",
        f"// Red-over-white overlay cell conflicts resolved with red priority: {conflict_count}.",
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
    parser = argparse.ArgumentParser(
        description="Build the player base and color overlay from an arcade asset in the full sprite bank."
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
    parser.add_argument("--out-base-bin", default="src/generated_player_sprite.bin", help="Output base sprite file")
    parser.add_argument("--out-overlay-bin", default="src/generated_player_overlay.bin", help="Output overlay sprite file")
    args = parser.parse_args()

    asset, layer_bytes = load_player_asset(Path(args.metadata), Path(args.sprite_bank), args.asset_label)

    try:
        base_packed = layer_bytes[PLAYER_BASE_COLOR]
        overlay_layer = layer_bytes[PLAYER_OVERLAY_COLOR]
        red_layer = layer_bytes[PLAYER_RED_COLOR]
    except KeyError as exc:
        raise ValueError(
            f"{args.asset_label} must expose base={PLAYER_BASE_COLOR}, overlay={PLAYER_OVERLAY_COLOR}, red={PLAYER_RED_COLOR} layers"
        ) from exc

    overlay_rows, conflict_count = build_overlay_rows(red_layer, overlay_layer)
    overlay_packed = pack_multicolor_sprite_bytes(overlay_rows)

    out_asm = Path(args.out_asm)
    out_base_bin = Path(args.out_base_bin)
    out_overlay_bin = Path(args.out_overlay_bin)
    write_asm(out_asm, base_packed, overlay_packed, asset["label"], conflict_count)
    out_base_bin.write_bytes(bytes(base_packed))
    out_overlay_bin.write_bytes(bytes(overlay_packed))

    print(f"Wrote {out_asm}")
    print(f"Wrote {out_base_bin}")
    print(f"Wrote {out_overlay_bin}")
    print(f"Source asset: {asset['label']}")
    print(f"Overlay conflicts resolved with red priority: {conflict_count}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
