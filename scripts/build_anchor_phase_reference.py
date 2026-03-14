#!/usr/bin/env python3
import argparse
import json
import shutil
from pathlib import Path
from typing import Optional


DEFAULT_TARGETS = (
    ("anchor1_phase0", 1, 0),
    ("anchor0_phase0", 0, 0),
)


def parse_target(text: str) -> tuple[str, int, int]:
    parts = text.split(":")
    if len(parts) != 3:
        raise argparse.ArgumentTypeError(
            f"Invalid target '{text}'. Expected label:anchor:phase"
        )
    label, anchor_text, phase_text = parts
    return label, int(anchor_text, 10), int(phase_text, 10)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Build a Finder-sorted before/during/after reference pack from review records."
    )
    parser.add_argument("--records", type=Path, required=True)
    parser.add_argument("--output-dir", type=Path, required=True)
    parser.add_argument(
        "--target",
        action="append",
        type=parse_target,
        help="Target in label:anchor:phase form. Defaults to anchor1_phase0 and anchor0_phase0.",
    )
    return parser.parse_args()


def find_target_index(samples: list[dict], anchor: int, phase: int) -> Optional[int]:
    for index, sample in enumerate(samples):
        if index == 0 or index + 1 >= len(samples):
            continue
        if sample.get("formation_anchor_col") != anchor:
            continue
        if sample.get("formation_shift_phase") != phase:
            continue
        return index
    return None


def main() -> int:
    args = parse_args()
    records_path = args.records.resolve()
    output_dir = args.output_dir.resolve()

    records = json.loads(records_path.read_text())
    samples = records.get("samples", [])
    targets = args.target or list(DEFAULT_TARGETS)

    if output_dir.exists():
        shutil.rmtree(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    summary = {
        "success": True,
        "records": str(records_path),
        "frame_count": len(samples),
        "capture_mode": records.get("artifacts", {}).get("capture_mode"),
        "selection": {},
        "reference_dirs": {},
        "missing_targets": [],
    }

    for label, anchor, phase in targets:
        match_index = find_target_index(samples, anchor, phase)
        if match_index is None:
            summary["missing_targets"].append(
                {
                    "label": label,
                    "anchor": anchor,
                    "phase": phase,
                }
            )
            continue

        target_dir = output_dir / "selected" / label
        target_dir.mkdir(parents=True, exist_ok=True)

        selection = {
            "anchor": anchor,
            "phase": phase,
            "sample_index": match_index,
            "movement_direction": samples[match_index].get("formation_dir_name"),
            "files": [],
        }
        summary["selection"][label] = selection
        summary["reference_dirs"][label] = str(target_dir)

        for prefix, stage_label, offset in (
            ("1", "before", -1),
            ("2", "during", 0),
            ("3", "after", 1),
        ):
            sample = samples[match_index + offset]
            source = Path(sample["screenshot"])
            destination = target_dir / f"{prefix}-{stage_label}-{source.name}"
            shutil.copy2(source, destination)
            selection["files"].append(
                {
                    "label": stage_label,
                    "sample_index": match_index + offset,
                    "source": str(source),
                    "copied_frame": str(destination),
                }
            )

    (output_dir / "summary.json").write_text(json.dumps(summary, indent=2))
    (output_dir / "records.json").write_text(json.dumps(records, indent=2))
    print(json.dumps(summary, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
