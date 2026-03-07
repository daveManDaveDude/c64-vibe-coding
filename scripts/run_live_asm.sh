#!/usr/bin/env bash
set -euo pipefail

SRC="src/hello-asm.asm"
PRG="build/hello-asm.prg"
D64="build/hello-asm.d64"
CBMNAME="HELLOASM"
LOGFILE="artifacts/vice-asm-live.log"

mkdir -p artifacts

scripts/build_asm.sh "$SRC" "build"
scripts/make_d64.sh "$PRG" "$D64" "ASMHELLO" "00" "$CBMNAME"

scripts/run_vice.sh "$D64" "$CBMNAME" "" "" "$LOGFILE"
