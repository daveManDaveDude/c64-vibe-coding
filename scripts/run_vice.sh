#!/usr/bin/env bash
set -euo pipefail

D64="${1:-build/hello.d64}"
CBMNAME="${2:-HELLO}"
CYCLES="${3-12000000}"
SCREENSHOT="${4-artifacts/vice-exit.png}"
LOGFILE="${5-artifacts/vice.log}"

if [ -n "$SCREENSHOT" ]; then
  mkdir -p "$(dirname "$SCREENSHOT")"
fi

ARGS=(
  -default
  +confirmonexit +saveres
  -pal -power50
  -autostart-warp
  -logfile "$LOGFILE"
  -autostart "$D64:$CBMNAME"
)

if [ -n "$CYCLES" ]; then
  ARGS+=(-limitcycles "$CYCLES")
fi

if [ -n "$SCREENSHOT" ]; then
  ARGS+=(-exitscreenshot "$SCREENSHOT")
fi

x64sc "${ARGS[@]}"
