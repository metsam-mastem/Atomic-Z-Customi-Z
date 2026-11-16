# Research Register and Architecture Decisions

Date: 2026-11-16. Research informs architecture; it does not prove the project's code or fitment.

## Repository baseline observed
Repository: https://github.com/metsam-mastem/Atomic-Z-Customi-Z
Observed: Godot 4 Compatibility project, Android arm64 export preset, main scene, bike assembly script, neon skin runtime, legacy JSON, Tkinter preview, Godot/Python tests, architecture/acceptance/research docs. Recent commits include neon runtime, garage controls, validation, save/reload and Android export changes. That initial branch/PR snapshot is historical and no longer current; use the live GitHub snapshot in [PROJECT_STATUS.md](PROJECT_STATUS.md) and the mandatory preflight in AGENTS.md before acting. README still calls Tkinter a separate preview tool and ModernGL an isolated experiment; unified-system spec supersedes this framing.

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

## External adoption checklist
Verify license and commercial rights, maintenance/release, Godot/API compatibility, copied code versus inspiration, exact upstream commit, dependencies/security, attribution, integration tests and reason native Godot features are insufficient. No external code or asset is automatically approved by being listed here.

## Motorcycle-game and reverse-engineering source decision — 2026-11-16

A dedicated [Research Vault](../research/README.md) now contains the source registry, pinned commit references, per-project architecture dossiers, legal/provenance boundaries and a sparse local source-retrieval helper.

This audit establishes a **research-only** source baseline. It does not approve adding a riding simulator, importing another game's source, or changing the Godot renderer. In particular:
- DankNooner and its standalone predecessor are AGPL-3.0 and target newer Godot/renderer configurations; study their controller boundaries, not their code or assets.
- OpenNFS's original code is MIT, but the project is a desktop C++/Bullet car engine and EA assets/data are not covered by its code licence.
- OpenUG2 and Roadkill do not have a repository-level licence grant established for the full content; keep them study-only.
- SPEED RE's MIT statement is explicitly limited to original contributions and excludes recovered game content.
- REA's canonical upstream is [morluto/rea](https://github.com/morluto/rea), MIT; it remains an optional separate analysis tool.
- CC0 Innerscene models are possible placeholder meshes only, not OEM CAD or fitment evidence.

No external code or asset was imported into the Godot runtime in this task. Any future code adoption requires a separate licence review, architecture decision, isolated implementation PR and verification against Atomic-Z's BuildDocument and Android constraints.


### Call of Duty source/reconstruction classification — 2026-11-16

The dedicated [COD reconstruction dossier](../research/sources/COD_RECONSTRUCTION.md) resolves the earlier broad source question:
- Activision's official open-source release is selected Telescope Webkit middleware source with per-version licence archives, not complete Call of Duty game source.
- OpenCOD1 and OpenCOD2 are independent, unfinished engine reconstructions; inspected repositories have no detected licence grant and depend on separately supplied lawful game data.
- CoDWaW's MIT-licensed public repository is reverse-engineering notes and evidence tables, not proprietary game code or redistributable game content.
- CoD-Research is GPL-3.0 community documentation.
- The MW2 2009 dashboard refers to a private reconstruction; no public source repository or licence was established.

No COD source, binaries, game assets or recovered data are added to Atomic-Z. This classification is now machine-readable in the Research Vault source registry. It does not expand the product scope beyond the existing motorcycle customization workbench.


## Godot vehicle systems and configurator review — 2026-11-16

The research vault now includes [three additional Godot vehicle references](../research/sources/GODOT_VEHICLE_SYSTEMS.md) and [two configurator/showroom references](../research/sources/MOTORCYCLE_CONFIGURATORS.md).

Decision:
- Seerban's MIT Godot Vehicle is a Godot 4.6 Forward Plus four-wheel car system. It is a useful RigidBody/raycast wheel and ghost-race reference, not a motorcycle solver.
- KV Vehicle has no root licence established and documents concrete shapecast/suspension/feedback limitations. No code reuse.
- ModuVehicle's original code carries CC0 but is a WIP C++ GDExtension targeting Godot 4.5+. Its combined tyre-force, slip, traction-control and suspension math are research references only; adding C++ would expand Atomic-Z's build matrix without demonstrated need.
- MotoForge and VOLT R1 Showroom have no root repository licence established. Their compatibility checks, shareable configuration, GLB contracts, mobile lazy-loading, camera choreography and GPU telemetry can inform independent implementation, but their web runtimes, source code and fictional data are not copied.

No external runtime, database, editor or physics engine is added. Godot 4 / GDScript, Android-first delivery and the existing BuildDocument remain the single product architecture. Any rideable simulation is still a separate product-scope decision and must be specified and accepted before implementation.
