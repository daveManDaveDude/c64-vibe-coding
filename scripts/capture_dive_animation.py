#!/usr/bin/env python3
import argparse
import json
import shutil
import socket
import subprocess
import sys
import time
from pathlib import Path

from playtest_asm import BinaryMonitor, PlaytestFailure, load_symbols


DEFAULT_MONITOR_ADDRESS = ("127.0.0.1", 6502)
SPRITE0_X = 0xD000
SPRITE0_Y = 0xD001
SPRITE1_Y = 0xD003
SPRITE_ENABLE = 0xD015
INITIAL_EXPECTED_SPRITES = 0xFB


def connect_monitor() -> BinaryMonitor:
    deadline = time.time() + 15.0
    last_error = None
    while time.time() < deadline:
        try:
            sock = socket.create_connection(DEFAULT_MONITOR_ADDRESS, timeout=1.0)
            sock.settimeout(2.0)
            monitor = BinaryMonitor(sock)
            monitor.vice_info()
            return monitor
        except OSError as exc:
            last_error = exc
            time.sleep(0.1)
    raise PlaytestFailure(f"Could not connect to VICE binary monitor: {last_error}")


def read_u8(monitor: BinaryMonitor, address: int) -> int:
    return monitor.mem_get(address, 1)[0]


def combine_x(low: int, high: int) -> int:
    return low | (high << 8)


def wait_for_game_ready(monitor: BinaryMonitor, timeout_seconds: float) -> None:
    deadline = time.time() + timeout_seconds

    while time.time() < deadline:
        monitor.exit_monitor()
        time.sleep(0.05)

        vic_data = monitor.mem_get(SPRITE0_X, (SPRITE_ENABLE - SPRITE0_X) + 1)
        sprite_enable = vic_data[SPRITE_ENABLE - SPRITE0_X]
        formation_y = vic_data[SPRITE0_Y - SPRITE0_X]
        player_y = vic_data[SPRITE1_Y - SPRITE0_X]

        if (
            sprite_enable & INITIAL_EXPECTED_SPRITES == INITIAL_EXPECTED_SPRITES
            and player_y > formation_y
            and player_y >= 180
            and formation_y <= 100
        ):
            return

    raise PlaytestFailure("Timed out waiting for the game shell to initialize")


