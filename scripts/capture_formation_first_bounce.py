#!/usr/bin/env python3
import argparse
import hashlib
import json
import shutil
import struct
import time
import zlib
from pathlib import Path
from typing import Optional

from playtest_asm import Logger, PlaytestFailure, Playtester


PNG_SIGNATURE = b"\x89PNG\r\n\x1a\n"
DISPLAY_WIDTH = 384
DISPLAY_HEIGHT = 272
DISPLAY_SCALE = 2
SCREEN_ORIGIN_X = 24
SCREEN_ORIGIN_Y = 50
SCREEN_WIDTH = 320
SCREEN_HEIGHT = 200
FORMATION_BITMAP_PATH = Path(__file__).resolve().parent.parent / "src" / "generated_formation_char_bitmap.bin"
FORMATION_ANIMATION_SEQUENCES = (
    (0, 1, 0, 1),
    (0, 1, 0, 1),
    (2, 3, 2, 3),
    (2, 3, 2, 3),
    (4, 5, 4, 5),
    (4, 5, 4, 5),
)
C64_RGBA_PALETTE = (
    (0x00, 0x00, 0x00, 0xFF),
    (0xFF, 0xFF, 0xFF, 0xFF),
    (0x88, 0x00, 0x00, 0xFF),
    (0xAA, 0xFF, 0xEE, 0xFF),
    (0xCC, 0x44, 0xCC, 0xFF),
    (0x00, 0xCC, 0x55, 0xFF),
    (0x00, 0x00, 0xAA, 0xFF),
    (0xEE, 0xEE, 0x77, 0xFF),
    (0xDD, 0x88, 0x55, 0xFF),
    (0x66, 0x44, 0x00, 0xFF),
    (0xFF, 0x77, 0x77, 0xFF),
    (0x33, 0x33, 0x33, 0xFF),
    (0x77, 0x77, 0x77, 0xFF),
    (0xAA, 0xFF, 0x66, 0xFF),
    (0x00, 0x88, 0xFF, 0xFF),
    (0xBB, 0xBB, 0xBB, 0xFF),
)


def png_chunk(chunk_type: bytes, payload: bytes) -> bytes:
    return (
        struct.pack(">I", len(payload))
        + chunk_type
        + payload
        + struct.pack(">I", zlib.crc32(chunk_type + payload) & 0xFFFFFFFF)
    )


def write_rgba_png(path: Path, rows: list[list[tuple[int, int, int, int]]]) -> str:
    raw = bytearray()
    for row in rows:
        raw.append(0)
        for red, green, blue, alpha in row:
            raw.extend((red, green, blue, alpha))

    ihdr = struct.pack(">IIBBBBB", len(rows[0]), len(rows), 8, 6, 0, 0, 0)
    payload = bytearray(PNG_SIGNATURE)
    payload.extend(png_chunk(b"IHDR", ihdr))
    payload.extend(png_chunk(b"IDAT", zlib.compress(bytes(raw))))
    payload.extend(png_chunk(b"IEND", b""))

    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(payload)
    return hashlib.sha256(payload).hexdigest()


def scaled_rows(rows: list[list[tuple[int, int, int, int]]], factor: int) -> list[list[tuple[int, int, int, int]]]:
    if factor <= 1:
        return rows
    scaled = []
    for row in rows:
        scaled_row = []
        for pixel in row:
            scaled_row.extend([pixel] * factor)
        for _ in range(factor):
            scaled.append(list(scaled_row))
    return scaled


def c64_rgba(color_index: int) -> tuple[int, int, int, int]:
    return C64_RGBA_PALETTE[color_index & 0x0F]


def draw_pixel(rows: list[list[tuple[int, int, int, int]]], x: int, y: int, color: tuple[int, int, int, int]) -> None:
    if 0 <= x < DISPLAY_WIDTH and 0 <= y < DISPLAY_HEIGHT:
        rows[y][x] = color


