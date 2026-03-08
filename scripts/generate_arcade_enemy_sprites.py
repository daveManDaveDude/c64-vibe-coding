#!/usr/bin/env python3
import argparse
import struct
import zlib
from pathlib import Path


PNG_SIGNATURE = b"\x89PNG\r\n\x1a\n"

ROW_LABELS = ("flagship", "escort", "grunt")
BLACK = (0, 0, 0, 255)
GRAY_SEPARATOR = (48, 48, 48, 255)
SOURCE_BLACK = (0, 0, 0, 255)
SOURCE_RED = (224, 0, 0, 255)
SOURCE_CYAN = (0, 133, 148, 255)
SOURCE_PURPLE = (133, 0, 217, 255)
SOURCE_BLUE = (0, 0, 217, 255)
SOURCE_LIGHT_BLUE = (0, 91, 217, 255)
SOURCE_YELLOW = (224, 224, 0, 255)

# C64 multicolor sprite slots:
# 00 transparent, 01 shared multicolor 0, 10 sprite-specific color, 11 shared multicolor 1.
ROW_COLOR_CODES = (
    {
        SOURCE_BLACK: 0,
        SOURCE_LIGHT_BLUE: 1,
        SOURCE_YELLOW: 2,
        SOURCE_RED: 3,
    },
    {
        SOURCE_BLACK: 0,
        SOURCE_BLUE: 1,
        SOURCE_PURPLE: 2,
        SOURCE_RED: 3,
    },
    {
        SOURCE_BLACK: 0,
        SOURCE_BLUE: 1,
        SOURCE_CYAN: 2,
        SOURCE_RED: 3,
    },
)


def paeth_predictor(a: int, b: int, c: int) -> int:
    prediction = a + b - c
    pa = abs(prediction - a)
    pb = abs(prediction - b)
    pc = abs(prediction - c)
    if pa <= pb and pa <= pc:
        return a
    if pb <= pc:
        return b
    return c


