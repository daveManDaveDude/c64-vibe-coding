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
MEM_SET = 0x02
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
RASTER = 0xD012
SPRITE_ENABLE = 0xD015
JOYSTICK_PORT_2 = 0xDC00

LEFT_KEY_CODE = 123
RIGHT_KEY_CODE = 124
FIRE_KEY_CODE = 49
LEFT_MASK = 0x04
RIGHT_MASK = 0x08
FIRE_MASK = 0x10
SHOT_SPRITE_MASK = 0x04
DEFAULT_FORMATION_SLOT_COUNT = 6
FORMATION_RENDERER_CHAR = 1
FORMATION_RENDERER_NAMES = {
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

    def mem_set(self, start: int, data: bytes, side_effects: bool = False) -> None:
        if not data:
            return
        end = start + len(data) - 1
        body = (
            struct.pack("<BHHBH", 0x01 if side_effects else 0x00, start, end, MAIN_MEMSPACE, 0x0000)
            + data
        )
        self.send_command(MEM_SET, body)

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


def bcd_byte_to_int(value: int) -> int:
    return ((value >> 4) * 10) + (value & 0x0F)


def score_bytes_to_int(lo: int, mid: int, hi: int) -> int:
    return (bcd_byte_to_int(hi) * 10000) + (bcd_byte_to_int(mid) * 100) + bcd_byte_to_int(lo)


class MacOSGui:
    def __init__(self, process_name: str, logger: Logger, capture_region: str):
        self.process_name = process_name
        self.logger = logger
        self.capture_region = capture_region
        self.pid = None
        self.window_id = None
        self.window_capture_disabled = False
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

    def _window_id_script(self):
        if self.pid is None:
            return [
                'tell application "System Events"',
                f'  tell application process "{self.process_name}"',
                '    if (count of windows) is 0 then error "VICE window not found"',
                '    return value of attribute "AXWindowNumber" of window 1',
                "  end tell",
                "end tell",
            ]
        return [
            'tell application "System Events"',
            f'  set matchingProcesses to every application process whose unix id is {self.pid}',
            '  if (count of matchingProcesses) is 0 then error "VICE process not found"',
            "  tell item 1 of matchingProcesses",
            '    if (count of windows) is 0 then error "VICE window not found"',
            '    return value of attribute "AXWindowNumber" of window 1',
            "  end tell",
            "end tell",
        ]

    def get_window_id(self) -> Optional[int]:
        if self.window_capture_disabled:
            return None
        if self.window_id is not None:
            return self.window_id
        try:
            raw_value = self._run_osascript(self._window_id_script())
        except PlaytestFailure as exc:
            self.logger.log(f"Window-id capture unavailable, falling back to region capture: {exc}")
            self.window_capture_disabled = True
            return None
        try:
            self.window_id = int(raw_value.strip())
        except ValueError:
            self.logger.log(
                f"Window-id capture unavailable, falling back to region capture: invalid window id {raw_value!r}"
            )
            self.window_capture_disabled = True
            return None
        return self.window_id

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

    def capture_window(self, destination: Path) -> tuple[str, str]:
        destination.parent.mkdir(parents=True, exist_ok=True)
        window_id = self.get_window_id()
        if window_id is not None:
            try:
                subprocess.run(
                    ["screencapture", "-x", "-o", "-l", str(window_id), str(destination)],
                    check=True,
                    capture_output=True,
                    text=True,
                )
            except subprocess.CalledProcessError as exc:
                self.logger.log(
                    "Window-id capture failed, falling back to region capture: "
                    f"{exc.stderr.strip() or exc.stdout.strip() or exc}"
                )
                self.window_id = None
                self.window_capture_disabled = True
            else:
                digest = hashlib.sha256(destination.read_bytes()).hexdigest()
                return digest, "window"
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
        return digest, "region"


class Playtester:
    def __init__(self, args, logger: Logger):
        self.args = args
        self.logger = logger
        self.symbols = load_symbols(args.prg.with_suffix(".sym"))
        self.formation_slot_count = self.symbols.get("FORMATION_SLOT_COUNT", DEFAULT_FORMATION_SLOT_COUNT)
        self.formation_sprite_masks = [0x01, 0x08, 0x10, 0x20, 0x40, 0x80]
        capture_region = f"{args.window_x},{args.window_y},{args.window_width},{args.window_height}"
        self.gui = MacOSGui(args.process_name, logger, capture_region)
        self.monitor = None
        self.vice_process = None
        self.sample_counter = 0
        self.samples = []
        self.capture_modes_seen = set()
        self.host_capture_enabled = args.capture_host_screenshots
        self.host_capture_failure = None
        self.suppress_host_capture = False
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
                "capture_mode": None,
                "capture_modes_seen": [],
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

    def run_without_host_capture(self, callback, *args, **kwargs):
        previous = self.suppress_host_capture
        self.suppress_host_capture = True
        try:
            return callback(*args, **kwargs)
        finally:
            self.suppress_host_capture = previous

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
            "-VICIIfilter",
            "0",
            "-VICIIglfilter",
            "0",
            "-VICIIaspectmode",
            "0",
            "-VICIIdscan",
            "-VICIIvsync",
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
        monitor_commands = getattr(self.args, "monitor_commands", None)
        if monitor_commands is not None:
            command[-1:-1] = [
                "-initbreak",
                getattr(self.args, "initbreak", "ready"),
                "-moncommands",
                str(monitor_commands),
            ]
            monitor_log = getattr(self.args, "monitor_log", None)
            if monitor_log is not None:
                command[-1:-1] = [
                    "-monlogname",
                    str(monitor_log),
                    "-monlog",
                ]
        remote_monitor_address = getattr(self.args, "remote_monitor_address", None)
        if remote_monitor_address is not None:
            command[-1:-1] = [
                "-remotemonitor",
                "-remotemonitoraddress",
                str(remote_monitor_address),
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
        formation_slot_count = self.formation_slot_count
        alive_data = None
        if "formation_slot0_alive" in self.symbols:
            alive_data = self.monitor.mem_get(self.symbols["formation_slot0_alive"], formation_slot_count)
        formation_renderer_mode = FORMATION_RENDERER_CHAR
        if "formation_renderer_mode" in self.symbols:
            formation_renderer_mode = self.monitor.mem_get(self.symbols["formation_renderer_mode"], 1)[0]
        formation_position_data = None
        if "formation_slot0_x_lo" in self.symbols:
            formation_position_data = self.monitor.mem_get(
                self.symbols["formation_slot0_x_lo"], formation_slot_count * 2
            )
        dive_active = False
        dive_slot = None
        if "dive_active" in self.symbols:
            dive_active = self.monitor.mem_get(self.symbols["dive_active"], 1)[0] != 0
        if "dive_slot" in self.symbols:
            raw_dive_slot = self.monitor.mem_get(self.symbols["dive_slot"], 1)[0]
            if raw_dive_slot < formation_slot_count:
                dive_slot = raw_dive_slot
        dive_x = None
        dive_y = None
        if dive_active and "dive_x_lo" in self.symbols and "dive_x_hi" in self.symbols:
            dive_x_lo = self.monitor.mem_get(self.symbols["dive_x_lo"], 1)[0]
            dive_x_hi = self.monitor.mem_get(self.symbols["dive_x_hi"], 1)[0]
            dive_x = dive_x_lo | (dive_x_hi << 8)
        if dive_active and "dive_y" in self.symbols:
            dive_y = self.monitor.mem_get(self.symbols["dive_y"], 1)[0]
        dive_launch_counter = None
        if "dive_launch_counter" in self.symbols:
            dive_launch_counter = self.monitor.mem_get(self.symbols["dive_launch_counter"], 1)[0]
        dive_launch_y = None
        if "dive_launch_y_debug" in self.symbols:
            dive_launch_y = self.monitor.mem_get(self.symbols["dive_launch_y_debug"], 1)[0]
        dive_anim_frame = None
        if "dive_anim_frame" in self.symbols:
            dive_anim_frame = self.monitor.mem_get(self.symbols["dive_anim_frame"], 1)[0]
        dive_anim_tick = None
        if "dive_anim_tick" in self.symbols:
            dive_anim_tick = self.monitor.mem_get(self.symbols["dive_anim_tick"], 1)[0]
        dive_sprite_pointer = None
        if "dive_sprite_pointer" in self.symbols:
            dive_sprite_pointer = self.monitor.mem_get(self.symbols["dive_sprite_pointer"], 1)[0]
        shot_active = None
        if "shot_active" in self.symbols:
            shot_active = self.monitor.mem_get(self.symbols["shot_active"], 1)[0] != 0
        player_respawn_timer = None
        if "player_respawn_timer" in self.symbols:
            player_respawn_timer = self.monitor.mem_get(self.symbols["player_respawn_timer"], 1)[0]
        player_extra_visible = None
        if "player_extra_visible" in self.symbols:
            player_extra_visible = self.monitor.mem_get(self.symbols["player_extra_visible"], 1)[0] != 0
        player_explosion_active = None
        if "player_explosion_active" in self.symbols:
            player_explosion_active = self.monitor.mem_get(self.symbols["player_explosion_active"], 1)[0] != 0
        player_bottom_sprite_mask_debug = None
        if "player_bottom_sprite_mask_debug" in self.symbols:
            player_bottom_sprite_mask_debug = self.monitor.mem_get(
                self.symbols["player_bottom_sprite_mask_debug"], 1
            )[0]
        game_state = None
        if "game_state" in self.symbols:
            game_state = self.monitor.mem_get(self.symbols["game_state"], 1)[0]
        formation_char_render_mask = None
        if "formation_char_render_mask" in self.symbols:
            formation_char_render_mask = self.monitor.mem_get(self.symbols["formation_char_render_mask"], 1)[0]
            if "formation_char_render_mask_hi" in self.symbols:
                formation_char_render_mask |= (
                    self.monitor.mem_get(self.symbols["formation_char_render_mask_hi"], 1)[0] << 8
                )
            if "formation_char_render_mask_hi2" in self.symbols:
                formation_char_render_mask |= (
                    self.monitor.mem_get(self.symbols["formation_char_render_mask_hi2"], 1)[0] << 16
                )
        formation_shift_phase = None
        if "formation_shift_phase" in self.symbols:
            formation_shift_phase = self.monitor.mem_get(self.symbols["formation_shift_phase"], 1)[0]
        raster_phase = None
        if "raster_phase" in self.symbols:
            raster_phase = self.monitor.mem_get(self.symbols["raster_phase"], 1)[0]
        formation_render_start_phase = None
        if "formation_render_start_phase" in self.symbols:
            formation_render_start_phase = self.monitor.mem_get(
                self.symbols["formation_render_start_phase"], 1
            )[0]
        formation_render_start_raster = None
        if "formation_render_start_raster" in self.symbols:
            formation_render_start_raster = self.monitor.mem_get(
                self.symbols["formation_render_start_raster"], 1
            )[0]
        formation_render_top_row_end_phase = None
        if "formation_render_top_row_end_phase" in self.symbols:
            formation_render_top_row_end_phase = self.monitor.mem_get(
                self.symbols["formation_render_top_row_end_phase"], 1
            )[0]
        formation_render_top_row_end_raster = None
        if "formation_render_top_row_end_raster" in self.symbols:
            formation_render_top_row_end_raster = self.monitor.mem_get(
                self.symbols["formation_render_top_row_end_raster"], 1
            )[0]
        formation_render_end_phase = None
        if "formation_render_end_phase" in self.symbols:
            formation_render_end_phase = self.monitor.mem_get(
                self.symbols["formation_render_end_phase"], 1
            )[0]
        formation_render_end_raster = None
        if "formation_render_end_raster" in self.symbols:
            formation_render_end_raster = self.monitor.mem_get(
                self.symbols["formation_render_end_raster"], 1
            )[0]
        formation_shared_cache_update_counter = None
        if "formation_shared_cache_update_counter" in self.symbols:
            formation_shared_cache_update_counter = self.monitor.mem_get(
                self.symbols["formation_shared_cache_update_counter"], 1
            )[0]
        formation_shared_cache_update_start_phase = None
        if "formation_shared_cache_update_start_phase" in self.symbols:
            formation_shared_cache_update_start_phase = self.monitor.mem_get(
                self.symbols["formation_shared_cache_update_start_phase"], 1
            )[0]
        formation_shared_cache_update_start_raster = None
        if "formation_shared_cache_update_start_raster" in self.symbols:
            formation_shared_cache_update_start_raster = self.monitor.mem_get(
                self.symbols["formation_shared_cache_update_start_raster"], 1
            )[0]
        formation_shared_cache_update_end_phase = None
        if "formation_shared_cache_update_end_phase" in self.symbols:
            formation_shared_cache_update_end_phase = self.monitor.mem_get(
                self.symbols["formation_shared_cache_update_end_phase"], 1
            )[0]
        formation_shared_cache_update_end_raster = None
        if "formation_shared_cache_update_end_raster" in self.symbols:
            formation_shared_cache_update_end_raster = self.monitor.mem_get(
                self.symbols["formation_shared_cache_update_end_raster"], 1
            )[0]
        frame_capture_counter = None
        if "frame_capture_counter" in self.symbols:
            frame_capture_counter = self.monitor.mem_get(self.symbols["frame_capture_counter"], 1)[0]
        enemy_attack_active = None
        if "enemy_attack_active" in self.symbols:
            enemy_attack_active = self.monitor.mem_get(self.symbols["enemy_attack_active"], 1)[0] != 0
        frame_capture_ready = None
        if "frame_capture_ready" in self.symbols:
            frame_capture_ready = self.monitor.mem_get(self.symbols["frame_capture_ready"], 1)[0]
        score_total_data = None
        if "score_total_lo" in self.symbols:
            score_total_data = self.monitor.mem_get(self.symbols["score_total_lo"], 3)

        def vic(offset: int) -> int:
            return vic_data[offset - SPRITE0_X]

        def formation_slot_x(index: int) -> int:
            if formation_position_data is None:
                sprite_offsets = [SPRITE0_X, SPRITE3_X, SPRITE4_X, SPRITE5_X, SPRITE6_X, SPRITE7_X]
                sprite_bits = [0, 3, 4, 5, 6, 7]
                if index >= len(sprite_offsets):
                    return 0
                return combine_sprite_x(vic(sprite_offsets[index]), msb, sprite_bits[index])
            base = index * 2
            return formation_position_data[base] | (formation_position_data[base + 1] << 8)

        msb = vic(SPRITE_X_MSB)
        sprite_enable = vic(SPRITE_ENABLE)
        active_sprite_slots = [index for index in range(8) if sprite_enable & (1 << index)]
        shot_sprite_enabled = (sprite_enable & SHOT_SPRITE_MASK) != 0
        slot_rows = [self.slot_visual_y({}, index) for index in range(formation_slot_count)]
        active_formation_rows = [
            slot_rows[index]
            for index in range(formation_slot_count)
            if (alive_data[index] != 0 if alive_data is not None else True)
            and not (dive_active and dive_slot == index)
        ]
        formation_logical_alive_count = sum(
            1 for index in range(formation_slot_count) if alive_data[index] != 0
        ) if alive_data is not None else sum(
            1
            for mask in self.formation_sprite_masks
            if sprite_enable & mask
        )
        state = {
            "player_x": combine_sprite_x(vic(SPRITE1_X), msb, 1),
            "player_y": vic(SPRITE1_Y),
            "formation_y": min(active_formation_rows) if active_formation_rows else vic(SPRITE0_Y),
            "shot_x": combine_sprite_x(vic(SPRITE2_X), msb, 2),
            "shot_y": vic(SPRITE2_Y),
            "shot_active": shot_active if shot_active is not None else shot_sprite_enabled,
            "player_respawn_timer": player_respawn_timer,
            "player_extra_visible": player_extra_visible,
            "player_explosion_active": player_explosion_active,
            "player_bottom_sprite_mask_debug": player_bottom_sprite_mask_debug,
            "game_state": game_state,
            "sprite_enable": sprite_enable,
            "sprite_x_msb": msb,
            "active_sprite_slots": active_sprite_slots,
            "player_enabled": (sprite_enable & 0x02) != 0,
            "shot_enabled": shot_sprite_enabled,
            "formation_renderer_mode": formation_renderer_mode,
            "formation_renderer_mode_name": describe_renderer_mode(formation_renderer_mode),
            "formation_slot_count": formation_slot_count,
            "formation_logical_alive_count": formation_logical_alive_count,
            "formation_char_render_mask": formation_char_render_mask,
            "formation_shift_phase": formation_shift_phase,
            "raster_phase": raster_phase,
            "raster_line": vic(RASTER),
            "formation_render_start_phase": formation_render_start_phase,
            "formation_render_start_raster": formation_render_start_raster,
            "formation_render_top_row_end_phase": formation_render_top_row_end_phase,
            "formation_render_top_row_end_raster": formation_render_top_row_end_raster,
            "formation_render_end_phase": formation_render_end_phase,
            "formation_render_end_raster": formation_render_end_raster,
            "formation_shared_cache_update_counter": formation_shared_cache_update_counter,
            "formation_shared_cache_update_start_phase": formation_shared_cache_update_start_phase,
            "formation_shared_cache_update_start_raster": formation_shared_cache_update_start_raster,
            "formation_shared_cache_update_end_phase": formation_shared_cache_update_end_phase,
            "formation_shared_cache_update_end_raster": formation_shared_cache_update_end_raster,
            "frame_capture_counter": frame_capture_counter,
            "enemy_attack_active": enemy_attack_active,
            "frame_capture_ready": frame_capture_ready,
            "score_total": (
                score_bytes_to_int(
                    score_total_data[0],
                    score_total_data[1],
                    score_total_data[2],
                )
                if score_total_data is not None
                else None
            ),
            "score_total_lo": score_total_data[0] if score_total_data is not None else None,
            "score_total_mid": score_total_data[1] if score_total_data is not None else None,
            "score_total_hi": score_total_data[2] if score_total_data is not None else None,
            "dive_active": dive_active,
            "dive_slot": dive_slot,
            "dive_x": dive_x,
            "dive_y": dive_y,
            "dive_launch_counter": dive_launch_counter,
            "dive_launch_y": dive_launch_y,
            "dive_anim_frame": dive_anim_frame,
            "dive_anim_tick": dive_anim_tick,
            "dive_sprite_pointer": dive_sprite_pointer,
            "joystick_port_2": joystick_value,
            "joystick_left_pressed": (joystick_value & LEFT_MASK) == 0 if include_joystick else False,
            "joystick_right_pressed": (joystick_value & RIGHT_MASK) == 0 if include_joystick else False,
            "joystick_fire_pressed": (joystick_value & FIRE_MASK) == 0 if include_joystick else False,
        }
        for index in range(formation_slot_count):
            sprite_mask = self.formation_sprite_masks[index] if index < len(self.formation_sprite_masks) else 0
            state[f"formation_{index}_x"] = formation_slot_x(index)
            state[f"formation_{index}_enabled"] = bool(sprite_mask and (sprite_enable & sprite_mask))
            state[f"formation_{index}_alive"] = (
                alive_data[index] != 0 if alive_data is not None else bool(sprite_mask and (sprite_enable & sprite_mask))
            )
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
            "capture_mode": None,
        }
        if self.host_capture_enabled and not self.suppress_host_capture:
            screenshot_path = self.args.frames_dir / f"{self.sample_counter:03d}-{stage}.png"
            try:
                screenshot_settle_seconds = getattr(self.args, "screenshot_settle_seconds", 0.0)
                if screenshot_settle_seconds > 0:
                    time.sleep(screenshot_settle_seconds)
                screenshot_hash, capture_mode = self.gui.capture_window(screenshot_path)
            except PlaytestFailure as exc:
                self.host_capture_enabled = False
                self.host_capture_failure = str(exc)
                self.logger.log(
                    f"Disabling host screenshot capture for the rest of the run: {self.host_capture_failure}"
                )
            else:
                sample["screenshot"] = str(screenshot_path)
                sample["screenshot_sha256"] = screenshot_hash
                sample["capture_mode"] = capture_mode
                self.capture_modes_seen.add(capture_mode)
                self.results["artifacts"]["capture_modes_seen"] = sorted(self.capture_modes_seen)
                self.results["artifacts"]["capture_mode"] = (
                    capture_mode if len(self.capture_modes_seen) == 1 else "mixed"
                )
        self.sample_counter += 1
        self.samples.append(sample)
        return sample

    def wait_for_render_complete(self, sample=None):
        if "frame_capture_ready" not in self.symbols:
            return sample if sample is not None else self.read_state(include_joystick=False)

        latest = sample if sample is not None else self.read_state(include_joystick=False)
        for _ in range(8):
            if latest.get("frame_capture_ready") == 1:
                return latest
            self.resume_for(0.01)
            latest = self.read_state(include_joystick=False)
        return latest

    def wait_for_game_ready(self):
        latest = None
        for _ in range(60):
            self.resume_for(0.25)
            latest = self.read_state(include_joystick=False)
            if (
                latest["player_enabled"]
                and latest["formation_logical_alive_count"] >= 1
                and latest["formation_renderer_mode"] == FORMATION_RENDERER_CHAR
                and latest["player_y"] > latest["formation_y"]
                and latest["player_y"] >= 180
                and latest["formation_y"] <= 100
            ):
                return latest
        raise PlaytestFailure(f"Timed out waiting for the game shell to appear: {latest}")

    def formation_top_slot_count(self) -> int:
        return self.symbols.get("FORMATION_TOP_SLOT_COUNT", 2)

    def formation_mid_slot_count(self) -> int:
        return self.symbols.get("FORMATION_MID_SLOT_COUNT", 2)

    def formation_mid_slot_end(self) -> int:
        return self.formation_top_slot_count() + self.formation_mid_slot_count()

    def preferred_bottom_target_slot(self) -> int:
        bottom_start = self.formation_mid_slot_end()
        bottom_count = max(self.formation_slot_count - bottom_start, 1)
        return min(bottom_start + max(bottom_count - 2, 0), self.formation_slot_count - 1)

    def formation_char_row(self, slot_index: int) -> int:
        table_symbol = self.symbols.get("formation_char_row_table")
        if table_symbol is not None and slot_index < self.formation_slot_count:
            return self.monitor.mem_get(table_symbol + slot_index, 1)[0]
        if slot_index < self.formation_top_slot_count():
            return self.symbols["FORMATION_CHAR_BAND_TOP_ROW"]
        if slot_index < self.formation_mid_slot_end():
            return self.symbols["FORMATION_CHAR_BAND_MID_ROW"]
        return self.symbols["FORMATION_CHAR_BAND_BOTTOM_ROW"]

    def formation_char_col(self, sample, slot_index: int) -> int:
        playfield_left = self.symbols["PLAYFIELD_LEFT_X_LO"] + (self.symbols["PLAYFIELD_LEFT_X_HI"] << 8)
        relative_x = sample[f"formation_{slot_index}_x"] - playfield_left
        shift_phase = sample.get("formation_shift_phase") or 0
        return ((relative_x - shift_phase) >> 3) + self.symbols[
            "FORMATION_CHAR_BAND_ORIGIN_COL"
        ]

    def char_code_is_visually_blank(self, value: int) -> bool:
        if value == 0x20:
            return True
        required_symbols = {"CHARSET_RAM"}
        missing = sorted(required_symbols - self.symbols.keys())
        self.assert_true(
            "formation_char_charset_symbols_present",
            not missing,
            {"missing": missing, "symbols": self.symbols},
        )
        bitmap = self.monitor.mem_get(self.symbols["CHARSET_RAM"] + (value * 8), 8)
        return not any(bitmap)

    def formation_char_cells(self, sample, slot_index: int):
        required_symbols = {"SCREEN_RAM", "CHARSET_RAM"}
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
        visual_blank = []
        band_width = self.symbols.get("FORMATION_CHAR_BAND_WIDTH", 40)
        slot_stride = self.symbols.get("FORMATION_CHAR_SLOT_STRIDE", 4)
        for offset in range(slot_stride):
            probe_col = col + offset
            if probe_col >= band_width:
                addresses.append(None)
                values.append(0x20)
                visual_blank.append(True)
                continue
            address = self.symbols["SCREEN_RAM"] + (row * 40) + probe_col
            value = self.monitor.mem_get(address, 1)[0]
            addresses.append(address)
            values.append(value)
            visual_blank.append(self.char_code_is_visually_blank(value))
        return {
            "row": row,
            "col": col,
            "values": values,
            "addresses": addresses,
            "visual_blank": visual_blank,
        }

    def slot_visual_y(self, sample, slot_index: int) -> int:
        table_symbol = self.symbols.get("formation_slot_visual_y_table")
        if table_symbol is not None and slot_index < self.formation_slot_count:
            return self.monitor.mem_get(table_symbol + slot_index, 1)[0]
        playfield_top_y = self.symbols.get("PLAYFIELD_TOP_Y", self.symbols["FORMATION_TOP_Y"])
        trim_top_rows = self.symbols.get("FORMATION_CHAR_TRIM_TOP_ROWS", 0)
        top_y = self.symbols.get(
            "FORMATION_CHAR_TOP_Y",
            playfield_top_y + (self.symbols.get("FORMATION_CHAR_BAND_TOP_ROW", 0) * 8) - trim_top_rows,
        )
        mid_y = self.symbols.get(
            "FORMATION_CHAR_MID_Y",
            playfield_top_y + (self.symbols.get("FORMATION_CHAR_BAND_MID_ROW", 0) * 8) - trim_top_rows,
        )
        bottom_y = self.symbols.get(
            "FORMATION_CHAR_BOTTOM_Y",
            playfield_top_y + (self.symbols.get("FORMATION_CHAR_BAND_BOTTOM_ROW", 0) * 8) - trim_top_rows,
        )
        if slot_index < self.formation_top_slot_count():
            return top_y
        if slot_index < self.formation_mid_slot_end():
            return mid_y
        return bottom_y

    def assert_char_renderer_output(self, name: str, sample):
        sample = self.wait_for_render_complete(sample)
        if sample.get("formation_char_render_mask") is not None and self.formation_slot_count <= 24:
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
            "CHARSET_RAM",
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
            latest_sample = self.wait_for_render_complete(latest_sample)
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
                        if not self.char_code_is_visually_blank(probe_value):
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
        self.assert_true(
            f"{name}_char_mode",
            sample["formation_renderer_mode"] == FORMATION_RENDERER_CHAR,
            sample,
        )
        self.assert_char_renderer_output(name, sample)

    def assert_char_ready_without_pack_sprites(self, name: str):
        sample = self.wait_for_sample_matching(
            name,
            lambda current: (
                not current.get("shot_enabled")
                and not current.get("dive_active")
                and not current.get("player_explosion_active")
            ),
        )
        self.assert_char_renderer_output(f"{name}_char_output", sample)
        self.assert_true(
            f"{name}_dynamic_slots",
            all(slot in {1, 3, 4} for slot in self.effective_sprite_slots(sample)),
            sample,
        )
        self.record_step(name, "passed", sample)
        return sample

    def assert_char_slot_blank(self, name: str, sample, slot_index: int):
        attempts = []
        latest_sample = sample
        for attempt in range(4):
            latest_sample = self.wait_for_render_complete(latest_sample)
            cells = self.formation_char_cells(latest_sample, slot_index)
            required_blank = self.required_gap_blank_cells(latest_sample, slot_index)
            attempts.append(
                {
                    "sample": latest_sample,
                    "slot": slot_index,
                    "cells": cells,
                    "required_blank": required_blank,
                }
            )
            if all(
                (not must_be_blank) or is_blank
                for must_be_blank, is_blank in zip(required_blank, cells["visual_blank"])
            ):
                return cells
            if attempt < 3:
                self.resume_for(0.05)
                latest_sample = self.read_state(include_joystick=False)

        self.assert_true(name, False, {"attempts": attempts})

    def required_gap_blank_cells(self, sample, slot_index: int) -> list[bool]:
        slot_row = self.formation_char_row(slot_index)
        slot_x = sample[f"formation_{slot_index}_x"]
        slot_stride = self.symbols.get("FORMATION_CHAR_SLOT_STRIDE", 4)
        slot_width_pixels = slot_stride * 8
        required_blank = [True] * slot_stride
        for slot in self.live_formation_slots(sample):
            if slot["index"] == slot_index:
                continue
            if self.formation_char_row(slot["index"]) != slot_row:
                continue
            delta_x = slot["x"] - slot_x
            if 0 < delta_x < slot_width_pixels:
                overlap_cells = max(1, ((slot_width_pixels - delta_x) + 7) // 8)
                for offset in range(slot_stride - overlap_cells, slot_stride):
                    required_blank[offset] = False
            elif -slot_width_pixels < delta_x < 0:
                overlap_cells = max(1, ((slot_width_pixels + delta_x) + 7) // 8)
                for offset in range(overlap_cells):
                    required_blank[offset] = False
        return required_blank

    def capture_shot_active_slots(self, name: str, launch_sample):
        sample = self.wait_for_sample_matching(
            name,
            lambda current: current.get("shot_enabled"),
            initial_sample=launch_sample,
        )
        self.record_step(name, "passed", sample)
        return sample

    def capture_miss_shot_active_slots(self, name: str):
        self.logger.log("Firing a deliberate miss so the active shot sprite allocation can be sampled")
        launch = self.fire_once(name)
        sample = self.capture_shot_active_slots(f"{name}-active", launch)
        self.wait_for_sample_matching(
            f"{name}-clear",
            lambda current: not current.get("shot_enabled"),
            max_samples=40,
            sample_interval=0.15,
            initial_sample=sample,
        )
        return sample

    def provoke_player_hit_and_verify_layers(self, name: str):
        self.logger.log("Steering into an incoming dive to verify player explosion and respawn layering")
        attempts = []

        for attempt in range(1, 5):
            launch = self.wait_for_active_dive(
                f"{name}-launch-{attempt}",
                max_samples=30,
                sample_interval=0.25,
            )
            attempt_detail = {
                "attempt": attempt,
                "launch_sample": launch,
                "observations": [],
            }
            current = launch

            for watch_index in range(48):
                if watch_index > 0:
                    self.resume_for(0.10)
                    current = self.capture_sample(
                        f"{name}-attempt-{attempt}-watch-{watch_index}",
                        include_joystick=False,
                    )
                attempt_detail["observations"].append(current)

                if current.get("player_explosion_active"):
                    attempt_detail["hit_sample"] = current
                    explosion_sample = self.wait_for_sample_matching(
                        f"{name}-explosion-{attempt}",
                        lambda sample: (
                            sample.get("player_explosion_active")
                            and all(slot in self.effective_sprite_slots(sample) for slot in (1, 2, 3, 4))
                        ),
                        initial_sample=current,
                    )
                    self.assert_true(
                        f"{name}_explosion_slots",
                        all(slot in self.effective_sprite_slots(explosion_sample) for slot in (1, 2, 3, 4)),
                        explosion_sample,
                    )
                    respawn_sample = self.wait_for_sample_matching(
                        f"{name}-respawn-{attempt}",
                        lambda sample: (
                            not sample.get("player_explosion_active")
                            and sample.get("player_respawn_timer") not in (None, 0)
                            and all(slot in self.effective_sprite_slots(sample) for slot in (1, 3, 4))
                            and 2 not in self.effective_sprite_slots(sample)
                        ),
                    )
                    self.assert_true(
                        f"{name}_respawn_slots",
                        all(slot in self.effective_sprite_slots(respawn_sample) for slot in (1, 3, 4))
                        and 2 not in self.effective_sprite_slots(respawn_sample),
                        respawn_sample,
                    )
                    result = {
                        "hit_sample": current,
                        "explosion_sample": explosion_sample,
                        "respawn_sample": respawn_sample,
                        "attempt": attempt,
                    }
                    self.record_step(name, "passed", result)
                    return result

                if not current.get("dive_active"):
                    attempt_detail["result"] = "dive_ended"
                    attempt_detail["final_sample"] = current
                    break

                dive_x = current.get("dive_x")
                if dive_x is None:
                    continue
                delta_x = current["player_x"] - dive_x
                if abs(delta_x) <= 6:
                    continue

                key_code = LEFT_KEY_CODE if delta_x > 0 else RIGHT_KEY_CODE
                self.gui.key_down(key_code)
                try:
                    self.resume_for(self.dive_tracking_burst_seconds(delta_x))
                finally:
                    self.gui.key_up(key_code)
            else:
                attempt_detail["result"] = "timeout"
                attempt_detail["final_sample"] = current

            attempts.append(attempt_detail)

        raise PlaytestFailure(f"{name}_timeout: {attempts}")

    def expected_score_award(self, slot_index: int) -> int:
        if slot_index < self.formation_top_slot_count():
            return 80
        if slot_index < self.formation_mid_slot_end():
            return 50
        return 30

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
        slot_count = sample.get("formation_slot_count", self.formation_slot_count)
        return [
            {
                "index": index,
                "x": sample[f"formation_{index}_x"],
                "alive": sample[f"formation_{index}_alive"],
            }
            for index in range(slot_count)
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

    def sprite_slot_enabled(self, sample, slot_index: int) -> bool:
        return slot_index in sample.get("active_sprite_slots", [])

    def effective_sprite_slots(self, sample):
        mask = sample.get("sprite_enable", 0)
        debug_mask = sample.get("player_bottom_sprite_mask_debug")
        if debug_mask is not None:
            mask |= debug_mask
        return [index for index in range(8) if mask & (1 << index)]

    def wait_for_sample_matching(
        self,
        name: str,
        predicate,
        max_samples: int = 24,
        sample_interval: float = 0.07,
        initial_sample=None,
    ):
        attempts = []
        if initial_sample is not None:
            attempts.append(initial_sample)
            if predicate(initial_sample):
                return initial_sample
        for index in range(max_samples):
            self.resume_for(sample_interval)
            sample = self.capture_sample(f"{name}-{index}", include_joystick=False)
            attempts.append(sample)
            if predicate(sample):
                return sample
        raise PlaytestFailure(f"{name}_timeout: {attempts}")

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

    def wait_for_active_dive(self, name: str, max_samples: int = 24, sample_interval: float = 0.35):
        attempts = []
        for index in range(max_samples):
            self.resume_for(sample_interval)
            sample = self.capture_sample(f"{name}-{index}", include_joystick=False)
            attempts.append(sample)
            if sample["dive_active"] and sample["dive_slot"] is not None:
                return sample
        raise PlaytestFailure(f"{name}_timeout: {attempts}")

    def wait_for_next_dive_launch(
        self,
        name: str,
        previous_counter: int,
        max_samples: int = 240,
        sample_interval: float = 0.05,
    ):
        attempts = []
        for index in range(max_samples):
            self.resume_for(sample_interval)
            sample = self.capture_sample(f"{name}-{index}", include_joystick=False)
            attempts.append(sample)
            if (
                sample.get("dive_launch_counter") is not None
                and sample["dive_launch_counter"] != previous_counter
                and sample.get("dive_active")
                and sample.get("dive_slot") is not None
            ):
                return sample
        raise PlaytestFailure(f"{name}_timeout: {attempts}")

    def capture_dive_renderer_state(self, sample, dive_slot: int):
        sample = self.wait_for_render_complete(sample)
        cells = self.formation_char_cells(sample, dive_slot)
        dive_sprite_slot = self.symbols.get("DIVE_VIC_SPRITE_SLOT", 0)
        sprite_enabled = self.sprite_slot_enabled(sample, dive_sprite_slot)
        char_blank = all(cells["visual_blank"])
        return {
            "sample": sample,
            "dive_slot": dive_slot,
            "dive_sprite_slot": dive_sprite_slot,
            "sprite_enabled": sprite_enabled,
            "char_cells": cells,
            "char_blank": char_blank,
            "dive_renderer_state": {
                "mode": "sprite_only" if sprite_enabled and char_blank else "mixed",
                "formation_renderer_mode": sample.get("formation_renderer_mode_name"),
                "dive_sprite_slot": dive_sprite_slot,
                "sprite_enabled": sprite_enabled,
                "char_blank": char_blank,
            },
        }

    def assert_char_dive_launch_positions(self, name: str):
        self.logger.log("Checking the slot launch Y tables and sampling the first armed dive pair")
        initial = self.read_state(include_joystick=False)
        previous_counter = initial.get("dive_launch_counter")
        visual_y_table_symbol = self.symbols.get("formation_slot_visual_y_table")
        self.assert_true(
            f"{name}_launch_symbols_present",
            previous_counter is not None
            and "FORMATION_TOP_Y" in self.symbols
            and "FORMATION_MID_Y" in self.symbols
            and "FORMATION_BOTTOM_Y" in self.symbols,
            {"initial": initial, "symbols": self.symbols},
        )
        self.assert_true(
            f"{name}_launch_table_symbols_present",
            visual_y_table_symbol is not None,
            {"symbols": self.symbols},
        )

        visual_y_table = list(self.monitor.mem_get(visual_y_table_symbol, self.formation_slot_count))
        expected_visual_y_table = [
            self.slot_visual_y({}, slot_index)
            for slot_index in range(self.formation_slot_count)
        ]
        self.assert_true(
            f"{name}_visual_y_table",
            visual_y_table == expected_visual_y_table,
            {
                "expected": expected_visual_y_table,
                "actual": visual_y_table,
            },
        )

        expected_order = [4, 5]
        launches = []
        for expected_slot in expected_order:
            launch = self.wait_for_next_dive_launch(
                f"{name}-slot-{expected_slot}",
                previous_counter,
            )
            previous_counter = launch["dive_launch_counter"]
            expected_y = self.slot_visual_y(launch, expected_slot)
            detail = {
                "expected_slot": expected_slot,
                "expected_y": expected_y,
                "launch": launch,
            }
            self.assert_true(
                f"{name}_slot_{expected_slot}_order",
                launch["dive_slot"] == expected_slot,
                detail,
            )
            self.assert_true(
                f"{name}_slot_{expected_slot}_y",
                launch.get("dive_launch_y") == expected_y,
                detail,
            )
            launches.append(
                {
                    "slot": expected_slot,
                    "launch_counter": launch["dive_launch_counter"],
                    "dive_launch_y": launch.get("dive_launch_y"),
                    "expected_y": expected_y,
                }
            )

        detail = {
            "launches": launches,
            "visual_y_table": visual_y_table,
        }
        self.record_step(name, "passed", detail)
        return detail

    def assert_char_dive_handoff(self, name: str):
        self.logger.log("Watching for a char-mode dive so the sprite handoff can be inspected")
        launch = self.wait_for_active_dive(name)
        dive_slot = launch["dive_slot"]
        observations = [self.capture_dive_renderer_state(launch, dive_slot)]
        dive_sprite_slot = self.symbols.get("DIVE_VIC_SPRITE_SLOT", 0)
        sprite_sample = self.wait_for_sample_matching(
            f"{name}-sprite-sample",
            lambda sample: (
                sample["dive_active"]
                and sample["dive_slot"] == dive_slot
                and self.sprite_slot_enabled(sample, dive_sprite_slot)
            ),
            initial_sample=launch,
        )

        while len(observations) < 3:
            self.resume_for(0.35)
            sample = self.capture_sample(f"{name}-observe-{len(observations)}", include_joystick=False)
            if not (sample["dive_active"] and sample["dive_slot"] == dive_slot):
                break
            observations.append(self.capture_dive_renderer_state(sample, dive_slot))

        self.assert_true(
            f"{name}_dive_active",
            all(item["sample"]["dive_active"] for item in observations),
            {"observations": observations},
        )
        self.assert_true(
            f"{name}_sprite_enabled",
            all(item["sprite_enabled"] for item in observations),
            {"observations": observations},
        )
        self.assert_true(
            f"{name}_char_slot_blank",
            all(item["char_blank"] for item in observations),
            {"observations": observations},
        )
        result = {
            "observations": observations,
            "dive_launch_slot": dive_slot,
            "dive_renderer_state": observations[-1]["dive_renderer_state"],
            "sprite_sample": sprite_sample,
            "last_sample": observations[-1]["sample"],
        }
        self.record_step(name, "passed", result)
        return result

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

    def dive_tracking_burst_seconds(self, delta: int) -> float:
        distance = abs(delta)
        if distance > 96:
            return 0.14
        if distance > 40:
            return 0.09
        return 0.05

    def align_player_with_formation_slot(self, preferred_index: Optional[int] = None):
        self.logger.log("Aligning the player ship under a live formation slot before firing")
        if preferred_index is None:
            preferred_index = self.preferred_bottom_target_slot()
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

    def align_player_with_gap(self):
        self.logger.log("Aligning the player ship under a persistent gap before arming enemy dives")
        playing_state = self.symbols.get("GAME_STATE_PLAYING", 1)
        player_min_x = self.symbols["PLAYER_MIN_X_LO"] + (self.symbols["PLAYER_MIN_X_HI"] << 8)
        player_max_x = self.symbols["PLAYER_MAX_X_LO"] + (self.symbols["PLAYER_MAX_X_HI"] << 8)
        last_detail = None
        for _ in range(40):
            current = self.capture_sample("gap-align-check", include_joystick=False)
            if (
                not current.get("player_enabled")
                or current.get("player_explosion_active")
                or current.get("player_respawn_timer", 0) != 0
                or current.get("game_state") != playing_state
            ):
                last_detail = {"slot": None, "sample": current, "mode": "waiting-for-recovery"}
                self.resume_for(0.15)
                continue

            dead_slots = [slot for slot in self.formation_slots(current) if not slot["alive"]]
            if not dead_slots:
                detail = {"slot": None, "sample": current, "mode": "no-gap"}
                self.record_step("player_gap_aligned", "skipped", detail)
                return detail

            reachable_dead_slots = [
                slot
                for slot in dead_slots
                if (player_min_x - 10) <= slot["x"] <= (player_max_x + 10)
            ]
            if not reachable_dead_slots:
                target_slot = min(dead_slots, key=lambda slot: abs(slot["x"] - current["player_x"]))
                last_detail = {
                    "slot": target_slot["index"],
                    "sample": current,
                    "mode": "gap-out-of-range",
                }
                self.resume_for(0.15)
                continue

            target_slot = min(reachable_dead_slots, key=lambda slot: abs(slot["x"] - current["player_x"]))
            delta = current["player_x"] - target_slot["x"]
            last_detail = {"slot": target_slot["index"], "sample": current, "mode": "gap"}
            if abs(delta) <= 10:
                self.record_step("player_gap_aligned", "passed", last_detail)
                return last_detail

            key_code = LEFT_KEY_CODE if delta > 0 else RIGHT_KEY_CODE
            self.gui.key_down(key_code)
            try:
                self.resume_for(self.alignment_burst_seconds(delta))
            finally:
                self.gui.key_up(key_code)

        raise PlaytestFailure(f"player_gap_alignment_timeout: {last_detail}")

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
                or self.total_formation_alive_count(launched) < self.formation_slot_count,
                launched,
            )
            return launched
        finally:
            self.gui.key_up(FIRE_KEY_CODE)

    def arm_enemy_attacks(self):
        self.wait_for_sample_matching(
            "enemy-attack-arm-ready",
            lambda sample: (
                sample.get("player_enabled")
                and not sample.get("player_explosion_active")
                and sample.get("game_state") == self.symbols.get("GAME_STATE_PLAYING", 1)
            ),
            max_samples=120,
            sample_interval=0.15,
        )
        self.align_player_with_gap()
        self.logger.log("Firing once through the current gap to arm enemy dives")
        launch = self.fire_once(0)
        self.assert_true(
            "enemy_attack_armed",
            bool(launch.get("enemy_attack_active")),
            launch,
        )

        last_sample = launch
        for _ in range(20):
            if not last_sample["shot_enabled"]:
                self.record_step("enemy_attack_armed", "passed", last_sample)
                return last_sample
            self.resume_for(0.15)
            last_sample = self.capture_sample("enemy-attack-arm-watch", include_joystick=False)

        self.record_step("enemy_attack_armed", "passed", last_sample)
        return last_sample

    def resolve_dive_and_verify_gap(self, name: str, initial_sample=None):
        self.logger.log("Waiting for a dive to resolve and checking that the existing gaps stay stable")
        baseline_state = self.read_state(include_joystick=False)
        baseline_alive_count = self.total_formation_alive_count(baseline_state)
        baseline_destroyed_slots = [
            slot["index"] for slot in self.formation_slots(baseline_state) if not slot["alive"]
        ]
        baseline_score_total = baseline_state.get("score_total")
        attempts = []

        for attempt in range(1, 5):
            if (
                attempt == 1
                and initial_sample is not None
                and initial_sample["dive_active"]
                and initial_sample["dive_slot"] is not None
            ):
                launch = initial_sample
            else:
                if attempt > 1:
                    self.arm_enemy_attacks()
                else:
                    current_state = self.read_state(include_joystick=False)
                    if not current_state.get("enemy_attack_active"):
                        self.arm_enemy_attacks()
                launch = self.wait_for_active_dive(
                    f"{name}-launch-{attempt}",
                    max_samples=30,
                    sample_interval=0.25,
                )
            dive_slot = launch["dive_slot"]
            attempt_detail = {
                "attempt": attempt,
                "dive_slot": dive_slot,
                "launch_sample": launch,
                "baseline_destroyed_slots": baseline_destroyed_slots,
                "score_before": baseline_score_total,
                "observations": [],
            }
            current = launch

            for watch_index in range(48):
                if watch_index > 0:
                    self.resume_for(0.12)
                    current = self.capture_sample(
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

                if current.get("player_explosion_active"):
                    attempt_detail["result"] = "player_hit"
                    attempt_detail["final_sample"] = current
                    break

                if current["dive_active"] and current["dive_slot"] == dive_slot:
                    continue

                self.resume_for(0.8)
                follow_up = self.capture_sample(f"{name}-follow-up-{attempt}", include_joystick=False)
                destroyed_slots = [
                    slot["index"] for slot in self.formation_slots(follow_up) if not slot["alive"]
                ]
                attempt_detail["follow_up_sample"] = follow_up
                attempt_detail["destroyed_slots"] = destroyed_slots
                attempt_detail["score_after"] = follow_up.get("score_total")
                if baseline_score_total is not None and attempt_detail["score_after"] is not None:
                    attempt_detail["score_delta"] = attempt_detail["score_after"] - baseline_score_total

                if destroyed_slots == baseline_destroyed_slots and follow_up[f"formation_{dive_slot}_alive"]:
                    attempt_detail["result"] = "exit"
                    self.assert_true(
                        f"{name}_alive_count",
                        self.total_formation_alive_count(follow_up) == baseline_alive_count,
                        {
                            "baseline_alive_count": baseline_alive_count,
                            "follow_up": follow_up,
                        },
                    )
                    if attempt_detail.get("score_delta") is not None:
                        self.assert_true(
                            f"{name}_score_unchanged",
                            attempt_detail["score_delta"] == 0,
                            attempt_detail,
                        )
                    self.record_step(name, "passed", attempt_detail)
                    return attempt_detail

                if (
                    destroyed_slots == sorted(baseline_destroyed_slots + [dive_slot])
                    and not follow_up[f"formation_{dive_slot}_alive"]
                ):
                    attempt_detail["result"] = "hit"
                    attempt_detail["gap_char_cells"] = self.assert_char_slot_blank(
                        f"{name}_slot_blank_after_hit",
                        follow_up,
                        dive_slot,
                    )
                    self.assert_true(
                        f"{name}_alive_count",
                        self.total_formation_alive_count(follow_up) == baseline_alive_count - 1,
                        {
                            "baseline_alive_count": baseline_alive_count,
                            "follow_up": follow_up,
                        },
                    )
                    if baseline_score_total is not None and attempt_detail["score_after"] is not None:
                        attempt_detail["score_expected"] = self.expected_score_award(dive_slot)
                        self.assert_true(
                            f"{name}_score_award",
                            attempt_detail.get("score_delta") == attempt_detail.get("score_expected"),
                            attempt_detail,
                        )
                    self.record_step(name, "passed", attempt_detail)
                    return attempt_detail

                attempt_detail["result"] = "unexpected_gap_change"
                attempt_detail["final_sample"] = current
                break
            else:
                attempt_detail["result"] = "timeout"
                attempt_detail["final_sample"] = current

            attempts.append(attempt_detail)

        raise PlaytestFailure(f"{name}_timeout: {attempts}")

    def destroy_formation_member(self):
        attempts = []
        baseline_state = self.read_state(include_joystick=False)
        initial_alive_count = self.total_formation_alive_count(baseline_state)
        initial_score_total = baseline_state.get("score_total")
        for attempt in range(1, 5):
            alignment = self.align_player_with_formation_slot(
                preferred_index=self.preferred_bottom_target_slot()
            )
            launch = self.fire_once(attempt)
            attempt_detail = {
                "attempt": attempt,
                "target_slot": alignment["slot"],
                "aligned_sample": alignment["sample"],
                "launch_sample": launch,
                "shot_seen": launch["shot_enabled"],
                "score_before": initial_score_total,
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
                    attempt_detail["score_after"] = watch_sample.get("score_total")
                    if (
                        initial_score_total is not None
                        and attempt_detail["score_after"] is not None
                        and len(attempt_detail["destroyed_slots"]) == 1
                    ):
                        destroyed_slot = attempt_detail["destroyed_slots"][0]
                        attempt_detail["score_expected"] = self.expected_score_award(destroyed_slot)
                        attempt_detail["score_delta"] = (
                            attempt_detail["score_after"] - initial_score_total
                        )
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
        destroyed_slot = destroyed_slots[0]
        self.assert_true(
            "gap_alive_count",
            self.total_formation_alive_count(follow_up) == self.formation_slot_count - 1,
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
            "gap_logical_slot_stays_dead",
            not follow_up[f"formation_{destroyed_slot}_alive"],
            {"destroyed_slot": destroyed_slot, "sample": follow_up},
        )
        gap_char_cells = self.assert_char_slot_blank(
            "gap_char_slot_blank_after_hit",
            follow_up,
            destroyed_slot,
        )
        self.assert_true(
            "formation_continues_after_hit",
            self.leftmost_formation_x(hit_sample) != self.leftmost_formation_x(follow_up),
            {"hit_sample": hit_sample, "follow_up": follow_up},
        )
        self.record_step(
            "gap_persists",
            "passed",
            {
                "destroyed_slots": destroyed_slots,
                "sample": follow_up,
                "gap_char_cells": gap_char_cells,
            },
        )
        return follow_up

    def assert_post_dive_idle_motion(self, name: str, expected_destroyed_slots, initial_sample):
        self.logger.log("Checking that the formation returns to idle motion after the dive resolves")
        expected_destroyed_slots = sorted(expected_destroyed_slots)
        playing_state = self.symbols.get("GAME_STATE_PLAYING", 1)
        recovered = self.wait_for_sample_matching(
            f"{name}-recovered",
            lambda sample: (
                sample.get("player_enabled")
                and not sample.get("shot_enabled")
                and not sample.get("dive_active")
                and not sample.get("player_explosion_active")
                and sample.get("game_state") == playing_state
            ),
            max_samples=120,
            sample_interval=0.15,
            initial_sample=initial_sample,
        )
        recovered_destroyed_slots = [
            slot["index"] for slot in self.formation_slots(recovered) if not slot["alive"]
        ]
        self.assert_true(
            f"{name}_same_dead_slots",
            recovered_destroyed_slots == expected_destroyed_slots,
            {
                "expected_destroyed_slots": expected_destroyed_slots,
                "actual_destroyed_slots": recovered_destroyed_slots,
                "sample": recovered,
            },
        )
        gap_cells = [
            {
                "slot": slot_index,
                "cells": self.assert_char_slot_blank(f"{name}_slot_{slot_index}_blank", recovered, slot_index),
            }
            for slot_index in expected_destroyed_slots
        ]
        self.assert_char_renderer_output(f"{name}_char_output", recovered)

        moving = self.wait_for_sample_matching(
            f"{name}-moving",
            lambda sample: (
                sample.get("player_enabled")
                and not sample.get("shot_enabled")
                and not sample.get("dive_active")
                and not sample.get("player_explosion_active")
                and sample.get("game_state") == playing_state
                and self.leftmost_formation_x(sample) != self.leftmost_formation_x(recovered)
            ),
            max_samples=24,
            sample_interval=0.08,
        )
        moving_destroyed_slots = [
            slot["index"] for slot in self.formation_slots(moving) if not slot["alive"]
        ]
        self.assert_true(
            f"{name}_still_idle",
            moving.get("player_enabled")
            and not moving.get("shot_enabled")
            and not moving.get("dive_active")
            and not moving.get("player_explosion_active")
            and moving.get("game_state") == playing_state,
            moving,
        )
        self.assert_true(
            f"{name}_dead_slots_persist",
            moving_destroyed_slots == expected_destroyed_slots,
            {
                "expected_destroyed_slots": expected_destroyed_slots,
                "actual_destroyed_slots": moving_destroyed_slots,
                "sample": moving,
            },
        )
        self.assert_true(
            f"{name}_formation_moves",
            self.leftmost_formation_x(recovered) != self.leftmost_formation_x(moving),
            {"recovered": recovered, "moving": moving},
        )
        result = {
            "destroyed_slots": expected_destroyed_slots,
            "gap_cells": gap_cells,
            "recovered_sample": recovered,
            "moving_sample": moving,
        }
        self.record_step(name, "passed", result)
        return result

    def run(self):
        self.launch_vice()
        ready_state = self.wait_for_game_ready()
        self.record_step("game_ready", "passed", ready_state)
        if "player_lives" in self.symbols:
            # Give the scripted run headroom for movement-only tuning changes.
            self.monitor.mem_set(self.symbols["player_lives"], bytes([9]))

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
        ready_sprite_sample = self.assert_char_ready_without_pack_sprites(
            "ready_state_pack_free_of_sprite_bits"
        )

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
        shot_active_sample = self.capture_miss_shot_active_slots("summary-shot")

        bounce_state = self.wait_for_formation_bounce()
        self.assert_true("formation_moves", bounce_state["moved"], bounce_state)
        self.assert_true(
            "formation_bounces",
            bounce_state["positive_seen"] and bounce_state["negative_seen"],
            bounce_state,
        )
        playing_state = self.symbols.get("GAME_STATE_PLAYING", 1)
        char_motion_state = self.assert_char_renderer_motion("formation_char_motion_visible")
        dive_handoff_state = None
        dive_resolution_state = None
        post_dive_idle_state = None

        hit_state = self.destroy_formation_member()
        self.assert_true(
            "one_slot_destroyed",
            len(hit_state["destroyed_slots"]) == 1,
            hit_state,
        )
        if hit_state.get("score_expected") is not None:
            self.assert_true(
                "score_award_after_hit",
                hit_state.get("score_delta") == hit_state.get("score_expected"),
                hit_state,
            )
        gap_state = self.verify_gap_persists(hit_state["destroyed_slots"], hit_state["final_sample"])
        self.arm_enemy_attacks()
        dive_handoff_state = self.run_without_host_capture(
            self.assert_char_dive_handoff,
            "formation_char_dive_handoff",
        )
        self.wait_for_sample_matching(
            "post_handoff_recovered",
            lambda sample: (
                sample.get("player_enabled")
                and not sample.get("player_explosion_active")
                and sample.get("game_state") == playing_state
            ),
            max_samples=120,
            sample_interval=0.15,
        )
        armed_dive_state = self.arm_enemy_attacks()
        dive_resolution_state = self.run_without_host_capture(
            self.resolve_dive_and_verify_gap,
            "formation_char_dive_resolved",
            initial_sample=armed_dive_state,
        )
        post_dive_idle_state = self.assert_post_dive_idle_motion(
            "pack_gap_dive_idle_regression",
            dive_resolution_state["destroyed_slots"],
            dive_resolution_state["follow_up_sample"],
        )

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
            "formation_char_motion_samples": len(char_motion_state["transitions"]),
            "formation_char_dive_samples": len(dive_handoff_state["observations"]),
            "dive_launch_slot": dive_handoff_state["dive_launch_slot"],
            "dive_renderer_state": dive_handoff_state["dive_renderer_state"],
            "shot_attempts": hit_state["attempt"],
            "destroyed_slots": hit_state["destroyed_slots"],
            "score_after_hit": hit_state.get("score_after"),
            "score_delta": hit_state.get("score_delta"),
            "dive_resolution": dive_resolution_state.get("result"),
            "dive_resolved_slot": dive_resolution_state.get("dive_slot"),
            "dive_score_delta": dive_resolution_state.get("score_delta"),
            "alive_slots_after_hit": self.total_formation_alive_count(gap_state),
            "post_dive_idle_destroyed_slots": post_dive_idle_state["destroyed_slots"],
            "post_dive_idle_motion_delta": (
                self.leftmost_formation_x(post_dive_idle_state["moving_sample"])
                - self.leftmost_formation_x(post_dive_idle_state["recovered_sample"])
            ),
            "sprite_slots_by_state": {
                "ready": self.effective_sprite_slots(ready_sprite_sample),
                "shot_active": self.effective_sprite_slots(shot_active_sample),
                "dive_active": self.effective_sprite_slots(dive_handoff_state["sprite_sample"]),
            },
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
    parser.add_argument("--window-width", type=int, default=768)
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
