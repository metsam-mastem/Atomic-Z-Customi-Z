# Source Dossier: Need for Speed reconstruction projects

This dossier separates official and independent NFS references: an MIT-licensed scratch-built car engine, a reconstruction with unclear project-wide rights, a detailed but incomplete source reconstruction with limited MIT scope, and older unlicensed leads.

## 1. OpenNFS

**Repository:** https://github.com/OpenNFS/OpenNFS  
**Reviewed revision:** `dcd9197033272f8be307a839105e74185809f9f9`  
**Repository licence:** MIT (repository code; dependencies and any third-party content retain their own terms)  
**Language/runtime:** C++ desktop engine with Bullet Physics, OpenGL/GLFW and related libraries  
**Disposition:** architecture/algorithm study; no C++ runtime import into Atomic-Z.

### Project structure and scope

The inspected tree contains roughly 320 paths and 178 C++ source/header files. Major areas include:
- `src/Physics/`: vehicle dynamics, rigid-body integration, collision and AABB structures;
- `src/Camera/`: camera hierarchy and spline/Hermite camera logic;
- `src/Race/`: player/racer agents, race session, racer manager and skid marks;
- `src/Renderer/`: model renderers and shader families;
- `src/Loaders/`: cars, tracks, text and music;
- `src/GameState/`: menu, vehicle selection, track selection and race loading.

README describes an engine intended to load data from classic NFS 1–5 releases. The project is still incomplete and parser refactors have affected some formats. The README explicitly says it does not bundle EA intellectual property and that the user supplies files from a lawful original game installation.

### Physics findings

`NFS4VehiclePhysics.cpp` maps per-car physics data into an explicit parameter structure. The fields inspected include mass, maximum velocity, min/redline RPM, gas-off factor, lateral grip multiplier, front grip bias, front drive ratio, brake bias, understeer gradient, steering response, turning-circle radius, downforce, weight-transfer factor, turn-in/out ramp, braking deceleration and shift delay. It also maps torque curves, gear velocity/RPM ratios, gear efficiency, shift blips and brake curves.

The solver accepts throttle, brake, steering and handbrake inputs, tracks gear/RPM/contact/slip state and derives speed from chassis velocity. This demonstrates the value of per-vehicle data plus a distinct runtime state model.

`RaycastVehicle.cpp` customizes Bullet's raycast vehicle update. It:
- updates wheel transforms and raycasts wheel contact;
- computes suspension impulses from contact normals;
- caches contact information before later stages update it;
- calculates wheel rotation from local velocity;
- handles wheel spin/slip conditions separately from grounded contact.

The concept is useful: keep wheel contact, suspension response, tire slip and visual wheel rotation as distinct signals. However, OpenNFS simulates four-wheel cars. A motorcycle has two wheel contact patches plus a balancing/leaning body, steering geometry, rider mass shift and different stability constraints. The four-wheel solver cannot be copied as a motorcycle physics model.

### Rendering and game-flow findings

The project separates camera types, renderer/shader families, menu/game states, track/car loaders, race agents and race session management. This is a good example of keeping data loading, game flow, simulation and rendering from becoming one monolithic class.

### Build and compatibility

The inspected README/build guide uses CMake/Ninja and desktop dependencies such as GLEW, GLFW, GLM, Bullet3, FreeType, Google Test and g3log. It is not a Godot module or Android-ready plug-in. Importing it would add a second rendering/physics stack and conflict with Atomic-Z's single-runtime rule.

### Rights boundary

The MIT notice applies to OpenNFS's original code. It does not grant rights to EA models, textures, cars, tracks, music or other material loaded from an original game. Third-party libraries also have their own licences. Do not add EA game assets or data to this repository.

## 2. OpenUG2

**Repository:** https://github.com/whoismept/OpenUG2  
**Reviewed revision:** `a66dc198bca3629f616684093b8d0743f20bd6a6`  
**GitHub licence detection:** `NOASSERTION` / no clear SPDX grant established  
**Language:** C / C++ and related systems code  
**Disposition:** `STUDY_ONLY`; do not copy source or recovered data.

