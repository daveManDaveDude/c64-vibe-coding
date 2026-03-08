#!/usr/bin/env bash
set -euo pipefail

PRG="${1:-build/autoplay/hello-asm.prg}"
TRANSCRIPT_LOG="${2:-artifacts/playtest-asm-visible-vice.log}"
ADDRESS="${3:-ip4://127.0.0.1:6502}"
INTERNAL_LOG="${TRANSCRIPT_LOG%.log}-internal.log"

mkdir -p "$(dirname "$TRANSCRIPT_LOG")"
rm -f "$TRANSCRIPT_LOG" "$INTERNAL_LOG"

exec x64sc \
  -default \
  +confirmonexit +saveres \
  -pal -power50 \
  -autostart-warp \
  -binarymonitor \
  -binarymonitoraddress "$ADDRESS" \
  -autostartprgmode 1 \
  -logfile "$INTERNAL_LOG" \
  "$PRG"
