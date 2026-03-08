# C64 Galaxian-Style Game Plan — Codex Backlog Version

This document rewrites the earlier plan into a **Codex-friendly staged backlog**.

## How to use this file

- Feed **one stage at a time** into Codex.
- Do not ask Codex to jump ahead unless the current stage is working.
- Keep each stage focused on **one visible improvement**.
- Prefer “make this work cleanly” over “make this advanced”.
- Do not optimise early unless a stage explicitly says to do so.

## Global design intent

Build a **C64-friendly Galaxian-style shooter** that preserves the following feel:

- player ship at the bottom,
- enemy formation at the top,
- player fires upward,
- enemies can break formation and dive,
- lively screen with color and motion,
- simple but satisfying arcade pressure.

## Global implementation rules

Ask Codex to follow these rules throughout the project:

- Keep the design incremental.
- Keep systems simple and readable.
- Avoid premature optimisation.
- Avoid adding features from future stages.
- Prefer stable gameplay over clever rendering tricks.
- Preserve a clean separation between:
  - player logic,
  - formation logic,
  - attack logic,
  - bullet logic,
  - collision logic,
  - score and game-state logic.
- Keep all gameplay deterministic and testable.
- Do not introduce large refactors unless a stage specifically needs one.

---

# Stage 1 — machine setup and one moving alien

## Prompt for Codex

Build the first playable shell for a C64 Galaxian-style project in assembly.

Requirements:

- Set up a stable screen and game loop.
- Display one alien-like object on screen.
- Move it left and right smoothly.
- Keep movement stable and flicker-free.
- Reserve space on screen for a future score and lives area.
- Keep the implementation minimal and easy to extend later.

Constraints:

- Do not add the player yet.
- Do not add bullets yet.
- Do not add sound yet.
- Do not optimise beyond what is needed for stable movement.

Success criteria:

- Program starts cleanly.
- One visible enemy object moves predictably.
- The project now has a tiny but stable game shell.

---

# Stage 2 — add the player ship

## Prompt for Codex

Extend the current project by adding the player ship.

Requirements:

- Place the player ship at the bottom of the playfield.
- Allow left and right movement only.
- Clamp movement so the player cannot leave the visible play area.
- Keep the moving alien visible above.
- Preserve the existing stable update loop.

Constraints:

- Do not add shooting yet.
- Do not add enemy attacks yet.
- Do not add score yet.

Success criteria:

- The player ship is controllable.
- The player and enemy can coexist on screen cleanly.
- The layout now clearly resembles a fixed shooter.

---

# Stage 3 — add one player shot

## Prompt for Codex

Extend the project by adding the player’s first shot.

Requirements:

- Allow the player to fire one shot upward.
- Limit the player to a single active shot at a time.
- Move the shot upward each update.
- Remove the shot when it leaves the top of the screen.
- Detect collision between the shot and the current enemy.
- Remove or destroy the enemy when hit.
- Add a very small visual indication of a hit if that is easy to do.

Constraints:

- Keep collision simple and reliable.
- Do not add multiple shots.
- Do not add enemy bullets.
- Do not add lives yet.

Success criteria:

- The player can move, fire, and hit the enemy.
- The project now has a complete minimal shooter loop.

---

# Stage 4 — replace the single alien with a tiny formation

## Prompt for Codex

Replace the single enemy with a very small formation.

Requirements:

- Represent enemies as formation slots rather than one isolated object.
- Start with a tiny formation, such as a short row or small block.
- Move the whole formation left and right together.
- Reverse direction at screen edges.
- Keep enemy spacing clean and readable.
- Allow the player shot to destroy individual formation members.
- Leave visible gaps where enemies have been destroyed.

Constraints:

- Keep the formation intentionally small for now.
- Do not add diving attacks yet.
- Do not add enemy fire yet.
- Do not make the display strategy overly complex at this stage.

Success criteria:

- The screen now reads clearly as an enemy formation.
- Destroyed enemies leave holes in the group.
- The formation logic is clean enough to grow later.

---

