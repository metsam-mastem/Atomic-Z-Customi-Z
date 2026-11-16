# Source Dossier: DankNooner

**Canonical repository:** https://github.com/ssebs/DankNooner  
**Reviewed revision:** `85bb82f1afe88d6baa564a77ab04b0d7aab3429b`  
**Licence:** AGPL-3.0  
**Observed project:** Godot 4.7, Forward+ (v2)  
**Repository size at audit:** approximately 1.19 GB; tree contained roughly 15,646 entries and 590 GDScript files.  
**Disposition:** `STUDY_ONLY` — architecture and behaviour reference; do not copy/vendoredrop into Atomic-Z.

## Why it matters

DankNooner is the closest match found to the user's requested riding-game direction. Its V2 is an open-world multiplayer motorcycle game with free-roam, server-authoritative physics, client prediction/rollback, a manual gearbox and clutch, progressive braking, a broad trick set, combos/boost, crash and ragdoll handling, races, NPC traffic, rider IK, custom audio and a bike/skin system. The project README explicitly says V2 is a rewrite and remains in active development; its TODO and planning documents show further work is planned.

## Architecture reverse-engineered from the checked source

### Player composition

The V2 player is a `CharacterBody3D` entity. `v2/player/player_entity.gd` composes focused controllers rather than making one script own the entire player. `v2/planning_docs/PlayerController.md` documents the responsibilities and update order:

1. Boost controller.
2. Movement controller.
3. Gearing controller.
4. Trick controller.
5. Crash controller.

Input is gathered before the rollback tick. Animation, camera, audio and HUD are derived from or observe controller state. This separation is a strong maintainability pattern.

### Movement and riding

`v2/player/controllers/movement_controller.gd` contains the main motion model. The inspected implementation includes:
- wheelie force and lean influence;
- slope gravity and a maximum climb angle;
- air drag and airborne roll control;
- surface alignment and ramp/loop handling;
- steering limits while wheelieing/stoppieing;
- speed wobble/drift interactions;
- explicit thresholds to avoid treating tiny bumps as full jumps.

This is an arcade/simulation hybrid implemented around a CharacterBody-style controller. It is not a two-wheel tire-contact solver or OEM-validated motorcycle model. Constants are gameplay tuning, not engineering specifications.

### Tricks and crash rules

`trick_controller.gd` maps context and gesture (tap, double-tap, hold) to trick states. It tracks trick state, airtime, wheelie/stoppie detection, trick combos, scoring and trick animation windows. `crash_controller.gd` separates low-side/high-side, brake washout, power washout, collision and landing-mid-trick checks. `wobble_controller.gd` contributes recoverable instability before a crash.

The important lesson is not any particular threshold: use explicit entry/exit thresholds, timers, last-tick state and carefully ordered transitions to prevent state flicker and accidental crashes.

### Gearbox and boost

`gearing_controller.gd` uses per-bike gear ratios, max speed, idle/max RPM, a power curve, clutch engagement, shift-cut time and a rev limiter. Its requested gear is absolute rather than edge-triggered, which avoids losing/doubling shifts during stale network input and resimulation.

`boost_controller.gd` owns the meter and burn lifecycle. `ComboAndBoost.md` explains why earning, spending and banking are separate responsibilities. State that participates in rollback must be mutated inside the rollback tick: a manager writing rollback-owned state from ordinary `_process()` can have its value overwritten when historical state is reapplied.

### Bike definition and visuals

`v2/resources/bikes/bike_skin_definition.gd` distinguishes a skin definition from a base bike type and stores mesh reference, marker transforms, rider pose targets, mods and audio configuration. This separation between simulation definition and visual skin is a useful idea to evaluate. It should not be cloned blindly because Atomic-Z already has a canonical `BuildDocument` and a project-specific part/surface model.

### Camera, animation, audio and test strategy

The camera controller includes multiple camera modes, smoothed targets, look controls, FOV speed response, trauma/shake and boost effects. Player architecture documents IK markers and animation ownership. The testing document describes a multi-process orchestration with isolated save slots, test-only scene wrappers and in-game input injection; however, that document itself says its multi-peer steps still need to be verified. Do not confuse a written test design with complete acceptance.

## Compatibility and adoption blockers

- AGPL-3.0: copying/adapting code into a distributed combined product can create source-disclosure and licence-compliance obligations. Obtain a deliberate legal/product decision before reuse.
- Godot 4.7 Forward+ differs from Atomic-Z's documented Godot 4.4.1 / Compatibility baseline.
- The repository is large and contains bundled assets, sounds, fonts, add-ons and other material with separate attribution/licence considerations.
- Multiplayer dependencies (netfox, WebRTC/Steam-related systems) are not needed for the current garage.
- The game is an open-world riding product, while Atomic-Z is currently a customization workbench.

## Atomic-Z transfer decision

**Transfer as written design constraints, not copied code:**
- small controllers with clear ownership;
- a documented physics/update order;
- per-bike tuning data separated from cosmetic skin;
- explicit state transitions with hysteresis;
- camera/animation/audio driven from stable gameplay state;
- tests that isolate save files and do not mutate user data.

**Do not transfer now:**
- AGPL source or asset packs;
- full netcode, traffic, gamemode stack or FMOD pipeline;
- undocumented gameplay constants as real-world dynamics;
- duplicate bike definition/save/skin systems.

Pinned source paths:
- [Player entity](https://github.com/ssebs/DankNooner/blob/85bb82f1afe88d6baa564a77ab04b0d7aab3429b/v2/player/player_entity.gd)
- [Movement controller](https://github.com/ssebs/DankNooner/blob/85bb82f1afe88d6baa564a77ab04b0d7aab3429b/v2/player/controllers/movement_controller.gd)
- [Trick controller](https://github.com/ssebs/DankNooner/blob/85bb82f1afe88d6baa564a77ab04b0d7aab3429b/v2/player/controllers/trick_controller.gd)
- [Crash controller](https://github.com/ssebs/DankNooner/blob/85bb82f1afe88d6baa564a77ab04b0d7aab3429b/v2/player/controllers/crash_controller.gd)
- [Boost controller](https://github.com/ssebs/DankNooner/blob/85bb82f1afe88d6baa564a77ab04b0d7aab3429b/v2/player/controllers/boost_controller.gd)
- [Gearbox controller](https://github.com/ssebs/DankNooner/blob/85bb82f1afe88d6baa564a77ab04b0d7aab3429b/v2/player/controllers/gearing_controller.gd)
- [Player controller design](https://github.com/ssebs/DankNooner/blob/85bb82f1afe88d6baa564a77ab04b0d7aab3429b/v2/planning_docs/PlayerController.md)
- [Combo and boost design](https://github.com/ssebs/DankNooner/blob/85bb82f1afe88d6baa564a77ab04b0d7aab3429b/v2/planning_docs/ComboAndBoost.md)
