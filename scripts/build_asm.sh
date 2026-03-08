#!/usr/bin/env bash
set -euo pipefail

SRC="${1:-src/hello-asm.asm}"
if [ "$#" -gt 0 ]; then
  shift
fi

OUTDIR="${1:-build}"
if [ "$#" -gt 0 ]; then
  shift
fi

EXTRA_ARGS=("$@")

scripts/install_kickassembler.sh
JAVA_BIN="$(scripts/find_java.sh)"

mkdir -p "$OUTDIR"
ABS_OUTDIR="$(cd "$OUTDIR" && pwd)"

if [ "${#EXTRA_ARGS[@]}" -gt 0 ]; then
  "$JAVA_BIN" -jar tools/KickAssembler/KickAss.jar -odir "$ABS_OUTDIR" "${EXTRA_ARGS[@]}" "$SRC"
else
  "$JAVA_BIN" -jar tools/KickAssembler/KickAss.jar -odir "$ABS_OUTDIR" "$SRC"
fi

OUTPRG="$OUTDIR/$(basename "${SRC%.asm}").prg"
echo "Built: $OUTPRG"
