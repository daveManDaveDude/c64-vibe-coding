#!/usr/bin/env bash
set -euo pipefail

PRG="${1:-build/hello.prg}"
D64="${2:-build/hello.d64}"
DISKNAME="${3:-HELLO}"
DISKID="${4:-00}"
CBMNAME="${5:-HELLO}"

mkdir -p "$(dirname "$D64")"

# Create/format a new D64
c1541 -format "${DISKNAME},${DISKID}" d64 "$D64"

# Write PRG onto it with a known CBM filename (no extension, typically uppercase)
c1541 -attach "$D64" -write "$PRG" "$CBMNAME"

echo "Built: $D64 (contains: $CBMNAME)"
