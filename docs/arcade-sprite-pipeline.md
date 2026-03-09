# Arcade Sprite Pipeline

This project treats `ArcadeGalaxianSprites.png` as the source of truth for the arcade-derived game art.
The goal of the pipeline is simple: convert that PNG into raw `64`-byte C64 sprite layers that the game can import directly, while also producing metadata and SVG previews for debugging.

## One-command Regeneration

To rebuild the sprite outputs and refresh the previews:

```sh
make preview-sprites
```

That runs:

```sh
python3 scripts/generate_arcade_enemy_sprites.py
python3 scripts/generate_arcade_full_sheet_assets.py
python3 scripts/generate_player_sprite.py
python3 scripts/generate_player_explosion_sprites.py
python3 scripts/preview_c64_sprites.py
python3 scripts/preview_c64_sprites.py src/generated_arcade_sprites.bin --out artifacts/arcade-sprites-preview.svg
python3 scripts/preview_player_sprite.py
python3 scripts/preview_player_explosion.py
```

The specific file you asked to regenerate is:

- `artifacts/arcade-sprites-preview.svg`

## Full-sheet Conversion

The full-sheet exporter is `scripts/generate_arcade_full_sheet_assets.py`.
It reads `ArcadeGalaxianSprites.png` and converts every sprite-like segment on the sheet into one or more C64 sprite layers.

The conversion rules are:

1. The script decodes the PNG into RGBA pixels.
2. It finds the gray separator lines that divide the sheet into horizontal bands and vertical segments.
3. It extracts each non-empty segment and assigns it a stable asset label such as `arcade_b4_s0`.
4. The first `3x3` area is also exported separately as the enemy subset used by the current game logic.
5. Each extracted asset is mapped into C64 sprite data:
   - If the asset fits in a single C64 multicolor sprite (`<= 12` logical columns and `<= 3` visible colors), it becomes one multicolor sprite layer.
   - Otherwise it becomes multiple single-color layers, one layer per source color, so the game can stack hardware sprites to reproduce the art.
6. Every layer is packed as a standard `64`-byte C64 sprite block.

This is the important design point: the pipeline does not stop at a preview or an assembly listing.
It produces raw sprite bytes that are already in the format the game can import.

## Generated Outputs

The full-sheet export writes three files:

- `src/generated_arcade_sprites.bin`
  Raw sprite bank. This is the game-usable output.
- `src/generated_arcade_sprites.asm`
  Human-readable KickAssembler blocks for inspection.
- `src/generated_arcade_sprites.json`
  Metadata describing each exported asset, its layers, color mode, and sprite indices inside the raw bank.

The current export from `ArcadeGalaxianSprites.png` produces `55` assets as `64` sprite layers.
That count may change if the source sheet changes.

## Enemy Subset

The enemy-only exporter is `scripts/generate_arcade_enemy_sprites.py`.
It extracts the first `3x3` block from the same PNG and writes:

- `src/generated_enemy_sprites.bin`
- `src/generated_enemy_sprites.asm`

This is the compact bank used by the current enemy formation code.

## Player-specific Outputs

Two small repo-local generators derive player art from the source PNGs:

- `scripts/generate_player_sprite.py`
  Extracts the layered player ship from `generated_arcade_sprites.bin` and writes the red, white, and cyan sprite files the game imports.
- `scripts/generate_player_explosion_sprites.py`
  Converts `ArcadeGalaxianSprites explosions.png` into a `4`-frame `2x2` multicolor metasprite bank for the player death animation.

Those generators write:

- `src/generated_player_sprite.asm`
- `src/generated_player_sprite.bin`
- `src/generated_player_overlay.bin`
- `src/generated_player_extra.bin`
- `src/generated_player_explosion.asm`
- `src/generated_player_explosion.bin`

## How The Game Uses The Results

The assembly program imports the generated sprite banks directly as binary data.
The full arcade bank is imported in [src/hello-asm.asm](/Users/david/Documents/c64/c64-vibe-coding/src/hello-asm.asm#L2685).

The intended workflow is:

1. Draw or edit art in `ArcadeGalaxianSprites.png`.
2. Run `make preview-sprites`.
3. Inspect `artifacts/arcade-sprites-preview.svg`.
4. Use `src/generated_arcade_sprites.json` to find the sprite index or indices for the asset you want.
5. Point the game at the matching layer or layered sprite stack in `src/generated_arcade_sprites.bin`.

If an asset exports as multiple layers, that means the game needs multiple hardware sprites to reproduce it accurately.
If it exports as a single multicolor layer, one hardware sprite is enough.

## Preview And Debug Files

For inspection, the pipeline also writes:

- `artifacts/arcade-sprites-preview.svg`
- `artifacts/enemy-sprites-preview.svg`
- `artifacts/player-sprite-preview.svg`
- `artifacts/player-explosion-preview.svg`

These previews are for validation only.
The real interchange format for the game is the `.bin` sprite data plus the `.json` metadata.

## Minimal Manual Commands

If you only want the full-sheet export and its preview:

```sh
python3 scripts/generate_arcade_full_sheet_assets.py
python3 scripts/preview_c64_sprites.py src/generated_arcade_sprites.bin --out artifacts/arcade-sprites-preview.svg
```

If you want to inspect how a particular asset was layered:

```sh
python3 scripts/debug_sprite_frames.py src/generated_arcade_sprites.asm --labels arcade_b4_s0_layer0,arcade_b4_s0_layer1,arcade_b4_s0_layer2 --mode singlecolor
```
