#!/usr/bin/env bash
set -euo pipefail

SRC="${1:-src/hello.bas}"
OUTDIR="${2:-build}"
OUTPRG="${3:-hello.prg}"

mkdir -p "$OUTDIR"

# -w2 = Commodore 64 BASIC V2 tokenization.
# "--" ends option parsing and treats the rest as filenames.
petcat -w2 -o "$OUTDIR/$OUTPRG" -- "$SRC"
echo "Built: $OUTDIR/$OUTPRG"
