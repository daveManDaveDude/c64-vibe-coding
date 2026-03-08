#!/usr/bin/env bash
set -euo pipefail

AUTOPLAY_DIR="build/autoplay"
PRG="$AUTOPLAY_DIR/hello-asm.prg"
SYM="$AUTOPLAY_DIR/hello-asm.sym"
LOGFILE="artifacts/playtest-asm.log"
JSONFILE="artifacts/playtest-asm.json"
VICELOG="artifacts/playtest-asm-vice.log"

mkdir -p artifacts
rm -f "$LOGFILE" "$JSONFILE" "$VICELOG" "${VICELOG%.log}-internal.log"

scripts/build_asm_autoplay.sh "src/hello-asm.asm" "$AUTOPLAY_DIR"
python3 scripts/playtest_asm.py \
  --prg "$PRG" \
  --sym "$SYM" \
  --log "$LOGFILE" \
  --json "$JSONFILE" \
  --vice-log "$VICELOG"
