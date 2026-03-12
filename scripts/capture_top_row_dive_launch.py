#!/usr/bin/env python3
import argparse
import json
import socket
import shutil
import time
from pathlib import Path
from typing import Optional

from playtest_asm import FIRE_KEY_CODE, LEFT_KEY_CODE, Logger, PlaytestFailure, Playtester, RIGHT_KEY_CODE


def parse_args():
    parser = argparse.ArgumentParser(
        description="Capture frame-by-frame host screenshots around the top-row dive launches."
    )
    parser.add_argument("--prg", type=Path, default=Path("build/hello-asm.prg"))
    parser.add_argument("--log", type=Path, default=Path("artifacts/top-row-dive-launch.log"))
    parser.add_argument("--json", type=Path, default=Path("artifacts/top-row-dive-launch.json"))
    parser.add_argument("--vice-log", type=Path, default=Path("artifacts/top-row-dive-launch-vice.log"))
    parser.add_argument("--frames-dir", type=Path, default=Path("artifacts/top-row-dive-launch-frames"))
    parser.add_argument(
        "--selected-frames-dir",
        type=Path,
        default=Path("artifacts/top-row-dive-launch-selected"),
    )
    parser.add_argument(
        "--monitor-commands",
        type=Path,
        default=Path("artifacts/top-row-dive-launch-moncommands.txt"),
    )
    parser.add_argument(
        "--monitor-log",
        type=Path,
        default=Path("artifacts/top-row-dive-launch-monitor.log"),
    )
    parser.add_argument(
        "--remote-monitor-address",
        default="ip4://127.0.0.1:6510",
    )
    parser.add_argument("--keymap", type=Path, default=Path("artifacts/top-row-dive-launch-keymap.vkm"))
    parser.add_argument("--exit-screenshot", type=Path, default=Path("artifacts/top-row-dive-launch-exit.png"))
    parser.add_argument("--window-x", type=int, default=80)
    parser.add_argument("--window-y", type=int, default=80)
    parser.add_argument("--window-width", type=int, default=720)
    parser.add_argument("--window-height", type=int, default=638)
    parser.add_argument("--process-name", default="x64sc")
    parser.add_argument("--frame-poll-interval", type=float, default=0.0005)
    parser.add_argument("--frame-timeout", type=float, default=2.0)
    parser.add_argument("--launch-poll-interval", type=float, default=0.02)
    parser.add_argument("--launch-timeout", type=float, default=60.0)
    parser.add_argument("--capture-after-launches", type=int, default=4)
    parser.add_argument("--target-slots", default="0,1")
    parser.add_argument("--frames-after-last-target-launch", type=int, default=8)
    parser.add_argument("--selected-before", type=int, default=2)
    parser.add_argument("--selected-after", type=int, default=6)
    parser.add_argument("--prime-move-seconds", type=float, default=0.90)
    parser.add_argument("--fire-hold-seconds", type=float, default=0.06)
    parser.add_argument("--arm-timeout", type=float, default=2.0)
    parser.add_argument("--screenshot-settle-seconds", type=float, default=0.01)
    parser.add_argument("--capture-host-screenshots", action="store_true", default=True)
    return parser.parse_args()


def parse_target_slots(raw_value: str) -> list[int]:
    slots = []
    for item in raw_value.split(","):
        stripped = item.strip()
        if not stripped:
            continue
        slot = int(stripped, 10)
        if slot < 0:
            raise ValueError(f"Invalid target slot {slot}; expected a non-negative slot index")
        slots.append(slot)
    if not slots:
        raise ValueError("At least one target slot is required")
    return sorted(set(slots))


def reset_output_dir(path: Path) -> None:
    if path.exists():
        shutil.rmtree(path)
    path.mkdir(parents=True, exist_ok=True)


def write_monitor_commands(
    path: Path, symbols: dict[str, int], target_slots: list[int], formation_slot_count: int
) -> None:
    lines = []
    for slot_index in range(formation_slot_count):
        if slot_index in target_slots:
            continue
        symbol_name = f"formation_slot{slot_index}_alive"
        if symbol_name not in symbols:
            raise PlaytestFailure(f"Missing symbol for monitor setup: {symbol_name}")
        lines.append(f"> ${symbols[symbol_name]:04x} 0")
    lines.append("x")
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def read_symbol_u8(playtester: Playtester, symbol: str) -> int:
    return playtester.monitor.mem_get(playtester.symbols[symbol], 1)[0]


