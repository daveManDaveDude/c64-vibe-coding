#!/usr/bin/env bash
set -euo pipefail

SRC_PNG="${1:-ArcadeGalaxian3ships.png}"
OUT_DIR="${2:-artifacts/png2prg_enemy_rows}"
OUT_BIN="${3:-src/generated_enemy_sprites_png2prg.bin}"

mkdir -p "$OUT_DIR"
: > "$OUT_BIN"

for ROW in 0 1 2; do
  NORMALIZED_PNG="$OUT_DIR/row${ROW}.png"
  OUT_PRG="$OUT_DIR/row${ROW}.prg"
  OUT_RAW="$OUT_DIR/row${ROW}.bin"
  BPC="0,6,-1,2"

  case "$ROW" in
    0) BPC="0,6,7,2" ;;
    1) BPC="0,6,4,2" ;;
    2) BPC="0,6,3,2" ;;
  esac

  python3 scripts/build_png2prg_enemy_sheet.py --png "$SRC_PNG" --row "$ROW" --out "$NORMALIZED_PNG"
  tools/bin/png2prg -m mcsprites -bpc "$BPC" -o "$OUT_PRG" "$NORMALIZED_PNG"
  tail -c +3 "$OUT_PRG" > "$OUT_RAW"
  cat "$OUT_RAW" >> "$OUT_BIN"

  echo "Wrote $NORMALIZED_PNG"
  echo "Wrote $OUT_PRG"
  echo "Wrote $OUT_RAW"
done

echo "Wrote $OUT_BIN"