def launch_vice(args) -> subprocess.Popen:
    command = [
        shutil.which("x64sc") or "x64sc",
        "-default",
        "+confirmonexit",
        "+saveres",
        "-pal",
        "-power50",
        "-autostart-warp",
        "-binarymonitor",
        "-binarymonitoraddress",
        "ip4://127.0.0.1:6502",
        "-autostartprgmode",
        "1",
        "-exitscreenshot",
        str(args.exit_screenshot),
        "-logfile",
        str(args.vice_log),
        str(args.prg),
    ]
    return subprocess.Popen(command, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


def capture_state(monitor: BinaryMonitor, symbols: dict[str, int], sample_index: int) -> dict:
    dive_x = combine_x(read_u8(monitor, symbols["dive_x_lo"]), read_u8(monitor, symbols["dive_x_hi"]))
    player_x = combine_x(
        read_u8(monitor, symbols["player_x_lo"]),
        read_u8(monitor, symbols["player_x_hi"]),
    )
    return {
        "sample_index": sample_index,
        "timestamp": time.time(),
        "dive_active": read_u8(monitor, symbols["dive_active"]) != 0,
        "dive_slot": read_u8(monitor, symbols["dive_slot"]),
        "dive_phase": read_u8(monitor, symbols["dive_phase"]),
        "dive_x": dive_x,
        "dive_y": read_u8(monitor, symbols["dive_y"]),
        "dive_anim_frame": read_u8(monitor, symbols["dive_anim_frame"]),
        "dive_anim_tick": read_u8(monitor, symbols["dive_anim_tick"]),
        "dive_sprite_pointer": read_u8(monitor, symbols["dive_sprite_pointer"]),
        "player_x": player_x,
        "player_dx": dive_x - player_x,
    }


def enrich_trace(trace: list[dict]) -> list[dict]:
    enriched = []
    previous = None
    for sample in trace:
        item = dict(sample)
        if previous is None:
            item["dx"] = 0
            item["frame_delta"] = 0
        else:
            item["dx"] = sample["dive_x"] - previous["dive_x"]
            item["frame_delta"] = sample["dive_anim_frame"] - previous["dive_anim_frame"]
        enriched.append(item)
        previous = sample
    return enriched


def trim_trace(trace: list[dict], length: int = 24) -> list[dict]:
    if len(trace) <= length:
        return enrich_trace(trace)
    return enrich_trace(trace[-length:])


def wait_for_moving_capture(
    monitor: BinaryMonitor, symbols: dict[str, int], timeout_seconds: float
) -> dict:
    deadline = time.time() + timeout_seconds
    trace: list[dict] = []
    previous = None
    sample_index = 0

    while time.time() < deadline:
        monitor.exit_monitor()
        time.sleep(0.02)

        current = capture_state(monitor, symbols, sample_index)
        sample_index += 1
        trace.append(current)

        if previous and current["dive_active"] and previous["dive_active"]:
            dx = current["dive_x"] - previous["dive_x"]
            frame_delta = current["dive_anim_frame"] - previous["dive_anim_frame"]
            if dx != 0 and frame_delta > 0 and current["dive_anim_frame"] >= 6:
                return {
                    "event": "moving_animation_advance",
                    "sample": current,
                    "previous": previous,
                    "trace": trim_trace(trace),
                }

        previous = current

    raise PlaytestFailure("Timed out waiting for a moving dive animation frame advance")


def wait_for_unwind_capture(
    monitor: BinaryMonitor, symbols: dict[str, int], timeout_seconds: float
) -> dict:
    deadline = time.time() + timeout_seconds
    trace: list[dict] = []
    previous = None
    sample_index = 0
    moving_seen = False
    unwind_started = False
    unwind_start_frame = 0

    while time.time() < deadline:
        monitor.exit_monitor()
        time.sleep(0.02)

        current = capture_state(monitor, symbols, sample_index)
        sample_index += 1
        trace.append(current)

        if previous and current["dive_active"] and previous["dive_active"]:
            dx = current["dive_x"] - previous["dive_x"]
            frame_delta = current["dive_anim_frame"] - previous["dive_anim_frame"]

            if dx != 0 and current["dive_anim_frame"] >= 3:
                moving_seen = True

            if moving_seen and dx == 0 and frame_delta < 0:
                if not unwind_started:
                    unwind_started = True
                    unwind_start_frame = previous["dive_anim_frame"]

                if current["dive_anim_frame"] == 0:
                    return {
                        "event": "stopped_animation_unwind",
                        "sample": current,
                        "previous": previous,
                        "unwind_start_frame": unwind_start_frame,
                        "trace": trim_trace(trace, length=40),
                    }

        previous = current

    raise PlaytestFailure("Timed out waiting for a stopped dive animation unwind")


def parse_args():
    parser = argparse.ArgumentParser(description="Capture dive animation motion and unwind states.")
    parser.add_argument("--prg", type=Path, required=True)
    parser.add_argument("--sym", type=Path, required=True)
    parser.add_argument("--json", type=Path, required=True)
    parser.add_argument("--vice-log", type=Path, required=True)
    parser.add_argument("--exit-screenshot", type=Path, required=True)
    parser.add_argument("--mode", choices=["moving", "unwind"], required=True)
    parser.add_argument("--timeout", type=float, default=30.0)
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    args.json.parent.mkdir(parents=True, exist_ok=True)
    args.vice_log.parent.mkdir(parents=True, exist_ok=True)
    args.exit_screenshot.parent.mkdir(parents=True, exist_ok=True)

    symbols = load_symbols(args.sym)
    vice_process = None
    monitor = None
    result = {
        "success": False,
        "mode": args.mode,
        "artifacts": {
            "prg": str(args.prg),
            "sym": str(args.sym),
            "json": str(args.json),
            "vice_log": str(args.vice_log),
            "exit_screenshot": str(args.exit_screenshot),
        },
    }

    try:
        vice_process = launch_vice(args)
        monitor = connect_monitor()
        wait_for_game_ready(monitor, timeout_seconds=5.0)

        if args.mode == "moving":
            result["capture"] = wait_for_moving_capture(monitor, symbols, args.timeout)
        else:
            result["capture"] = wait_for_unwind_capture(monitor, symbols, args.timeout)

        monitor.exit_monitor()
        time.sleep(0.15)
        result["success"] = True
    except Exception as exc:
        result["failure"] = str(exc)
    finally:
        if monitor is not None:
            try:
                monitor.quit_vice()
            except Exception:
                pass
            monitor.close()
        if vice_process is not None:
            try:
                vice_process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                vice_process.terminate()
                try:
                    vice_process.wait(timeout=5)
                except subprocess.TimeoutExpired:
                    vice_process.kill()
                    vice_process.wait(timeout=5)

        result["artifacts"]["exit_screenshot_exists"] = args.exit_screenshot.exists()
        args.json.write_text(json.dumps(result, indent=2), encoding="utf-8")

    return 0 if result["success"] else 1


if __name__ == "__main__":
    sys.exit(main())