def draw_formation_slot(
    rows: list[list[tuple[int, int, int, int]]],
    sample: dict,
    symbols: dict,
    formation_bitmap_data: bytes,
    slot_index: int,
) -> None:
    if not sample.get(f"formation_{slot_index}_alive", False):
        return
    if sample.get("dive_active") and sample.get("dive_slot") == slot_index:
        return

    top_row = symbols["FORMATION_CHAR_BAND_TOP_ROW"]
    mid_row = symbols["FORMATION_CHAR_BAND_MID_ROW"]
    row = (top_row, top_row, mid_row, mid_row, symbols["FORMATION_CHAR_BAND_BOTTOM_ROW"], symbols["FORMATION_CHAR_BAND_BOTTOM_ROW"])[slot_index]
    slot_color = (
        symbols["FLAGSHIP_COLOR"],
        symbols["FLAGSHIP_COLOR"],
        symbols["ESCORT_COLOR"],
        symbols["ESCORT_COLOR"],
        symbols["GRUNT_COLOR"],
        symbols["GRUNT_COLOR"],
    )[slot_index]
    playfield_left = symbols["PLAYFIELD_LEFT_X_LO"] + (symbols["PLAYFIELD_LEFT_X_HI"] << 8)
    slot_x = sample[f"formation_{slot_index}_x"]
    relative_x = slot_x - playfield_left
    char_col = relative_x >> 3
    shift_phase = relative_x & 0x07
    animation_shift = symbols["FORMATION_ANIMATION_SHIFT"]
    anim_index = (sample["formation_frame_value"] >> animation_shift) & 0x03
    formation_char_value = FORMATION_ANIMATION_SEQUENCES[slot_index][anim_index]
    frame_offset = (formation_char_value << 8) + (shift_phase << 5)
    glyph_bytes = formation_bitmap_data[frame_offset : frame_offset + 32]

    for glyph_index in range(4):
        if char_col + glyph_index >= symbols["FORMATION_CHAR_BAND_WIDTH"]:
            break
        glyph = glyph_bytes[glyph_index * 8 : (glyph_index + 1) * 8]
        pixel_x = SCREEN_ORIGIN_X + ((char_col + glyph_index) * 8)
        pixel_y = SCREEN_ORIGIN_Y + (row * 8)
        for glyph_y in range(8):
            bits = glyph[glyph_y]
            for pair_index in range(4):
                code = (bits >> (6 - (pair_index * 2))) & 0b11
                if code == 0:
                    continue
                if code == 1:
                    pixel_color = c64_rgba(symbols["FORMATION_MULTI0_COLOR"])
                elif code == 2:
                    pixel_color = c64_rgba(symbols["FORMATION_MULTI1_COLOR"])
                else:
                    pixel_color = c64_rgba(slot_color)
                pixel_pair_x = pixel_x + (pair_index * 2)
                draw_pixel(rows, pixel_pair_x, pixel_y + glyph_y, pixel_color)
                draw_pixel(rows, pixel_pair_x + 1, pixel_y + glyph_y, pixel_color)


def render_sample_frame(sample: dict, symbols: dict, formation_bitmap_data: bytes, output_path: Path) -> str:
    border_color = c64_rgba(symbols["BORDER_BASE_COLOR"])
    background_color = c64_rgba(0)
    rows = [[border_color for _ in range(DISPLAY_WIDTH)] for _ in range(DISPLAY_HEIGHT)]
    for y in range(SCREEN_ORIGIN_Y, SCREEN_ORIGIN_Y + SCREEN_HEIGHT):
        for x in range(SCREEN_ORIGIN_X, SCREEN_ORIGIN_X + SCREEN_WIDTH):
            rows[y][x] = background_color

    for slot_index in range(6):
        draw_formation_slot(rows, sample, symbols, formation_bitmap_data, slot_index)

    return write_rgba_png(output_path, scaled_rows(rows, DISPLAY_SCALE))


def render_samples_to_frames(samples: list[dict], frames_dir: Path, symbols: dict) -> None:
    formation_bitmap_data = FORMATION_BITMAP_PATH.read_bytes()
    for sample in samples:
        output_path = frames_dir / f"{sample['index']:03d}-{sample['stage']}.png"
        sample["screenshot"] = str(output_path)
        sample["screenshot_sha256"] = render_sample_frame(sample, symbols, formation_bitmap_data, output_path)


def parse_args():
    parser = argparse.ArgumentParser(
        description="Capture every frame until the first formation bounce, then continue for a few more frames."
    )
    parser.add_argument("--prg", type=Path, default=Path("build/hello-asm.prg"))
    parser.add_argument("--log", type=Path, default=Path("artifacts/formation-first-bounce.log"))
    parser.add_argument("--json", type=Path, default=Path("artifacts/formation-first-bounce.json"))
    parser.add_argument("--vice-log", type=Path, default=Path("artifacts/formation-first-bounce-vice.log"))
    parser.add_argument("--frames-dir", type=Path, default=Path("artifacts/formation-first-bounce-frames"))
    parser.add_argument("--keymap", type=Path, default=Path("artifacts/formation-first-bounce-keymap.vkm"))
    parser.add_argument("--exit-screenshot", type=Path, default=Path("artifacts/formation-first-bounce-exit.png"))
    parser.add_argument("--window-x", type=int, default=80)
    parser.add_argument("--window-y", type=int, default=80)
    parser.add_argument("--window-width", type=int, default=720)
    parser.add_argument("--window-height", type=int, default=638)
    parser.add_argument("--process-name", default="x64sc")
    parser.add_argument("--frames-after-bounce", type=int, default=5)
    parser.add_argument("--frame-poll-interval", type=float, default=0.0005)
    parser.add_argument("--frame-timeout", type=float, default=2.0)
    parser.add_argument("--screenshot-settle-seconds", type=float, default=0.01)
    parser.add_argument("--capture-host-screenshots", action="store_true", default=False)
    return parser.parse_args()


def reset_output_dir(path: Path) -> None:
    if path.exists():
        shutil.rmtree(path)
    path.mkdir(parents=True, exist_ok=True)


def read_symbol_u8(playtester: Playtester, symbol: str) -> int:
    return playtester.monitor.mem_get(playtester.symbols[symbol], 1)[0]


