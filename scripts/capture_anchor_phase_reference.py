#!/usr/bin/env python3
import argparse
import json
import shutil
import time
from pathlib import Path

from playtest_asm import Logger, PlaytestFailure, Playtester
from review_formation_render_native import (
    RemoteTextMonitor,
    apply_clear_strategy,
    capture_review_sample,
    reset_output_dir,
    wait_for_stage,
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Capture a latched before/during/after reference set for a target anchor/phase."
    )
    parser.add_argument("--prg", type=Path, default=Path("build/hello-asm.prg"))
    parser.add_argument("--output-dir", type=Path, required=True)
    parser.add_argument("--stage", choices=("ready", "play"), default="play")
    parser.add_argument("--target-anchor", type=int, required=True)
    parser.add_argument("--target-phase", type=int, required=True)
    parser.add_argument("--target-label")
    parser.add_argument("--max-seconds", type=float, default=20.0)
    parser.add_argument("--sample-interval", type=float, default=0.02)
    parser.add_argument("--clear-strategy", choices=("edge_global", "rowwise"), default="rowwise")
    parser.add_argument("--process-name", default="x64sc")
    parser.add_argument("--window-x", type=int, default=80)
    parser.add_argument("--window-y", type=int, default=80)
    parser.add_argument("--window-width", type=int, default=768)
    parser.add_argument("--window-height", type=int, default=638)
    parser.add_argument("--remote-monitor-address", default="ip4://127.0.0.1:6510")
    parser.add_argument("--screenshot-format", type=int, default=2)
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    output_dir = args.output_dir.resolve()
    frames_dir = output_dir / "frames"
    label = args.target_label or f"anchor{args.target_anchor}_phase{args.target_phase}"

    reset_output_dir(output_dir)
    frames_dir.mkdir(parents=True, exist_ok=True)

    args.log = output_dir / "capture.log"
    args.json = output_dir / "records.json"
    args.vice_log = output_dir / "vice.log"
    args.frames_dir = frames_dir
    args.keymap = output_dir / "capture.vkm"
    args.exit_screenshot = output_dir / "exit.png"
    args.capture_host_screenshots = False

    logger = Logger(args.log)
    playtester = Playtester(args, logger)
    remote_monitor = RemoteTextMonitor(args.remote_monitor_address)

    records = {
        "success": False,
        "failure": None,
        "target": {
            "label": label,
            "anchor": args.target_anchor,
            "phase": args.target_phase,
        },
        "artifacts": {
            "dir": str(output_dir),
            "frames_dir": str(frames_dir),
            "log": str(args.log),
            "vice_log": str(args.vice_log),
            "exit_screenshot": str(args.exit_screenshot),
            "keymap": str(args.keymap),
        },
        "samples": [],
        "selection": None,
    }

    try:
        playtester.launch_vice()
        remote_monitor.connect()
        wait_for_stage(playtester, args.stage)
        clear_strategy_value = apply_clear_strategy(playtester, args.clear_strategy)
        logger.log(
            f"Capturing until {label} (anchor={args.target_anchor}, phase={args.target_phase}) is seen"
        )

        start_time = time.time()
        target_index = None
        deadline = start_time + args.max_seconds

        while time.time() < deadline:
            sample = capture_review_sample(
                playtester,
                remote_monitor,
                args.stage,
                args.clear_strategy,
                clear_strategy_value,
                start_time,
                frames_dir,
                args.screenshot_format,
            )
            records["samples"].append(sample)

            if (
                target_index is None
                and len(records["samples"]) >= 2
                and sample.get("formation_anchor_col") == args.target_anchor
                and sample.get("formation_shift_phase") == args.target_phase
            ):
                target_index = len(records["samples"]) - 1
                logger.log(
                    f"Target {label} matched at sample {target_index} moving {sample.get('formation_dir_name')}"
                )
            elif target_index is not None and len(records["samples"]) >= target_index + 2:
                break

            playtester.resume_for(args.sample_interval)

        if target_index is None or len(records["samples"]) < target_index + 2:
            raise PlaytestFailure(
                f"Timed out before capturing full reference set for {label}: "
                f"samples={len(records['samples'])} target_index={target_index}"
            )

        selected_dir = output_dir / "selected" / label
        selected_dir.mkdir(parents=True, exist_ok=True)
        selection = {
            "label": label,
            "sample_index": target_index,
            "movement_direction": records["samples"][target_index].get("formation_dir_name"),
            "files": [],
        }
        for prefix, stage_label, offset in (
            ("1", "before", -1),
            ("2", "during", 0),
            ("3", "after", 1),
        ):
            sample_index = target_index + offset
            sample = records["samples"][sample_index]
            source = Path(sample["screenshot"])
            destination = selected_dir / f"{prefix}-{stage_label}-{source.name}"
            shutil.copy2(source, destination)
            selection["files"].append(
                {
                    "label": stage_label,
                    "sample_index": sample_index,
                    "source": str(source),
                    "copied_frame": str(destination),
                }
            )

        records["selection"] = selection
        records["success"] = True
    except Exception as exc:
        records["failure"] = str(exc)
    finally:
        try:
            remote_monitor.close()
        except Exception:
            pass
        try:
            playtester.shutdown()
        except Exception:
            pass
        args.json.write_text(json.dumps(records, indent=2))

    print(json.dumps(records, indent=2))
    return 0 if records["success"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
