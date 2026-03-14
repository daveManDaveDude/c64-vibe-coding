#!/usr/bin/env python3
import argparse
import json
import shutil
from pathlib import Path

import imageio.v2 as imageio


def parse_args():
    parser = argparse.ArgumentParser(description="Dump every frame from a video file into a folder.")
    parser.add_argument("--source", type=Path, required=True)
    parser.add_argument("--output-dir", type=Path, required=True)
    return parser.parse_args()


def reset_output_dir(path: Path) -> None:
    if path.exists():
        shutil.rmtree(path)
    path.mkdir(parents=True, exist_ok=True)


def main() -> int:
    args = parse_args()
    source = args.source.resolve()
    output_dir = args.output_dir.resolve()
    frames_dir = output_dir / "frames"

    reset_output_dir(output_dir)
    frames_dir.mkdir(parents=True, exist_ok=True)

    reader = imageio.get_reader(source)
    metadata = reader.get_meta_data()
    count = 0

    try:
        for index, frame in enumerate(reader):
            frame_path = frames_dir / f"{index:04d}.png"
            imageio.imwrite(frame_path, frame)
            count = index + 1
    finally:
        reader.close()

    summary = {
        "success": True,
        "source": str(source),
        "frames_dir": str(frames_dir),
        "frame_count": count,
        "fps": metadata.get("fps"),
        "duration": metadata.get("duration"),
        "size": metadata.get("size"),
    }
    (output_dir / "summary.json").write_text(json.dumps(summary, indent=2), encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
