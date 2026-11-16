# Source Dossier: moto-player-controller-godot

**Canonical repository:** https://github.com/ssebs/moto-player-controller-godot  
**Reviewed revision:** `a5bd7699cb58b73dd8f9a79a6e871587693b7604`  
**Licence:** AGPL-3.0  
**Observed project:** Godot 4.5, Forward+  
**Disposition:** `STUDY_ONLY` — predecessor/reference implementation; no direct code reuse approved.

## Project position

This repository is the author's standalone motorcycle controller project. The DankNooner README identifies it as a prototype that fed into DankNooner V2; the author's future work is in DankNooner. It is easier to read than the full open-world game and provides a compact view of a component-oriented motorcycle controller, but it should not be treated as the current upstream implementation.

## Inspected structure

Relevant paths:
- `scenes/bike/player_controller.gd`
- `scenes/bike/components/bike_input.gd`
- `scenes/bike/components/bike_state.gd`
- `scenes/bike/components/bike_physics.gd`
- `scenes/bike/components/bike_gearing.gd`
- `scenes/bike/components/bike_tricks.gd`
- `scenes/bike/components/bike_crash.gd`
- `scenes/bike/components/bike_camera.gd`
- `scenes/bike/resources/bike_resource.gd`
- `Attributions.md`

## Reverse-engineered runtime flow

The root `PlayerController` is a `CharacterBody3D`. On ready it selects a bike resource, applies configuration, sets up each component and then resets the player. In `_physics_process` it:
1. handles crash/crashed states early;
2. gathers input;
3. updates the state machine;
4. updates gearing, tricks, crash, audio, UI, camera and physics components;
5. calls `move_and_slide()`;
6. updates visual animation;
7. updates enabled mods.

This is straightforward to trace and is a useful example of separating responsibilities. It is not evidence that every component is independently reusable: they are coupled through a shared controller, shared state resource and named scene nodes.

### Input

`BikeInput` turns throttle, front/rear brake, steer, lean, clutch, gear, trick and bike-switch actions into stored values/signals. It also exposes vibration helpers. For Atomic-Z, the lesson is to normalize touch, keyboard and controller input before gameplay consumes it.

### State

`BikeState` tracks IDLE, RIDING, AIRBORNE, TRICK_AIR, TRICK_GROUND, CRASHING and CRASHED. It holds speed, lean, pitch, gear, RPM, combo and boost data. An important code-review finding: the proposed valid-transition table in this source is commented out, so `request_state_change` currently accepts any transition except the same state. Atomic-Z should not copy that weakness; a strict transition graph and tests are preferable.

### Motion

`BikePhysics` uses a scalar speed and a forward direction. Acceleration comes from gearbox power output and a per-bike acceleration value; braking and coasting move the speed toward zero; steering is derived from input lean; slope alignment and airborne gravity are handled separately. This is a gameplay controller, not a full rigid-body bicycle/motorcycle tire model. It has no demonstrated two-contact suspension/tyre force solver in the inspected path.

### Gearing

`BikeGearing` separates gear selection, RPM/clutch and power output from the movement controller. It is a useful boundary for a future gameplay prototype. Parameters still need a clearly validated unit system and per-bike calibration.

### Tricks and crash

`BikeTricks` owns Wheelie, Stoppie, Fishtail/Drift, scoring and Boost behaviour. `BikeCrash` evaluates pitch/lean and brake/grip conditions, collision layers and ragdoll/respawn flow. The separation is useful, but the older implementation contains gameplay tuning and special cases that need review rather than blind adoption.

### Camera and rider

The project has dedicated camera/animation components, rider animation resources, wheel markers and crash-camera transitions. This suggests a clean transform hierarchy: physics/collision root stays authoritative; the bike/rider mesh lives under a visual lean/pitch root; cameras follow stable markers.

## Limitations for Atomic-Z

- AGPL-3.0 code licence; no direct code import without a deliberate licence decision.
- Godot 4.5 Forward+ rather than the project's documented Godot 4.4.1 Compatibility baseline.
- Shared controller/state coupling means this is not a standalone plug-in.
- CharacterBody scalar-speed model is arcade-like, not validated vehicle dynamics.
- It lacks Atomic-Z's existing BuildDocument, GLB surface catalog and project-specific assembly/material ownership.

## Atomic-Z decision

Use the component boundaries and update-order lessons as design reference only. If a rideable prototype is authorized, rebuild a smaller Godot-native controller around a written input contract and explicit state machine. Keep tuning data, visual skin and BuildDocument ownership separate. Any future implementation must be tested against fixed-step movement, slopes, jumps, braking, low-speed steering, crash/reset and Android touch input.

Pinned source links:
- [Player controller](https://github.com/ssebs/moto-player-controller-godot/blob/a5bd7699cb58b73dd8f9a79a6e871587693b7604/scenes/bike/player_controller.gd)
- [Bike physics](https://github.com/ssebs/moto-player-controller-godot/blob/a5bd7699cb58b73dd8f9a79a6e871587693b7604/scenes/bike/components/bike_physics.gd)
- [Input component](https://github.com/ssebs/moto-player-controller-godot/blob/a5bd7699cb58b73dd8f9a79a6e871587693b7604/scenes/bike/components/bike_input.gd)
- [State resource](https://github.com/ssebs/moto-player-controller-godot/blob/a5bd7699cb58b73dd8f9a79a6e871587693b7604/scenes/bike/components/bike_state.gd)
- [Trick component](https://github.com/ssebs/moto-player-controller-godot/blob/a5bd7699cb58b73dd8f9a79a6e871587b7604/scenes/bike/components/bike_tricks.gd)
