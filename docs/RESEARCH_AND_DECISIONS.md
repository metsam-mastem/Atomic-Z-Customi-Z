# Research Register and Architecture Decisions

Date: 2026-11-16. Research informs architecture; it does not prove the project's code or fitment.

## Repository baseline observed
Repository: https://github.com/metsam-mastem/Atomic-Z-Customi-Z
Observed on 2026-11-16 05:16 UTC: `main` is `4d2cf3b82bd78437541b49da46f522c06d2652b5`. Active dependency chain is PR #28 (Android artifact hardening) → PR #29 (GLB surface catalog / BuildDocument integration) → PR #30 (legacy neon profile migration). PR #28's Android Debug export passed; its BuildDocument smoke subtest exposed a false-green assertion helper. PR #29 corrected that helper and its exact-head Godot/Python/Android CI passed in run #43807888243. PR #30 exact head `cc72cafd645d5b3c7b3551eb24a63312fd059b4d` passed Godot, Python and Android Debug export in run #43808940023. PR #30 remains a draft stacked on PR #29; no changes have been merged to `main`. The current `main` still contains the legacy profile writer and old BuildDocument test helper; their retirement/correction exists only in PR branches. The architecture/1, architecture/2 and architecture/3 branches are divergent, unmerged historical work; PR #30 is the reviewed current migration path. Open-issue search returned none.

## Open-source references
- Godot: https://github.com/godotengine/godot — use native scene, resource, renderer, UI, input, persistence and Android export.
- Blender: https://github.com/blender/blender — author/repair geometry, UVs, pivots, material slots and GLB.
- Khronos glTF: https://github.com/KhronosGroup/glTF
- glTF samples: https://github.com/KhronosGroup/glTF-Sample-Models
- glTF Validator: https://github.khronos.org/glTF-Validator/
- ModuVehicle: https://github.com/AurickMikleton/ModuVehicle — WIP Godot modular powertrain resources; pattern reference, not drop-in dependency.
- kv-vehicle: https://github.com/Kurtzmusch/kv-vehicle — modular Godot vehicle/physics patterns; do not adopt physics without a defined need.
- ModernGL: https://github.com/moderngl/moderngl and https://github.com/moderngl/moderngl-window — OpenGL 3.3+ desktop/headless research; not Android product runtime.
- Build Your Own X: https://github.com/codecrafters-io/build-your-own-x
- Tiny Renderer: https://github.com/ssloy/tinyrenderer/wiki
- Scratchapixel: https://www.scratchapixel.com/
- Physically Based Rendering: https://www.pbr-book.org/
- Broad-phase collision detection: https://buildnewgames.com/broad-phase-collision-detection/
- Motorcycle/product pattern leads: https://github.com/Whauv/MotoForge and https://github.com/rohithyv/3D-Motorcycle-Showroom. Verify license, maintenance and provenance before copying.
- https://github.com/Seerban/godot-vehicle — MIT-licensed Godot vehicle project. Its `Scripts/vehicle/MeshColorable.gd` is a useful reference for duplicating a material before changing its color. The project targets Godot 4.6 and includes driving/racing systems; use the material-isolation idea only, not as a drop-in dependency for this Godot 4.4.1 garage.
- https://github.com/Maxim-Lanskoy/KenneyNL-RacingKit — MIT-licensed Godot 4.6 kit with a modular vehicle rig, swappable motorcycle model adapter and `VehicleConfig` resource. Useful architecture reference for future asset adapters, but its racing physics are outside the current garage scope and its engine version is newer than the pinned project runtime.
- Android export diagnosis: Godot issue https://github.com/godotengine/godot/issues/123504 documents the blank headless Android preset error when ETC2/ASTC texture import is disabled. The project lacked `rendering/textures/vram_compression/import_etc2_astc=true`; enabling it restored a successful Godot 4.4.1 Android Debug export in CI run #43788240486.
- https://github.com/hughdtt/motorbike-configurator — small React Three Fiber/glTF color-picker demonstration. No repository license file was found during inspection; inspect only, do not copy source code or assets.
- https://github.com/Whauv/MotoForge — full-stack configurator architecture reference. No repository license file was found during inspection; inspect only, do not copy source code or assets.

## Nature and peer-reviewed research
- Nature Index, Product Configuration Systems and Mass Customization: https://www.nature.com/nature-index/topics/l4/product-configuration-systems-and-mass-customization-strategies. Translate into rule-based configuration and compatibility constraints.
- Nature Index, Product Family Design and Platform Optimization: https://www.nature.com/nature-index/topics/l4/product-family-design-and-platform-optimization. Balance shared platform/common parts with controlled variant-specific features.
- Nature Index, Modular Design Methods for Complex Systems: https://www.nature.com/nature-index/topics/l4/modular-design-methods-for-complex-systems. Use Design Structure Matrix (DSM) to map dependencies and set internal module boundaries while keeping one integrated product.
- Tao, Zhang & Zhang, “Advancements and challenges of digital twins in industry”, Nature Computational Science 4, 169–177 (2024): https://www.nature.com/articles/s43588-024-00603-w. Lifecycle data and explicit maturity/limitations matter; do not label placeholder geometry a digital twin.
- Ferrari & Willcox, “Digital twins in mechanical and aerospace engineering”, Nature Computational Science 4, 178–183 (2024): https://www.nature.com/articles/s43588-024-00613-8. Fitness-for-purpose is more important than photorealism; engineering fidelity requires appropriate evidence.
- “Digital twin-driven variant design of a 3C electronic product assembly line”, Scientific Reports (2022): https://www.nature.com/articles/s41598-022-07894-x. Variant design links configuration, planning, control, development and optimization in a closed loop.
Nature Index topic pages are synthesized summaries, not direct validation. Consult cited research before engineering claims.

## Decisions
| ID | Decision | Reason |
|---|---|---|
| ADR-001 | One Godot runtime, one user workflow | Avoid duplicate apps/state |
| ADR-002 | Internal modules with stable contracts | Parallel development without product fragmentation |
| ADR-003 | One versioned BuildDocument | Prevent schema divergence |
| ADR-004 | GLB/glTF 2.0 preferred | Preserve scene/mesh/material hierarchy |
| ADR-005 | Godot native glow before custom bloom | Lower mobile integration/performance risk |
| ADR-006 | Hardware mapping requires calibration | No invented LED indices or wiring |
| ADR-007 | Visual and engineering evidence separated | Prevent false safety/fitment claims |
| ADR-008 | Branch/PR-only collaboration | Prevent direct-main races |
| ADR-009 | Retire the unused SkinProfileStore and NeonSkin.save_skin writers; treat legacy `user://skin_profile.json` as a read-only, one-time migration input into BuildDocument; preserve unmapped 0..10 glow/pulse values in a versioned extension and retain the original file | Enforce one canonical writable state without losing legacy user data | Accepted by product owner; implementation proposed in PR #30 |

## External adoption checklist
Verify license and commercial rights, maintenance/release, Godot/API compatibility, copied code versus inspiration, exact upstream commit, dependencies/security, attribution, integration tests and reason native Godot features are insufficient. No external code or asset is automatically approved by being listed here.