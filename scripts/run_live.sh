#!/usr/bin/env bash
set -euo pipefail

SRC="src/hello.bas"
PRG="build/hello.prg"
D64="build/hello.d64"
CBMNAME="HELLO"
LOGFILE="artifacts/vice-live.log"

mkdir -p artifacts

scripts/build_prg.sh "$SRC" "build" "$(basename "$PRG")"
scripts/make_d64.sh "$PRG" "$D64" "HELLO" "00" "$CBMNAME"

# Live mode: no cycle limit, no forced exit screenshot.
scripts/run_vice.sh "$D64" "$CBMNAME" "" "" "$LOGFILE"
