# C64 Galaxian Pack Renderer Migration Backlog

This backlog is for the next major change after the current playable shell:

- keep the player, player shot, diving enemies, and major effects on hardware sprites,
- move the in-formation enemy pack off hardware sprites,
- preserve a playable game at every stage,
- preserve or improve the current automated test coverage.

Use this file one stage at a time.
Do not skip ahead until the current gate is passing.

## Target architecture

The recommended architecture for this repo is:

- formation model remains logical and slot-based,
- pack renderer becomes a character-mode renderer,
- divers remain hardware sprites,
- enemy bullets remain character-rendered,
- collisions continue to use logical slot positions, not screen scraping,
- test harnesses read logical state first and VIC state second.

This is a hybrid renderer, not a full bitmap/software-sprite rewrite.

## Non-negotiable rules

- The game must remain bootable and playable after every stage.
- `make verify-asm` is the minimum gate for every stage.
- Any stage that changes gameplay or renderer handoff must also pass `make playtest-asm`.
- Do not remove the existing sprite formation path until the char formation path is proven.
- Prefer adding flags and parallel code paths before deleting working code.

## Required baseline commands

- `make verify-asm`
- `make playtest-asm`
- `make playtest-asm-visible`

Use `make playtest-asm-visible` for the stages that need visual confirmation of alignment, flicker, or handoff.

---

# Stage 1 - carve out a formation renderer boundary

## Prompt for Codex

Refactor the formation code so formation update logic and formation render logic are separate.

Requirements:

- Keep the current sprite-based formation visuals unchanged.
- Introduce a clear renderer entry point for the formation.
- Ensure formation movement, animation state, slot alive state, and dive ownership live in logical state rather than being implied by sprite registers.
- Add a `formation_renderer_mode` symbol or byte so tests and future code can detect which renderer is active.
- Do not change gameplay behavior, timing, or layout.

Constraints:

- Do not introduce the new character renderer yet.
- Do not change the current dive behavior.
- Do not change the player reuse raster behavior yet.

Success criteria:

- The game looks the same as before.
- Formation sprite writes are isolated behind formation renderer routines.
- The codebase now has a stable seam where the new pack renderer can be added.

## Exact test additions

- Update [`scripts/playtest_asm.py`](/Users/david/Documents/c64/c64-vibe-coding/scripts/playtest_asm.py) to read `formation_renderer_mode` from symbols if present.
- Keep current sprite-enable assertions for now, but also record the renderer mode in samples and JSON output.
- Add a playtest assertion that the renderer mode is `sprite` or `0` during this stage.

## Gate

- `make verify-asm`
- `make playtest-asm`

---

# Stage 2 - make the playtest logical-state first

## Prompt for Codex

Refactor the autoplay harness so it treats formation logical state as the source of truth instead of assuming visible formation sprites are always enabled.

Requirements:

- Read formation alive flags and logical X positions from symbols first.
- Fall back to VIC sprite registers only when the logical symbols are unavailable.
- Remove the assumption that all six formation members must map to enabled hardware sprites.
- Preserve all current player movement, firing, bounce, and gap tests.
- Keep the current game code visually unchanged.

Constraints:

- Do not change in-game rendering yet.
- Do not weaken the existing test coverage.

Success criteria:

- The playtest passes against the unchanged sprite renderer.
- The playtest is now ready for a non-sprite pack renderer.

## Exact test additions

- Replace `INITIAL_EXPECTED_SPRITES` usage in the formation-ready path with a new readiness check:
  - player sprite visible,
  - at least one logical formation slot alive,
  - formation Y in the expected top band.
- Add `formation_renderer_mode` and `formation_logical_alive_count` to every captured sample.
- Change `formation_slots()` and gap checks to use logical alive state only.
- Keep `shot_enabled` and `player_enabled` VIC checks unchanged.

## Gate

- `make verify-asm`
- `make playtest-asm`

---

# Stage 3 - build the pack character band without using it as primary output

## Prompt for Codex

Add the first formation character renderer path in parallel with the current sprite renderer.

Requirements:

- Reserve a character-mode band for the formation near the top of the playfield.
- Create routines that can draw and erase formation members into screen RAM and color RAM based on logical slot state.
- Keep the sprite formation renderer active as the default visible output.
- Add a debug switch or build-time flag to enable the char renderer for development.
- Keep the current game playable in either mode.