def decode_png_rgba(path: Path) -> tuple[int, int, list[list[tuple[int, int, int, int]]]]:
    payload = path.read_bytes()
    if not payload.startswith(PNG_SIGNATURE):
        raise ValueError(f"{path} is not a PNG file")

    position = len(PNG_SIGNATURE)
    width = height = 0
    bit_depth = color_type = compression = filter_method = interlace = None
    idat_chunks: list[bytes] = []

    while position < len(payload):
        chunk_length = struct.unpack(">I", payload[position : position + 4])[0]
        position += 4
        chunk_type = payload[position : position + 4]
        position += 4
        chunk_data = payload[position : position + chunk_length]
        position += chunk_length + 4

        if chunk_type == b"IHDR":
            width, height, bit_depth, color_type, compression, filter_method, interlace = struct.unpack(
                ">IIBBBBB", chunk_data
            )
        elif chunk_type == b"IDAT":
            idat_chunks.append(chunk_data)
        elif chunk_type == b"IEND":
            break

    if (bit_depth, color_type, compression, filter_method, interlace) != (8, 6, 0, 0, 0):
        raise ValueError(
            f"Unsupported PNG format in {path}: bit_depth={bit_depth}, color_type={color_type}, "
            f"compression={compression}, filter={filter_method}, interlace={interlace}"
        )

    raw = zlib.decompress(b"".join(idat_chunks))
    bytes_per_pixel = 4
    stride = width * bytes_per_pixel
    expected_size = height * (stride + 1)
    if len(raw) != expected_size:
        raise ValueError(f"Decoded PNG size mismatch for {path}: expected {expected_size}, got {len(raw)}")

    rows: list[list[tuple[int, int, int, int]]] = []
    previous = [0] * stride
    offset = 0
    for _ in range(height):
        filter_type = raw[offset]
        offset += 1
        filtered = list(raw[offset : offset + stride])
        offset += stride

        recon = [0] * stride
        for index in range(stride):
            left = recon[index - bytes_per_pixel] if index >= bytes_per_pixel else 0
            up = previous[index]
            up_left = previous[index - bytes_per_pixel] if index >= bytes_per_pixel else 0

            if filter_type == 0:
                value = filtered[index]
            elif filter_type == 1:
                value = (filtered[index] + left) & 0xFF
            elif filter_type == 2:
                value = (filtered[index] + up) & 0xFF
            elif filter_type == 3:
                value = (filtered[index] + ((left + up) // 2)) & 0xFF
            elif filter_type == 4:
                value = (filtered[index] + paeth_predictor(left, up, up_left)) & 0xFF
            else:
                raise ValueError(f"Unsupported PNG filter type {filter_type} in {path}")

            recon[index] = value

        row = []
        for index in range(0, stride, bytes_per_pixel):
            row.append(tuple(recon[index : index + bytes_per_pixel]))
        rows.append(row)
        previous = recon

    return width, height, rows


def split_ranges(length: int, separators: list[int]) -> list[range]:
    boundaries = [-1, *separators, length]
    ranges = []
    for start, end in zip(boundaries, boundaries[1:]):
        if end - start <= 1:
            continue
        ranges.append(range(start + 1, end))
    return ranges


def find_separators(rows: list[list[tuple[int, int, int, int]]]) -> tuple[list[int], list[int], tuple[int, int, int, int]]:
    height = len(rows)
    width = len(rows[0])
    counts: dict[tuple[int, int, int, int], int] = {}
    for row in rows:
        for pixel in row:
            counts[pixel] = counts.get(pixel, 0) + 1

    background = max(counts.items(), key=lambda item: item[1])[0]

    separator_rows = []
    for y in range(height):
        row = rows[y]
        if all(pixel == row[0] for pixel in row) and row[0] != background:
            separator_rows.append(y)

    separator_cols = []
    for x in range(width):
        column = [rows[y][x] for y in range(height)]
        if all(pixel == column[0] for pixel in column) and column[0] != background:
            separator_cols.append(x)

    if len(separator_rows) != 2 or len(separator_cols) != 2:
        raise ValueError(
            f"Expected a 3x3 grid in the PNG, found separator rows={separator_rows} cols={separator_cols}"
        )

    return separator_rows, separator_cols, background


def non_separator_ranges(separator_mask: list[bool]) -> list[range]:
    ranges: list[range] = []
    start = None
    for index, is_separator in enumerate(separator_mask):
        if not is_separator and start is None:
            start = index
        elif is_separator and start is not None:
            ranges.append(range(start, index))
            start = None
    if start is not None:
        ranges.append(range(start, len(separator_mask)))
    return ranges


def full_sheet_segments(
    rows: list[list[tuple[int, int, int, int]]],
    separator_color: tuple[int, int, int, int] = GRAY_SEPARATOR,
    background: tuple[int, int, int, int] = BLACK,
) -> list[tuple[int, int, range, range, list[list[tuple[int, int, int, int]]]]]:
    y_ranges = non_separator_ranges([all(pixel == separator_color for pixel in row) for row in rows])

    segments: list[tuple[int, int, range, range, list[list[tuple[int, int, int, int]]]]] = []
    width = len(rows[0])
    for band_index, y_range in enumerate(y_ranges):
        x_ranges = non_separator_ranges(
            [all(rows[y][x] == separator_color for y in y_range) for x in range(width)]
        )
        for segment_index, x_range in enumerate(x_ranges):
            pixels = cell_pixels(rows, x_range, y_range, background)
            if not any(
                pixel not in (background, separator_color)
                for row in pixels
                for pixel in row
            ):
                continue
            segments.append((band_index, segment_index, x_range, y_range, pixels))
    return segments


def is_full_arcade_sheet(
    width: int,
    height: int,
    rows: list[list[tuple[int, int, int, int]]],
) -> bool:
    return (
        width == 203
        and height == 86
        and all(pixel == GRAY_SEPARATOR for pixel in rows[0])
    )


def enemy_cells_from_full_sheet(
    rows: list[list[tuple[int, int, int, int]]],
) -> list[list[list[list[tuple[int, int, int, int]]]]]:
    grouped: dict[tuple[int, int], list[list[tuple[int, int, int, int]]]] = {}
    for band_index, segment_index, _, _, pixels in full_sheet_segments(rows):
        grouped[(band_index, segment_index)] = pixels

    enemy_cells: list[list[list[list[tuple[int, int, int, int]]]]] = []
    for band_index in range(3):
        row_cells = []
        for segment_index in range(3):
            key = (band_index, segment_index)
            if key not in grouped:
                raise ValueError(
                    f"ArcadeGalaxianSprites.png is missing expected enemy cell band={band_index} segment={segment_index}"
                )
            row_cells.append(grouped[key])
        enemy_cells.append(row_cells)
    return enemy_cells


def cell_pixels(
    rows: list[list[tuple[int, int, int, int]]],
    x_range: range,
    y_range: range,
    background: tuple[int, int, int, int],
) -> list[list[tuple[int, int, int, int]]]:
    bitmap: list[list[tuple[int, int, int, int]]] = []
    for y in y_range:
        row_pixels = []
        for x in x_range:
            pixel = rows[y][x]
            row_pixels.append(background if pixel == background else pixel)
        bitmap.append(row_pixels)
    return bitmap


def fit_color_rows_to_sprite_grid(
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

    content_width = max_x - min_x + 1
    if content_width > target_width:
        raise ValueError(
            f"Source sprite content width {content_width} exceeds C64 multicolor sprite width {target_width}"
        )

    source_x_start = min_x
    copy_width = min(target_width, source_width - source_x_start)

    for y in range(source_height):
        for x in range(copy_width):
            fitted[y][x] = color_rows[y][source_x_start + x]

    return fitted


def pixels_to_color_codes(
    pixels: list[list[tuple[int, int, int, int]]],
    color_codes: dict[tuple[int, int, int, int], int],
) -> list[list[int]]:
    rows: list[list[int]] = []
    for row in pixels:
        rows.append([color_codes.get(pixel, 0) for pixel in row])
    return rows


def pack_multicolor_sprite_bytes(color_rows: list[list[int]]) -> list[int]:
    packed: list[int] = []
    for row in color_rows:
        row_value = 0
        for code in row:
            row_value = (row_value << 2) | (code & 0b11)
        packed.extend(((row_value >> 16) & 0xFF, (row_value >> 8) & 0xFF, row_value & 0xFF))
    packed.append(0)
    return packed


def format_byte_rows(data: list[int]) -> list[str]:
    rows = []
    for offset in range(0, 63, 3):
        chunk = data[offset : offset + 3]
        rows.append("  .byte " + ",".join(f"%{value:08b}" for value in chunk))
    rows.append("  .byte $00")
    return rows


def sprite_block(address: int, title: str, label: str, data: list[int]) -> str:
    lines = [f'* = ${address:04x} "{title}"', "", f"{label}:"]
    lines.extend(format_byte_rows(data))
    return "\n".join(lines)


def generate_sprite_rows(png_path: Path) -> list[tuple[str, str, list[int]]]:
    width, height, rows = decode_png_rgba(png_path)
    if is_full_arcade_sheet(width, height, rows):
        enemy_pixels = enemy_cells_from_full_sheet(rows)
    else:
        separator_rows, separator_cols, background = find_separators(rows)

        x_ranges = split_ranges(len(rows[0]), separator_cols)
        y_ranges = split_ranges(len(rows), separator_rows)

        if len(x_ranges) != 3 or len(y_ranges) != 3:
            raise ValueError(f"Expected 3 cell ranges in each direction, got x={x_ranges}, y={y_ranges}")

        enemy_pixels = []
        for row_index in range(3):
            row_cells = []
            for frame_index in range(3):
                row_cells.append(cell_pixels(rows, x_ranges[frame_index], y_ranges[row_index], background))
            enemy_pixels.append(row_cells)

    sprite_rows: list[tuple[str, str, list[int]]] = []
    for row_index, row_label in enumerate(ROW_LABELS):
        for frame_index in range(3):
            pixels = enemy_pixels[row_index][frame_index]
            codes = pixels_to_color_codes(pixels, ROW_COLOR_CODES[row_index])
            fitted = fit_color_rows_to_sprite_grid(codes)
            packed = pack_multicolor_sprite_bytes(fitted)
            title = f"{row_label.capitalize()} Sprite {frame_index}"
            label = f"{row_label}_sprite_frame{frame_index}"
            sprite_rows.append((title, label, packed))

    return sprite_rows


def generate_source(png_path: Path) -> str:
    blocks = [
        f"// Generated from {png_path.name} by scripts/generate_arcade_enemy_sprites.py.",
        "// Do not edit by hand.",
        "",
    ]

    base_address = 0x2000
    for sprite_index, (title, label, packed) in enumerate(generate_sprite_rows(png_path)):
        address = base_address + sprite_index * 0x40
        blocks.append(sprite_block(address, title, label, packed))
        blocks.append("")

    return "\n".join(blocks).rstrip() + "\n"


def generate_binary(png_path: Path) -> bytes:
    data = bytearray()
    for _, _, packed in generate_sprite_rows(png_path):
        data.extend(packed)
    return bytes(data)


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Generate the 9 enemy C64 sprites from ArcadeGalaxianSprites.png or a compatible 3x3 sheet."
    )
    parser.add_argument(
        "--png",
        default="ArcadeGalaxianSprites.png",
        help="Input PNG sprite sheet",
    )
    parser.add_argument(
        "--out",
        default="src/generated_enemy_sprites.asm",
        help="Generated KickAssembler source file",
    )
    parser.add_argument(
        "--out-bin",
        default="src/generated_enemy_sprites.bin",
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
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
