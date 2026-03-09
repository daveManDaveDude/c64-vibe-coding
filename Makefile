.PHONY: all build d64 run run-live run-timed build-asm d64-asm run-asm run-asm-live run-asm-timed verify-asm playtest-asm playtest-asm-visible debug-sprites preview-sprites convert-sprites-png2prg clean

all: run-live

build:
	./scripts/build_prg.sh

d64: build
	./scripts/make_d64.sh

run: d64
	./scripts/run_live.sh

run-timed: d64
	./scripts/pipeline.sh

run-live:
	./scripts/run_live.sh

build-asm:
	./scripts/build_asm.sh

d64-asm: build-asm
	./scripts/make_d64.sh build/hello-asm.prg build/hello-asm.d64 ASMHELLO 00 HELLOASM

run-asm:
	./scripts/run_live_asm.sh

run-asm-live:
	./scripts/run_live_asm.sh

run-asm-timed:
	./scripts/pipeline_asm.sh

verify-asm:
	./scripts/verify_asm_console.sh

playtest-asm:
	./scripts/playtest_asm.sh

playtest-asm-visible:
	./scripts/playtest_asm_visible.sh

debug-sprites:
	python3 scripts/generate_arcade_enemy_sprites.py
	python3 scripts/generate_arcade_full_sheet_assets.py
	python3 scripts/generate_player_sprite.py
	python3 scripts/generate_player_explosion_sprites.py
	python3 scripts/debug_sprite_frames.py --grouped
	python3 scripts/debug_sprite_frames.py src/generated_player_sprite.asm --labels player_red_sprite_png --mode singlecolor
	python3 scripts/debug_sprite_frames.py src/generated_player_sprite.asm --labels player_white_sprite_png --mode singlecolor
	python3 scripts/debug_sprite_frames.py src/generated_player_sprite.asm --labels player_cyan_sprite_png --mode singlecolor
	python3 scripts/preview_c64_sprites.py
	python3 scripts/preview_player_sprite.py
	python3 scripts/preview_player_explosion.py

preview-sprites:
	python3 scripts/generate_arcade_enemy_sprites.py
	python3 scripts/generate_arcade_full_sheet_assets.py
	python3 scripts/generate_player_sprite.py
	python3 scripts/generate_player_explosion_sprites.py
	python3 scripts/preview_c64_sprites.py
	python3 scripts/preview_c64_sprites.py src/generated_arcade_sprites.bin --out artifacts/arcade-sprites-preview.svg
	python3 scripts/preview_player_sprite.py
	python3 scripts/preview_player_explosion.py

convert-sprites-png2prg:
	bash scripts/convert_enemy_sprites_with_png2prg.sh

clean:
	rm -rf build artifacts