def parse_tcp_address(raw_value: str) -> tuple[str, int]:
    prefix = "ip4://"
    if not raw_value.startswith(prefix):
        raise PlaytestFailure(f"Unsupported remote monitor address: {raw_value}")
    host_port = raw_value[len(prefix) :]
    host, port_text = host_port.rsplit(":", 1)
    return host, int(port_text, 10)


def read_remote_monitor_output(sock: socket.socket) -> str:
    chunks = []
    while True:
        try:
            chunk = sock.recv(4096)
        except socket.timeout:
            break
        except ConnectionResetError:
            break
        except OSError as exc:
            if exc.errno in (54, 57):
                break
            raise
        if not chunk:
            break
        chunks.append(chunk.decode("utf-8", errors="replace"))
        if chunks and chunks[-1].rstrip().endswith(")"):
            break
    return "".join(chunks)


def send_remote_monitor_commands(address: str, commands: list[str]) -> str:
    host, port = parse_tcp_address(address)
    with socket.create_connection((host, port), timeout=5.0) as sock:
        sock.settimeout(0.20)
        output = ""
        sent_commands = 0
        try:
            output += read_remote_monitor_output(sock)
            for command in commands:
                sock.sendall((command + "\n").encode("utf-8"))
                sent_commands += 1
                output += read_remote_monitor_output(sock)
            sock.sendall(b"x\n")
            output += read_remote_monitor_output(sock)
            return output
        except ConnectionResetError:
            if sent_commands > 0:
                return output
            raise
        except OSError as exc:
            if sent_commands > 0 and exc.errno in (54, 57):
                return output
            raise


def apply_top_row_only_patch(
    playtester: Playtester,
    logger: Logger,
    target_slots: list[int],
    timeout: float = 2.0,
) -> dict:
    if "formation_slot0_alive" not in playtester.symbols:
        raise PlaytestFailure("Missing formation_slot0_alive symbol for binary monitor patch")

    patch_values = bytes(
        1 if slot_index in target_slots else 0
        for slot_index in range(playtester.formation_slot_count)
    )
    logger.log("Patching lower-row alive flags through the binary monitor")
    playtester.monitor.mem_set(playtester.symbols["formation_slot0_alive"], patch_values)
    deadline = time.time() + timeout
    latest = None
    while time.time() < deadline:
        playtester.resume_for(0.02)
        latest = playtester.read_state(include_joystick=False)
        if live_slot_indexes(playtester, latest) == target_slots:
            return {
                "patched_bytes": list(patch_values),
                "state": latest,
            }

    raise PlaytestFailure(
        f"Timed out waiting for top-row-only live state: target={target_slots} latest={latest}"
    )


def step_to_next_frame(
    playtester: Playtester, previous_frame_value: int, poll_interval: float, timeout: float
) -> int:
    deadline = time.time() + timeout
    while time.time() < deadline:
        playtester.resume_for(poll_interval)
        current_frame_value = read_symbol_u8(playtester, "frame_capture_counter")
        if current_frame_value != previous_frame_value:
            return current_frame_value
    raise PlaytestFailure(
        f"Timed out waiting for the next frame: previous_frame_value={previous_frame_value}"
    )


def capture_enriched_sample(
    playtester: Playtester, stage: str, previous_sample: Optional[dict]
) -> dict:
    sample = playtester.capture_sample(stage, include_joystick=False)
    sample["frame_capture_counter"] = read_symbol_u8(playtester, "frame_capture_counter")
    sample["formation_frame_value"] = read_symbol_u8(playtester, "formation_frame")
    sample["slot_0_visual_y"] = playtester.slot_visual_y(sample, 0)
    sample["slot_1_visual_y"] = playtester.slot_visual_y(sample, 1)
    dive_slot = normalize_dive_slot(sample.get("dive_slot"), playtester.formation_slot_count)
    sample["dive_expected_y"] = (
        playtester.slot_visual_y(sample, dive_slot) if dive_slot is not None else None
    )
    if previous_sample is None:
        sample["frame_advance"] = 0
        sample["launch_counter_delta"] = 0
    else:
        sample["frame_advance"] = (
            sample["frame_capture_counter"] - previous_sample["frame_capture_counter"]
        ) & 0xFF
        previous_counter = previous_sample.get("dive_launch_counter") or 0
        current_counter = sample.get("dive_launch_counter") or 0
        sample["launch_counter_delta"] = (current_counter - previous_counter) & 0xFF
    return sample