Constraints:

- Do not remove the sprite formation renderer.
- Do not convert dive rendering yet.
- Do not attempt sub-cell smooth movement yet.

Success criteria:

- The code can draw the pack with chars in a controlled mode.
- Sprite mode still behaves exactly as before.
- The project now has both renderer paths available.

## Exact test additions

- Add a char-renderer smoke assertion path in [`scripts/playtest_asm.py`](/Users/david/Documents/c64/c64-vibe-coding/scripts/playtest_asm.py):
  - when renderer mode reports `char`,
  - sample a small set of screen RAM addresses or exported debug bytes for the formation band,
  - assert that alive slots produce non-blank output.
- Add one or more exported debug symbols for the formation band origin, width, and height if needed.
- Keep existing gameplay assertions unchanged.

## Gate

- `make verify-asm`
- `make playtest-asm`
- `make playtest-asm-visible`

Visual check:

- formation band is aligned,
- colors are readable,
- no corruption of HUD or lower playfield.

---

# Stage 4 - add pre-shifted formation graphics for smooth horizontal motion

## Prompt for Codex

Upgrade the character-based formation renderer so pack movement remains smooth and visually convincing while the formation moves horizontally.

Requirements:

- Introduce pre-shifted formation graphics or an equivalent staged-cell approach.
- Preserve the existing formation animation identity for flagship, escort, and grunt rows.
- Make horizontal movement appear smooth enough that replacing the sprite pack does not feel like a downgrade.
- Keep logical slot positions authoritative for collision and dive launch.

Constraints:

- Do not remove the sprite formation renderer yet.
- Do not change dive behavior yet.
- Do not widen the formation yet.

Success criteria:

- Char-rendered pack movement is visually acceptable in motion.
- Bounce behavior remains readable.
- Shot collisions still match what the player sees.

## Exact test additions

- Add renderer-mode-aware movement checks:
  - in char mode, bounce tests should continue to use logical `formation_*_x` values,
  - add a sampled assertion that rendered pack cells change position over time in the expected direction.
- Add one new debug export if needed for the current phase or shift index.
- Extend the playtest JSON summary to include `formation_renderer_mode` and `formation_shift_phase`.

## Gate

- `make verify-asm`
- `make playtest-asm`
- `make playtest-asm-visible`

Visual check:

- no obvious 8-pixel jumping,
- no ghost columns left behind,
- no pack smear during bounce reversal.

---

# Stage 5 - switch the pack to char rendering by default

## Prompt for Codex

Make the character renderer the default renderer for in-formation enemies, while keeping the old sprite renderer available as a temporary fallback.

Requirements:

- Default the game to the char-rendered pack.
- Keep the old sprite formation renderer behind a debug or emergency switch for one stage.
- Ensure pack animation, movement, gap persistence, and score-award flow still work.
- Keep the player, shot, and existing enemy bullet behavior unchanged.

Constraints:

- Do not change the dive takeover yet beyond what is necessary to avoid duplicate visuals.
- Do not remove the fallback sprite path yet.

Success criteria:

- Normal gameplay now uses the char-rendered pack.
- Formation sprite-enable bits are no longer required for ordinary pack visibility.
- Existing gameplay remains intact.

## Exact test additions

- Update playtest readiness to require `formation_renderer_mode == char` by default.
- Remove any remaining expectation that all pack slots have enabled VIC sprites during ready state.
- Add a gap persistence assertion that checks:
  - logical slot stays dead,
  - the corresponding char band output stays blank after destruction,
  - the formation continues moving.

## Gate

- `make verify-asm`
- `make playtest-asm`
- `make playtest-asm-visible`

---

# Stage 6 - implement clean pack-to-diver handoff

## Prompt for Codex

Integrate the char-rendered pack with the existing dive system so a slot cleanly disappears from the pack when it launches and cleanly returns or stays absent when appropriate.

Requirements:

- When a slot starts diving, remove its pack image from the character band immediately.
- Render the diver only as a hardware sprite while it is detached.
- If the diver returns to formation, restore the pack image at the correct logical slot.
- If the diver is destroyed, keep the slot empty and preserve scoring and explosion behavior.
- Avoid duplicate ships during the handoff.

