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

EXTRA_ARGS=()

if [ "$#" -gt 0 ]; then
  EXTRA_ARGS+=("$@")
fi

has_arg() {
  local needle="$1"
  local arg
  if [ "${#EXTRA_ARGS[@]}" -eq 0 ]; then
    return 1
  fi
  for arg in "${EXTRA_ARGS[@]}"; do
    if [ "$arg" = "$needle" ]; then
      return 0
    fi
  done
  return 1
}

SPRITE_PNG="ArcadeGalaxianSprites.png"
PLAYER_EXPLOSION_PNG="ArcadeGalaxianSprites explosions.png"
SPRITE_ASM="src/generated_enemy_sprites.asm"
SPRITE_BIN="src/generated_enemy_sprites.bin"
FULL_SPRITE_ASM="src/generated_arcade_sprites.asm"
FULL_SPRITE_BIN="src/generated_arcade_sprites.bin"
FULL_SPRITE_JSON="src/generated_arcade_sprites.json"
PLAYER_SPRITE_ASM="src/generated_player_sprite.asm"
PLAYER_SPRITE_BIN="src/generated_player_sprite.bin"
PLAYER_OVERLAY_BIN="src/generated_player_overlay.bin"
PLAYER_EXTRA_BIN="src/generated_player_extra.bin"
PLAYER_EXPLOSION_ASM="src/generated_player_explosion.asm"
PLAYER_EXPLOSION_BIN="src/generated_player_explosion.bin"
FORMATION_CHAR_BIN="src/generated_formation_char_bitmap.bin"

if [ ! -f "$SPRITE_ASM" ] || [ ! -f "$SPRITE_BIN" ] || [ "$SPRITE_PNG" -nt "$SPRITE_ASM" ] || [ "$SPRITE_PNG" -nt "$SPRITE_BIN" ]; then
  python3 scripts/generate_arcade_enemy_sprites.py
fi

if [ ! -f "$FULL_SPRITE_ASM" ] || [ ! -f "$FULL_SPRITE_BIN" ] || [ ! -f "$FULL_SPRITE_JSON" ] || [ "$SPRITE_PNG" -nt "$FULL_SPRITE_ASM" ] || [ "$SPRITE_PNG" -nt "$FULL_SPRITE_BIN" ] || [ "$SPRITE_PNG" -nt "$FULL_SPRITE_JSON" ]; then
  python3 scripts/generate_arcade_full_sheet_assets.py
fi

if [ ! -f "$PLAYER_SPRITE_ASM" ] || [ ! -f "$PLAYER_SPRITE_BIN" ] || [ ! -f "$PLAYER_OVERLAY_BIN" ] || [ ! -f "$PLAYER_EXTRA_BIN" ] || [ "$FULL_SPRITE_BIN" -nt "$PLAYER_SPRITE_ASM" ] || [ "$FULL_SPRITE_BIN" -nt "$PLAYER_SPRITE_BIN" ] || [ "$FULL_SPRITE_BIN" -nt "$PLAYER_OVERLAY_BIN" ] || [ "$FULL_SPRITE_BIN" -nt "$PLAYER_EXTRA_BIN" ] || [ "$FULL_SPRITE_JSON" -nt "$PLAYER_SPRITE_ASM" ] || [ "$FULL_SPRITE_JSON" -nt "$PLAYER_SPRITE_BIN" ] || [ "$FULL_SPRITE_JSON" -nt "$PLAYER_OVERLAY_BIN" ] || [ "$FULL_SPRITE_JSON" -nt "$PLAYER_EXTRA_BIN" ]; then
  python3 scripts/generate_player_sprite.py
fi

if [ ! -f "$PLAYER_EXPLOSION_ASM" ] || [ ! -f "$PLAYER_EXPLOSION_BIN" ] || [ "$PLAYER_EXPLOSION_PNG" -nt "$PLAYER_EXPLOSION_ASM" ] || [ "$PLAYER_EXPLOSION_PNG" -nt "$PLAYER_EXPLOSION_BIN" ]; then
  python3 scripts/generate_player_explosion_sprites.py
fi

if [ ! -f "$FORMATION_CHAR_BIN" ] || [ "$SPRITE_BIN" -nt "$FORMATION_CHAR_BIN" ] || [ "scripts/generate_formation_char_bitmap.py" -nt "$FORMATION_CHAR_BIN" ]; then
  python3 scripts/generate_formation_char_bitmap.py
fi

scripts/install_kickassembler.sh
JAVA_BIN="$(scripts/find_java.sh)"

mkdir -p "$OUTDIR"
ABS_OUTDIR="$(cd "$OUTDIR" && pwd)"
OUTBASE="$(basename "${SRC%.asm}")"
ASMINFO_FILE="$ABS_OUTDIR/${OUTBASE}.info"

# VS64 expects KickAssembler projects to emit build/<name>.dbg for source-level debugging.
# Mirror the extension's default debug build flags so F5 can load debug info.
if ! has_arg "-debugdump"; then
  EXTRA_ARGS+=("-debugdump")
fi
if ! has_arg "-debug"; then
  EXTRA_ARGS+=("-debug")
fi
if ! has_arg "-asminfo"; then
  EXTRA_ARGS+=("-asminfo" "files|errors")
fi
if ! has_arg "-asminfofile"; then
  EXTRA_ARGS+=("-asminfofile" "$ASMINFO_FILE")
fi

if [ "${#EXTRA_ARGS[@]}" -gt 0 ]; then
  "$JAVA_BIN" -jar tools/KickAssembler/KickAss.jar -odir "$ABS_OUTDIR" "${EXTRA_ARGS[@]}" "$SRC"
else
  "$JAVA_BIN" -jar tools/KickAssembler/KickAss.jar -odir "$ABS_OUTDIR" "$SRC"
fi

OUTPRG="$OUTDIR/${OUTBASE}.prg"
echo "Built: $OUTPRG"