def arm_enemy_attack(
    playtester: Playtester,
    logger: Logger,
    move_right_seconds: float,
    fire_hold_seconds: float,
    arm_timeout: float,
) -> dict:
    if move_right_seconds > 0:
        logger.log(f"Moving player right for {move_right_seconds:.2f}s before arming the attack")
        playtester.gui.key_down(RIGHT_KEY_CODE)
        try:
            playtester.resume_for(move_right_seconds)
        finally:
            playtester.gui.key_up(RIGHT_KEY_CODE)

    logger.log("Firing once to arm the enemy attack loop")
    playtester.gui.key_down(FIRE_KEY_CODE)
    try:
        playtester.resume_for(fire_hold_seconds)
    finally:
        playtester.gui.key_up(FIRE_KEY_CODE)

    deadline = time.time() + arm_timeout
    latest = None
    while time.time() < deadline:
        latest = playtester.read_state(include_joystick=False)
        if latest.get("enemy_attack_active") or latest.get("shot_active"):
            return latest
        playtester.resume_for(0.02)

    raise PlaytestFailure(f"Timed out waiting for enemy attack arm state: {latest}")


def normalize_dive_slot(raw_slot: Optional[int], formation_slot_count: int) -> Optional[int]:
    if raw_slot is None:
        return None
    if 0 <= raw_slot < formation_slot_count:
        return raw_slot
    return None


def live_slot_indexes(playtester: Playtester, sample: dict) -> list[int]:
    return [slot["index"] for slot in playtester.formation_slots(sample) if slot["alive"]]


def destroy_next_diver_for_prune(playtester: Playtester, logger: Logger, name: str) -> dict:
    baseline_state = playtester.read_state(include_joystick=False)
    baseline_alive_count = playtester.total_formation_alive_count(baseline_state)
    baseline_score_total = baseline_state.get("score_total")
    attempts = []

    for attempt in range(1, 5):
        launch = playtester.wait_for_active_dive(
            f"{name}-launch-{attempt}",
            max_samples=40,
            sample_interval=0.20,
        )
        dive_slot = normalize_dive_slot(launch.get("dive_slot"), playtester.formation_slot_count)
        if dive_slot is None:
            attempts.append({"attempt": attempt, "launch": launch, "result": "invalid_slot"})
            continue

        attempt_detail = {
            "attempt": attempt,
            "dive_slot": dive_slot,
            "launch_sample": launch,
            "score_before": baseline_score_total,
            "observations": [],
        }
        shot_fired = False
        current = launch

        for watch_index in range(40):
            if watch_index > 0:
                playtester.resume_for(0.12)
                current = playtester.capture_sample(
                    f"{name}-attempt-{attempt}-watch-{watch_index}",
                    include_joystick=False,
                )

            delta_x = None if current["dive_x"] is None else current["player_x"] - current["dive_x"]
            attempt_detail["observations"].append(
                {
                    "sample": current,
                    "delta_x": delta_x,
                }
            )

            if not shot_fired:
                if (
                    not current["dive_active"]
                    or normalize_dive_slot(
                        current.get("dive_slot"), playtester.formation_slot_count
                    ) != dive_slot
                ):
                    attempt_detail["result"] = "dive_ended_before_fire"
                    attempt_detail["final_sample"] = current
                    break

                if delta_x is not None and abs(delta_x) > 16:
                    key_code = LEFT_KEY_CODE if delta_x > 0 else RIGHT_KEY_CODE
                    playtester.gui.key_down(key_code)
                    try:
                        playtester.resume_for(playtester.dive_tracking_burst_seconds(delta_x))
                    finally:
                        playtester.gui.key_up(key_code)
                    continue

                if current["dive_y"] is not None and current["dive_y"] >= 96 and not current["shot_enabled"]:
                    fire_sample = playtester.fire_once(f"{name}-{attempt}")
                    attempt_detail["fire_sample"] = fire_sample
                    shot_fired = True
                    current = fire_sample

            if not shot_fired:
                continue

            if not current[f"formation_{dive_slot}_alive"]:
                attempt_detail["result"] = "hit"
                attempt_detail["hit_sample"] = current
                attempt_detail["score_after"] = current.get("score_total")
                if baseline_score_total is not None and attempt_detail["score_after"] is not None:
                    attempt_detail["score_expected"] = playtester.expected_score_award(dive_slot)
                    attempt_detail["score_delta"] = attempt_detail["score_after"] - baseline_score_total
                playtester.assert_true(
                    f"{name}_alive_count",
                    playtester.total_formation_alive_count(current) == baseline_alive_count - 1,
                    {
                        "baseline_alive_count": baseline_alive_count,
                        "current": current,
                    },
                )
                if attempt_detail.get("score_expected") is not None:
                    playtester.assert_true(
                        f"{name}_score_award",
                        attempt_detail.get("score_delta") == attempt_detail.get("score_expected"),
                        attempt_detail,
                    )
                return attempt_detail

            if not current["shot_enabled"] and (
                not current["dive_active"]
                or normalize_dive_slot(
                    current.get("dive_slot"), playtester.formation_slot_count
                ) != dive_slot
            ):
                attempt_detail["result"] = "miss"
                attempt_detail["final_sample"] = current
                break
        else:
            attempt_detail["result"] = "timeout"
            attempt_detail["final_sample"] = current

        attempts.append(attempt_detail)

    raise PlaytestFailure(f"{name}_timeout: {attempts}")


