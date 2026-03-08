#!/usr/bin/env bash
set -euo pipefail

PRG="${1:-build/autoplay/hello-asm.prg}"
TRANSCRIPT_LOG="${2:-artifacts/playtest-asm-vice.log}"
ADDRESS="${3:-ip4://127.0.0.1:6502}"
INTERNAL_LOG="${TRANSCRIPT_LOG%.log}-internal.log"

mkdir -p "$(dirname "$TRANSCRIPT_LOG")"
rm -f "$TRANSCRIPT_LOG" "$INTERNAL_LOG"

exec script -q "$TRANSCRIPT_LOG" \
  x64sc \
  -console \
  -default \
  +confirmonexit +saveres \
  +sound \
  -pal -power50 \
  -autostart-warp \
  -binarymonitor \
  -binarymonitoraddress "$ADDRESS" \
  -autostartprgmode 1 \
  -logfile "$INTERNAL_LOG" \
  "$PRG"