Constraints:

- Only support the current single-diver design.
- Do not expand the formation yet.

Success criteria:

- Dive launch looks like a true detach from the pack.
- No sprite/char double-draw appears during dive launch or return.
- Player can still shoot divers and pack ships reliably.

## Exact test additions

- Extend [`scripts/playtest_asm.py`](/Users/david/Documents/c64/c64-vibe-coding/scripts/playtest_asm.py) with a new dive handoff scenario:
  - wait for a dive launch,
  - assert `dive_active`,
  - assert the launched slot is absent from char-pack output while diving,
  - assert the diver sprite is active.
- Add a second scenario:
  - shoot the diver,
  - assert the slot remains dead logically,
  - assert the pack image does not reappear.
- Record `dive_launch_slot` and `dive_renderer_state` in results.

## Gate

- `make verify-asm`
- `make playtest-asm`
- `make playtest-asm-visible`

Visual check:

- no duplicate enemy on launch,
- no one-frame reappearance during return/destruction,
- dive path still reads clearly.

---

# Stage 7 - remove pack dependence from player sprite reuse

## Prompt for Codex

Simplify the raster and sprite-allocation path so player lower layers and effects no longer depend on borrowing the former formation sprite slots as part of normal pack rendering.

Requirements:

- Rework sprite slot reuse around the actual remaining sprite users:
  - player,
  - player shot,
  - diver,
  - effects.
- Remove assumptions that slots 0 and 3-7 are primarily formation slots during normal pack rendering.
- Preserve player appearance and explosion behavior.
- Keep raster IRQ behavior stable.

Constraints:

- Do not add new gameplay features.
- Do not increase diver count yet.

Success criteria:

- Sprite ownership is clearer and less brittle.
- The char-pack renderer is now the normal top-of-screen path.
- The freed sprite budget is ready for future attacking enemies.

## Exact test additions

- Add a playtest assertion that ordinary ready-state pack rendering no longer requires any formation sprite-enable bits.
- Add a new check during respawn/explosion windows that player layered sprites still appear and clear correctly.
- Add one summary field that records which sprite slots are active during:
  - ready,
  - shot active,
  - dive active,
  - player explosion.

## Gate

- `make verify-asm`
- `make playtest-asm`
- `make playtest-asm-visible`

---

# Stage 8 - delete the old sprite pack path and prepare for formation expansion

## Prompt for Codex

Remove the obsolete sprite-based pack renderer and finish the migration so the codebase is ready for a larger formation.

Requirements:

- Delete or fully retire the old sprite-pack path.
- Leave the formation model and char renderer table-driven enough to support a larger pack.
- Remove dead code that only existed to preserve the old pack renderer.
- Keep the current six-slot formation behavior stable as the final pre-expansion baseline.

Constraints:

- Do not expand the formation in this stage.
- Do not add more simultaneous divers in this stage.

Success criteria:

- The renderer migration is complete.
- The codebase is smaller and clearer than the temporary dual-renderer phase.
- The next feature work can focus on expanding the formation rather than revisiting the renderer decision.

## Exact test additions

- Remove fallback test branches that only exist for the old sprite-pack path.
- Make char-rendered pack assertions the only default path.
- Add one regression scenario that combines:
  - formation movement,
  - pack hit and persistent gap,
  - dive launch,
  - diver hit or exit,
  - return to idle movement.

## Gate

- `make verify-asm`
- `make playtest-asm`
- `make playtest-asm-visible`

---

## Recommended implementation order after this backlog

Once Stage 8 is stable, the next backlog should be:

1. convert the six-slot formation code to table-driven loops,
2. increase the pack size gradually,
3. add more dive candidates,
4. use the freed sprite budget for multiple attackers and richer effects.

## Definition of done

This migration is done when all of the following are true:

- pack ships are char-rendered by default,
- divers remain sprite-rendered,
- ready-state gameplay no longer depends on formation sprites,
- collisions and scoring still use logical slot data,
- `make verify-asm` passes,
- `make playtest-asm` passes,
- `make playtest-asm-visible` confirms the visual handoff is clean.
