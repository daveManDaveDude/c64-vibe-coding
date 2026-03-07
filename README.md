# C64 BASIC + Assembly Pipeline (VICE + VS Code)

A reproducible Commodore 64 development environment for macOS using VICE tools for both BASIC and assembly.

This project:
- tokenizes ASCII BASIC (`.bas`) to C64 BASIC v2 program (`.prg`) via `petcat`
- assembles KickAssembler source (`.asm`) into a `.prg` with a BASIC `SYS` stub via `BasicUpstart2`
- builds a fresh disk image (`.d64`) and writes the program via `c1541`
- runs in `x64sc` in live mode (keep emulator open) or timed mode (auto-exit with screenshot/log capture)
- supports VICE/VS64 debugging for both BASIC and assembly builds

## Prerequisites

- macOS
- [Homebrew](https://brew.sh/)
- VICE tools on `PATH`
- Java runtime for KickAssembler

Install the macOS toolchain:

```bash
brew install vice openjdk
```

Verify tools:

```bash
command -v x64sc petcat c1541
/opt/homebrew/opt/openjdk/bin/java -version
```

Expected output includes paths for the VICE tools plus a working Java runtime.

KickAssembler is downloaded from its official site on first assembly build into `tools/KickAssembler/`.

## Recommended Stack

For a developer-focused macOS setup, this repo now uses:

- VICE `x64sc` for emulation and remote debugging
- KickAssembler for 6510 assembly with a BASIC launcher stub
- VS64 for VS Code build/debug integration

`acme` and `cc65` are both available through Homebrew and work on macOS, but KickAssembler is the best fit here because it combines a strong C64-specific workflow with `BasicUpstart2`, symbol output, and smooth VICE/VS64 integration.

## Project Structure

```text
src/                 BASIC and assembly source files
scripts/             build/run scripts
build/               generated .prg and .d64
artifacts/           run logs, screenshots, status files
.vscode/tasks.json   VS Code task integration
Makefile             command entry points
```

## Quick Start

Build and run BASIC live (keeps emulator open):

```bash
make run
```

Build and run assembly live:

```bash
make run-asm
```

Build and run the timed pipelines (auto-exit):

```bash
make run-timed
make run-asm-timed
```

Clean outputs:

```bash
make clean
```

## Program Preview

![Creative C64 hello world](docs/hello-screenshot.png)

## BASIC Targets

- `make build`: `src/hello.bas` -> `build/hello.prg`
- `make d64`: creates `build/hello.d64` and writes `HELLO`
- `make run`: BASIC live mode
- `make run-live`: BASIC live alias
- `make run-timed`: BASIC timed mode

## Assembly Targets

- `make build-asm`: `src/hello-asm.asm` -> `build/hello-asm.prg`
- `make d64-asm`: creates `build/hello-asm.d64` and writes `HELLOASM`
- `make run-asm`: assembly live mode
- `make run-asm-live`: assembly live alias
- `make run-asm-timed`: assembly timed mode

## Assembly Hello World

The sample assembly program lives at `src/hello-asm.asm`.

It uses KickAssembler's `BasicUpstart2(start)` macro to generate the BASIC stub at `$0801`, then jumps into the machine-code entry point at `$1000`. That gives you the same "autostart from BASIC" style workflow you already had for BASIC sources, but with the body implemented in 6510 assembly.

## VS Code Integration

Configured tasks in `.vscode/tasks.json`:

- `C64: Build PRG`
- `C64: Build D64`
- `C64: Run (VICE Pipeline)` (timed mode)
- `C64: Run Live (Keep Open)` (default build task)
- `C64 ASM: Build PRG`
- `C64 ASM: Build D64`
- `C64 ASM: Run (VICE Pipeline)`
- `C64 ASM: Run Live (Keep Open)`
- `C64: Clean`

Usage:

1. Open this folder in VS Code.
2. Press `Cmd+Shift+B` to run the default build task (live mode).
3. Use `Cmd+Shift+P` -> `Tasks: Run Task` to run any specific task.

If task behavior seems stale after edits, run `Developer: Reload Window`.

## Outputs

Live mode:
- `artifacts/vice-live.log`

Timed mode:
- `artifacts/vice.log`
- `artifacts/vice-exit.png`
- `artifacts/run_status.txt`

## Notes

- BASIC keywords should stay lowercase in ASCII source for reliable tokenization.
- Timed mode may report a VICE non-zero exit when cycle limit is reached; pipeline handling normalizes this in `run_status.txt`.
- `c1541` may print `OPENCBM` dynamic library warnings on macOS Homebrew installs; `.d64` creation still works for this workflow.

## Debugging in VS Code (BASIC step-through)

This repo supports integrated BASIC and assembly debugging through VS64 + the VICE binary monitor.

### One-time setup

1. Install VS64 extension: `rosc.vs64` (workspace recommends it automatically).
2. Ensure VICE is installed and `x64sc` is on `PATH`:

```bash
brew install vice openjdk
```

### Debug flow

1. Open either `src/hello.bas` or `src/hello-asm.asm`.
2. Click the gutter to set a breakpoint.
3. Press `F5`.
4. Choose `Debug Active C64 File (VICE / VS64)`.

Expected behavior:
- If the active file is `hello.bas`, VS Code builds `build/hello.prg` and launches that.
- If the active file is `hello-asm.asm`, VS Code builds `build/hello-asm.prg` and launches that.
- For assembly, VS64 resolves labels from `build/hello-asm.sym`.

### Attach flow (optional)

1. Open the `.bas` or `.asm` file you want to debug.
2. Run task: `C64: Start VICE Debug Server For Active Source`.
3. Press `F5`.
4. Choose `Attach to VICE (Active C64 File / VS64)`.

### Troubleshooting

- If VS64 cannot connect, check port `6502` is free, then keep `.vscode/settings.json` and `.vscode/launch.json` ports aligned.
- `F5` follows the active editor now; if the wrong program launches, make sure the `.bas` or `.asm` tab you want is focused before starting debug.
- If ASM breakpoints do not hit, rebuild so `build/hello-asm.sym` matches `build/hello-asm.prg`.
- If PRG autostart is flaky, keep `-autostartprgmode 1` enabled.
