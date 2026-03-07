#!/usr/bin/env bash
set -euo pipefail

if [ -x "/opt/homebrew/opt/openjdk/bin/java" ]; then
  echo "/opt/homebrew/opt/openjdk/bin/java"
  exit 0
fi

if [ -x "/usr/local/opt/openjdk/bin/java" ]; then
  echo "/usr/local/opt/openjdk/bin/java"
  exit 0
fi

if command -v java >/dev/null 2>&1 && java -version >/dev/null 2>&1; then
  command -v java
  exit 0
fi

echo "ERROR: No working Java runtime found." >&2
echo "Install Homebrew openjdk: brew install openjdk" >&2
exit 1
