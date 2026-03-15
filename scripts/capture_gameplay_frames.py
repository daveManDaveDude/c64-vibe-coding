#!/usr/bin/env python3
import argparse
import json
import os
import shutil
import signal
import subprocess
import time
from pathlib import Path

import imageio_ffmpeg

from dump_video_frames import dump_video_frames


REPO_ROOT = Path(__file__).resolve().parent.parent
DEFAULT_SOURCE = Path("src/hello-asm.asm")
DEFAULT_BUILD_DIR = Path("build")
DEFAULT_OUTPUT_DIR = Path("artifacts/gameplay-capture")
DEFAULT_CBM_NAME = "HELLOASM"
DEFAULT_WINDOW_X = 80
DEFAULT_WINDOW_Y = 80
DEFAULT_WINDOW_WIDTH = 768
DEFAULT_WINDOW_HEIGHT = 638


def parse_args():
    parser = argparse.ArgumentParser(
        description="Launch the assembly build in VICE, record a short gameplay clip, and dump every frame."
    )
    parser.add_argument("--source", type=Path, default=DEFAULT_SOURCE)
    parser.add_argument("--build-dir", type=Path, default=DEFAULT_BUILD_DIR)
    parser.add_argument("--output-dir", type=Path, default=DEFAULT_OUTPUT_DIR)
    parser.add_argument("--cbm-name", default=DEFAULT_CBM_NAME)
    parser.add_argument("--duration-seconds", type=float, default=5.0)
    parser.add_argument("--warmup-seconds", type=float, default=3.0)
    parser.add_argument("--fps", type=int, default=50)
    parser.add_argument("--window-x", type=int, default=DEFAULT_WINDOW_X)
    parser.add_argument("--window-y", type=int, default=DEFAULT_WINDOW_Y)
    parser.add_argument("--window-width", type=int, default=DEFAULT_WINDOW_WIDTH)
    parser.add_argument("--window-height", type=int, default=DEFAULT_WINDOW_HEIGHT)
    parser.add_argument("--process-name", default="x64sc")
    return parser.parse_args()


def reset_output_dir(path: Path) -> None:
    if path.exists():
        shutil.rmtree(path)
    path.mkdir(parents=True, exist_ok=True)


def run_checked(command: list[str]) -> None:
    subprocess.run(command, cwd=REPO_ROOT, check=True)


def build_disk_image(args) -> Path:
    build_dir = (REPO_ROOT / args.build_dir).resolve()
    outbase = args.source.stem
    prg_path = build_dir / f"{outbase}.prg"
    d64_path = build_dir / f"{outbase}.d64"

    run_checked(["bash", "scripts/build_asm.sh", str(args.source), str(build_dir)])
    run_checked(
        [
            "bash",
            "scripts/make_d64.sh",
            str(prg_path),
            str(d64_path),
            "ASMHELLO",
            "00",
            args.cbm_name,
        ]
    )
    return d64_path


def vice_command(args, d64_path: Path, vice_log_path: Path) -> list[str]:
    return [
        args.process_name,
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
        "-windowxpos",
        str(args.window_x),
        "-windowypos",
        str(args.window_y),
        "-windowwidth",
        str(args.window_width),
        "-windowheight",
        str(args.window_height),
        "-autostart-warp",
        "-logfile",
        str(vice_log_path),
        "-autostart",
        f"{d64_path}:{args.cbm_name}",
    ]


def launch_vice(args, d64_path: Path, vice_log_path: Path) -> subprocess.Popen:
    return subprocess.Popen(
        vice_command(args, d64_path, vice_log_path),
        cwd=REPO_ROOT,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        start_new_session=True,
    )


def bring_process_to_front(process_name: str) -> None:
    script = (
        'tell application "System Events"\n'
        f'  tell process "{process_name}"\n'
        "    set frontmost to true\n"
        "  end tell\n"
        "end tell\n"
    )
    subprocess.run(
        ["osascript", "-e", script],
        check=False,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )


def record_video(args, video_path: Path, ffmpeg_log_path: Path) -> None:
    ffmpeg = imageio_ffmpeg.get_ffmpeg_exe()
    crop = f"crop={args.window_width}:{args.window_height}:{args.window_x}:{args.window_y}"
    command = [
        ffmpeg,
        "-y",
        "-f",
        "avfoundation",
        "-framerate",
        str(args.fps),
        "-capture_cursor",
        "0",
        "-pixel_format",
        "uyvy422",
        "-i",
        "Capture screen 0:none",
        "-an",
        "-t",
        str(args.duration_seconds),
        "-vf",
        crop,
        "-r",
        str(args.fps),
        "-c:v",
        "libx264",
        "-preset",
        "ultrafast",
        "-crf",
        "10",
        "-pix_fmt",
        "yuv420p",
        str(video_path),
    ]
    with ffmpeg_log_path.open("w", encoding="utf-8") as handle:
        subprocess.run(command, cwd=REPO_ROOT, check=True, stdout=handle, stderr=subprocess.STDOUT)


def stop_process(process: subprocess.Popen) -> None:
    if process.poll() is not None:
        return
    try:
        os.killpg(process.pid, signal.SIGTERM)
        process.wait(timeout=5)
    except subprocess.TimeoutExpired:
        os.killpg(process.pid, signal.SIGKILL)
        process.wait(timeout=5)


def write_summary(path: Path, summary: dict) -> None:
    path.write_text(json.dumps(summary, indent=2), encoding="utf-8")


def main() -> int:
    args = parse_args()
    output_dir = (REPO_ROOT / args.output_dir).resolve()
    reset_output_dir(output_dir)

    video_path = output_dir / "gameplay.mp4"
    frames_output_dir = output_dir / "frame-dump"
    vice_log_path = output_dir / "vice.log"
    ffmpeg_log_path = output_dir / "ffmpeg.log"
    summary_path = output_dir / "summary.json"

    vice_process = None
    try:
        d64_path = build_disk_image(args)
        vice_process = launch_vice(args, d64_path, vice_log_path)
        time.sleep(args.warmup_seconds)
        if vice_process.poll() is not None:
            raise RuntimeError(f"{args.process_name} exited before capture started")
        bring_process_to_front(args.process_name)
        record_video(args, video_path, ffmpeg_log_path)
        frame_summary = dump_video_frames(video_path, frames_output_dir)
        write_summary(frames_output_dir / "summary.json", frame_summary)
        write_summary(
            summary_path,
            {
                "success": True,
                "source": str((REPO_ROOT / args.source).resolve()),
                "video": str(video_path),
                "ffmpeg_log": str(ffmpeg_log_path),
                "vice_log": str(vice_log_path),
                "frames_dir": str((frames_output_dir / "frames").resolve()),
                "frame_dump_dir": str(frames_output_dir),
                "frame_dump_summary": str((frames_output_dir / "summary.json").resolve()),
                "duration_seconds": args.duration_seconds,
                "warmup_seconds": args.warmup_seconds,
                "fps_requested": args.fps,
                "window": {
                    "x": args.window_x,
                    "y": args.window_y,
                    "width": args.window_width,
                    "height": args.window_height,
                },
                "captured_frame_count": frame_summary["frame_count"],
                "captured_fps": frame_summary.get("fps"),
                "captured_duration": frame_summary.get("duration"),
                "captured_size": frame_summary.get("size"),
            },
        )
    except Exception as exc:
        write_summary(summary_path, {"success": False, "error": str(exc)})
        raise
    finally:
        if vice_process is not None:
            stop_process(vice_process)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
