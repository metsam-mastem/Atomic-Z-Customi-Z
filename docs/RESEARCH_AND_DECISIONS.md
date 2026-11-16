# Research Register and Architecture Decisions

Date: 2026-11-16. Research informs architecture; it does not prove the project's code or fitment.

## Repository baseline observed
Repository: https://github.com/metsam-mastem/Atomic-Z-Customi-Z
Observed on 2026-11-16 05:37 UTC: `main` remains `4d2cf3b82bd78437541b49da46f522c06d2652b5`; no implementation writes were made to main. Active dependency chain: PR #28 → PR #29 → PR #30. PR #28 head `4bf83ef75d196b8a1259179b034632ebca2ca6bf` passed exact-head Godot/Python/Android Debug and ephemeral-key Android Release CI in run [#43810187315](https://github.com/metsam-mastem/Atomic-Z-Customi-Z/actions/runs/43810187315). PR #29 head `2325738c652733723412e2e1f7b91fd45e20d961` passed exact-head Godot/Python/Android Debug CI in run [#43807893732](https://github.com/metsam-mastem/Atomic-Z-Customi-Z/actions/runs/43807893732). PR #30 head `7571d24f5bca2d6d8806c0a9ee0e7ba1c65a463d` passed exact-head Godot/Python/Android Debug CI in run [#43811283663](https://github.com/metsam-mastem/Atomic-Z-Customi-Z/actions/runs/43811283663), including the imported two-surface glTF fixture, BuildDocument reference identity/migration tests, and first-launch runtime hydration assertions. PR #30 records the owner-selected 2026 ZX-25RR reference identity; market remains unset and geometry is unverified. PR #31 `d8a26a4a481d454d8a8c2c6e9503426ab5edff5f` is a separate Draft AI adapter proposal with generic CI green but no dedicated provider tests; integration review flags missing owner scope approval and credential/transport protections. No PR has been merged; branch protection remains UNVERIFIED. Physical Redmi QA and production ZX-25RR asset validation remain NOT RUN.

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
| ADR-010 | Set the product reference identity to Kawasaki Ninja ZX-25RR model year 2026; keep market unset until explicitly selected; legacy ZX-25R neon settings may migrate as customization data only, with their source identity retained and no geometry/fitment inference | Reflect the owner-selected model year/variant without misrepresenting regional specification or legacy geometry | Accepted by product owner; implemented in PR #30 |

## External adoption checklist
Verify license and commercial rights, maintenance/release, Godot/API compatibility, copied code versus inspiration, exact upstream commit, dependencies/security, attribution, integration tests and reason native Godot features are insufficient. No external code or asset is automatically approved by being listed here.