### What is valuable

OpenUG2 is an independent reimplementation/reconstruction of the NFS Underground 2 engine. The inspected tree contains about 677 paths and roughly 270 C/C++ source files. The source areas include drivetrain, braking, contact, ground motion, lateral handling, camera, HUD, rendering, resource loading and menus.

The most useful material for Atomic-Z is the clean-room methodology documented under `docs/cleanroom-driving-physics/`:
- `PROVENANCE.md` records target identity, a legal owner-supplied reference build, staged analysis roles, hashes and limitations.
- `SPEC.md` separates observable behaviour and derived rules from implementation.
- `QUESTIONS.md` preserves unresolved questions.
- `test-vectors/` and review/verification reports make the assumptions testable.
- Reviewer gates explicitly distinguish static-analysis-derived vectors from retail runtime captures.

The provenance history records a past operational deviation: an earlier analysis ran under Wine without a VM and without network isolation. That deviation was documented rather than hidden. Atomic-Z's playbook should retain this level of transparency and stricter isolation for future work.

### Findings and limits

The NFSU2 work is about car behaviour, not motorcycle physics. Its test vectors are often derived from the written specification; the project's own review states that they are not retail runtime captures and do not prove end-to-end fidelity. It explicitly retains unresolved behaviours and precision limitations. Treat its process as a quality standard, not its numerical vehicle model as ground truth.

The repository's GitHub licence detection is NOASSERTION. Until an explicit licence is established for the exact source and data, treat all code and derived content as not reusable. Do not commit original game binaries, assets, decompilation dumps or proprietary tables.

## 3. SPEED RE

**Repository:** https://github.com/troikoss/speed-re  
**Reviewed revision:** `892e5c31d77c751acd123330eda15c157c4f1b1f` (2026-10-29).  
**Licence:** limited MIT grant for original project contributions only; the LICENSE expressly excludes recovered/reconstructed NFSU2 code under `src/Speed/Indep/`, recovered game data, embedded protected material, retail assets and third-party imports.  
**Disposition:** `STUDY_ONLY`; no wholesale vendoring or recovered-source import.

### Findings

SPEED RE describes itself as an unofficial reconstruction of EA Black Box's SPEED engine with NFS Underground 2 PC v1.2 as its initial reference. The Linux demo is explicitly an intermediate milestone and the decompilation is incomplete. The user must supply a legally obtained PC v1.2 install, including the supported `speed2.exe`; the project says it does not supply the original executable or game assets.

Its stated analysis approach distinguishes:
- functions that byte-match the target;
- bounded original/rebuilt execution comparisons;
- routines that remain unmatched or unverified.

This explicit split between code presence, byte matching and behavioural comparison is valuable. It prevents a working demo from being misrepresented as a complete reconstruction.

### Restrictions

The README and NOTICE prohibit committing retail assets, executables, compiler binaries and generated disassembly. The MIT grant covers only original scaffolding/tools/docs and excludes recovered NFSU2 code/data. The code tree is mixed-scope; every file would need provenance and licence review before reuse.

## 4. Other NFS research leads

- `yugecin/nfsu2-re`: older hobby reverse-engineering project; no licence grant was established in the metadata inspected. Study-only.
- `s-b-repo/nfsmw-2005-re`: describes a Most Wanted 2005 reverse-engineering effort, but GitHub reports `NOASSERTION`; no code reuse.
- No official complete Activision or EA game-source repository suitable for reuse was established. Independent reconstructions are listed above, but their licensing and compatibility restrictions make them research references, not Atomic-Z dependencies.

## Atomic-Z decision

Use OpenNFS to study data-driven vehicle parameters, raycast contact/suspension architecture, wheel slip and race/camera separation. Use OpenUG2 and SPEED RE to study provenance, behavioural specifications, evidence confidence and independent verification. Do not transplant EA assets, game code or recovered tables. Any future motorcycle solver must be newly specified for two-wheel dynamics and validated independently.


