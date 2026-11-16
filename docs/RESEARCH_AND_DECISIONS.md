# Research Register and Architecture Decisions

Date: 2026-11-16. Research informs architecture; it does not prove the project's code or fitment.

## Repository baseline observed
Repository: https://github.com/metsam-mastem/Atomic-Z-Customi-Z
Observed: Godot 4 Compatibility project, Android arm64 export preset, main scene, bike assembly script, neon skin runtime, legacy JSON, Tkinter preview, Godot/Python tests, architecture/acceptance/research docs. Recent commits include neon runtime, garage controls, validation, save/reload and Android export changes. Branch search showed main only; PR search returned none; open issue search returned none. Commit responses did not identify every agent reliably. README still calls Tkinter a separate preview tool and ModernGL an isolated experiment; unified-system spec supersedes this framing.

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
| ADR-009 | BuildDocument-only neon persistence; preserve legacy shader parameters as an unmapped extension | Prevent competing writers and avoid guessing a 0..10 to 0..1 conversion |

## External adoption checklist
Verify license and commercial rights, maintenance/release, Godot/API compatibility, copied code versus inspiration, exact upstream commit, dependencies/security, attribution, integration tests and reason native Godot features are insufficient. No external code or asset is automatically approved by being listed here.

## Legacy neon persistence reconciliation — 2026-11-16

The orphaned `scripts/skin_profile_store.gd` writer is removed. It was not registered as an Autoload and had no product-code callers. The `NeonSkin.save_skin()` writer is also removed. `neon_skin_config.json` remains a read-only migration input. When no valid `user://atomic_z_build.json` exists, the application imports `user://skin_profile.json`: its color becomes the primary BuildDocument palette, while its original 0..10 glow/pulse values are stored unchanged in a versioned `extensions` record with status `preserved_unmapped`. The source file remains untouched. A valid canonical BuildDocument always takes precedence. Hardware export and the experimental `neon_glow.gdshader` are not enabled by this migration.
