#!/usr/bin/env python3
import argparse
import ctypes
import ctypes.util
import hashlib
import json
import shutil
import socket
import struct
import subprocess
import sys
import time
from pathlib import Path
from typing import Optional


API_VERSION = 0x02
MEM_GET = 0x01
VICE_INFO = 0x85
EXIT_MONITOR = 0xAA
QUIT_VICE = 0xBB
EVENT_REQUEST_ID = 0xFFFFFFFF
MAIN_MEMSPACE = 0x00
DEFAULT_MONITOR_ADDRESS = ("127.0.0.1", 6502)

SPRITE0_X = 0xD000
SPRITE0_Y = 0xD001
SPRITE1_X = 0xD002
SPRITE1_Y = 0xD003
SPRITE2_X = 0xD004
SPRITE2_Y = 0xD005
SPRITE3_X = 0xD006
SPRITE3_Y = 0xD007
SPRITE4_X = 0xD008
SPRITE4_Y = 0xD009
SPRITE5_X = 0xD00A
SPRITE5_Y = 0xD00B
SPRITE6_X = 0xD00C
SPRITE6_Y = 0xD00D
SPRITE7_X = 0xD00E
SPRITE7_Y = 0xD00F
SPRITE_X_MSB = 0xD010
SPRITE_ENABLE = 0xD015
JOYSTICK_PORT_2 = 0xDC00

LEFT_KEY_CODE = 123
RIGHT_KEY_CODE = 124
FIRE_KEY_CODE = 49
LEFT_MASK = 0x04
RIGHT_MASK = 0x08
FIRE_MASK = 0x10
SHOT_SPRITE_MASK = 0x04
INITIAL_FORMATION_ALIVE_COUNT = 6
FORMATION_RENDERER_SPRITE = 0
FORMATION_RENDERER_NAMES = {
    0: "sprite",
    1: "char",
}


class PlaytestFailure(Exception):
    pass


def load_symbols(path: Path) -> dict[str, int]:
    if not path.exists():
        return {}

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
    def __init__(self, sock: socket.socket):
        self.sock = sock
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

    def exit_monitor(self) -> None:
        self.send_command(EXIT_MONITOR)

    def quit_vice(self) -> None:
        try:
            self.send_command(QUIT_VICE)
        except Exception:
            pass


def combine_sprite_x(low: int, msb_register: int, bit_index: int) -> int:
    return low | (((msb_register >> bit_index) & 0x01) << 8)


def describe_renderer_mode(mode: Optional[int]) -> Optional[str]:
    if mode is None:
        return None
    return FORMATION_RENDERER_NAMES.get(mode, f"unknown-{mode}")


class MacOSGui:
    def __init__(self, process_name: str, logger: Logger, capture_region: str):
        self.process_name = process_name
        self.logger = logger
        self.capture_region = capture_region
        self.pid = None
        self.app_services = None
        self.core_foundation = None
        self.keyboard_backend = "osascript"
        self._init_keyboard_backend()

    def set_pid(self, pid: int) -> None:
        self.pid = pid

    def _init_keyboard_backend(self) -> None:
        app_services_path = ctypes.util.find_library("ApplicationServices")
        core_foundation_path = ctypes.util.find_library("CoreFoundation")
        if not app_services_path or not core_foundation_path:
            self.logger.log("CoreGraphics keyboard events unavailable, falling back to osascript")
            return

        self.app_services = ctypes.CDLL(app_services_path)
        self.core_foundation = ctypes.CDLL(core_foundation_path)
        self.app_services.CGEventCreateKeyboardEvent.argtypes = [
            ctypes.c_void_p,
            ctypes.c_uint16,
            ctypes.c_bool,
        ]
        self.app_services.CGEventCreateKeyboardEvent.restype = ctypes.c_void_p
        self.app_services.CGEventPostToPid.argtypes = [ctypes.c_int, ctypes.c_void_p]
        self.app_services.CGEventPostToPid.restype = None
        self.core_foundation.CFRelease.argtypes = [ctypes.c_void_p]
        self.core_foundation.CFRelease.restype = None
        self.keyboard_backend = "coregraphics_pid"

    def _run_osascript(self, lines):
        command = ["osascript"]
        for line in lines:
            command.extend(["-e", line])
        try:
            result = subprocess.run(
                command,
                check=True,
                capture_output=True,
                text=True,
            )
        except subprocess.CalledProcessError as exc:
            stderr = exc.stderr.strip()
            if "Not authorized" in stderr or "not allowed" in stderr.lower():
                raise PlaytestFailure(
                    "macOS denied GUI automation. Grant Accessibility access to the terminal or VS Code for System Events."
                ) from exc
            raise PlaytestFailure(f"osascript failed: {stderr or exc.stdout.strip()}") from exc
        return result.stdout.strip()

    def wait_for_process(self, timeout_seconds: float = 15.0):
        deadline = time.time() + timeout_seconds
        while time.time() < deadline:
            if self.pid is None:
                output = self._run_osascript(
                    [
                        'tell application "System Events"',
                        f'  if exists application process "{self.process_name}" then return "ready"',
                        "end tell",
                    ]
                )
            else:
                output = self._run_osascript(
                    [
                        'tell application "System Events"',
                        f'  set matchingProcesses to every application process whose unix id is {self.pid}',
                        '  if (count of matchingProcesses) > 0 then return "ready"',
                        "end tell",
                    ]
                )
            if output == "ready":
                return
            time.sleep(0.1)
        raise PlaytestFailure(f"Timed out waiting for {self.process_name} process")

    def activate(self) -> None:
        if self.pid is None:
            lines = [
                'tell application "System Events"',
                f'  tell application process "{self.process_name}"',
                "    set frontmost to true",
                '    try',
                '      perform action "AXRaise" of window 1',
                "    end try",
                "  end tell",
                "end tell",
            ]
        else:
            lines = [
                'tell application "System Events"',
                f'  set matchingProcesses to every application process whose unix id is {self.pid}',
                '  if (count of matchingProcesses) is 0 then error "VICE process not found"',
                "  tell item 1 of matchingProcesses",
                "    set frontmost to true",
                '    try',
                '      perform action "AXRaise" of window 1',
                "    end try",
                "  end tell",
                "end tell",
            ]
        self._run_osascript(lines)

    def key_down(self, key_code: int) -> None:
        self._send_key_event(key_code, True)

    def key_up(self, key_code: int) -> None:
        try:
            self._send_key_event(key_code, False)
        except PlaytestFailure:
            self.logger.log(f"Ignoring failed key release for key code {key_code}")

    def _send_key_event(self, key_code: int, is_key_down: bool) -> None:
        if self.keyboard_backend == "coregraphics_pid":
            if self.pid is None:
                raise PlaytestFailure("VICE pid is not set for CoreGraphics keyboard events")
            event = self.app_services.CGEventCreateKeyboardEvent(None, key_code, is_key_down)
            if not event:
                raise PlaytestFailure(f"Could not create keyboard event for key code {key_code}")
            try:
                self.app_services.CGEventPostToPid(self.pid, event)
            finally:
                self.core_foundation.CFRelease(event)
            return

        direction = "down" if is_key_down else "up"
        self._run_osascript(
            [
                'tell application "System Events"',
                f"  key {direction} key code {key_code}",
                "end tell",
            ]
        )

    def capture_window(self, destination: Path) -> str:
        destination.parent.mkdir(parents=True, exist_ok=True)
        try:
            subprocess.run(
                ["screencapture", "-x", "-R", self.capture_region, str(destination)],
                check=True,
                capture_output=True,
                text=True,
            )
        except subprocess.CalledProcessError as exc:
            stderr = exc.stderr.strip()
            raise PlaytestFailure(
                "screencapture failed. Grant Screen Recording access to the terminal or VS Code."
                if stderr
                else "screencapture failed."
            ) from exc
        digest = hashlib.sha256(destination.read_bytes()).hexdigest()
        return digest


