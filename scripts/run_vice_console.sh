#!/usr/bin/env bash
set -euo pipefail

D64="${1:-build/hello.d64}"
CBMNAME="${2:-HELLO}"
CYCLES="${3:-12000000}"
LOGFILE="${4:-artifacts/vice-console.log}"

mkdir -p "$(dirname "$LOGFILE")"
rm -f "$LOGFILE"

script -q "$LOGFILE" \
  x64sc \
  -console \
  -default \
  +confirmonexit +saveres \
  +sound \
  -pal -power50 \
  -autostart-warp \
  -limitcycles "$CYCLES" \
  -autostart "$D64:$CBMNAME"
