#!/usr/bin/env bash
set -euo pipefail

SRC="${1:-}"

if [ -z "$SRC" ]; then
  echo "ERROR: No source file provided." >&2
  exit 1
fi

case "$SRC" in
  *.bas)
    scripts/build_prg.sh "$SRC" "build" "$(basename "${SRC%.bas}").prg"
    ;;
  *.asm)
    scripts/build_asm.sh "$SRC" "build"
    ;;
  *)
    echo "ERROR: Unsupported source file '$SRC'." >&2
    echo "Open a .bas or .asm file before starting debug." >&2
    exit 1
    ;;
esac
