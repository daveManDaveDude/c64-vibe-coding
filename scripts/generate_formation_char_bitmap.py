#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path


SPRITE_BYTES = 64
SPRITE_ROW_BYTES = 3
SPRITE_VISIBLE_ROWS = 21
CHAR_ROWS = 8
CHAR_BYTES_PER_ROW = 4
SHIFT_PHASES = 8

# The formation uses the first two frames for each enemy type.
FORMATION_FRAME_SPRITE_INDICES = (0, 1, 3, 4, 6, 7)
# The second animation frame for each formation type carries the same tiny
# detached bottom-row pixel pair in the sprite art. It reads as corruption in
# the shared char renderer, so trim that row in the generated char pack only.
TRIM_BOTTOM_ROW_SPRITE_INDICES = {1, 4, 7}
SPRITE_TO_CHAR_PAIR = {
    "00": "00",
    "01": "01",
    "10": "11",
    "11": "10",
}


def load_sprites(path: Path) -> list[bytes]:
    raw = path.read_bytes()
    if len(raw) % SPRITE_BYTES != 0:
        raise ValueError(f"{path} size {len(raw)} is not a multiple of {SPRITE_BYTES}")
    return [raw[offset : offset + SPRITE_BYTES] for offset in range(0, len(raw), SPRITE_BYTES)]


def first_active_row(sprite: bytes) -> int:
    for row in range(SPRITE_VISIBLE_ROWS):
        start = row * SPRITE_ROW_BYTES
        if any(sprite[start : start + SPRITE_ROW_BYTES]):
            return row
    raise ValueError("sprite contains no visible rows")


def sprite_row_to_multicolor_char_bytes(row_bytes: bytes) -> list[int]:
    sprite_bits = "".join(f"{value:08b}" for value in row_bytes)
    char_pairs = []

    for pair_index in range(0, 24, 2):
        pair = sprite_bits[pair_index : pair_index + 2]
        char_pairs.append(SPRITE_TO_CHAR_PAIR[pair])

    # Keep the historical 32-bit row width used by the formation char bank.
    char_pairs.extend(("00",) * 4)
    row = "".join(char_pairs)
    return [int(row[offset : offset + 8], 2) for offset in range(0, 32, 8)]


def pack_char_block(rows: list[list[int]]) -> bytes:
    packed = bytearray()
    for char_index in range(CHAR_BYTES_PER_ROW):
        for row_index in range(CHAR_ROWS):
            packed.append(rows[row_index][char_index])
    return bytes(packed)


def shift_row_right(row_bytes: list[int], shift: int) -> list[int]:
    # Multicolor character pixels are double-width, so odd hardware-pixel shifts
    # collapse onto the previous even phase in the char-rendered pack.
    shift &= 0xFE
    value = int.from_bytes(bytes(row_bytes), "big")
    shifted = value >> shift
    return list(shifted.to_bytes(CHAR_BYTES_PER_ROW, "big"))


def build_frame_pages(sprites: list[bytes]) -> bytes:
    output = bytearray()

    for sprite_index in FORMATION_FRAME_SPRITE_INDICES:
        sprite = sprites[sprite_index]
        top_row = first_active_row(sprite)
        if top_row + CHAR_ROWS > SPRITE_VISIBLE_ROWS:
            raise ValueError(
                f"sprite {sprite_index} active band starting at row {top_row} exceeds {CHAR_ROWS} rows"
            )

        base_rows = []
        for row in range(top_row, top_row + CHAR_ROWS):
            start = row * SPRITE_ROW_BYTES
            base_rows.append(sprite_row_to_multicolor_char_bytes(sprite[start : start + SPRITE_ROW_BYTES]))

        if sprite_index in TRIM_BOTTOM_ROW_SPRITE_INDICES:
            # The source art keeps a tiny dangling tail pair on animation frame 1.
            # In the shared char cache that row reads like a detached corruption blob,
            # so keep the sprite art unchanged and trim it only for the char pack.
            base_rows[-1] = [0] * CHAR_BYTES_PER_ROW

        for shift in range(SHIFT_PHASES):
            shifted_rows = [shift_row_right(row_bytes, shift) for row_bytes in base_rows]
            output.extend(pack_char_block(shifted_rows))

    return bytes(output)


def main() -> None:
    repo_root = Path(__file__).resolve().parent.parent
    sprite_bin = repo_root / "src" / "generated_enemy_sprites.bin"
    output_bin = repo_root / "src" / "generated_formation_char_bitmap.bin"

    sprites = load_sprites(sprite_bin)
    data = build_frame_pages(sprites)
    expected_size = len(FORMATION_FRAME_SPRITE_INDICES) * SHIFT_PHASES * CHAR_ROWS * CHAR_BYTES_PER_ROW
    if len(data) != expected_size:
        raise ValueError(f"expected {expected_size} bytes, generated {len(data)} bytes")

    output_bin.write_bytes(data)
    print(f"Wrote {output_bin} ({len(data)} bytes)")


if __name__ == "__main__":
    main()