# Stage 5 — add enemy classes and scoring identity

## Prompt for Codex

Extend the formation so it has multiple enemy classes.

Requirements:

- Split the formation into rows or groups with distinct enemy types.
- Give each type a distinct visual identity.
- Assign each type a different score value.
- Preserve formation structure as enemies are destroyed.
- Prepare the score values so they can be displayed later.

Constraints:

- Do not add the score display yet unless it is trivial.
- Do not add attack patterns yet.
- Keep the visual differences simple and readable.

Success criteria:

- The formation has ranked enemy types.
- The game now has the beginnings of arcade scoring logic.

---

# Stage 6 — add simple enemy animation

## Prompt for Codex

Extend the formation by adding simple animation to enemies.

Requirements:

- Alternate enemy appearance between two or more simple animation states.
- Keep animation lightweight and synchronized enough to look intentional.
- If practical, allow different enemy classes to animate differently.
- Preserve all earlier gameplay behavior.

Constraints:

- Do not add diving attacks yet.
- Do not add expensive rendering tricks.
- Keep the animation logic easy to maintain.

Success criteria:

- The formation looks alive even when not attacking.
- The project feels more like an arcade homage than a static prototype.

---

# Stage 7 — add one diving attacker

## Prompt for Codex

Add the first true Galaxian-style behavior: a diving attacker.

Requirements:

- Select a living enemy from the formation.
- Detach it from the formation temporarily.
- Move it along a visible dive path toward the player area.
- Allow the player to shoot it while it is diving.
- For the first version, it may either leave the screen or return to formation, whichever is simpler and cleaner.
- Keep the formation intact apart from the temporarily detached attacker.

Constraints:

- Only support one diving enemy at a time for now.
- Keep the attack route readable.
- Do not add complex group attacks yet.

Success criteria:

- An enemy can break formation and attack.
- The player must react differently than when only shooting the formation.

---

# Stage 8 — add enemy fire

## Prompt for Codex

Add enemy bullets so the player is under real threat.

Requirements:

- Allow a diving enemy, or another sensible enemy source, to fire downward.
- Limit the number of active enemy bullets.
- Move enemy bullets downward each update.
- Detect collisions between enemy bullets and the player ship.
- Add a clean player death or hit response.
- Preserve stable gameplay and readability.

Constraints:

- Keep bullet counts low.
- Avoid bullet spam.
- Keep the first version simple and fair.

Success criteria:

- The player must dodge as well as shoot.
- Enemy attacks now create real gameplay pressure.

---

# Stage 9 — add lives and basic game states

## Prompt for Codex

Add proper game states and lives management.

Requirements:

- Track player lives.
- Add basic states such as ready, playing, player hit, respawn, and game over.
- Pause briefly after the player is hit.
- Restore the player cleanly after death if lives remain.
- Do not corrupt the formation state during respawn handling.

Constraints:

- Keep transitions simple and readable.
- Do not add a full title screen yet unless it falls out naturally.

Success criteria:

- The game can be played, failed, and restarted cleanly.
- Loss and recovery states feel controlled rather than broken.

---

# Stage 10 — add score display and wave completion

## Prompt for Codex

Add visible score handling and level-clear logic.

Requirements:

- Display the player score on screen.
- Award points based on enemy type.
- Detect when all enemies in the wave are destroyed.
- Trigger a simple wave-complete transition.
- Prepare the game to start another wave cleanly.

Constraints:

- Keep the display simple and readable.
- Do not add advanced bonus systems yet.

Success criteria:

- The player can now clear a wave and see visible scoring progress.
- The project now qualifies as a playable first level.

---

# Stage 11 — add wave setup and difficulty ramp

## Prompt for Codex

Extend the game to support repeated waves and controlled difficulty growth.

Requirements:

- Rebuild the enemy formation at the start of each new wave.
- Increase difficulty gradually between waves.
- Difficulty may be adjusted through:
  - formation movement speed,
  - dive frequency,
  - bullet speed,
  - number of simultaneous threats,
  - reduced idle time.
