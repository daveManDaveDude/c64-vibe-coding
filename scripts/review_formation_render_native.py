#!/usr/bin/env python3
import argparse
import hashlib
import json
import shutil
import socket
import time
from pathlib import Path
from typing import Optional

from playtest_asm import Logger, PlaytestFailure, Playtester


CLEAR_STRATEGIES = {
    "edge_global": "FORMATION_CLEAR_STRATEGY_EDGE_GLOBAL",
    "rowwise": "FORMATION_CLEAR_STRATEGY_ROWWISE",
}

CAPTURE_LATCH_ARM = 0x01
CAPTURE_LATCH_STEP = 0x02


class RemoteTextMonitor:
    def __init__(self, address: str):
        self.host, self.port = self._parse_address(address)
        self.sock = None

    @staticmethod
    def _parse_address(address: str) -> tuple[str, int]:
        prefix = "ip4://"
        if not address.startswith(prefix):
            raise PlaytestFailure(f"Unsupported remote monitor address: {address}")
        host_port = address[len(prefix) :]
        host, port_text = host_port.rsplit(":", 1)
        return host, int(port_text, 10)

    def connect(self) -> None:
        last_error = None
        for _ in range(30):
            try:
                self.sock = socket.create_connection((self.host, self.port), timeout=1.0)
                self.sock.settimeout(0.2)
                self._read_until_quiet()
                return
            except OSError as exc:
                last_error = exc
                time.sleep(0.1)
        raise PlaytestFailure(f"Could not connect to VICE remote monitor: {last_error}")

    def close(self) -> None:
        if self.sock is None:
            return
        try:
            self.sock.close()
        finally:
            self.sock = None

    def _read_until_quiet(self) -> str:
        if self.sock is None:
            raise PlaytestFailure("Remote monitor is not connected")
        chunks = []
        while True:
            try:
                chunk = self.sock.recv(4096)
            except socket.timeout:
                break
            if not chunk:
                break
            chunks.append(chunk)
        return b"".join(chunks).decode("latin1", "replace")

    def command(self, text: str) -> str:
        if self.sock is None:
            raise PlaytestFailure("Remote monitor is not connected")
        self.sock.sendall(text.encode("utf-8") + b"\n")
        time.sleep(0.05)
        return self._read_until_quiet()

    def screenshot(self, path: Path, format_id: int = 2) -> None:
        path.parent.mkdir(parents=True, exist_ok=True)
        response = self.command(f'screenshot "{path}" {format_id}')
        if "ERROR" in response:
            raise PlaytestFailure(f"VICE screenshot command failed: {response.strip()}")
        for _ in range(20):
            if path.exists():
                return
            time.sleep(0.05)
        raise PlaytestFailure(f"VICE screenshot was not created: {path}")


def parse_args():
    parser = argparse.ArgumentParser(
        description="Capture a formation render review sequence using VICE-native screenshots."
    )
    parser.add_argument("--prg", type=Path, default=Path("build/hello-asm.prg"))
    parser.add_argument("--output-dir", type=Path, required=True)
    parser.add_argument("--stage", choices=("ready", "play"), default="play")
    parser.add_argument("--duration-seconds", type=float, default=5.0)
    parser.add_argument("--sample-interval", type=float, default=0.12)
    parser.add_argument("--frame-count", type=int)
    parser.add_argument("--clear-strategy", choices=tuple(CLEAR_STRATEGIES), default="rowwise")
    parser.add_argument("--force-zero-scroll", action="store_true")
    parser.add_argument("--process-name", default="x64sc")
    parser.add_argument("--window-x", type=int, default=80)
    parser.add_argument("--window-y", type=int, default=80)
    parser.add_argument("--window-width", type=int, default=768)
    parser.add_argument("--window-height", type=int, default=638)
    parser.add_argument("--remote-monitor-address", default="ip4://127.0.0.1:6510")
    parser.add_argument("--screenshot-format", type=int, default=2)
    parser.add_argument("--host-screenshots", action="store_true")
    parser.add_argument("--frame-hold-seconds", type=float, default=0.0)
    parser.add_argument("--log-top-page-rows", action="store_true")
    parser.add_argument(
        "--top-page-rows",
        help="Comma-separated screen row indexes to compare between page 0 and page 1. "
        "Defaults to the upper seam rows around FORMATION_ROW0/1_CHAR_ROW.",
    )
    return parser.parse_args()


