#!/usr/bin/env bash
set -euo pipefail

SRC="${1:-src/hello-asm.asm}"
OUTDIR="${2:-build}"

scripts/install_kickassembler.sh
JAVA_BIN="$(scripts/find_java.sh)"

mkdir -p "$OUTDIR"
ABS_OUTDIR="$(cd "$OUTDIR" && pwd)"

"$JAVA_BIN" -jar tools/KickAssembler/KickAss.jar -odir "$ABS_OUTDIR" "$SRC"

OUTPRG="$OUTDIR/$(basename "${SRC%.asm}").prg"
echo "Built: $OUTPRG"
