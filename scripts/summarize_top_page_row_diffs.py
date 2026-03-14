#!/usr/bin/env python3
import argparse
import json
from pathlib import Path


def parse_args():
    parser = argparse.ArgumentParser(
        description="Summarize page0/page1 top-row byte differences captured in review_formation_render_native records."
    )
    parser.add_argument("--records", type=Path, required=True)
    parser.add_argument(
        "--show-all",
        action="store_true",
        help="Show every captured sample, not just the ones with page differences.",
    )
    parser.add_argument(
        "--detail",
        action="store_true",
        help="Print per-row byte dumps for each sample that is shown.",
    )
    return parser.parse_args()


def format_ranges(ranges: list[list[int]]) -> str:
    if not ranges:
        return "-"
    parts = []
    for start, end in ranges:
        parts.append(str(start) if start == end else f"{start}-{end}")
    return ",".join(parts)


def main() -> int:
    args = parse_args()
    records = json.loads(args.records.resolve().read_text())
    samples = records.get("samples", [])
    shown = 0

    for sample in samples:
        debug = sample.get("top_page_row_debug")
        if not debug or not debug.get("enabled"):
            continue
        if not args.show_all and not debug.get("any_diff"):
            continue

        rows_with_diff = debug.get("rows_with_diff", [])
        print(
            f"sample={sample.get('index'):03d} "
            f"frame_counter={sample.get('frame_capture_counter')} "
            f"anchor={sample.get('formation_anchor_col')} "
            f"render_anchor={sample.get('formation_render_anchor_col')} "
            f"shift={sample.get('formation_shift_phase')} "
            f"render_scroll={sample.get('formation_render_scroll_phase')} "
            f"active_page={debug.get('active_screen_is_alt')} "
            f"render_page={debug.get('formation_render_page_is_alt')} "
            f"diff_rows={rows_with_diff or '-'} "
            f"total_diff_cells={debug.get('total_diff_cells', 0)}"
        )
        shown += 1

        if not args.detail:
            continue
        for row in debug.get("row_diffs", []):
            if not args.show_all and row.get("diff_count", 0) == 0:
                continue
            print(
                f"  row={row['row']:02d} diff_count={row['diff_count']:02d} "
                f"diff_cols={format_ranges(row.get('diff_ranges', []))}"
            )
            print(f"    page0: {row['page0_hex']}")
            print(f"    page1: {row['page1_hex']}")

    if shown == 0:
        print("No matching samples found.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
