.PHONY: all build d64 run run-live run-timed clean

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

clean:
	rm -rf build artifacts