- Keep the first wave easy and consistent for testing.

Constraints:

- Keep tuning values easy to change.
- Do not make difficulty jumps harsh.

Success criteria:

- The game has a progression curve.
- Later waves feel tougher without becoming chaotic.

---

# Stage 12 — add background stars

## Prompt for Codex

Add a lightweight starfield effect to improve the arcade feel.

Requirements:

- Render a star background behind gameplay.
- Make it drift, shimmer, or otherwise feel alive.
- Keep the effect lightweight enough that gameplay remains stable.
- Preserve readability of the player, enemies, and bullets.

Constraints:

- Do not sacrifice gameplay timing for visual flourish.
- Keep the first version simple.

Success criteria:

- The screen feels more like outer space.
- Quiet moments still have visual life.

---

# Stage 13 — improve attack behavior

## Prompt for Codex

Expand the enemy attack system beyond a single simple dive.

Requirements:

- Support more than one attack pattern.
- Allow attacks to be selected from sensible positions in the formation.
- If practical, introduce different dive behavior for different enemy classes.
- Keep attacks readable and fair.
- Preserve the clear distinction between enemies in formation and enemies in active attack mode.

Constraints:

- Do not make attacks feel random or messy.
- Prefer a small number of good patterns over many weak ones.

Success criteria:

- The game now has recognisable tactical variety.
- Enemy behavior feels more distinctly inspired by Galaxian.

---

# Stage 14 — add presentation polish

## Prompt for Codex

Improve the game’s overall presentation without changing the core gameplay structure.

Requirements:

- Add a simple title or start screen.
- Add a start prompt or ready message.
- Add wave banners or short transition messages.
- Improve hit feedback and player death feedback.
- Add simple sound priorities for:
  - player shot,
  - enemy hit,
  - enemy attack feel,
  - player death,
  - wave clear.
- Keep the presentation coherent and clean.

Constraints:

- Do not let polish features destabilize the gameplay loop.
- Keep the style simple and arcade-like.

Success criteria:

- The game feels cohesive rather than purely mechanical.
- Starting, playing, losing, and clearing waves all feel more satisfying.

---

# Stage 15 — optimise and choose final visual strategy

## Prompt for Codex

Review the current implementation and improve performance and rendering strategy where needed.

Requirements:

- Measure or identify the parts of the frame update that cost the most.
- Improve performance only where there is a real benefit.
- Evaluate whether the current formation display approach is sufficient.
- Only if needed, consider:
  - better sprite reuse,
  - more advanced sprite scheduling,
  - richer enemy visuals,
  - smoother starfield,
  - more simultaneous attackers,
  - better sound handling.
- Preserve gameplay behavior while improving implementation quality.

Constraints:

- Do not rewrite working systems without a clear reason.
- Do not chase technical cleverness unless it improves the visible game.

Success criteria:

- The game remains stable and playable.
- Performance headroom is improved where it matters.
- The final display strategy is a deliberate choice rather than an accident.

---

# Optional follow-on backlog after first playable level

Once the first playable level is working, future prompts can explore:

- better title screen presentation,
- attract mode,
- bonus enemy behavior,
- formation entry animation,
- richer sound design,
- high score table,
- more arcade-authentic attack waves,
- more advanced sprite multiplexing,
- visual polish to bring the game closer to the arcade original,
- packaging and build cleanup for repeatable development.

---

# Overall milestone summary

Use this order:

1. machine setup and one moving alien  
2. player ship  
3. player shot  
4. tiny formation  
5. enemy classes  
6. enemy animation  
7. one diving attacker  
8. enemy fire  
9. lives and game states  
10. score and wave completion  
11. multiple waves and difficulty ramp  
12. starfield  
13. better attack behavior  
14. presentation polish  
15. optimisation and final rendering strategy

---

# Final instruction you can prepend to every Codex prompt

Use the existing project and extend it incrementally. Keep the implementation simple, stable, and readable. Do not jump ahead to later stages. Do not add speculative features. Make the current stage work cleanly before introducing new complexity.
