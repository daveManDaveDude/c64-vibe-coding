#!/usr/bin/env bash
set -euo pipefail

TOOLS_DIR="${1:-tools}"
KICKASS_DIR="$TOOLS_DIR/KickAssembler"
KICKASS_ZIP="$TOOLS_DIR/KickAssembler.zip"
KICKASS_URL="${KICKASS_URL:-https://theweb.dk/KickAssembler/KickAssembler.zip}"

if [ -f "$KICKASS_DIR/KickAss.jar" ]; then
  exit 0
fi

mkdir -p "$TOOLS_DIR"
curl -L "$KICKASS_URL" -o "$KICKASS_ZIP"
unzip -oq "$KICKASS_ZIP" -d "$KICKASS_DIR"

test -f "$KICKASS_DIR/KickAss.jar" || {
  echo "ERROR: KickAssembler install failed." >&2
  exit 1
}

echo "Installed KickAssembler into $KICKASS_DIR"