def reset_output_dir(path: Path) -> None:
    if path.exists():
        shutil.rmtree(path)
    path.mkdir(parents=True, exist_ok=True)


def read_symbol_u8(playtester: Playtester, symbol: str):
    address = playtester.symbols.get(symbol)
    if address is None:
        return None
    return playtester.monitor.mem_get(address, 1)[0]


def has_capture_latch(playtester: Playtester) -> bool:
    required = {"frame_capture_latch_arm", "frame_capture_latch_ready"}
    return required.issubset(playtester.symbols)


def arm_capture_latch(playtester: Playtester) -> None:
    playtester.monitor.mem_set(playtester.symbols["frame_capture_latch_arm"], bytes([CAPTURE_LATCH_ARM]))


def step_capture_latch(playtester: Playtester) -> None:
    playtester.monitor.mem_set(playtester.symbols["frame_capture_latch_arm"], bytes([CAPTURE_LATCH_STEP]))


def wait_for_capture_latch(playtester: Playtester, previous_frame_counter: Optional[int] = None) -> None:
    for _ in range(400):
        latch_ready = read_symbol_u8(playtester, "frame_capture_latch_ready")
        current_frame_counter = read_symbol_u8(playtester, "frame_capture_counter")
        if latch_ready == 1 and (
            previous_frame_counter is None or current_frame_counter != previous_frame_counter
        ):
            return
        playtester.resume_for(0.005)
    raise PlaytestFailure(
        "Timed out waiting for frame_capture_latch_ready"
        if previous_frame_counter is None
        else f"Timed out waiting for next latched frame after counter {previous_frame_counter}"
    )


def release_capture_latch(playtester: Playtester) -> None:
    playtester.monitor.mem_set(playtester.symbols["frame_capture_latch_arm"], b"\x00")


def rightmost_formation_x(playtester: Playtester, sample: dict):
    live_slots = playtester.live_formation_slots(sample)
    if not live_slots:
        return None
    return max(slot["x"] for slot in live_slots)


def apply_clear_strategy(playtester: Playtester, clear_strategy: str) -> int:
    strategy_symbol = CLEAR_STRATEGIES[clear_strategy]
    if "formation_clear_strategy" not in playtester.symbols:
        raise PlaytestFailure("formation_clear_strategy symbol is missing from the build")
    if strategy_symbol not in playtester.symbols:
        raise PlaytestFailure(f"{strategy_symbol} symbol is missing from the build")
    strategy_value = playtester.symbols[strategy_symbol]
    playtester.monitor.mem_set(
        playtester.symbols["formation_clear_strategy"],
        bytes([strategy_value]),
    )
    return strategy_value


def apply_force_zero_scroll(playtester: Playtester, enabled: bool) -> int:
    if not enabled:
        return 0
    if "formation_force_zero_scroll_debug" not in playtester.symbols:
        raise PlaytestFailure("formation_force_zero_scroll_debug symbol is missing from the build")
    playtester.monitor.mem_set(
        playtester.symbols["formation_force_zero_scroll_debug"],
        b"\x01",
    )
    return 1


def hold_ready_state(playtester: Playtester) -> None:
    ready_state = playtester.symbols.get("GAME_STATE_READY")
    ready_delay = playtester.symbols.get("READY_DELAY")
    game_state = playtester.symbols.get("game_state")
    game_state_timer = playtester.symbols.get("game_state_timer")
    if ready_state is None or ready_delay is None or game_state is None or game_state_timer is None:
        return
    playtester.monitor.mem_set(game_state, bytes([ready_state]))
    playtester.monitor.mem_set(game_state_timer, bytes([ready_delay]))


