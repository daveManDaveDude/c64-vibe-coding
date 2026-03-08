# C64 Galaxian-Style Game Plan

Below is a practical build plan for a **C64 game inspired by the arcade feel of Galaxian**: fixed player ship at the bottom, enemy formation near the top, occasional diving attacks, colorful animated enemies, and a moving star background.

The original arcade **Galaxian** is notable for its multicolored animated sprites, fixed-shooter structure, and enemies that break formation to dive-bomb the player. On C64, the core constraints are the VIC-II’s 8 hardware sprites, 24×21 sprite size, raster interrupts, and the usual tradeoff between sprite use, CPU time, and screen mode choice.

## What to preserve from Galaxian

The part you most want to preserve is not exact arcade accuracy, but the **feel**:

- a neat enemy formation at the top,
- enemies with distinct visual ranks,
- occasional “break formation and swoop” attacks,
- player moving left-right at the bottom firing upward,
- a sense of life from stars, color, and animation,
- escalating pressure as fewer enemies remain.

That gives you a clear design rule for every step:

**Keep the formation readable, the attack behavior legible, and the screen lively.**

On C64, that usually means using hardware sprites for the most important moving objects and using the character screen for static or semi-static elements like score, labels, and possibly stars or decorative layers.

## The core C64 strategy

A Galaxian-like on C64 becomes much more feasible if you decide early on that:

- **The player ship is always a hardware sprite.**
- **Enemy divers are hardware sprites.**
- **The formation itself may start as logical objects first, and later become either hardware sprites with multiplexing or a hybrid of character graphics plus sprite overlays.**
- **Shots are cheap objects with strict limits.**
- **Background stars are a lightweight illusion, not a fully simulated field.**

This matters because the VIC-II only handles 8 sprites at once per scanline, so a full enemy formation cannot be represented naïvely as “one hardware sprite per alien all the time.”

A convincing C64 version usually needs one of three approaches:

1. small active set of visible sprite aliens with a reduced formation,
2. sprite multiplexing for more enemies across different vertical zones,
3. hybrid display where formation uses chars/tiles and only active attackers are sprites.

The third option is often the safest path for an iterative project like yours.

## Recommended design choice

For this project, the best high-level route is:

**Use a hybrid design.**

That means:

- the top formation is represented logically as a grid of enemy slots,
- early versions may draw that formation with simple character graphics or a limited number of sprites,
- when an enemy attacks, it “promotes” into an active moving sprite,
- the player and player bullet are always true gameplay sprites,
- enemy bullets are tightly limited,
- the final look is improved step by step without changing the underlying game model.

This is the most realistic route from “hello world alien” to “playable level” because it lets Codex build systems in layers instead of solving sprite multiplexing and full game logic all at once.

---



## The systems Codex should build, in plain English

### 1. Frame/update system

You want a consistent “heartbeat” for the game:

- read input,
- update game objects,
- resolve collisions,
- update display,
- repeat.

This should exist before any complex gameplay because every later system depends on predictable timing.

### 2. Object model

Even without fancy code architecture, you need clear categories:

- player,
- player shot,
- formation enemies,
- active diving enemies,
- enemy shots,
- effects,
- score/lives/game state.

That mental model helps Codex add things without creating spaghetti.

### 3. Formation model

The formation should be treated as a grid of slots, not just a pile of independent enemies.

Each slot should know:

- whether an enemy is alive,
- what type it is,
- where it sits in the formation,
- whether it is in formation or currently diving.

This matters because Galaxian’s identity comes from enemies belonging to an organised formation first, and individual attacks second.

### 4. Attack system

Attack behavior should be a separate layer from formation behavior.

A living enemy in the formation may be selected to:

- detach,
- follow an attack route,
- maybe fire,
- then either be destroyed, leave the screen, or rejoin.

This separation will make the project much easier for Codex to extend.

### 5. Collision system

Keep collision logic simple and explicit:

- player shot vs enemies,
- enemy shot vs player,
- diving enemy vs player,
- maybe player vs formation edge only if needed.

For a C64 arcade-style project, simple reliable collisions are better than fancy but inconsistent ones.

### 6. Difficulty system

Difficulty should not be magical. It should be a short list of tunable values:

- formation horizontal speed,
- pause at edges,
- chance of dive attack,
- bullet speed,
- number of simultaneous attackers,
- enemy shot frequency.

This lets you tune the feel without rewriting systems.

### 7. Presentation system

You want a lightweight layer for:

- title/start message,
- score/lives,
- wave banners,
- game over,
- sound cues,
- simple hit/death effects.

That prevents UI and feedback from becoming scattered across gameplay logic.

---

## What to avoid early

To keep this project moving, avoid asking Codex to solve these too soon:

- “Make it arcade-perfect.”
- “Use every sprite trick immediately.”
- “Support a huge full-sprite formation from day one.”
- “Add perfect starfield, music, sound, score, and attack AI all at once.”
- “Optimise before the gameplay loop is proven.”

The dangerous trap on C64 is burning time on rendering cleverness before the game is fun.

---

## The most sensible milestone path

This is the shortest practical route from nothing to playable:

1. one moving alien
2. player ship
3. player shot
4. tiny formation
5. destroy formation members
6. different enemy rows / scores
7. one diving attacker
8. enemy fire
9. lives / game over
10. full wave clear
11. multiple waves and difficulty ramp
12. stars / sound / polish
13. richer attacks
14. optimisation and final visual upgrades

That sequence keeps each step testable and gives Codex a clear “next thing to make work” every time.

---

## Recommendation for the overall vision

Aim for this statement:

**“A C64-friendly Galaxian-style shooter that preserves the formation, color, animation, and diving-attack feel of the arcade original, while using a hybrid display strategy so it stays achievable.”**

