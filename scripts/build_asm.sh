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

SPRITE_PNG="ArcadeGalaxianSprites.png"
SPRITE_ASM="src/generated_enemy_sprites.asm"
SPRITE_BIN="src/generated_enemy_sprites.bin"
FULL_SPRITE_ASM="src/generated_arcade_sprites.asm"
FULL_SPRITE_BIN="src/generated_arcade_sprites.bin"
FULL_SPRITE_JSON="src/generated_arcade_sprites.json"
PLAYER_SPRITE_ASM="src/generated_player_sprite.asm"
PLAYER_SPRITE_BIN="src/generated_player_sprite.bin"
PLAYER_OVERLAY_BIN="src/generated_player_overlay.bin"

if [ ! -f "$SPRITE_ASM" ] || [ ! -f "$SPRITE_BIN" ] || [ "$SPRITE_PNG" -nt "$SPRITE_ASM" ] || [ "$SPRITE_PNG" -nt "$SPRITE_BIN" ]; then
  python3 scripts/generate_arcade_enemy_sprites.py
fi

if [ ! -f "$FULL_SPRITE_ASM" ] || [ ! -f "$FULL_SPRITE_BIN" ] || [ ! -f "$FULL_SPRITE_JSON" ] || [ "$SPRITE_PNG" -nt "$FULL_SPRITE_ASM" ] || [ "$SPRITE_PNG" -nt "$FULL_SPRITE_BIN" ] || [ "$SPRITE_PNG" -nt "$FULL_SPRITE_JSON" ]; then
  python3 scripts/generate_arcade_full_sheet_assets.py
fi

if [ ! -f "$PLAYER_SPRITE_ASM" ] || [ ! -f "$PLAYER_SPRITE_BIN" ] || [ ! -f "$PLAYER_OVERLAY_BIN" ] || [ "$FULL_SPRITE_BIN" -nt "$PLAYER_SPRITE_ASM" ] || [ "$FULL_SPRITE_BIN" -nt "$PLAYER_SPRITE_BIN" ] || [ "$FULL_SPRITE_BIN" -nt "$PLAYER_OVERLAY_BIN" ] || [ "$FULL_SPRITE_JSON" -nt "$PLAYER_SPRITE_ASM" ] || [ "$FULL_SPRITE_JSON" -nt "$PLAYER_SPRITE_BIN" ] || [ "$FULL_SPRITE_JSON" -nt "$PLAYER_OVERLAY_BIN" ]; then
  python3 scripts/generate_player_sprite.py
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