def relation_label(offset: int) -> str:
    if offset == 0:
        return "launch"
    if offset < 0:
        return f"pre{-offset:02d}"
    return f"post{offset:02d}"


def collect_selected_frames(result: dict, args) -> None:
    samples = result["samples"]
    args.selected_frames_dir.mkdir(parents=True, exist_ok=True)
    selected_frames = []

    for launch in result["target_launches"]:
        launch_sample_index = launch["sample_index"]
        slot = launch["dive_slot"]
        start_index = max(0, launch_sample_index - args.selected_before)
        end_index = min(len(samples) - 1, launch_sample_index + args.selected_after)

        for sample_index in range(start_index, end_index + 1):
            sample = samples[sample_index]
            screenshot = sample.get("screenshot")
            if screenshot is None:
                continue
            offset = sample_index - launch_sample_index
            destination = args.selected_frames_dir / (
                f"slot{slot}-launch{launch['dive_launch_counter']:02d}-"
                f"{relation_label(offset)}-sample{sample['index']:03d}.png"
            )
            shutil.copy2(screenshot, destination)
            selected_frames.append(
                {
                    "slot": slot,
                    "dive_launch_counter": launch["dive_launch_counter"],
                    "sample_index": sample_index,
                    "relation_to_launch": relation_label(offset),
                    "source_screenshot": screenshot,
                    "copied_screenshot": str(destination),
                    "frame_capture_counter": sample.get("frame_capture_counter"),
                    "dive_active": sample.get("dive_active"),
                    "dive_slot": sample.get("dive_slot"),
                    "dive_y": sample.get("dive_y"),
                    "dive_launch_y": sample.get("dive_launch_y"),
                    "dive_expected_y": sample.get("dive_expected_y"),
                }
            )

    result["selected_frames"] = selected_frames