def read_formation_debug(playtester: Playtester) -> dict:
    formation_frame = read_symbol_u8(playtester, "formation_frame")
    frame_capture_counter = read_symbol_u8(playtester, "frame_capture_counter")
    formation_dir = read_symbol_u8(playtester, "formation_dir")
    return {
        "frame_capture_counter": frame_capture_counter,
        "formation_frame_value": formation_frame,
        "formation_dir_raw": formation_dir,
        "formation_dir_name": "left" if formation_dir & 0x80 else "right",
    }


def step_to_next_frame(playtester: Playtester, previous_frame_value: int, poll_interval: float, timeout: float) -> int:
    deadline = time.time() + timeout
    while time.time() < deadline:
        playtester.resume_for(poll_interval)
        current_frame_value = read_symbol_u8(playtester, "frame_capture_counter")
        if current_frame_value != previous_frame_value:
            return current_frame_value
    raise PlaytestFailure(
        f"Timed out waiting for the next frame: previous_frame_value={previous_frame_value}"
    )


def capture_enriched_sample(playtester: Playtester, stage: str, previous_sample: Optional[dict]) -> dict:
    sample = playtester.capture_sample(stage, include_joystick=False)
    sample.update(read_formation_debug(playtester))
    sample["leftmost_x"] = playtester.leftmost_formation_x(sample)
    if previous_sample is None or sample["leftmost_x"] is None or previous_sample["leftmost_x"] is None:
        sample["leftmost_delta"] = 0
    else:
        sample["leftmost_delta"] = sample["leftmost_x"] - previous_sample["leftmost_x"]
    if previous_sample is None:
        sample["frame_advance"] = 0
        sample["dir_changed"] = False
    else:
        sample["frame_advance"] = (
            sample["frame_capture_counter"] - previous_sample["frame_capture_counter"]
        ) & 0xFF
        sample["dir_changed"] = sample["formation_dir_raw"] != previous_sample["formation_dir_raw"]
    return sample


def main() -> int:
    args = parse_args()
    args.log.parent.mkdir(parents=True, exist_ok=True)
    args.json.parent.mkdir(parents=True, exist_ok=True)
    args.vice_log.parent.mkdir(parents=True, exist_ok=True)
    args.exit_screenshot.parent.mkdir(parents=True, exist_ok=True)
    reset_output_dir(args.frames_dir)

    logger = Logger(args.log)
    playtester = Playtester(args, logger)
    result = {
        "success": False,
        "artifacts": {
            "log": str(args.log),
            "json": str(args.json),
            "vice_log": str(args.vice_log),
            "frames_dir": str(args.frames_dir),
            "keymap": str(args.keymap),
            "exit_screenshot": str(args.exit_screenshot),
        },
        "frames_after_bounce": args.frames_after_bounce,
        "samples": [],
    }

    try:
        playtester.launch_vice()
        ready = playtester.wait_for_game_ready()
        result["ready_state"] = ready

        if ready.get("formation_renderer_mode_name") != "char":
            raise PlaytestFailure(f"Expected char renderer, got {ready.get('formation_renderer_mode_name')}")

        logger.log("Capturing every frame until the first bounce, then five more frames")
        previous_sample = None
        sample = capture_enriched_sample(playtester, "frame-0000", previous_sample)
        result["samples"].append(sample)
        previous_sample = sample

        bounce_sample_index = None
        post_bounce_frames = 0

        while True:
            next_frame_value = step_to_next_frame(
                playtester,
                previous_sample["frame_capture_counter"],
                args.frame_poll_interval,
                args.frame_timeout,
            )
            stage = f"frame-{len(result['samples']):04d}"
            sample = capture_enriched_sample(playtester, stage, previous_sample)
            if sample["frame_capture_counter"] != next_frame_value:
                sample["captured_frame_mismatch"] = {
                    "expected": next_frame_value,
                    "captured": sample["frame_capture_counter"],
                }
            result["samples"].append(sample)

            if len(result["samples"]) % 50 == 0:
                logger.log(
                    f"Captured {len(result['samples'])} frames; leftmost_x={sample['leftmost_x']} dir={sample['formation_dir_name']}"
                )

            if bounce_sample_index is None:
                if previous_sample["formation_dir_name"] == "right" and sample["formation_dir_name"] == "left":
                    sample["bounce_event"] = "first_bounce"
                    bounce_sample_index = len(result["samples"]) - 1
                    result["bounce_sample_index"] = bounce_sample_index
                    result["bounce_sample"] = sample
                    logger.log(f"First bounce captured at sample {bounce_sample_index}")
            else:
                post_bounce_frames += 1
                if post_bounce_frames >= args.frames_after_bounce:
                    break

            previous_sample = sample

        result["captured_frame_count"] = len(result["samples"])
        render_samples_to_frames(result["samples"], args.frames_dir, playtester.symbols)
        result["success"] = True
    except Exception as exc:
        result["failure"] = str(exc)
    finally:
        try:
            playtester.shutdown()
        except Exception:
            pass
        logger.close()
        args.json.write_text(json.dumps(result, indent=2), encoding="utf-8")

    return 0 if result["success"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