class Playtester:
    def __init__(self, args, logger: Logger):
        self.args = args
        self.logger = logger
        self.symbols = load_symbols(args.prg.with_suffix(".sym"))
        capture_region = f"{args.window_x},{args.window_y},{args.window_width},{args.window_height}"
        self.gui = MacOSGui(args.process_name, logger, capture_region)
        self.monitor = None
        self.vice_process = None
        self.sample_counter = 0
        self.samples = []
        self.host_capture_enabled = args.capture_host_screenshots
        self.host_capture_failure = None
        self.results = {
            "mode": "external_gui_keyboard",
            "success": False,
            "artifacts": {
                "log": str(args.log),
                "json": str(args.json),
                "vice_log": str(args.vice_log),
                "frames_dir": str(args.frames_dir),
                "keymap": str(args.keymap),
                "capture_region": capture_region,
                "exit_screenshot": str(args.exit_screenshot),
                "keyboard_backend": self.gui.keyboard_backend,
                "capture_host_screenshots": args.capture_host_screenshots,
            },
            "steps": [],
            "samples": self.samples,
        }

    def record_step(self, name: str, status: str, detail=None) -> None:
        entry = {"name": name, "status": status}
        if detail is not None:
            entry["detail"] = detail
        self.results["steps"].append(entry)

    def assert_true(self, name: str, condition: bool, detail) -> None:
        if not condition:
            raise PlaytestFailure(f"{name}: {detail}")

    def create_keymap(self) -> None:
        x64sc_path = shutil.which("x64sc")
        if x64sc_path is None:
            raise PlaytestFailure("Could not find x64sc on PATH")
        default_keymap = (
            Path(x64sc_path).resolve().parent.parent / "share" / "vice" / "C64" / "gtk3_sym.vkm"
        )
        if not default_keymap.exists():
            raise PlaytestFailure(f"Could not find default VICE keymap at {default_keymap}")

        keymap_contents = "\n".join(
            [
                f"!INCLUDE {default_keymap}",
                "!UNDEF Left",
                "!UNDEF Right",
                "!UNDEF space",
                "Left -1 4",
                "Right -1 5",
                "space -1 0",
                "",
            ]
        )
        self.args.keymap.parent.mkdir(parents=True, exist_ok=True)
        self.args.keymap.write_text(keymap_contents, encoding="utf-8")
        self.logger.log(f"Wrote playtest keymap: {self.args.keymap}")

    def connect_monitor(self) -> BinaryMonitor:
        deadline = time.time() + 15.0
        last_error = None
        while time.time() < deadline:
            try:
                sock = socket.create_connection(DEFAULT_MONITOR_ADDRESS, timeout=1.0)
                sock.settimeout(2.0)
                return BinaryMonitor(sock)
            except OSError as exc:
                last_error = exc
                time.sleep(0.1)
        message = f"Could not connect to VICE binary monitor: {last_error}"
        if isinstance(last_error, OSError) and last_error.errno == 1:
            message += " (sandboxed Codex runs may need escalated permissions for localhost monitor access)"
        raise PlaytestFailure(message)

    def launch_vice(self) -> None:
        self.create_keymap()
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
            "-windowxpos",
            str(self.args.window_x),
            "-windowypos",
            str(self.args.window_y),
            "-windowwidth",
            str(self.args.window_width),
            "-windowheight",
            str(self.args.window_height),
            "-controlport2device",
            "1",
            "-joydev2",
            "2",
            "-keyset",
            "-keymap",
            "2",
            "-symkeymap",
            str(self.args.keymap),
            "-exitscreenshot",
            str(self.args.exit_screenshot),
            "-logfile",
            str(self.args.vice_log),
            str(self.args.prg),
        ]
        self.logger.log(f"Launching visible VICE playtest: {' '.join(command)}")
        self.vice_process = subprocess.Popen(
            command,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        self.gui.set_pid(self.vice_process.pid)
        self.monitor = self.connect_monitor()
        self.monitor.vice_info()
        self.gui.wait_for_process()
        self.gui.activate()
        self.record_step("monitor_connect", "passed")

    def shutdown(self) -> None:
        self.gui.key_up(LEFT_KEY_CODE)
        self.gui.key_up(RIGHT_KEY_CODE)
        self.gui.key_up(FIRE_KEY_CODE)
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

    def resume_for(self, seconds: float) -> None:
        self.monitor.exit_monitor()
        time.sleep(seconds)

    def read_state(self, include_joystick: bool = True):
        vic_data = self.monitor.mem_get(SPRITE0_X, (SPRITE_ENABLE - SPRITE0_X) + 1)
        joystick_value = self.monitor.mem_get(JOYSTICK_PORT_2, 1)[0] if include_joystick else None
        alive_data = None
        if "formation_slot0_alive" in self.symbols:
            alive_data = self.monitor.mem_get(self.symbols["formation_slot0_alive"], INITIAL_FORMATION_ALIVE_COUNT)
        formation_renderer_mode = FORMATION_RENDERER_SPRITE
        if "formation_renderer_mode" in self.symbols:
            formation_renderer_mode = self.monitor.mem_get(self.symbols["formation_renderer_mode"], 1)[0]
        formation_position_data = None
        if "formation_slot0_x_lo" in self.symbols:
            formation_position_data = self.monitor.mem_get(self.symbols["formation_slot0_x_lo"], INITIAL_FORMATION_ALIVE_COUNT * 2)
        dive_active = False
        dive_slot = None
        if "dive_active" in self.symbols:
            dive_active = self.monitor.mem_get(self.symbols["dive_active"], 1)[0] != 0
        if "dive_slot" in self.symbols:
            dive_slot = self.monitor.mem_get(self.symbols["dive_slot"], 1)[0]
        shot_active = None
        if "shot_active" in self.symbols:
            shot_active = self.monitor.mem_get(self.symbols["shot_active"], 1)[0] != 0
        player_respawn_timer = None
        if "player_respawn_timer" in self.symbols:
            player_respawn_timer = self.monitor.mem_get(self.symbols["player_respawn_timer"], 1)[0]
        formation_char_render_mask = None
        if "formation_char_render_mask" in self.symbols:
            formation_char_render_mask = self.monitor.mem_get(self.symbols["formation_char_render_mask"], 1)[0]
        formation_shift_phase = None
        if "formation_shift_phase" in self.symbols:
            formation_shift_phase = self.monitor.mem_get(self.symbols["formation_shift_phase"], 1)[0]

        def vic(offset: int) -> int:
            return vic_data[offset - SPRITE0_X]

        def formation_slot_x(index: int) -> int:
            if formation_position_data is None:
                sprite_offsets = [SPRITE0_X, SPRITE3_X, SPRITE4_X, SPRITE5_X, SPRITE6_X, SPRITE7_X]
                sprite_bits = [0, 3, 4, 5, 6, 7]
                return combine_sprite_x(vic(sprite_offsets[index]), msb, sprite_bits[index])
            base = index * 2
            return formation_position_data[base] | (formation_position_data[base + 1] << 8)

        msb = vic(SPRITE_X_MSB)
        sprite_enable = vic(SPRITE_ENABLE)
        shot_sprite_enabled = (sprite_enable & SHOT_SPRITE_MASK) != 0
        slot_rows = [
            self.symbols.get("FORMATION_TOP_Y", vic(SPRITE0_Y)),
            self.symbols.get("FORMATION_TOP_Y", vic(SPRITE0_Y)),
            self.symbols.get("FORMATION_MID_Y", vic(SPRITE4_Y)),
            self.symbols.get("FORMATION_MID_Y", vic(SPRITE4_Y)),
            self.symbols.get("FORMATION_BOTTOM_Y", vic(SPRITE6_Y)),
            self.symbols.get("FORMATION_BOTTOM_Y", vic(SPRITE6_Y)),
        ]
        active_formation_rows = [
            slot_rows[index]
            for index in range(INITIAL_FORMATION_ALIVE_COUNT)
            if (alive_data[index] != 0 if alive_data is not None else True)
            and not (dive_active and dive_slot == index)
        ]
        formation_logical_alive_count = sum(
            1 for index in range(INITIAL_FORMATION_ALIVE_COUNT) if alive_data[index] != 0
        ) if alive_data is not None else sum(
            1
            for mask in (0x01, 0x08, 0x10, 0x20, 0x40, 0x80)
            if sprite_enable & mask
        )
        state = {
            "player_x": combine_sprite_x(vic(SPRITE1_X), msb, 1),
            "player_y": vic(SPRITE1_Y),
            "formation_0_x": formation_slot_x(0),
            "formation_1_x": formation_slot_x(1),
            "formation_2_x": formation_slot_x(2),
            "formation_3_x": formation_slot_x(3),
            "formation_4_x": formation_slot_x(4),
            "formation_5_x": formation_slot_x(5),
            "formation_y": min(active_formation_rows) if active_formation_rows else vic(SPRITE0_Y),
            "shot_x": combine_sprite_x(vic(SPRITE2_X), msb, 2),
            "shot_y": vic(SPRITE2_Y),
            "shot_active": shot_active if shot_active is not None else shot_sprite_enabled,
            "player_respawn_timer": player_respawn_timer,
            "sprite_enable": sprite_enable,
            "sprite_x_msb": msb,
            "player_enabled": (sprite_enable & 0x02) != 0,
            "shot_enabled": shot_sprite_enabled,
            "formation_renderer_mode": formation_renderer_mode,
            "formation_renderer_mode_name": describe_renderer_mode(formation_renderer_mode),
            "formation_logical_alive_count": formation_logical_alive_count,
            "formation_char_render_mask": formation_char_render_mask,
            "formation_shift_phase": formation_shift_phase,
            "dive_active": dive_active,
            "dive_slot": dive_slot,
            "formation_0_enabled": (sprite_enable & 0x01) != 0,
            "formation_1_enabled": (sprite_enable & 0x08) != 0,
            "formation_2_enabled": (sprite_enable & 0x10) != 0,
            "formation_3_enabled": (sprite_enable & 0x20) != 0,
            "formation_4_enabled": (sprite_enable & 0x40) != 0,
            "formation_5_enabled": (sprite_enable & 0x80) != 0,
            "formation_0_alive": alive_data[0] != 0 if alive_data is not None else (sprite_enable & 0x01) != 0,
            "formation_1_alive": alive_data[1] != 0 if alive_data is not None else (sprite_enable & 0x08) != 0,
            "formation_2_alive": alive_data[2] != 0 if alive_data is not None else (sprite_enable & 0x10) != 0,
            "formation_3_alive": alive_data[3] != 0 if alive_data is not None else (sprite_enable & 0x20) != 0,
            "formation_4_alive": alive_data[4] != 0 if alive_data is not None else (sprite_enable & 0x40) != 0,
            "formation_5_alive": alive_data[5] != 0 if alive_data is not None else (sprite_enable & 0x80) != 0,
            "joystick_port_2": joystick_value,
            "joystick_left_pressed": (joystick_value & LEFT_MASK) == 0 if include_joystick else False,
            "joystick_right_pressed": (joystick_value & RIGHT_MASK) == 0 if include_joystick else False,
            "joystick_fire_pressed": (joystick_value & FIRE_MASK) == 0 if include_joystick else False,
        }
        return state

    def capture_sample(self, stage: str, include_joystick: bool = True):
        state = self.read_state(include_joystick=include_joystick)
        sample = {
            "index": self.sample_counter,
            "stage": stage,
            "timestamp": time.time(),
            **state,
            "screenshot": None,
            "screenshot_sha256": None,
        }
        if self.host_capture_enabled:
            screenshot_path = self.args.frames_dir / f"{self.sample_counter:03d}-{stage}.png"
            try:
                screenshot_hash = self.gui.capture_window(screenshot_path)
            except PlaytestFailure as exc:
                self.host_capture_enabled = False
                self.host_capture_failure = str(exc)
                self.logger.log(
                    f"Disabling host screenshot capture for the rest of the run: {self.host_capture_failure}"
                )
            else:
                sample["screenshot"] = str(screenshot_path)
                sample["screenshot_sha256"] = screenshot_hash
        self.sample_counter += 1
        self.samples.append(sample)
        return sample

    def wait_for_game_ready(self):
        latest = None
        for _ in range(60):
            self.resume_for(0.25)
            latest = self.read_state(include_joystick=False)
            if (
                latest["player_enabled"]
                and latest["formation_logical_alive_count"] >= 1
                and latest["player_y"] > latest["formation_y"]
                and latest["player_y"] >= 180
                and latest["formation_y"] <= 100
            ):
                return latest
        raise PlaytestFailure(f"Timed out waiting for the game shell to appear: {latest}")

    def formation_char_row(self, slot_index: int) -> int:
        if slot_index < 2:
            return self.symbols["FORMATION_CHAR_BAND_TOP_ROW"]
        if slot_index < 4:
            return self.symbols["FORMATION_CHAR_BAND_MID_ROW"]
        return self.symbols["FORMATION_CHAR_BAND_BOTTOM_ROW"]

    def formation_char_col(self, sample, slot_index: int) -> int:
        playfield_left = self.symbols["PLAYFIELD_LEFT_X_LO"] + (self.symbols["PLAYFIELD_LEFT_X_HI"] << 8)
        return ((sample[f"formation_{slot_index}_x"] - playfield_left) >> 3) + self.symbols[
            "FORMATION_CHAR_BAND_ORIGIN_COL"
        ]

    def formation_char_cells(self, sample, slot_index: int):
        required_symbols = {"SCREEN_RAM"}
        missing = sorted(required_symbols - self.symbols.keys())
        self.assert_true(
            "formation_char_cell_symbols_present",
            not missing,
            {"missing": missing, "symbols": self.symbols},
        )
        row = self.formation_char_row(slot_index)
        col = self.formation_char_col(sample, slot_index)
        values = []
        addresses = []
        for offset in (0, 1):
            address = self.symbols["SCREEN_RAM"] + (row * 40) + col + offset
            addresses.append(address)
            values.append(self.monitor.mem_get(address, 1)[0])
        return {
            "row": row,
            "col": col,
            "values": values,
            "addresses": addresses,
        }

    def assert_char_renderer_output(self, name: str, sample):
        if sample.get("formation_char_render_mask") is not None:
            expected_mask = 0
            for slot in self.live_formation_slots(sample):
                expected_mask |= 1 << slot["index"]
            self.assert_true(
                name,
                (sample["formation_char_render_mask"] & expected_mask) == expected_mask,
                {
                    "sample": sample,
                    "expected_mask": expected_mask,
                    "actual_mask": sample["formation_char_render_mask"],
                },
            )
            return

        required_symbols = {
            "SCREEN_RAM",
            "FORMATION_CHAR_BAND_ORIGIN_COL",
            "FORMATION_CHAR_BAND_TOP_ROW",
            "FORMATION_CHAR_BAND_MID_ROW",
            "FORMATION_CHAR_BAND_BOTTOM_ROW",
            "PLAYFIELD_LEFT_X_LO",
            "PLAYFIELD_LEFT_X_HI",
        }
        missing = sorted(required_symbols - self.symbols.keys())
        self.assert_true(f"{name}_symbols_present", not missing, {"missing": missing, "symbols": self.symbols})

        attempts = []
        latest_sample = sample
        for attempt in range(4):
            sampled_slots = []
            for slot in self.live_formation_slots(latest_sample):
                row = self.formation_char_row(slot["index"])
                col = self.formation_char_col(latest_sample, slot["index"])
                neighborhood = []
                value = 0x20
                for row_offset in (-1, 0, 1):
                    probe_row = row + row_offset
                    if probe_row < 0 or probe_row >= 25:
                        continue
                    for col_offset in (-1, 0, 1):
                        probe_col = col + col_offset
                        if probe_col < 0 or probe_col >= 40:
                            continue
                        address = self.symbols["SCREEN_RAM"] + (probe_row * 40) + probe_col
                        probe_value = self.monitor.mem_get(address, 1)[0]
                        neighborhood.append(
                            {
                                "row": probe_row,
                                "col": probe_col,
                                "address": address,
                                "value": probe_value,
                            }
                        )
                        if probe_value != 0x20:
                            value = probe_value
                sampled_slots.append(
                    {
                        "slot": slot["index"],
                        "row": row,
                        "col": col,
                        "value": value,
                        "neighborhood": neighborhood,
                    }
                )
            attempts.append({"sample": latest_sample, "slots": sampled_slots})
            if sampled_slots and all(slot["value"] != 0x20 for slot in sampled_slots):
                return
            if attempt < 3:
                self.resume_for(0.05)
                latest_sample = self.read_state(include_joystick=False)

        self.assert_true(f"{name}_slots_sampled", False, {"attempts": attempts})

    def assert_renderer_ready(self, name: str, sample):
        if (
            sample["formation_renderer_mode"] == FORMATION_RENDERER_SPRITE
            or sample["formation_renderer_mode_name"] == "sprite"
        ):
            self.assert_true(name, True, sample)
            return
        if sample["formation_renderer_mode_name"] == "char":
            self.assert_char_renderer_output(name, sample)
            return
        self.assert_true(name, False, sample)

    def drive_until_clamp(self, name: str, key_code: int, joystick_mask: int, moving_left: bool):
        direction_word = "left" if moving_left else "right"
        self.logger.log(f"Holding {direction_word} until player movement clamps")
        self.gui.key_down(key_code)
        try:
            self.resume_for(0.35)
            first = self.capture_sample(f"{name}-press")
            self.assert_true(
                f"{name}_joystick_active",
                (first["joystick_port_2"] & joystick_mask) == 0,
                first,
            )

            previous = first
            moved = False
            stable_samples = 0
            for _ in range(16):
                self.resume_for(1.0)
                current = self.capture_sample(f"{name}-hold")
                delta = current["player_x"] - previous["player_x"]
                if moving_left and delta < 0:
                    moved = True
                    stable_samples = 0
                elif not moving_left and delta > 0:
                    moved = True
                    stable_samples = 0
                elif delta == 0:
                    stable_samples += 1
                elif (moving_left and delta > 80) or (not moving_left and delta < -80):
                    self.logger.log(
                        f"Detected a respawn-sized reset during {name} clamp; restarting clamp tracking"
                    )
                    moved = False
                    stable_samples = 0
                else:
                    raise PlaytestFailure(
                        f"{name}_unexpected_player_direction: previous={previous} current={current}"
                    )

                previous = current
                if moved and stable_samples >= 2:
                    self.record_step(f"{name}_clamp", "passed", current)
                    return current

            raise PlaytestFailure(
                f"{name}_clamp_timeout: movement did not settle while holding {direction_word}"
            )
        finally:
            self.gui.key_up(key_code)

    def assert_idle(self, expected_x: int, stage_name: str):
        self.logger.log("Checking idle stability after releasing the key")
        self.resume_for(1.0)
        idle_one = self.capture_sample(f"{stage_name}-idle-1")
        self.resume_for(1.0)
        idle_two = self.capture_sample(f"{stage_name}-idle-2")
        self.assert_true(
            f"{stage_name}_idle_position",
            idle_one["player_x"] == expected_x == idle_two["player_x"],
            {"idle_one": idle_one, "idle_two": idle_two, "expected_x": expected_x},
        )
        self.assert_true(
            f"{stage_name}_idle_joystick_clear",
            not idle_two["joystick_left_pressed"] and not idle_two["joystick_right_pressed"],
            idle_two,
        )
        self.record_step(f"{stage_name}_idle", "passed", {"idle_one": idle_one, "idle_two": idle_two})

    def formation_slots(self, sample):
        return [
            {
                "index": 0,
                "x": sample["formation_0_x"],
                "alive": sample["formation_0_alive"],
            },
            {
                "index": 1,
                "x": sample["formation_1_x"],
                "alive": sample["formation_1_alive"],
            },
            {
                "index": 2,
                "x": sample["formation_2_x"],
                "alive": sample["formation_2_alive"],
            },
            {
                "index": 3,
                "x": sample["formation_3_x"],
                "alive": sample["formation_3_alive"],
            },
            {
                "index": 4,
                "x": sample["formation_4_x"],
                "alive": sample["formation_4_alive"],
            },
            {
                "index": 5,
                "x": sample["formation_5_x"],
                "alive": sample["formation_5_alive"],
            },
        ]

    def live_formation_slots(self, sample):
        return [
            slot
            for slot in self.formation_slots(sample)
            if slot["alive"] and not (sample.get("dive_active") and sample.get("dive_slot") == slot["index"])
        ]

    def formation_alive_count(self, sample):
        return len(self.live_formation_slots(sample))

    def total_formation_alive_count(self, sample):
        return sum(1 for slot in self.formation_slots(sample) if slot["alive"])

    def leftmost_formation_x(self, sample):
        live_slots = self.live_formation_slots(sample)
        if not live_slots:
            return None
        return min(slot["x"] for slot in live_slots)

    def formation_has_bounced(self):
        formation_positions = []
        for sample in self.samples:
            leftmost_x = self.leftmost_formation_x(sample)
            if leftmost_x is not None:
                formation_positions.append(leftmost_x)

        deltas = [
            current - previous
            for previous, current in zip(formation_positions, formation_positions[1:])
            if current != previous
        ]
        return {
            "moved": bool(deltas),
            "positive_seen": any(delta > 0 for delta in deltas),
            "negative_seen": any(delta < 0 for delta in deltas),
            "deltas": deltas,
        }

    def wait_for_formation_bounce(self):
        self.logger.log("Observing formation movement until a visible bounce is sampled")
        for _ in range(12):
            bounce_state = self.formation_has_bounced()
            if bounce_state["positive_seen"] and bounce_state["negative_seen"]:
                self.record_step("formation_bounce", "passed", bounce_state)
                return bounce_state
            self.resume_for(1.25)
            self.capture_sample("formation-watch", include_joystick=False)
        bounce_state = self.formation_has_bounced()
        raise PlaytestFailure(f"formation_bounce_timeout: {bounce_state}")

    def assert_char_renderer_motion(self, name: str):
        observations = []
        for sample in self.samples:
            if sample.get("formation_renderer_mode_name") != "char":
                continue
            live_slots = self.live_formation_slots(sample)
            if not live_slots:
                continue
            slot = min(live_slots, key=lambda item: item["x"])
            cells = self.formation_char_cells(sample, slot["index"])
            observations.append(
                {
                    "sample_index": sample["index"],
                    "stage": sample["stage"],
                    "slot": slot["index"],
                    "x": slot["x"],
                    "shift_phase": sample.get("formation_shift_phase"),
                    "col": cells["col"],
                    "values": cells["values"],
                }
            )

        transitions = []
        for previous, current in zip(observations, observations[1:]):
            logical_delta = current["x"] - previous["x"]
            if logical_delta == 0:
                continue
            rendered_changed = (
                current["col"] != previous["col"]
                or current["values"] != previous["values"]
                or current["shift_phase"] != previous["shift_phase"]
            )
            transitions.append(
                {
                    "previous": previous,
                    "current": current,
                    "logical_delta": logical_delta,
                    "rendered_changed": rendered_changed,
                }
            )

        self.assert_true(
            name,
            bool(transitions) and all(item["rendered_changed"] for item in transitions),
            {"observations": observations, "transitions": transitions},
        )
        return {"observations": observations, "transitions": transitions}

    def choose_target_slot(self, sample, preferred_index: int = 5):
        live_slots = self.live_formation_slots(sample)
        if not live_slots:
            raise PlaytestFailure(f"no_live_formation_slots: {sample}")
        for slot in live_slots:
            if slot["index"] == preferred_index:
                return preferred_index
        return min(live_slots, key=lambda slot: abs(slot["x"] - sample["player_x"]))["index"]

    def alignment_burst_seconds(self, delta: int) -> float:
        distance = abs(delta)
        if distance > 140:
            return 1.0
        if distance > 64:
            return 0.45
        if distance > 24:
            return 0.2
        return 0.1

    def align_player_with_formation_slot(self, preferred_index: int = 5):
        self.logger.log("Aligning the player ship under a live formation slot before firing")
        last_detail = None
        for _ in range(20):
            current = self.capture_sample("align-check", include_joystick=False)
            target_slot = self.choose_target_slot(current, preferred_index=preferred_index)
            target_x = current[f"formation_{target_slot}_x"]
            delta = current["player_x"] - target_x
            last_detail = {"slot": target_slot, "sample": current, "mode": "active"}
            if abs(delta) <= 10:
                self.record_step("player_aligned", "passed", last_detail)
                return last_detail

            key_code = LEFT_KEY_CODE if delta > 0 else RIGHT_KEY_CODE
            self.gui.key_down(key_code)
            try:
                self.resume_for(self.alignment_burst_seconds(delta))
            finally:
                self.gui.key_up(key_code)

        raise PlaytestFailure(f"player_alignment_timeout: {last_detail}")

    def fire_once(self, attempt: int):
        self.logger.log(f"Firing attempt {attempt}")
        self.gui.key_down(FIRE_KEY_CODE)
        try:
            self.resume_for(0.12)
            pressed = self.capture_sample(f"fire-{attempt}-press")
            self.assert_true(
                f"fire_{attempt}_joystick_active",
                pressed["joystick_fire_pressed"],
                pressed,
            )
            self.resume_for(0.12)
            launched = self.capture_sample(f"fire-{attempt}-launch", include_joystick=False)
            self.assert_true(
                f"fire_{attempt}_shot_spawned",
                launched["shot_enabled"]
                or self.total_formation_alive_count(launched) < INITIAL_FORMATION_ALIVE_COUNT,
                launched,
            )
            return launched
        finally:
            self.gui.key_up(FIRE_KEY_CODE)

    def destroy_formation_member(self):
        attempts = []
        initial_alive_count = INITIAL_FORMATION_ALIVE_COUNT
        for attempt in range(1, 5):
            alignment = self.align_player_with_formation_slot(preferred_index=5)
            launch = self.fire_once(attempt)
            attempt_detail = {
                "attempt": attempt,
                "target_slot": alignment["slot"],
                "aligned_sample": alignment["sample"],
                "launch_sample": launch,
                "shot_seen": launch["shot_enabled"],
            }

            watch_sample = launch
            for _ in range(16):
                self.resume_for(0.2)
                watch_sample = self.capture_sample(f"fire-{attempt}-watch", include_joystick=False)
                attempt_detail["shot_seen"] = attempt_detail["shot_seen"] or watch_sample["shot_enabled"]
                if self.total_formation_alive_count(watch_sample) == initial_alive_count - 1:
                    attempt_detail["result"] = "hit"
                    attempt_detail["destroyed_slots"] = [
                        slot["index"] for slot in self.formation_slots(watch_sample) if not slot["alive"]
                    ]
                    attempt_detail["final_sample"] = watch_sample
                    attempts.append(attempt_detail)
                    self.record_step("formation_member_destroyed", "passed", attempt_detail)
                    return attempt_detail
                if attempt_detail["shot_seen"] and not watch_sample["shot_enabled"]:
                    attempt_detail["result"] = "miss"
                    attempt_detail["final_sample"] = watch_sample
                    break
            else:
                attempt_detail["result"] = "timeout"
                attempt_detail["final_sample"] = watch_sample

            attempts.append(attempt_detail)

        raise PlaytestFailure(f"formation_destroy_timeout: {attempts}")

    def verify_gap_persists(self, destroyed_slots, hit_sample):
        self.logger.log("Checking that the destroyed slot remains a visible gap while the formation keeps moving")
        self.resume_for(0.8)
        follow_up = self.capture_sample("gap-check", include_joystick=False)
        self.assert_true(
            "gap_alive_count",
            self.total_formation_alive_count(follow_up) == INITIAL_FORMATION_ALIVE_COUNT - 1,
            follow_up,
        )
        current_destroyed_slots = [
            slot["index"] for slot in self.formation_slots(follow_up) if not slot["alive"]
        ]
        self.assert_true(
            "gap_same_slot_missing",
            current_destroyed_slots == destroyed_slots,
            {"expected": destroyed_slots, "sample": follow_up},
        )
        self.assert_true(
            "formation_continues_after_hit",
            self.leftmost_formation_x(hit_sample) != self.leftmost_formation_x(follow_up),
            {"hit_sample": hit_sample, "follow_up": follow_up},
        )
        self.record_step(
            "gap_persists",
            "passed",
            {"destroyed_slots": destroyed_slots, "sample": follow_up},
        )
        return follow_up

    def run(self):
        self.launch_vice()
        ready_state = self.wait_for_game_ready()
        self.record_step("game_ready", "passed", ready_state)

        initial = self.capture_sample("boot")
        self.assert_true(
            "initial_layout",
            initial["player_y"] > initial["formation_y"]
            and initial["player_y"] >= 180
            and initial["formation_y"] <= 100,
            initial,
        )
        self.assert_true(
            "initial_player_sprite_enabled",
            initial["player_enabled"],
            initial,
        )
        self.assert_true(
            "initial_formation_logical_alive",
            initial["formation_logical_alive_count"] >= 1,
            initial,
        )
        self.assert_renderer_ready("initial_renderer_mode", initial)
        self.record_step("initial_state", "passed", initial)

        left_clamp = self.drive_until_clamp("left", LEFT_KEY_CODE, LEFT_MASK, moving_left=True)
        self.assert_true(
            "left_clamp_moved",
            left_clamp["player_x"] < initial["player_x"],
            {"initial": initial, "clamp": left_clamp},
        )
        self.assert_idle(left_clamp["player_x"], "left")

        right_clamp = self.drive_until_clamp("right", RIGHT_KEY_CODE, RIGHT_MASK, moving_left=False)
        self.assert_true(
            "right_clamp_moved",
            right_clamp["player_x"] > left_clamp["player_x"],
            {"left_clamp": left_clamp, "right_clamp": right_clamp},
        )
        self.assert_idle(right_clamp["player_x"], "right")

        bounce_state = self.wait_for_formation_bounce()
        self.assert_true("formation_moves", bounce_state["moved"], bounce_state)
        self.assert_true(
            "formation_bounces",
            bounce_state["positive_seen"] and bounce_state["negative_seen"],
            bounce_state,
        )
        char_motion_state = None
        if initial["formation_renderer_mode_name"] == "char":
            char_motion_state = self.assert_char_renderer_motion("formation_char_motion_visible")

        hit_state = self.destroy_formation_member()
        self.assert_true(
            "one_slot_destroyed",
            len(hit_state["destroyed_slots"]) == 1,
            hit_state,
        )
        gap_state = self.verify_gap_persists(hit_state["destroyed_slots"], hit_state["final_sample"])

        captured_hashes = {
            sample["screenshot_sha256"]
            for sample in self.samples
            if sample["screenshot_sha256"] is not None
        }
        if self.host_capture_failure is not None:
            self.record_step(
                "host_screenshots",
                "skipped",
                {"reason": self.host_capture_failure},
            )
        elif len(captured_hashes) > 1:
            self.record_step(
                "host_screenshots",
                "passed",
                {"captured_frames": len(captured_hashes)},
            )
        elif captured_hashes:
            self.record_step(
                "host_screenshots",
                "skipped",
                {"reason": "Only one host screenshot was captured"},
            )
        else:
            self.record_step(
                "host_screenshots",
                "skipped",
                {"reason": "No host screenshots were captured"},
            )

        self.results["success"] = True
        self.results["final_state"] = self.samples[-1]
        self.results["summary"] = {
            "left_clamp_x": left_clamp["player_x"],
            "right_clamp_x": right_clamp["player_x"],
            "formation_renderer_mode": initial["formation_renderer_mode"],
            "formation_renderer_mode_name": initial["formation_renderer_mode_name"],
            "formation_shift_phase": initial["formation_shift_phase"],
            "formation_direction_samples": bounce_state["deltas"],
            "formation_char_motion_samples": 0 if char_motion_state is None else len(char_motion_state["transitions"]),
            "shot_attempts": hit_state["attempt"],
            "destroyed_slots": hit_state["destroyed_slots"],
            "alive_slots_after_hit": self.total_formation_alive_count(gap_state),
            "captured_frame_count": len(captured_hashes),
            "host_screenshots_enabled": self.args.capture_host_screenshots,
        }


def parse_args():
    parser = argparse.ArgumentParser(
        description="Visible external playtest for the C64 Galaxian shell using macOS key events."
    )
    parser.add_argument("--prg", type=Path, required=True)
    parser.add_argument("--log", type=Path, required=True)
    parser.add_argument("--json", type=Path, required=True)
    parser.add_argument("--vice-log", type=Path, required=True)
    parser.add_argument("--frames-dir", type=Path, required=True)
    parser.add_argument("--keymap", type=Path, required=True)
    parser.add_argument("--exit-screenshot", type=Path, required=True)
    parser.add_argument("--process-name", default="x64sc")
    parser.add_argument("--window-x", type=int, default=80)
    parser.add_argument("--window-y", type=int, default=80)
    parser.add_argument("--window-width", type=int, default=720)
    parser.add_argument("--window-height", type=int, default=638)
    parser.add_argument("--capture-host-screenshots", action="store_true")
    return parser.parse_args()


def main():
    args = parse_args()
    logger = Logger(args.log)
    playtester = Playtester(args, logger)
    exit_code = 0

    try:
        playtester.run()
        logger.log("Playtest passed")
    except PlaytestFailure as exc:
        playtester.results["failure"] = str(exc)
        if playtester.samples:
            playtester.results["last_sample"] = playtester.samples[-1]
        logger.log(f"Playtest failed: {exc}")
        exit_code = 1
    finally:
        playtester.shutdown()
        playtester.results["artifacts"]["exit_screenshot_exists"] = args.exit_screenshot.exists()
        args.json.parent.mkdir(parents=True, exist_ok=True)
        args.json.write_text(json.dumps(playtester.results, indent=2), encoding="utf-8")
        logger.close()

    return exit_code


if __name__ == "__main__":
    sys.exit(main())
