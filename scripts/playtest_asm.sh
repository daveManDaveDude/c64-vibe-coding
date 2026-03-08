#!/usr/bin/env bash
set -euo pipefail

PRG="build/hello-asm.prg"
LOGFILE="artifacts/playtest-asm.log"
JSONFILE="artifacts/playtest-asm.json"
VICELOG="artifacts/playtest-asm-vice.log"
FRAMESDIR="artifacts/playtest-asm-frames"
KEYMAPFILE="artifacts/playtest-asm-keymap.vkm"
EXITSCREENSHOT="artifacts/playtest-asm-exit.png"

mkdir -p artifacts
rm -f "$LOGFILE" "$JSONFILE" "$VICELOG" "$KEYMAPFILE" "$EXITSCREENSHOT"
rm -rf "$FRAMESDIR"

scripts/build_asm.sh "src/hello-asm.asm" "build"
python3 scripts/playtest_asm.py \
  --prg "$PRG" \
  --log "$LOGFILE" \
  --json "$JSONFILE" \
  --vice-log "$VICELOG" \
  --frames-dir "$FRAMESDIR" \
  --keymap "$KEYMAPFILE" \
  --exit-screenshot "$EXITSCREENSHOT"
