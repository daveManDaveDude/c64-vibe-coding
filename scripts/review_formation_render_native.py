#!/usr/bin/env python3
import argparse
import hashlib
import json
import shutil
import socket
import time
from pathlib import Path

from playtest_asm import Logger, PlaytestFailure, Playtester


CLEAR_STRATEGIES = {
    "edge_global": "FORMATION_CLEAR_STRATEGY_EDGE_GLOBAL",
    "rowwise": "FORMATION_CLEAR_STRATEGY_ROWWISE",
}


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
    parser.add_argument("--clear-strategy", choices=tuple(CLEAR_STRATEGIES), default="rowwise")
    parser.add_argument("--process-name", default="x64sc")
    parser.add_argument("--window-x", type=int, default=80)
    parser.add_argument("--window-y", type=int, default=80)
    parser.add_argument("--window-width", type=int, default=768)
    parser.add_argument("--window-height", type=int, default=638)
    parser.add_argument("--remote-monitor-address", default="ip4://127.0.0.1:6510")
    parser.add_argument("--screenshot-format", type=int, default=2)
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
    playtester.monitor.mem_set(playtester.symbols["frame_capture_latch_arm"], b"\x01")


def wait_for_capture_latch(playtester: Playtester) -> None:
    for _ in range(200):
        if read_symbol_u8(playtester, "frame_capture_latch_ready") == 1:
            return
        playtester.resume_for(0.01)
    raise PlaytestFailure("Timed out waiting for frame_capture_latch_ready")


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


def capture_review_sample(
    playtester: Playtester,
    remote_monitor: RemoteTextMonitor,
    stage: str,
    clear_strategy: str,
    clear_strategy_value: int,
    start_time: float,
    frames_dir: Path,
    screenshot_format: int,
) -> dict:
    capture_latched = False
    try:
        if has_capture_latch(playtester):
            arm_capture_latch(playtester)
            wait_for_capture_latch(playtester)
            capture_latched = True
        else:
            playtester.wait_for_render_complete()

        sample = playtester.capture_sample(stage, include_joystick=False)
        screenshot_path = frames_dir / f"{sample['index']:03d}-{stage}.png"
        remote_monitor.screenshot(screenshot_path, format_id=screenshot_format)
        formation_dir = read_symbol_u8(playtester, "formation_dir")
        formation_frame = read_symbol_u8(playtester, "formation_frame")
        sample.update(
            {
                "clear_strategy": clear_strategy,
                "clear_strategy_value": clear_strategy_value,
                "formation_frame": formation_frame,
                "formation_dir": formation_dir,
                "formation_dir_name": None if formation_dir is None else ("left" if formation_dir & 0x80 else "right"),
                "formation_anchor_col": read_symbol_u8(playtester, "formation_anchor_col"),
                "formation_render_anchor_col": read_symbol_u8(playtester, "formation_render_anchor_col"),
                "formation_render_scroll_phase": read_symbol_u8(playtester, "formation_render_scroll_phase"),
                "formation_render_dirty": read_symbol_u8(playtester, "formation_render_dirty"),
                "formation_full_redraw_pending": read_symbol_u8(playtester, "formation_full_redraw_pending"),
                "leftmost_x": playtester.leftmost_formation_x(sample),
                "rightmost_x": rightmost_formation_x(playtester, sample),
                "elapsed_seconds": round(time.time() - start_time, 4),
                "screenshot": str(screenshot_path),
                "screenshot_sha256": screenshot_sha256(screenshot_path),
                "capture_mode": "vice_monitor",
                "capture_latched": capture_latched,
            }
        )
        return sample
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
    args.capture_host_screenshots = False

    logger = Logger(args.log)
    playtester = Playtester(args, logger)
    remote_monitor = RemoteTextMonitor(args.remote_monitor_address)
    records = {
        "success": False,
        "failure": None,
        "stage": args.stage,
        "duration_seconds": args.duration_seconds,
        "sample_interval": args.sample_interval,
        "clear_strategy": args.clear_strategy,
        "artifacts": {
            "dir": str(output_dir),
            "frames_dir": str(frames_dir),
            "log": str(args.log),
            "vice_log": str(args.vice_log),
            "exit_screenshot": str(args.exit_screenshot),
            "keymap": str(args.keymap),
            "capture_mode": "vice_monitor",
            "capture_modes_seen": ["vice_monitor"],
        },
        "samples": [],
    }

    try:
        playtester.launch_vice()
        remote_monitor.connect()
        stage_sample = wait_for_stage(playtester, args.stage)
        clear_strategy_value = apply_clear_strategy(playtester, args.clear_strategy)
        logger.log(
            f"Capturing {args.stage} review for {args.duration_seconds:.2f}s with {args.clear_strategy} via VICE screenshots"
        )

        if args.stage == "ready":
            hold_ready_state(playtester)

        start_time = time.time()
        records["samples"].append(
            capture_review_sample(
                playtester,
                remote_monitor,
                args.stage,
                args.clear_strategy,
                clear_strategy_value,
                start_time,
                frames_dir,
                args.screenshot_format,
            )
        )

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
            records["samples"].append(
                capture_review_sample(
                    playtester,
                    remote_monitor,
                    args.stage,
                    args.clear_strategy,
                    clear_strategy_value,
                    start_time,
                    frames_dir,
                    args.screenshot_format,
                )
            )

        records["success"] = True
        records["stage_sample"] = stage_sample
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

    summary = {
        "success": records["success"],
        "failure": records["failure"],
        "frame_count": len(records["samples"]),
        "first_frame": records["samples"][0]["screenshot"] if records["samples"] else None,
        "last_frame": records["samples"][-1]["screenshot"] if records["samples"] else None,
        "start_elapsed": records["samples"][0]["elapsed_seconds"] if records["samples"] else None,
        "end_elapsed": records["samples"][-1]["elapsed_seconds"] if records["samples"] else None,
        "stage": args.stage,
        "clear_strategy": args.clear_strategy,
        "capture_mode": records["artifacts"]["capture_mode"],
        "capture_modes_seen": records["artifacts"]["capture_modes_seen"],
    }

    records["artifacts"]["exit_screenshot_exists"] = args.exit_screenshot.exists()
    args.json.write_text(json.dumps(records, indent=2), encoding="utf-8")
    (output_dir / "summary.json").write_text(json.dumps(summary, indent=2), encoding="utf-8")
    return 0 if records["success"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
