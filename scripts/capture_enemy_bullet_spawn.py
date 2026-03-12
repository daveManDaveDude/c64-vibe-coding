#!/usr/bin/env python3
import argparse
import json
import shutil
import socket
import subprocess
import sys
import time
from pathlib import Path

from playtest_asm import BinaryMonitor, PlaytestFailure


DEFAULT_MONITOR_ADDRESS = ("127.0.0.1", 6502)
ENEMY_BULLET_LIMIT = 2
PLAYFIELD_LEFT_X = 24
PLAYFIELD_TOP_Y = 50
SPRITE0_X = 0xD000
SPRITE0_Y = 0xD001
SPRITE1_Y = 0xD003
SPRITE_ENABLE = 0xD015
FORMATION_SPRITE_MASKS = (0x01, 0x08, 0x10, 0x20, 0x40, 0x80)


def parse_symbols(path: Path) -> dict[str, int]:
    symbols: dict[str, int] = {}
    for raw_line in path.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line.startswith(".label "):
            continue
        name, value = line[len(".label ") :].split("=", 1)
        name = name.strip()
        value = value.strip()
        if value.startswith("$"):
            symbols[name] = int(value[1:], 16)
        else:
            symbols[name] = int(value, 10)
    return symbols


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


def read_u8_array(monitor: BinaryMonitor, address: int, size: int) -> list[int]:
    return list(monitor.mem_get(address, size))


def combine_x(low: int, high: int) -> int:
    return low | (high << 8)


def logical_alive_count(monitor: BinaryMonitor, symbols: dict[str, int], sprite_enable: int) -> int:
    formation_slot_count = symbols.get("FORMATION_SLOT_COUNT", len(FORMATION_SPRITE_MASKS))
    if "formation_slot0_alive" in symbols:
        return sum(
            1
            for value in monitor.mem_get(symbols["formation_slot0_alive"], formation_slot_count)
            if value != 0
        )
    return sum(1 for mask in FORMATION_SPRITE_MASKS if sprite_enable & mask)


def capture_state(monitor: BinaryMonitor, symbols: dict[str, int]) -> dict:
    active = read_u8_array(monitor, symbols["enemy_bullet_active"], ENEMY_BULLET_LIMIT)
    x_lo = read_u8_array(monitor, symbols["enemy_bullet_x_lo"], ENEMY_BULLET_LIMIT)
    x_hi = read_u8_array(monitor, symbols["enemy_bullet_x_hi"], ENEMY_BULLET_LIMIT)
    y = read_u8_array(monitor, symbols["enemy_bullet_y"], ENEMY_BULLET_LIMIT)

    dive_x = combine_x(read_u8(monitor, symbols["dive_x_lo"]), read_u8(monitor, symbols["dive_x_hi"]))
    dive_y = read_u8(monitor, symbols["dive_y"])
    dive_active = read_u8(monitor, symbols["dive_active"])
    dive_phase = read_u8(monitor, symbols["dive_phase"])

    bullets = []
    for index in range(ENEMY_BULLET_LIMIT):
        bullet_x = combine_x(x_lo[index], x_hi[index])
        bullet_y = y[index]
        bullets.append(
            {
                "index": index,
                "active": active[index] != 0,
                "x": bullet_x,
                "y": bullet_y,
                "dx_from_dive": bullet_x - dive_x,
                "dy_from_dive": bullet_y - dive_y,
                "screen_x": bullet_x - PLAYFIELD_LEFT_X,
                "screen_y": bullet_y - PLAYFIELD_TOP_Y,
                "char_col": (bullet_x - PLAYFIELD_LEFT_X) // 8,
                "char_row": (bullet_y - PLAYFIELD_TOP_Y) // 8,
            }
        )

    return {
        "timestamp": time.time(),
        "dive_active": dive_active != 0,
        "dive_phase": dive_phase,
        "dive_x": dive_x,
        "dive_y": dive_y,
        "enemy_bullets": bullets,
    }


def wait_for_game_ready(monitor: BinaryMonitor, symbols: dict[str, int], timeout_seconds: float) -> None:
    deadline = time.time() + timeout_seconds

    while time.time() < deadline:
        monitor.exit_monitor()
        time.sleep(0.05)

        vic_data = monitor.mem_get(SPRITE0_X, (SPRITE_ENABLE - SPRITE0_X) + 1)
        sprite_enable = vic_data[SPRITE_ENABLE - SPRITE0_X]
        formation_y = vic_data[SPRITE0_Y - SPRITE0_X]
        player_y = vic_data[SPRITE1_Y - SPRITE0_X]

        if (
            (sprite_enable & 0x02) != 0
            and logical_alive_count(monitor, symbols, sprite_enable) >= 1
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


def wait_for_spawn(monitor: BinaryMonitor, symbols: dict[str, int], timeout_seconds: float) -> dict:
    wait_for_game_ready(monitor, symbols, timeout_seconds=5.0)

    deadline = time.time() + timeout_seconds
    previous_active = [0] * ENEMY_BULLET_LIMIT

    while time.time() < deadline:
        monitor.exit_monitor()
        time.sleep(0.02)

        current_active = read_u8_array(monitor, symbols["enemy_bullet_active"], ENEMY_BULLET_LIMIT)
        for index, value in enumerate(current_active):
            if value != 0 and previous_active[index] == 0:
                return capture_state(monitor, symbols)
        previous_active = current_active

    raise PlaytestFailure("Timed out waiting for the first enemy bullet spawn")


def parse_args():
    parser = argparse.ArgumentParser(description="Capture the first enemy bullet spawn frame from VICE.")
    parser.add_argument("--prg", type=Path, required=True)
    parser.add_argument("--sym", type=Path, required=True)
    parser.add_argument("--json", type=Path, required=True)
    parser.add_argument("--vice-log", type=Path, required=True)
    parser.add_argument("--exit-screenshot", type=Path, required=True)
    parser.add_argument("--post-spawn-seconds", type=float, default=0.0)
    parser.add_argument("--timeout", type=float, default=20.0)
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    args.json.parent.mkdir(parents=True, exist_ok=True)
    args.vice_log.parent.mkdir(parents=True, exist_ok=True)
    args.exit_screenshot.parent.mkdir(parents=True, exist_ok=True)

    symbols = parse_symbols(args.sym)
    vice_process = None
    monitor = None
    result = {
        "success": False,
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
        state = wait_for_spawn(monitor, symbols, args.timeout)
        result["success"] = True
        result["spawn_state"] = state
        if args.post_spawn_seconds > 0:
            monitor.exit_monitor()
            time.sleep(args.post_spawn_seconds)
            result["capture_state"] = capture_state(monitor, symbols)
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
