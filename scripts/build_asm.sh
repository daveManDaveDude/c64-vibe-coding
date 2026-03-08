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

SPRITE_PNG="ArcadeGalaxian3ships.png"
SPRITE_ASM="src/generated_enemy_sprites.asm"
SPRITE_BIN="src/generated_enemy_sprites.bin"

if [ ! -f "$SPRITE_ASM" ] || [ ! -f "$SPRITE_BIN" ] || [ "$SPRITE_PNG" -nt "$SPRITE_ASM" ] || [ "$SPRITE_PNG" -nt "$SPRITE_BIN" ]; then
  python3 scripts/generate_arcade_enemy_sprites.py
fi

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
