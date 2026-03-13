#!/usr/bin/env bash
set -euo pipefail

RUN_READY_ROW_CHECK=0

if [ "${1:-}" = "--ready-row-check" ]; then
  RUN_READY_ROW_CHECK=1
  shift
fi

if [ "$#" -gt 0 ]; then
  echo "Usage: scripts/review_formation_render.sh [--ready-row-check]" >&2
  exit 2
fi

PRG="build/hello-asm.prg"

scripts/build_asm.sh "src/hello-asm.asm" "build"

python3 scripts/review_formation_render.py \
  --prg "$PRG" \
  --output-dir "artifacts/play-10s-review-edge-clear" \
  --stage play \
  --duration-seconds 10 \
  --clear-strategy edge_global

python3 scripts/review_formation_render.py \
  --prg "$PRG" \
  --output-dir "artifacts/play-10s-review-row-clear" \
  --stage play \
  --duration-seconds 10 \
  --clear-strategy rowwise

if [ "$RUN_READY_ROW_CHECK" -eq 1 ]; then
  python3 scripts/review_formation_render.py \
    --prg "$PRG" \
    --output-dir "artifacts/ready-5s-review-row-clear" \
    --stage ready \
    --duration-seconds 5 \
    --clear-strategy rowwise
else
  echo "Rowwise READY review is available with: bash scripts/review_formation_render.sh --ready-row-check"
fi