def wait_for_stage(playtester: Playtester, stage: str) -> dict:
    ready_sample = playtester.wait_for_game_ready()
    if stage == "ready":
        return ready_sample

    playing_state = playtester.symbols.get("GAME_STATE_PLAYING", 1)
    latest = ready_sample
    for _ in range(160):
        if latest.get("game_state") == playing_state:
            return latest
        playtester.resume_for(0.05)
        latest = playtester.wait_for_render_complete()
    raise PlaytestFailure(f"Timed out waiting for PLAYING state: {latest}")


def screenshot_sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def parse_top_page_rows(row_text: Optional[str]) -> Optional[list[int]]:
    if row_text is None:
        return None
    rows = []
    for item in row_text.split(","):
        stripped = item.strip()
        if not stripped:
            continue
        try:
            row = int(stripped, 10)
        except ValueError as exc:
            raise PlaytestFailure(f"Invalid screen row in --top-page-rows: {stripped}") from exc
        if row < 0 or row >= 25:
            raise PlaytestFailure(f"Screen row out of range in --top-page-rows: {row}")
        rows.append(row)
    if not rows:
        raise PlaytestFailure("--top-page-rows did not contain any valid rows")
    return sorted(set(rows))


def default_top_page_rows(playtester: Playtester) -> list[int]:
    row0 = playtester.symbols.get("FORMATION_ROW0_CHAR_ROW")
    row1 = playtester.symbols.get("FORMATION_ROW1_CHAR_ROW")
    candidates = []
    if row0 is not None:
        candidates.extend([row0 - 2, row0 - 1, row0, row0 + 1])
    if row1 is not None:
        candidates.extend([row1, row1 + 1])
    rows = sorted({row for row in candidates if 0 <= row < 25})
    return rows or [2, 3, 4, 5, 6, 7]


def diff_ranges(diff_cols: list[int]) -> list[list[int]]:
    if not diff_cols:
        return []
    ranges = []
    start = diff_cols[0]
    end = start
    for col in diff_cols[1:]:
        if col == end + 1:
            end = col
            continue
        ranges.append([start, end])
        start = col
        end = col
    ranges.append([start, end])
    return ranges


def format_hex_bytes(values: list[int]) -> str:
    return " ".join(f"{value:02x}" for value in values)


def capture_top_page_row_debug(playtester: Playtester, rows: list[int]) -> dict:
    required_symbols = {"SCREEN_RAM", "SCREEN_RAM_ALT"}
    missing = sorted(required_symbols - playtester.symbols.keys())
    if missing:
        return {
            "enabled": False,
            "missing_symbols": missing,
        }

    screen_page0 = playtester.symbols["SCREEN_RAM"]
    screen_page1 = playtester.symbols["SCREEN_RAM_ALT"]
    row_diffs = []
    total_diff_cells = 0
    rows_with_diff = []

    for row in rows:
        page0_addr = screen_page0 + (row * 40)
        page1_addr = screen_page1 + (row * 40)
        page0_values = list(playtester.monitor.mem_get(page0_addr, 40))
        page1_values = list(playtester.monitor.mem_get(page1_addr, 40))
        diff_cols = [col for col, (left, right) in enumerate(zip(page0_values, page1_values)) if left != right]
        row_diff = {
            "row": row,
            "page0_addr": page0_addr,
            "page1_addr": page1_addr,
            "page0_values": page0_values,
            "page1_values": page1_values,
            "page0_hex": format_hex_bytes(page0_values),
            "page1_hex": format_hex_bytes(page1_values),
            "diff_cols": diff_cols,
            "diff_ranges": diff_ranges(diff_cols),
            "diff_count": len(diff_cols),
        }
        row_diffs.append(row_diff)
        total_diff_cells += len(diff_cols)
        if diff_cols:
            rows_with_diff.append(row)

    return {
        "enabled": True,
        "rows": rows,
        "row_diffs": row_diffs,
        "rows_with_diff": rows_with_diff,
        "any_diff": total_diff_cells > 0,
        "total_diff_cells": total_diff_cells,
        "active_screen_is_alt": read_symbol_u8(playtester, "active_screen_is_alt"),
        "screen_flip_pending": read_symbol_u8(playtester, "screen_flip_pending"),
        "formation_render_page_is_alt": read_symbol_u8(playtester, "formation_render_page_is_alt"),
        "memory_setup": read_symbol_u8(playtester, "MEMORY_SETUP"),
    }