## 5. SPEED RE — deeper vehicle-physics and reconstruction audit

**Canonical repository:** https://github.com/troikoss/speed-re  
**Reviewed revision:** `892e5c31d77c751acd123330eda15c157c4f1b1f` (2026-10-29)  
**Tree:** approximately 1,003 tracked paths.  
**Licence:** limited MIT grant for original project contributions only. The `LICENSE` expressly excludes recovered/reconstructed NFSU2 program code under `src/Speed/Indep/`, recovered game data, embedded protected material, retail executable/assets and third-party imports. `NOTICE` reiterates those exclusions.  
**Disposition:** `STUDY_ONLY`; do not vendor wholesale or copy recovered source.

This is the most technically detailed NFS reference reviewed. It is an active, incomplete source-reconstruction of EA Black Box's SPEED engine, using Need for Speed Underground 2 PC v1.2 as its first target. It is **not** an official EA release and not a complete finished game. The author explicitly says the basic driving demo is an intermediate milestone, not complete recovery.

### Repository architecture

The tree separates:
- `src/Speed/Indep/`: recovered/reconstructed engine/game implementation; this is expressly outside the MIT grant.
- `src/Platform/`: native platform replacement/scaffolding and integration boundaries; individual file rights still require review.
- `docs/`: per-subsystem recovery, provenance, verification and coverage notes.
- `tools/`: many isolated verification scripts and probes.
- `modding/`: optional native plugin SDK/loader, separate from recovered game source.
- `config/SPEED2_EXE_1_2/`: configuration/evidence metadata for the selected target.

The public tree includes separate write-ups for vehicle physics, wheel physics, physics parameters, drivetrain, controls, camera, collisions, racing, effects, HUD and native demo replacement. Its tooling includes many `verify_pc_*` scripts; these are subsystem-specific tests, not a single proof of complete game fidelity.

### Vehicle update and integration

The vehicle-physics dossier records an observed substep partition from the original executable. For finite nonnegative input durations, the recovered routine divides by approximately 0.0044, truncates the quotient and adds one; it is not simply a conventional `ceil` rule. Example values supplied to the isolated routine produce four substeps for 1/60 s, two for 1/144 s and one for 1/240 s.

**Important limitation:** the caller's clock source and units are not fully established, and this fragment does not prove the entire game runs at a fixed 240 Hz or is fully frame-rate independent. The original fragment and conversion helper were tested across 216 finite input cases and two x87 precision control words, but the whole vehicle update was not thereby executed.

The derivative collector gathers all registered block derivatives before integration; the integration routine updates scalar states in list order and invokes callbacks. The collector source is reported as byte-matching, while the integration candidate is explicitly reported as one byte short and **nonmatching**. The author does not fake a match with inline assembly or forced registers. This is an excellent example of keeping exact, nonmatching and unknown status separate.

### Engine/drivetrain/upgrade data

The physics parameter documentation describes:
- per-vehicle physics records and a data-driven tuning layout;
- a 64-sample drive curve;
- a selected drivetrain and wheel-radius/coefficient inputs;
- engine force sampled against speed and resampled into the destination curve;
- gear transition/shift-point logic;
- aerodynamic drag divided by mass in the speed helper;
- selected upgrade groups and per-upgrade modifiers affecting engine curves, drivetrain ratios, suspension/axle/wheel height, brake bias, engine range, limits and drag.

The source docs explicitly retain unresolved offsets, fields and composition steps. Units and meaning for every recovered field must not be assumed from its name alone.

### Wheel force, contact and collision findings

The wheel-physics dossier describes a staged chain:
1. Prepare wheel force state, transform motion to local coordinates, derive the quantized angle and slip variables, evaluate lateral force, apply lock-state logic and low-speed adjustments.
2. Correct force bases and coefficients, apply conditional drive-force scaling/undo paths, saturation/limiting, contact/flag overrides and motion-angle correction.
3. The original uses a quantized angle lookup path and explicit binary32 stores/reloads at precision-sensitive boundaries; a generic `atan2` or unbounded floating-point simplification is not equivalent.

