#!/usr/bin/env bash
set -euo pipefail

SRC="src/hello-asm.asm"
PRG="build/hello-asm.prg"
D64="build/hello-asm.d64"
CBMNAME="HELLOASM"
LOGFILE="artifacts/vice-asm-console.log"
STATUSFILE="artifacts/run_status_asm_console.txt"

rm -f "$LOGFILE" "$STATUSFILE"

scripts/build_asm.sh "$SRC" "build"
scripts/make_d64.sh "$PRG" "$D64" "ASMHELLO" "00" "$CBMNAME"

set +e
scripts/run_vice_console.sh "$D64" "$CBMNAME" "12000000" "$LOGFILE"
RC=$?
set -e

{
  echo "vice_exit_code=$RC"
  echo "logfile=$LOGFILE"
  echo "timestamp_utc=$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
} | tee "$STATUSFILE"

if strings "$LOGFILE" | grep -q "Loading program 'HELLOASM'"; then
  exit 0
fi

echo "ERROR: console verification did not reach program load"
exit 2