def capture_latched_review_sample(
    playtester: Playtester,
    remote_monitor: RemoteTextMonitor,
    stage: str,
    clear_strategy: str,
    clear_strategy_value: int,
    start_time: float,
    frames_dir: Path,
    screenshot_format: int,
    top_page_rows: Optional[list[int]],
    capture_latched: bool,
    previous_sample: Optional[dict],
) -> dict:
    sample = playtester.capture_sample(stage, include_joystick=False)
    screenshot_path = frames_dir / f"{sample['index']:03d}-{stage}.png"
    if sample.get("screenshot") is None:
        remote_monitor.screenshot(screenshot_path, format_id=screenshot_format)
        sample["screenshot"] = str(screenshot_path)
        sample["screenshot_sha256"] = screenshot_sha256(screenshot_path)
        sample["capture_mode"] = "vice_monitor"
    formation_dir = read_symbol_u8(playtester, "formation_dir")
    formation_frame = read_symbol_u8(playtester, "formation_frame")
    if (
        previous_sample is None
        or previous_sample.get("frame_capture_counter") is None
        or sample.get("frame_capture_counter") is None
    ):
        frame_advance = 0
    else:
        frame_advance = (
            sample["frame_capture_counter"] - previous_sample["frame_capture_counter"]
        ) & 0xFF
    sample.update(
        {
            "clear_strategy": clear_strategy,
            "clear_strategy_value": clear_strategy_value,
            "force_zero_scroll": read_symbol_u8(playtester, "formation_force_zero_scroll_debug"),
            "formation_frame": formation_frame,
            "formation_dir": formation_dir,
            "formation_dir_name": None if formation_dir is None else ("left" if formation_dir & 0x80 else "right"),
            "formation_anchor_col": read_symbol_u8(playtester, "formation_anchor_col"),
            "formation_render_anchor_col": read_symbol_u8(playtester, "formation_render_anchor_col"),
            "formation_render_scroll_phase": read_symbol_u8(playtester, "formation_render_scroll_phase"),
            "formation_render_dirty": read_symbol_u8(playtester, "formation_render_dirty"),
            "formation_full_redraw_pending": read_symbol_u8(playtester, "formation_full_redraw_pending"),
            "active_screen_is_alt": read_symbol_u8(playtester, "active_screen_is_alt"),
            "screen_flip_pending": read_symbol_u8(playtester, "screen_flip_pending"),
            "formation_render_page_is_alt": read_symbol_u8(playtester, "formation_render_page_is_alt"),
            "memory_setup": read_symbol_u8(playtester, "MEMORY_SETUP"),
            "leftmost_x": playtester.leftmost_formation_x(sample),
            "rightmost_x": rightmost_formation_x(playtester, sample),
            "elapsed_seconds": round(time.time() - start_time, 4),
            "capture_latched": capture_latched,
            "frame_advance": frame_advance,
        }
    )
    if top_page_rows:
        sample["top_page_row_debug"] = capture_top_page_row_debug(playtester, top_page_rows)
    return sample


def capture_review_sample(
    playtester: Playtester,
    remote_monitor: RemoteTextMonitor,
    stage: str,
    clear_strategy: str,
    clear_strategy_value: int,
    start_time: float,
    frames_dir: Path,
    screenshot_format: int,
    top_page_rows: Optional[list[int]],
    previous_sample: Optional[dict],
) -> dict:
    capture_latched = False
    try:
        if has_capture_latch(playtester):
            previous_frame_counter = read_symbol_u8(playtester, "frame_capture_counter")
            arm_capture_latch(playtester)
            wait_for_capture_latch(playtester, previous_frame_counter=previous_frame_counter)
            capture_latched = True
        else:
            playtester.wait_for_render_complete()

        return capture_latched_review_sample(
            playtester,
            remote_monitor,
            stage,
            clear_strategy,
            clear_strategy_value,
            start_time,
            frames_dir,
            screenshot_format,
            top_page_rows,
            capture_latched=capture_latched,
            previous_sample=previous_sample,
        )
    finally:
        if capture_latched:
            release_capture_latch(playtester)


