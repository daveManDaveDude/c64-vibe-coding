#!/usr/bin/env python3
import argparse
import json
import re
import socket
import struct
import subprocess
import sys
import time
from pathlib import Path


API_VERSION = 0x02
MEM_GET = 0x01
MEM_SET = 0x02
VICE_INFO = 0x85
EXIT_MONITOR = 0xAA
QUIT_VICE = 0xBB
EVENT_REQUEST_ID = 0xFFFFFFFF
MAIN_MEMSPACE = 0x00
DEFAULT_MONITOR_ADDRESS = ("127.0.0.1", 6502)


class PlaytestFailure(Exception):
    pass


class Logger:
    def __init__(self, path: Path):
        self.path = path
        self.path.parent.mkdir(parents=True, exist_ok=True)
        self.handle = self.path.open("w", encoding="utf-8")

    def log(self, message: str) -> None:
        line = f"[{time.strftime('%H:%M:%S')}] {message}"
        print(line)
        self.handle.write(line + "\n")
        self.handle.flush()

    def close(self) -> None:
        self.handle.close()


class BinaryMonitor:
    def __init__(self, sock: socket.socket, logger: Logger):
        self.sock = sock
        self.logger = logger
        self.request_id = 1

    def close(self) -> None:
        self.sock.close()

    def _recv_exact(self, size: int) -> bytes:
        data = bytearray()
        while len(data) < size:
            chunk = self.sock.recv(size - len(data))
            if not chunk:
                raise PlaytestFailure("VICE binary monitor connection closed unexpectedly")
            data.extend(chunk)
        return bytes(data)

    def _read_response(self):
        header = self._recv_exact(12)
        stx, version, body_len, response_type, error_code, request_id = struct.unpack(
            "<BBIBBI", header
        )
        if stx != 0x02:
            raise PlaytestFailure(f"Unexpected monitor STX byte: {stx:#04x}")
        if version != API_VERSION:
            raise PlaytestFailure(f"Unexpected monitor API version: {version}")
        body = self._recv_exact(body_len)
        return {
            "type": response_type,
            "error": error_code,
            "request_id": request_id,
            "body": body,
        }

    def send_command(self, command: int, body: bytes = b"") -> bytes:
        request_id = self.request_id
        self.request_id += 1
        packet = struct.pack("<BBIIB", 0x02, API_VERSION, len(body), request_id, command) + body
        self.sock.sendall(packet)

        while True:
            response = self._read_response()
            if response["request_id"] == EVENT_REQUEST_ID:
                continue
            if response["request_id"] != request_id:
                continue
            if response["type"] != command:
                raise PlaytestFailure(
                    f"Unexpected response type {response['type']:#04x} for command {command:#04x}"
                )
            if response["error"] != 0:
                raise PlaytestFailure(
                    f"VICE monitor error {response['error']:#04x} for command {command:#04x}"
                )
            return response["body"]

    def vice_info(self) -> bytes:
        return self.send_command(VICE_INFO)

    def mem_get(self, start: int, size: int) -> bytes:
        end = start + size - 1
        body = struct.pack("<BHHBH", 0x00, start, end, MAIN_MEMSPACE, 0x0000)
        response = self.send_command(MEM_GET, body)
        if len(response) < 2:
            raise PlaytestFailure("Memory get response too short")
        length = struct.unpack("<H", response[:2])[0]
        data = response[2:]
        if length != len(data):
            raise PlaytestFailure(
                f"Memory get length mismatch: declared {length}, received {len(data)}"
            )
        return data

    def mem_set(self, start: int, data: bytes) -> None:
        end = start + len(data) - 1
        body = struct.pack("<BHHBH", 0x00, start, end, MAIN_MEMSPACE, 0x0000) + data
        self.send_command(MEM_SET, body)

    def exit_monitor(self) -> None:
        self.send_command(EXIT_MONITOR)

    def quit_vice(self) -> None:
        try:
            self.send_command(QUIT_VICE)
        except Exception:
            pass


def parse_symbols(path: Path):
    label_pattern = re.compile(r"^\.label\s+([A-Za-z0-9_]+)=\$(?P<hex>[0-9a-fA-F]+)$")
    symbols = {}
    with path.open("r", encoding="utf-8") as handle:
        for line in handle:
            match = label_pattern.match(line.strip())
            if match:
                symbols[match.group(1)] = int(match.group("hex"), 16)
    return symbols


def require_symbols(symbols, names):
    missing = [name for name in names if name not in symbols]
    if missing:
        raise PlaytestFailure(f"Missing expected symbols: {', '.join(missing)}")


