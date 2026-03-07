#!/usr/bin/env bash
set -euo pipefail

PRG="${1:-build/hello.prg}"
LOGFILE="${2:-artifacts/vice-debug.log}"

mkdir -p "$(dirname "$LOGFILE")"

# Start VICE with binary monitor enabled (VS64 will attach on port 6502).
# autostartprgmode 1 makes PRG autostart inject-to-RAM.
exec x64sc \
  -binarymonitor \
  -binarymonitoraddress ip4://127.0.0.1:6502 \
  -autostartprgmode 1 \
  -logfile "$LOGFILE" \
  "$PRG"