def main() -> int:
    args = parse_args()
    output_dir = args.output_dir.resolve()
    frames_dir = output_dir / "frames"

    reset_output_dir(output_dir)
    frames_dir.mkdir(parents=True, exist_ok=True)

    args.log = output_dir / "capture.log"
    args.json = output_dir / "records.json"
    args.vice_log = output_dir / "vice.log"
    args.frames_dir = frames_dir
    args.keymap = output_dir / "capture.vkm"
    args.exit_screenshot = output_dir / "exit.png"
    args.capture_host_screenshots = args.host_screenshots

    logger = Logger(args.log)
    playtester = Playtester(args, logger)
    remote_monitor = RemoteTextMonitor(args.remote_monitor_address)
    records = {
        "success": False,
        "failure": None,
        "stage": args.stage,
        "duration_seconds": args.duration_seconds,
        "sample_interval": args.sample_interval,
        "frame_count_target": args.frame_count,
        "clear_strategy": args.clear_strategy,
        "force_zero_scroll": args.force_zero_scroll,
        "artifacts": {
            "dir": str(output_dir),
            "frames_dir": str(frames_dir),
            "log": str(args.log),
            "vice_log": str(args.vice_log),
            "exit_screenshot": str(args.exit_screenshot),
            "keymap": str(args.keymap),
            "capture_mode": None if args.host_screenshots else "vice_monitor",
            "capture_modes_seen": [] if args.host_screenshots else ["vice_monitor"],
        },
        "samples": [],
    }

    try:
        playtester.launch_vice()
        remote_monitor.connect()
        stage_sample = wait_for_stage(playtester, args.stage)
        top_page_rows = None
        if args.log_top_page_rows:
            top_page_rows = parse_top_page_rows(args.top_page_rows)
            if top_page_rows is None:
                top_page_rows = default_top_page_rows(playtester)
        clear_strategy_value = apply_clear_strategy(playtester, args.clear_strategy)
        force_zero_scroll_value = apply_force_zero_scroll(playtester, args.force_zero_scroll)
        logger.log(
            f"Capturing {args.stage} review for {args.duration_seconds:.2f}s with {args.clear_strategy} via VICE screenshots"
        )
        if force_zero_scroll_value:
            logger.log("Enabled formation_force_zero_scroll_debug")
        if top_page_rows:
            logger.log(f"Logging page0/page1 screen bytes for rows: {top_page_rows}")

        if args.stage == "ready":
            hold_ready_state(playtester)

        start_time = time.time()
        if args.frame_count is not None:
            if args.frame_count <= 0:
                raise PlaytestFailure(f"frame_count must be positive: {args.frame_count}")
            if not has_capture_latch(playtester):
                raise PlaytestFailure("frame_count capture requires frame_capture_latch support in the build")

            logger.log(
                f"Capturing {args.frame_count} consecutive frames at {args.stage} with {args.clear_strategy}"
            )
            previous_sample = None
            previous_frame_counter = read_symbol_u8(playtester, "frame_capture_counter")
            arm_capture_latch(playtester)
            latch_armed = True
            try:
                for index in range(args.frame_count):
                    if args.stage == "ready":
                        hold_ready_state(playtester)
                    wait_for_capture_latch(playtester, previous_frame_counter=previous_frame_counter)
                    sample = capture_latched_review_sample(
                        playtester,
                        remote_monitor,
                        args.stage,
                        args.clear_strategy,
                        clear_strategy_value,
                        start_time,
                        frames_dir,
                        args.screenshot_format,
                        top_page_rows,
                        capture_latched=True,
                        previous_sample=previous_sample,
                    )
                    records["samples"].append(sample)
                    previous_sample = sample
                    previous_frame_counter = sample.get("frame_capture_counter")
                    if index + 1 < args.frame_count:
                        if args.frame_hold_seconds > 0:
                            time.sleep(args.frame_hold_seconds)
                        step_capture_latch(playtester)
                    else:
                        release_capture_latch(playtester)
                        latch_armed = False
            finally:
                if latch_armed:
                    release_capture_latch(playtester)
        else:
            previous_sample = capture_review_sample(
                playtester,
                remote_monitor,
                args.stage,
                args.clear_strategy,
                clear_strategy_value,
                start_time,
                frames_dir,
                args.screenshot_format,
                top_page_rows,
                previous_sample=None,
            )
            records["samples"].append(previous_sample)

            deadline = start_time + args.duration_seconds
            while time.time() < deadline:
                if args.stage == "ready":
                    hold_ready_state(playtester)
                remaining = deadline - time.time()
                sleep_seconds = min(args.sample_interval, remaining)
                if sleep_seconds > 0:
                    playtester.resume_for(sleep_seconds)
                if args.stage == "ready":
                    hold_ready_state(playtester)
                previous_sample = capture_review_sample(
                    playtester,
                    remote_monitor,
                    args.stage,
                    args.clear_strategy,
                    clear_strategy_value,
                    start_time,
                    frames_dir,
                    args.screenshot_format,
                    top_page_rows,
                    previous_sample=previous_sample,
                )
                records["samples"].append(previous_sample)

        records["success"] = True
        records["stage_sample"] = stage_sample
        if args.host_screenshots:
            records["artifacts"]["capture_mode"] = playtester.results["artifacts"]["capture_mode"]
            records["artifacts"]["capture_modes_seen"] = playtester.results["artifacts"]["capture_modes_seen"]
    except Exception as exc:
        records["failure"] = str(exc)
        if playtester.samples:
            records["last_sample"] = playtester.samples[-1]
    finally:
        remote_monitor.close()
        try:
            playtester.shutdown()
        except Exception:
            pass
        logger.close()

    all_frame_advances_are_one = all(
        sample.get("frame_advance") == 1 for sample in records["samples"][1:]
    )
    first_frame_counter = records["samples"][0].get("frame_capture_counter") if records["samples"] else None
    last_frame_counter = records["samples"][-1].get("frame_capture_counter") if records["samples"] else None

    summary = {
        "success": records["success"],
        "failure": records["failure"],
        "frame_count": len(records["samples"]),
        "frame_count_target": args.frame_count,
        "first_frame": records["samples"][0]["screenshot"] if records["samples"] else None,
        "last_frame": records["samples"][-1]["screenshot"] if records["samples"] else None,
        "start_elapsed": records["samples"][0]["elapsed_seconds"] if records["samples"] else None,
        "end_elapsed": records["samples"][-1]["elapsed_seconds"] if records["samples"] else None,
        "stage": args.stage,
        "clear_strategy": args.clear_strategy,
        "force_zero_scroll": args.force_zero_scroll,
        "capture_mode": records["artifacts"]["capture_mode"],
        "capture_modes_seen": records["artifacts"]["capture_modes_seen"],
        "all_frame_advances_are_one": all_frame_advances_are_one,
        "first_frame_counter": first_frame_counter,
        "last_frame_counter": last_frame_counter,
        "frame_counter_span": None
        if first_frame_counter is None or last_frame_counter is None
        else ((last_frame_counter - first_frame_counter) & 0xFF),
    }
    if args.log_top_page_rows:
        samples_with_top_page_row_diff = [
            sample["index"]
            for sample in records["samples"]
            if sample.get("top_page_row_debug", {}).get("any_diff")
        ]
        summary["top_page_rows"] = (
            records["samples"][0].get("top_page_row_debug", {}).get("rows") if records["samples"] else None
        )
        summary["samples_with_top_page_row_diff"] = samples_with_top_page_row_diff
        summary["top_page_row_diff_sample_count"] = len(samples_with_top_page_row_diff)

    records["artifacts"]["exit_screenshot_exists"] = args.exit_screenshot.exists()
    args.json.write_text(json.dumps(records, indent=2), encoding="utf-8")
    (output_dir / "summary.json").write_text(json.dumps(summary, indent=2), encoding="utf-8")
    return 0 if records["success"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
