.PHONY: all build d64 run run-live run-timed build-asm d64-asm run-asm run-asm-live run-asm-timed clean

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

clean:
	rm -rf build artifacts