The documentation reports thousands of bounded original/rebuilt state comparisons for isolated functions. Some bodies byte-match; many reconstructed bodies do not. These are isolated emulator/probe comparisons with mapped target data, not a proof that the whole game behaves identically on hardware.

Collision research uses world collision bodies, convex support mappings, GJK pair distance/overlap, impulse response and cached track polygons. This is technically interesting as a modern reverse-engineering case study, but it is four-wheel car collision logic and cannot be transplanted as a two-wheel motorcycle stability or tyre-contact model.

### Controls, camera and native plugin SDK

- The PC controls documentation recovers keyboard binding UI and device-input interfaces. It is useful for action mapping and UI state ownership, not an Android touch implementation.
- Camera documentation covers chase/cockpit framing, collision push and shake behavior. Concepts such as stable camera targets and separate shake state can inform a new Godot camera, but the original code cannot be copied from excluded recovered paths.
- The modding SDK documents a native 32-bit Linux plugin interface with lifecycle, HUD and physics-provider callbacks. It is optional scaffolding, disabled by default. It does not provide a second solver or guarantee that the game is fully recovered. Native plugins execute in-process and are explicitly not sandboxed; this system is not appropriate to import into an Android Godot app.

### What remains incomplete

The project scope document explicitly requires executable-wide accounted-for code/data, reproducible source builds, correct original asset loading, verified caller composition/state transitions and end-to-end playable system coverage. It distinguishes byte matching from bounded behavioral evidence and says neither isolated emulation tests nor a playable driving demo establishes full completion.

Therefore, the repo's existence, large verifier count and native driving demo should not be read as “Need for Speed source is finished”. It is a detailed, ongoing reconstruction with substantial unresolved subsystems.

### Atomic-Z transfer decision

**High-value lessons to translate into an independent Godot design:**
- separate per-bike parameter data from runtime state and visual skin;
- use fixed-step/substep simulation only after the timestep contract is measured;
- preserve units, coordinate frames, binary32/precision boundaries and explicit data validation;
- separate engine torque curves, gear ratios, suspension tuning, wheel contact and body collision;
- model each verifier against a defined subsystem contract and preserve failing/nonmatching cases;
- use an explicit coverage inventory and mark every unknown instead of inventing plausible values.

**Do not transfer:**
- recovered NFSU2 routines or layouts from `src/Speed/Indep/`;
- retail executable bytes, mapped game files, track/car geometry, textures, audio or tuning tables;
- the native Linux 32-bit host/plugin loader into Godot/Android;
- any NFS car parameters as motorcycle parameters.

Pinned documents:
- [Vehicle physics](https://github.com/troikoss/speed-re/blob/892e5c31d77c751acd123330eda15c157c4f1b1f/docs/pc-vehicle-physics.md)
- [Wheel physics](https://github.com/troikoss/speed-re/blob/892e5c31d77c751acd123330eda15c157c4f1b1f/docs/pc-wheel-physics.md)
- [Physics parameters](https://github.com/troikoss/speed-re/blob/892e5c31d77c751acd123330eda15c157c4f1b1f/docs/pc-physics-parameters.md)
- [Controls](https://github.com/troikoss/speed-re/blob/892e5c31d77c751acd123330eda15c157c4f1b1f/docs/pc-controls.md)
- [Camera](https://github.com/troikoss/speed-re/blob/892e5c31d77c751acd123330eda15c157c4f1b1f/docs/pc-camera.md)
- [Collision](https://github.com/troikoss/speed-re/blob/892e5c31d77c751acd123330eda15c157c4f1b1f/docs/pc-collision-notifications.md)
- [Native demo](https://github.com/troikoss/speed-re/blob/892e5c31d77c751acd123330eda15c157c4f1b1f/docs/NATIVE_DEMO.md)
- [Decompilation scope](https://github.com/troikoss/speed-re/blob/892e5c31d77c751acd123330eda15c157c4f1b1f/docs/DECOMPILATION_SCOPE.md)