def combine_u16(low: int, high: int) -> int:
    return low | (high << 8)


def diff_u16(current: int, previous: int) -> int:
    return (current - previous) & 0xFFFF


class Playtester:
    def __init__(self, args, logger: Logger):
        self.args = args
        self.logger = logger
        self.results = {
            "success": False,
            "steps": [],
            "failures": [],
            "artifacts": {
                "log": str(args.log),
                "json": str(args.json),
                "vice_log": str(args.vice_log),
            },
        }
        self.vice_process = None
        self.monitor = None
        self.symbols = parse_symbols(args.sym)
        require_symbols(
            self.symbols,
            [
                "autoplay_input_bits",
                "autoplay_mode",
                "autoplay_status",
                "autoplay_stage",
                "autoplay_error_code",
                "autoplay_frame_counter",
                "player_x_lo",
                "player_x_hi",
                "alien_x_lo",
                "alien_x_hi",
                "alien_dir",
                "player_min_x_lo",
                "player_min_x_hi",
                "player_max_x_lo",
                "player_max_x_hi",
                "alien_min_x_lo",
                "alien_min_x_hi",
                "alien_max_x_lo",
                "alien_max_x_hi",
                "PLAYER_Y",
                "ALIEN_Y",
            ],
        )
        self.state_labels = [
            "alien_x_lo",
            "alien_x_hi",
            "alien_dir",
            "player_x_lo",
            "player_x_hi",
            "autoplay_input_bits",
            "autoplay_mode",
            "autoplay_status",
            "autoplay_stage",
            "autoplay_error_code",
            "autoplay_frame_counter",
        ]
        self.state_start = min(self.symbols[label] for label in self.state_labels)
        self.state_end = max(
            self.symbols["autoplay_frame_counter"] + 1,
            max(self.symbols[label] for label in self.state_labels),
        )
        self.last_sample = None

    def record_step(self, name: str, status: str, detail=None) -> None:
        entry = {"name": name, "status": status}
        if detail is not None:
            entry["detail"] = detail
        self.results["steps"].append(entry)

    def connect_monitor(self) -> BinaryMonitor:
        deadline = time.time() + 15.0
        last_error = None
        while time.time() < deadline:
            try:
                sock = socket.create_connection(DEFAULT_MONITOR_ADDRESS, timeout=1.0)
                sock.settimeout(2.0)
                return BinaryMonitor(sock, self.logger)
            except OSError as exc:
                last_error = exc
                time.sleep(0.1)
        message = f"Could not connect to VICE binary monitor: {last_error}"
        if isinstance(last_error, OSError) and last_error.errno == 1:
            message += " (sandboxed Codex runs may need escalated permissions for localhost monitor access)"
        raise PlaytestFailure(message)

    def launch_vice(self) -> None:
        command = [
            str(self.args.runner),
            str(self.args.prg),
            str(self.args.vice_log),
            "ip4://127.0.0.1:6502",
        ]
        self.logger.log(f"Launching VICE monitor runner: {' '.join(command)}")
        self.vice_process = subprocess.Popen(
            command,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        self.monitor = self.connect_monitor()
        self.monitor.vice_info()
        self.record_step("monitor_connect", "passed")

    def shutdown(self) -> None:
        if self.monitor is not None:
            self.monitor.quit_vice()
            self.monitor.close()
            self.monitor = None
        if self.vice_process is not None:
            try:
                self.vice_process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                self.vice_process.terminate()
                try:
                    self.vice_process.wait(timeout=5)
                except subprocess.TimeoutExpired:
                    self.vice_process.kill()
                    self.vice_process.wait(timeout=5)

    def read_state(self):
        start = self.state_start
        size = (self.state_end - start) + 1
        data = self.monitor.mem_get(start, size)

        def byte_at(label):
            return data[self.symbols[label] - start]

        state = {
            "frame": combine_u16(
                byte_at("autoplay_frame_counter"),
                data[self.symbols["autoplay_frame_counter"] - start + 1],
            ),
            "player_x": combine_u16(byte_at("player_x_lo"), byte_at("player_x_hi")),
            "alien_x": combine_u16(byte_at("alien_x_lo"), byte_at("alien_x_hi")),
            "alien_dir": byte_at("alien_dir"),
            "autoplay_mode": byte_at("autoplay_mode"),
            "autoplay_status": byte_at("autoplay_status"),
            "autoplay_stage": byte_at("autoplay_stage"),
            "autoplay_error_code": byte_at("autoplay_error_code"),
            "player_y": self.symbols["PLAYER_Y"],
            "alien_y": self.symbols["ALIEN_Y"],
            "player_min": combine_u16(
                self.symbols["player_min_x_lo"], self.symbols["player_min_x_hi"]
            ),
            "player_max": combine_u16(
                self.symbols["player_max_x_lo"], self.symbols["player_max_x_hi"]
            ),
            "alien_min": combine_u16(
                self.symbols["alien_min_x_lo"], self.symbols["alien_min_x_hi"]
            ),
            "alien_max": combine_u16(
                self.symbols["alien_max_x_lo"], self.symbols["alien_max_x_hi"]
            ),
        }
        self.last_sample = state
        return state

    def set_input_bits(self, value: int) -> None:
        self.monitor.mem_set(self.symbols["autoplay_input_bits"], bytes([value & 0xFF]))

    def set_autoplay_mode(self, value: int) -> None:
        self.monitor.mem_set(self.symbols["autoplay_mode"], bytes([value & 0xFF]))

    def wait_for_frame_delta(self, minimum_delta: int, max_polls: int = 200):
        start_state = self.read_state()
        start_frame = start_state["frame"]
        for _ in range(max_polls):
            self.monitor.exit_monitor()
            time.sleep(0.01)
            state = self.read_state()
            if diff_u16(state["frame"], start_frame) >= minimum_delta:
                return state
        raise PlaytestFailure(
            f"Timed out waiting for frame counter to advance by {minimum_delta} frames"
        )

    def wait_with_long_resume(self, minimum_delta: int, sleep_seconds: float):
        start_state = self.read_state()
        start_frame = start_state["frame"]
        latest_state = start_state
        while diff_u16(latest_state["frame"], start_frame) < minimum_delta:
            self.monitor.exit_monitor()
            time.sleep(sleep_seconds)
            latest_state = self.read_state()
        return latest_state

    def assert_true(self, name: str, condition: bool, detail):
        if not condition:
            raise PlaytestFailure(f"{name}: {detail}")

    def run_until(self, stage_name: str, predicate, timeout_frames: int, poll_frames: int = 15):
        initial_state = self.read_state()
        start_frame = initial_state["frame"]
        latest_state = initial_state
        while diff_u16(latest_state["frame"], start_frame) <= timeout_frames:
            if predicate(latest_state):
                return latest_state
            latest_state = self.wait_for_frame_delta(poll_frames)
        raise PlaytestFailure(
            f"{stage_name}: timeout after {timeout_frames} frames at state {latest_state}"
        )

    def run(self):
        self.launch_vice()

        self.logger.log("Waiting for autoplay frame counter to start advancing")
        self.wait_for_frame_delta(2)
        self.record_step("frame_counter_started", "passed")

        if self.args.mode == "internal":
            return self.run_internal_scripted_test()

        initial = self.read_state()
        self.assert_true(
            "initial_player_bounds",
            initial["player_min"] <= initial["player_x"] <= initial["player_max"],
            initial,
        )
        self.assert_true(
            "initial_alien_bounds",
            initial["alien_min"] <= initial["alien_x"] <= initial["alien_max"],
            initial,
        )
        self.assert_true(
            "initial_layout",
            initial["player_y"] > initial["alien_y"] and initial["player_y"] >= 200 and initial["alien_y"] <= 80,
            initial,
        )
        self.record_step("initial_state", "passed", initial)

        self.logger.log("Driving player left to the clamp")
        self.set_input_bits(0x01)
        left_min_seen = initial["player_x"]
        left_state = self.run_until(
            "player_left_clamp",
            lambda state: state["player_x"] == state["player_min"],
            timeout_frames=2000,
        )
        left_min_seen = min(left_min_seen, left_state["player_x"])
        self.assert_true(
            "left_clamp_exact",
            left_state["player_x"] == left_state["player_min"],
            left_state,
        )
        self.assert_true(
            "left_clamp_bounds",
            left_min_seen >= left_state["player_min"],
            left_state,
        )
        self.record_step("left_clamp", "passed", left_state)

        self.logger.log("Checking idle stability")
        self.set_input_bits(0x00)
        idle_start = self.read_state()
        idle_end = self.wait_for_frame_delta(30, max_polls=200)
        self.assert_true(
            "idle_no_drift",
            idle_end["player_x"] == idle_start["player_x"],
            {"before": idle_start, "after": idle_end},
        )
        self.record_step("idle_stability", "passed", {"before": idle_start, "after": idle_end})

        self.logger.log("Driving player right to the clamp")
        self.set_input_bits(0x02)
        right_state = self.run_until(
            "player_right_clamp",
            lambda state: state["player_x"] == state["player_max"],
            timeout_frames=2000,
        )
        self.assert_true(
            "right_clamp_exact",
            right_state["player_x"] == right_state["player_max"],
            right_state,
        )
        self.assert_true(
            "right_clamp_bounds",
            right_state["player_x"] <= right_state["player_max"],
            right_state,
        )
        self.record_step("right_clamp", "passed", right_state)

        self.logger.log("Observing alien motion and bounce")
        self.set_input_bits(0x00)
        alien_start = self.read_state()
        alien_initial_dir = alien_start["alien_dir"]
        alien_positions = {alien_start["alien_x"]}
        alien_flipped = False
        start_frame = alien_start["frame"]
        alien_state = alien_start
        while diff_u16(alien_state["frame"], start_frame) <= 2000:
            alien_state = self.wait_for_frame_delta(15, max_polls=200)
            alien_positions.add(alien_state["alien_x"])
            if alien_state["alien_dir"] != alien_initial_dir:
                alien_flipped = True
            self.assert_true(
                "alien_bounds",
                alien_state["alien_min"] <= alien_state["alien_x"] <= alien_state["alien_max"],
                alien_state,
            )
            if alien_flipped and len(alien_positions) > 1:
                break
        self.assert_true(
            "alien_moves",
            len(alien_positions) > 1,
            {"start": alien_start, "end": alien_state},
        )
        self.assert_true(
            "alien_flips_direction",
            alien_flipped,
            {"start": alien_start, "end": alien_state},
        )
        self.record_step(
            "alien_motion",
            "passed",
            {
                "start": alien_start,
                "end": alien_state,
                "positions_seen": sorted(alien_positions),
            },
        )

        self.results["success"] = True
        self.results["final_state"] = alien_state

    def run_internal_scripted_test(self):
        initial = self.read_state()
        self.assert_true(
            "initial_layout",
            initial["player_y"] > initial["alien_y"] and initial["player_y"] >= 200 and initial["alien_y"] <= 80,
            initial,
        )
        self.assert_true(
            "initial_player_bounds",
            initial["player_min"] <= initial["player_x"] <= initial["player_max"],
            initial,
        )
        self.assert_true(
            "initial_alien_bounds",
            initial["alien_min"] <= initial["alien_x"] <= initial["alien_max"],
            initial,
        )
        self.record_step("initial_state", "passed", initial)

        self.logger.log("Starting internal autoplay script")
        self.set_input_bits(0x00)
        self.set_autoplay_mode(0x01)

        start_state = self.read_state()
        latest_state = start_state
        start_frame = start_state["frame"]
        while diff_u16(latest_state["frame"], start_frame) <= 2500:
            latest_state = self.wait_with_long_resume(120, 2.5)
            if latest_state["autoplay_status"] == 0x01:
                self.record_step("internal_autoplay", "passed", latest_state)
                self.results["success"] = True
                self.results["final_state"] = latest_state
                return
            if latest_state["autoplay_status"] == 0x80:
                raise PlaytestFailure(
                    f"internal_autoplay_failed: error_code={latest_state['autoplay_error_code']} state={latest_state}"
                )

        raise PlaytestFailure(
            f"internal_autoplay_timeout: state={latest_state}"
        )


def write_json(path: Path, payload) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8") as handle:
        json.dump(payload, handle, indent=2, sort_keys=True)
        handle.write("\n")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--prg", type=Path, required=True)
    parser.add_argument("--sym", type=Path, required=True)
    parser.add_argument("--log", type=Path, required=True)
    parser.add_argument("--json", type=Path, required=True)
    parser.add_argument("--vice-log", type=Path, required=True)
    parser.add_argument(
        "--runner",
        type=Path,
        default=Path("scripts/run_vice_binary_monitor.sh"),
    )
    parser.add_argument(
        "--mode",
        choices=("external", "internal"),
        default="external",
    )
    args = parser.parse_args()

    logger = Logger(args.log)
    playtester = Playtester(args, logger)

    exit_code = 0
    try:
        playtester.run()
        logger.log("Autoplay smoke test passed")
    except Exception as exc:
        exit_code = 1
        logger.log(f"Autoplay smoke test failed: {exc}")
        playtester.results["success"] = False
        playtester.results["failures"].append(
            {
                "error": str(exc),
                "last_sample": playtester.last_sample,
            }
        )
    finally:
        try:
            playtester.shutdown()
        finally:
            write_json(args.json, playtester.results)
            logger.close()

    sys.exit(exit_code)


if __name__ == "__main__":
    main()
