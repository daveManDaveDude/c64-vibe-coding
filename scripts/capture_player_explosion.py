#!/usr/bin/env python3
import argparse
import json
from pathlib import Path

from playtest_asm import (
    LEFT_KEY_CODE,
    Logger,
    PlaytestFailure,
    Playtester,
    SPRITE0_X,
)


SPRITE_POINTERS = 0x07F8
SPRITE_MULTICOLOR = 0xD01C
SPRITE_MULTICOLOR_0 = 0xD025
SPRITE_MULTICOLOR_1 = 0xD026
SPRITE0_COLOR = 0xD027


def add_explosion_registers(playtester: Playtester, sample: dict) -> None:
    vic = playtester.monitor.mem_get(SPRITE_MULTICOLOR, (SPRITE_MULTICOLOR_1 - SPRITE_MULTICOLOR) + 1)
    color_data = list(playtester.monitor.mem_get(SPRITE0_COLOR, 8))
    pointers = list(playtester.monitor.mem_get(SPRITE_POINTERS, 8))

    sprite_multicolor = vic[0]
    sprite_multicolor_0 = vic[SPRITE_MULTICOLOR_0 - SPRITE_MULTICOLOR]
    sprite_multicolor_1 = vic[SPRITE_MULTICOLOR_1 - SPRITE_MULTICOLOR]

    sample["sprite_multicolor"] = sprite_multicolor
    sample["sprite_multicolor_0"] = sprite_multicolor_0
    sample["sprite_multicolor_1"] = sprite_multicolor_1
    sample["sprite_pointers"] = pointers
    sample["sprite_colors"] = color_data

    symbols = playtester.symbols
    if "player_explosion_active" in symbols:
        sample["player_explosion_active"] = playtester.monitor.mem_get(symbols["player_explosion_active"], 1)[0]
    if "player_explosion_frame" in symbols:
        sample["player_explosion_frame"] = playtester.monitor.mem_get(symbols["player_explosion_frame"], 1)[0]
    if "player_explosion_timer" in symbols:
        sample["player_explosion_timer"] = playtester.monitor.mem_get(symbols["player_explosion_timer"], 1)[0]
    if "player_white_slot" in symbols:
        sample["player_white_slot"] = playtester.monitor.mem_get(symbols["player_white_slot"], 1)[0]
    if "player_cyan_slot" in symbols:
        sample["player_cyan_slot"] = playtester.monitor.mem_get(symbols["player_cyan_slot"], 1)[0]


def parse_args():
    parser = argparse.ArgumentParser(description="Capture host screenshots and VIC register state for the first player explosion.")
    parser.add_argument("--prg", type=Path, default=Path("build/hello-asm.prg"))
    parser.add_argument("--log", type=Path, default=Path("artifacts/player-explosion-capture.log"))
    parser.add_argument("--json", type=Path, default=Path("artifacts/player-explosion-capture.json"))
    parser.add_argument("--vice-log", type=Path, default=Path("artifacts/player-explosion-capture-vice.log"))
    parser.add_argument("--frames-dir", type=Path, default=Path("artifacts/player-explosion-capture-frames"))
    parser.add_argument("--keymap", type=Path, default=Path("artifacts/player-explosion-capture-keymap.vkm"))
    parser.add_argument("--exit-screenshot", type=Path, default=Path("artifacts/player-explosion-capture-exit.png"))
    parser.add_argument("--window-x", type=int, default=80)
    parser.add_argument("--window-y", type=int, default=80)
    parser.add_argument("--window-width", type=int, default=768)
    parser.add_argument("--window-height", type=int, default=638)
    parser.add_argument("--process-name", default="x64sc")
    parser.add_argument("--sample-count", type=int, default=10)
    parser.add_argument("--sample-interval", type=float, default=0.10)
    parser.add_argument("--wait-timeout", type=float, default=20.0)
    parser.add_argument("--capture-host-screenshots", action="store_true", default=True)
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    args.log.parent.mkdir(parents=True, exist_ok=True)
    args.json.parent.mkdir(parents=True, exist_ok=True)
    args.frames_dir.mkdir(parents=True, exist_ok=True)

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
        "samples": [],
    }

    try:
        playtester.launch_vice()
        ready = playtester.wait_for_game_ready()
        result["ready_state"] = ready

        logger.log("Holding left until the first player hit triggers the explosion")
        playtester.gui.key_down(LEFT_KEY_CODE)
        try:
            deadline = __import__("time").time() + args.wait_timeout
            hit_sample = None
            while __import__("time").time() < deadline:
                playtester.resume_for(0.10)
                current = playtester.capture_sample("wait-hit", include_joystick=False)
                add_explosion_registers(playtester, current)
                if current.get("player_respawn_timer", 0) > 0:
                    hit_sample = current
                    break
            if hit_sample is None:
                raise PlaytestFailure("Timed out waiting for the first player explosion")
        finally:
            playtester.gui.key_up(LEFT_KEY_CODE)

        result["hit_sample"] = hit_sample

        logger.log("Capturing the explosion sequence")
        captured = []
        for index in range(args.sample_count):
            if index != 0:
                playtester.resume_for(args.sample_interval)
            sample = playtester.capture_sample(f"explosion-{index:02d}", include_joystick=False)
            add_explosion_registers(playtester, sample)
            captured.append(sample)
        result["samples"] = captured
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
