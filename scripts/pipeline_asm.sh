#!/usr/bin/env bash
set -euo pipefail

SRC="src/hello-asm.asm"
PRG="build/hello-asm.prg"
D64="build/hello-asm.d64"
CBMNAME="HELLOASM"
SCREENSHOT="artifacts/vice-asm-exit.png"
LOGFILE="artifacts/vice-asm.log"
STATUSFILE="artifacts/run_status_asm.txt"

rm -f "$SCREENSHOT" "$LOGFILE" "$STATUSFILE"

scripts/build_asm.sh "$SRC" "build"
scripts/make_d64.sh "$PRG" "$D64" "ASMHELLO" "00" "$CBMNAME"

set +e
scripts/run_vice.sh "$D64" "$CBMNAME" "12000000" "$SCREENSHOT" "$LOGFILE"
RC=$?
set -e

FINAL_RC="$RC"
if [ "$RC" -ne 0 ] && [ -f "$SCREENSHOT" ]; then
  FINAL_RC=0
fi

{
  echo "vice_exit_code=$RC"
  echo "final_exit_code=$FINAL_RC"
  echo "screenshot=$SCREENSHOT"
  echo "logfile=$LOGFILE"
  echo "timestamp_utc=$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
} | tee "$STATUSFILE"

test -f "$SCREENSHOT" || { echo "ERROR: screenshot not created"; exit 2; }
exit "$FINAL_RC"
