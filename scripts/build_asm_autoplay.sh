#!/usr/bin/env bash
set -euo pipefail

SRC="${1:-src/hello-asm.asm}"
OUTDIR="${2:-build/autoplay}"

scripts/build_asm.sh "$SRC" "$OUTDIR" -define TEST_AUTOPLAY