def main() -> int:
    args = parse_args()
    target_slots = parse_target_slots(args.target_slots)

    args.log.parent.mkdir(parents=True, exist_ok=True)
    args.json.parent.mkdir(parents=True, exist_ok=True)
    args.vice_log.parent.mkdir(parents=True, exist_ok=True)
    args.exit_screenshot.parent.mkdir(parents=True, exist_ok=True)
    reset_output_dir(args.frames_dir)
    reset_output_dir(args.selected_frames_dir)

    logger = Logger(args.log)
    args.monitor_commands = None
    args.monitor_log = None
    args.remote_monitor_address = None
    playtester = Playtester(args, logger)
    result = {
        "success": False,
        "target_slots": target_slots,
        "capture_after_launches": args.capture_after_launches,
        "artifacts": {
            "log": str(args.log),
            "json": str(args.json),
            "vice_log": str(args.vice_log),
            "frames_dir": str(args.frames_dir),
            "selected_frames_dir": str(args.selected_frames_dir),
            "keymap": str(args.keymap),
            "exit_screenshot": str(args.exit_screenshot),
        },
        "warmup_launches": [],
        "pruned_divers": [],
        "captured_launches": [],
        "target_launches": [],
        "samples": [],
    }

    try:
        playtester.launch_vice()
        invalid_target_slots = [
            slot for slot in target_slots if slot >= playtester.formation_slot_count
        ]
        if invalid_target_slots:
            raise PlaytestFailure(
                f"Invalid target slots for current build: {invalid_target_slots}; "
                f"formation_slot_count={playtester.formation_slot_count}"
            )
        ready = playtester.wait_for_game_ready()
        result["ready_state"] = ready

        if ready.get("formation_renderer_mode_name") != "char":
            raise PlaytestFailure(
                f"Expected char renderer, got {ready.get('formation_renderer_mode_name')}"
            )

        result["armed_state"] = arm_enemy_attack(
            playtester,
            logger,
            move_right_seconds=args.prime_move_seconds,
            fire_hold_seconds=args.fire_hold_seconds,
            arm_timeout=args.arm_timeout,
        )

        result["top_row_only_patch"] = apply_top_row_only_patch(
            playtester,
            logger,
            target_slots,
        )

        playtester.assert_true(
            "top_row_only_setup",
            live_slot_indexes(playtester, result["top_row_only_patch"]["state"]) == target_slots,
            {
                "expected": target_slots,
                "actual": live_slot_indexes(playtester, result["top_row_only_patch"]["state"]),
                "patch_state": result["top_row_only_patch"]["state"],
            },
        )

        logger.log("Starting frame-by-frame capture with only top-row slots alive")
        previous_sample = capture_enriched_sample(playtester, "frame-0000", None)
        result["samples"].append(previous_sample)

        post_target_frames_remaining = None
        while True:
            next_frame_value = step_to_next_frame(
                playtester,
                previous_sample["frame_capture_counter"],
                args.frame_poll_interval,
                args.frame_timeout,
            )
            sample = capture_enriched_sample(
                playtester,
                f"frame-{len(result['samples']):04d}",
                previous_sample,
            )
            if sample["frame_capture_counter"] != next_frame_value:
                sample["captured_frame_mismatch"] = {
                    "expected": next_frame_value,
                    "captured": sample["frame_capture_counter"],
                }
            result["samples"].append(sample)

            if sample.get("dive_launch_counter") != previous_sample.get("dive_launch_counter"):
                launch_event = {
                    "sample_index": len(result["samples"]) - 1,
                    "frame_capture_counter": sample["frame_capture_counter"],
                    "dive_launch_counter": sample.get("dive_launch_counter"),
                    "dive_slot": sample.get("dive_slot"),
                    "dive_launch_y": sample.get("dive_launch_y"),
                    "dive_expected_y": sample.get("dive_expected_y"),
                    "dive_y": sample.get("dive_y"),
                    "screenshot": sample.get("screenshot"),
                }
                result["captured_launches"].append(launch_event)
                logger.log(
                    "Captured launch "
                    f"{launch_event['dive_launch_counter']}: slot={launch_event['dive_slot']} "
                    f"launch_y={launch_event['dive_launch_y']} expected={launch_event['dive_expected_y']} "
                    f"sample={launch_event['sample_index']}"
                )
                if launch_event["dive_slot"] in target_slots:
                    result["target_launches"].append(launch_event)
                    if {item["dive_slot"] for item in result["target_launches"]} == set(target_slots):
                        post_target_frames_remaining = args.frames_after_last_target_launch
            elif (
                {item["dive_slot"] for item in result["target_launches"]} != set(target_slots)
                and not sample.get("enemy_attack_active")
                and not sample.get("shot_active")
                and (sample.get("player_respawn_timer") or 0) == 0
            ):
                logger.log("Enemy attack went idle before both top-row launches; re-arming it")
                arm_enemy_attack(
                    playtester,
                    logger,
                    move_right_seconds=0.0,
                    fire_hold_seconds=args.fire_hold_seconds,
                    arm_timeout=args.arm_timeout,
                )

            if post_target_frames_remaining is not None:
                if post_target_frames_remaining == 0:
                    break
                post_target_frames_remaining -= 1

            previous_sample = sample

        if not result["target_launches"]:
            raise PlaytestFailure("No target top-row launches were captured")

        collect_selected_frames(result, args)
        result["captured_frame_count"] = len(result["samples"])
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
