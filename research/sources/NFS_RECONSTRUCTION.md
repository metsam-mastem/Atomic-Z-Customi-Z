# Source Dossier: Need for Speed reconstruction projects

This dossier separates three very different kinds of NFS reference: an MIT-licensed scratch-built car engine, a clean-room reconstruction with unclear project-wide rights, and a newer incomplete source-reconstruction effort whose MIT notice expressly excludes recovered game content.

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
**Current branch observed:** `main`; exact commit could not be pinned through the active repository connector during this audit.  
**Licence statement:** README says original project contributions are MIT, but explicitly excludes recovered Underground 2 code, reconstructed game data, retail assets and third-party material. It says the repository is not licensed as a whole under MIT.  
**Disposition:** `STUDY_ONLY`, `NEEDS_PIN`; manual link only, no automatic fetch or source import.

### Findings

SPEED RE describes itself as an unofficial reconstruction of EA Black Box's SPEED engine with NFS Underground 2 PC v1.2 as its initial reference. The Linux demo is explicitly an intermediate milestone and the decompilation is incomplete. The user must supply a legally obtained PC v1.2 install, including the supported `speed2.exe`; the project says it does not supply the original executable or game assets.

Its stated analysis approach distinguishes:
- functions that byte-match the target;
- bounded original/rebuilt execution comparisons;
- routines that remain unmatched or unverified.

This explicit split between code presence, byte matching and behavioural comparison is valuable. It prevents a working demo from being misrepresented as a complete reconstruction.

### Restrictions

The README warns not to commit retail assets, executables, compiler binaries or generated disassembly. It says the MIT grant does not cover recovered UG2 code or game data and does not represent permission from the rights holder. Consequently, the source is not safe to vendor as a whole even though an MIT licence file exists.

## 4. Other NFS research leads

- `yugecin/nfsu2-re`: older hobby reverse-engineering project; no licence grant was established in the metadata inspected. Study-only.
- `s-b-repo/nfsmw-2005-re`: describes a Most Wanted 2005 reverse-engineering effort, but GitHub reports `NOASSERTION`; no code reuse.
- No official complete Call of Duty or Need for Speed game source was found that can be adopted as a licensed game engine for Atomic-Z.

## Atomic-Z decision

Use OpenNFS to study data-driven vehicle parameters, raycast contact/suspension architecture, wheel slip and race/camera separation. Use OpenUG2 and SPEED RE to study provenance, behavioural specifications, evidence confidence and independent verification. Do not transplant EA assets, game code or recovered tables. Any future motorcycle solver must be newly specified for two-wheel dynamics and validated independently.
