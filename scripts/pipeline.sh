#!/usr/bin/env bash
set -euo pipefail

SRC="src/hello.bas"
PRG="build/hello.prg"
D64="build/hello.d64"
CBMNAME="HELLO"
SCREENSHOT="artifacts/vice-exit.png"
LOGFILE="artifacts/vice.log"
STATUSFILE="artifacts/run_status.txt"

rm -f "$SCREENSHOT" "$LOGFILE" "$STATUSFILE"

scripts/build_prg.sh "$SRC" "build" "$(basename "$PRG")"
scripts/make_d64.sh "$PRG" "$D64" "HELLO" "00" "$CBMNAME"

set +e
scripts/run_vice.sh "$D64" "$CBMNAME" "12000000" "$SCREENSHOT" "$LOGFILE"
RC=$?
set -e

# x64sc typically returns non-zero when -limitcycles is reached; if screenshot exists,
# treat that as a successful automated run.
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
