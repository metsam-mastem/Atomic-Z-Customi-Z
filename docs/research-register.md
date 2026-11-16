# Research Register

These are implementation leads. Recheck each repository's license, maintenance, API compatibility and asset provenance before adoption.

## Core runtime and interchange
- Godot Engine: https://github.com/godotengine/godot — MIT-licensed cross-platform 2D/3D engine with Android export.
- Blender: https://github.com/blender/blender — authoring, mesh cleanup, UVs, materials and GLB export.
- Khronos glTF: https://github.com/KhronosGroup/glTF — royalty-free 3D transmission format designed for efficient loading and interoperability.
- glTF sample models: https://github.com/KhronosGroup/glTF-Sample-Models — importer and rendering test assets.
- glTF Validator: https://github.khronos.org/glTF-Validator/ — validate GLB/glTF structure before import.

## Product-pattern references
- MotoForge: https://github.com/Whauv/MotoForge — motorcycle parts catalog, compatibility filtering, 3D preview, build summary and quotation flow. Pattern reference only; inspect its license before code reuse.
- 3D Motorcycle Showroom: https://github.com/rohithyv/3D-Motorcycle-Showroom — cinematic product presentation, named model parts, exploded views, configurator and mobile-performance patterns. Inspect license and source before reuse.
- Build Your Own X: https://github.com/codecrafters-io/build-your-own-x — tutorial index. Relevant tracks: 3D renderer, physics engine, game engine, voxel engine and computer graphics. Use selectively to understand components; do not rewrite a renderer or physics engine when Godot already supplies them.

## Nature / bioinspired engineering
- Nature Reviews Bioengineering, “Bioinspired engineering” (2025): https://www.nature.com/articles/s44222-025-00379-2
  - Translate biological strategies into adaptive, efficient and sustainable engineering; prioritize function, not surface imitation.
- Nature Reviews Materials, “Quantitative biomimetics of high-performance materials” (2025): https://www.nature.com/articles/s41578-024-00753-3
  - Relevant concepts: hierarchical multiscale architectures, interfaces, graph descriptions, theory/simulation/ML integration and quantitative property trade-offs.
- Nature Communications, “An all-natural bioinspired structural material for plastic replacement” (2020): https://doi.org/10.1038/s41467-020-19174-1
- Nature, “Toughening mechanisms of the elytra of the diabolical ironclad beetle” (2020): https://doi.org/10.1038/s41586-020-2813-8

## Design translations to prototype
| Biological strategy | Engineering exploration | Candidate motorcycle application |
|---|---|---|
| Nacre / layered composites | Crack deflection and layered reinforcement concepts | Non-structural fairing skins and impact visualization |
| Bone / trabecular architecture | Density-graded lattice and topology exploration | Lightweight brackets and internal ribs; solver validation required |
| Beetle elytra | Multi-scale damage-tolerant structure | Protective covers and sacrificial panels |
| Shark skin / riblets | Surface texture and flow hypotheses | Visual texture presets first; aerodynamic claims require CFD |
| Pinecone / hygromorphic motion | Passive geometry response | Vent/duct concepts; material response must be measured |

## Adoption rules
1. Prefer source repositories and official documentation over aggregator summaries.
2. Record repository license and commit/release before copying or vendoring.
3. Never treat a biological inspiration as proof of performance.
4. Record each experiment as hypothesis → geometry/material → simulation or test → measured result.

## Additional model leads and Build-Your-Own-X tracks

### Licensed motorcycle geometry leads
- Innerscene sport motorcycle (listed as CC0, GLB, 7.2 MB): https://www.innerscene.com/tools/library/3d-parts/sport-motorcycle-e21e8303
- Innerscene race-replica superbike (listed as CC0, GLB, 20.1 MB): https://www.innerscene.com/tools/library/3d-parts/race-replica-superbike-fully-faired-badbd83b
- Innerscene naked sport motorcycle (listed as CC0, GLB, 19.1 MB): https://www.innerscene.com/tools/library/3d-parts/sport-motorcycle-naked-sport-bike-fc4c9758
- Innerscene road motorcycle (listed as CC0, GLB, 627 KB): https://www.innerscene.com/tools/library/3d-parts/road-motorcycle-f2519759

These are generic, unbranded assets, not Kawasaki ZX-25RR geometry. They are suitable for testing import, material assignment and assembly workflows only. Check the current license statement and download availability at acquisition time.

### Build Your Own X — selected learning paths
- Tiny Renderer (software rasterization): https://github.com/ssloy/tinyrenderer/wiki
- Scratchapixel (ray tracing, rasterization and graphics foundations): https://www.scratchapixel.com/
- Physically Based Rendering book: https://www.pbr-book.org/
- Video game physics and rigid-body foundations: https://www.toptal.com/game/video-game-physics-part-i-an-introduction-to-rigid-body-dynamics
- Broad-phase collision detection / spatial partitioning: https://buildnewgames.com/broad-phase-collision-detection/
- A 3D modeller architecture walkthrough: http://aosabook.org/en/500L/a-3d-modeller.html

Implementation decision: study algorithms selectively, but use Godot's renderer and physics engine for the mobile product. Custom rendering/physics is a research branch only if a measured product requirement cannot be met by the engine.

### ZX-25R / ZX-25RR asset caution
- A publicly listed ZX-25R miniature STL exists, but it is described as a miniature and is not evidence of full-scale factory CAD: https://cults3d.com/en/3d-model/game/kawasaki-ninja-zx25r-ninja-250
- Paid ZX-25R model listings exist, but their geometry, node separation, license scope and engineering accuracy require direct inspection before purchase or use.
- Kawasaki Japan's 2026 ZX-25RR FAQ is a primary source for the model-year-specific specification sheet: https://faq.kawasaki-motors.com/faq/show/4668?category_id=2&site_domain=default

No generic asset, miniature STL or render mesh should be relabeled as a factory-accurate ZX-25RR CAD assembly.

---

## Verified source audit — 2026-11-16

This section records a repository-level verification pass. It corrects unverified leads from informal research and does not authorize automatic dependency adoption.

### Godot editor tools and vehicle references

| Resource | Verified facts | Compatibility / license finding | Decision |
|---|---|---|---|
| GoBuild — https://github.com/marcel-b-roodt/GoBuild | Godot EditorPlugin for in-editor vertex/edge/face mesh editing; README says active development and UV tools are in progress | README states Godot 4.4+ and GPL-3 | Study workflow only. Do not vendor or bundle in a commercial distribution without a specific GPL compatibility review. Not a runtime dependency. |
| HammerForge — https://github.com/saworbit/hammerforge | Brush-based level/CSG environment editor, not a motorcycle CAD or assembly tool | README requires Godot 4.7+ and labels project early alpha; MIT | Reject for current Godot 4.4.1 baseline. Revisit only after an intentional engine upgrade and a concrete garage-environment need. |
| ModuVehicle — https://github.com/AurickMikleton/ModuVehicle | Modular vehicle system for Godot | Repository metadata reports CC0-1.0; description targets Godot 4.5+ | Study resource/assembly patterns only. Do not add as a dependency to the current 4.4.1 project. |
| kv-vehicle — https://github.com/Kurtzmusch/kv-vehicle | Godot vehicle-system reference | Repository metadata did not provide a declared SPDX license | Study algorithms only; no code copying or vendoring until license is verified. |
| MotoForge — https://github.com/Whauv/MotoForge | Small motorcycle parts/catalog concept reference | License and maintenance suitability were not established in this audit | Product-flow inspiration only; no source reuse. |
| 3D Motorcycle Showroom — https://github.com/rohithyv/3D-Motorcycle-Showroom | Cinematic electric-motorcycle presentation using Next.js, React Three Fiber and GSAP | Different runtime from the Godot product; license not established here | Study presentation and configurator patterns only. Do not port its framework or introduce a second runtime. |

### Corrected / unverified leads

- https://github.com/rishabhsinghio/Godot-Simple-Motorcycle-Physics returned HTTP 404 during this audit. It is not a verified source and must not be used as an implementation reference.
- https://github.com/studioheadpats/poibuilder returned HTTP 404 during this audit. It is not a verified source and must not be used as an implementation reference.
- Do not infer that a repository exists from a search snippet, package name or prior assistant response. Verify the canonical repository URL before listing it as a usable source.

### Asset and authoring pipeline

- Preserve the existing decision: Blender is the authoring environment; GLB/glTF 2.0 is the interchange format; Khronos glTF Validator is the pre-import validation gate; Godot owns runtime loading, rendering and Android export.
- Poly Haven: https://polyhaven.com/ — candidate source for HDRIs, textures and 3D assets. Check each asset's current license and metadata at acquisition time; do not assume all third-party content has identical rights.
- ambientCG: https://ambientcg.com/ — candidate PBR material and HDRI source. Verify the current asset license and record source URL, asset identifier and hash in the project asset manifest.
- FreeCAD: https://www.freecad.org/ — optional engineering authoring/reference tool for dimensioned parts. It does not replace Blender's approved GLB delivery path.
- Generic motorcycle assets may be used for import/assembly pipeline tests only. They are not ZX-25RR factory geometry and cannot support fitment or engineering claims.

### Architecture translations worth implementing later

1. Asset provenance manifest: every imported asset records stable asset ID, source URI, SHA-256, license identifier/text, author, acquisition date, target vehicle variant/year/market, units, coordinate frame and validation status.
2. Assembly metadata: stable part IDs, parent IDs, mount-point IDs, home transforms and deterministic exploded transforms. Display names and array indices are not identifiers.
3. Material presets: store PBR parameters and texture references inside the canonical BuildDocument's customization/material domain. Do not introduce a separate preset database or profile JSON as a second source of truth.
4. Surface-bound graphics: attach decals/neon through verified UVs, decal meshes or registered surface curves. Keep legacy 2D points labelled unverified until a measured reference and surface mapping exist.
5. Performance evidence: measure frame time, memory and thermal behavior on the exact target device before changing the Compatibility renderer baseline or selecting costly effects.
6. Engineering evidence ledger: separate visual preview, geometric validation, mass properties, solver output, fitment and physical hardware evidence. Every result records inputs, units, assumptions, tool/version and PASS/FAIL/NOT RUN/BLOCKED status.
7. Extension packages: future extensions must declare ID, version, API range, capabilities, dependencies, asset list, license, hashes, permissions and network needs. They execute within the same Godot application and BuildDocument; they do not create independent apps or stores.

### Current PR and CI integration findings

- PR #3 (BuildDocument contract) contains the correct architectural direction: migrate legacy neon data into one canonical versioned document and bind assembly, paint, neon and persistence to the same state. Its Godot smoke/contract tests passed in the inspected run; Android export failed.
- PR #4 (neon shader/profile proposal) contains a potentially reusable shader concept, but `scripts/skin_profile_store.gd` creates `user://skin_profile.json`, a second authoritative store. Its glow range is 0..10 while the canonical BuildDocument render intensity is 0..1. Do not merge the profile store in this form. Evaluate the shader only after it is adapted to the canonical range and integrated into the existing NeonSkin/BuildDocument path.
- Both PR #3 and PR #4 Android export jobs reported: `Cannot export project with preset "Android Debug" due to configuration errors`. The available job logs did not expose the specific failed preset setting. Diagnose the exact export configuration before changing presets or claiming an APK build.
- PR #2 is a separate documentation PR. Reconcile it through review; do not overwrite its branch or duplicate its charter/workflow files.

### Non-negotiable adoption gate

No external source or asset is adopted merely because it is open-source or visually useful. Before adoption: verify exact upstream commit/release, license and commercial rights, maintenance, Godot/API compatibility, dependency/security posture, provenance, attribution, code actually reused versus concepts studied, target-device impact and tests. Prefer native Godot functionality unless a measured gap justifies an external dependency.


### Kawasaki primary-source identity and specification references — 2026-11-16

- Official Kawasaki Japan 2026 ZX-25RR page: https://www.kawasaki-motors.com/ja-jp/motorcycle/ninja/supersport/ninja-zx-25r/2026-ninja-zx-25rr
- Official Kawasaki Japan 2026 FAQ / specification attachment: https://faq.kawasaki-motors.com/faq/show/4668?category_id=2&site_domain=default
- Official Kawasaki Japan 2027 FAQ / specification and accessory attachments: https://faq.kawasaki-motors.com/faq/show/5840?site_domain=default

The official Japanese-market 2027 FAQ identifies the Ninja ZX-25RR as a distinct model from the ZX-25R SE and states its model-specific equipment differences: RR graphic, clear windscreen, Showa BFRC-lite rear shock absorber, and omission of frame sliders and USB socket. The official 2026 product page publishes model specifications including 249 cm³ inline-four engine, 184 kg curb mass, 1,380 mm wheelbase, 1,980 × 750 × 1,110 mm overall dimensions, and 110/70R17 front / 150/60R17 rear tyres. Confirm the exact year/market document before attaching any value to a vehicle definition.

These specification sheets are authoritative identity/specification references, not CAD geometry, part-surface topology, mounting coordinates or engineering drawings. They may seed a cited spec sheet and validation checklist, but they do not validate the procedural placeholder mesh or any fitment.

A third-party parts-catalogue listing was also found, but it is hosted on a document-sharing site and is not the preferred provenance source. Do not copy or redistribute the catalogue. Prefer manufacturer-issued parts documentation and legally obtained model-specific material.


## Motorcycle and game-source research vault — 2026-11-16

The detailed, pinned audit now lives in the [Atomic-Z Research Vault](../research/README.md), including individual source dossiers, immutable revisions, licence scope, compatibility notes, rejected leads and a sparse fetch helper. Use [source-registry.json](../research/source-registry.json) as the machine-readable index.

Important corrections and dispositions:
- `ssebs/DankNooner` is a substantial Godot 4.7 / Forward+ motorcycle game, but AGPL-3.0 and about 1.19 GB; study architecture only.
- `ssebs/moto-player-controller-godot` is an AGPL-3.0 predecessor on Godot 4.5 / Forward+; it is not a current plug-in.
- `OpenNFS` is MIT-licensed C++/Bullet car-engine research; EA game assets/data and bundled dependencies are separate rights. It is not a Godot motorcycle solver.
- `OpenUG2` has no clear SPDX licence grant established; study clean-room methods only.
- `troikoss/speed-re` has a limited MIT statement applying to original contributions, with recovered NFSU2 code/data and retail assets expressly excluded; the repository is now pinned at commit `892e5c31d77c751acd123330eda15c157c4f1b1f`, but the recovered NFSU2 code/data remain excluded from its MIT grant.
- The correct official REA project is `morluto/rea`; similarly named forks are not authoritative.
- `nicolasbize/roadkill` is a confirmed Godot pseudo-3D racing/fighting game, but GitHub reports `NOASSERTION` despite the itch page's MIT/CC claim.
- The previously cited `rishabhsinghio/Godot-Simple-Motorcycle-Physics` URL returned 404. The cited `alvariusgames/bearcycle` contents did not match a motorcycle project.
- Two Innerscene motorcycle GLB pages state CC0, but no model was downloaded or committed; file hashes and import validation remain pending.

Do not treat the older unverified candidate entries above this section as licence approval. The Research Vault is the current source of truth for this source-audit pass.


### Call of Duty source audit — 2026-11-16

Call of Duty has more open research material than a blanket “no source exists” statement suggests, but none is a complete official game-source release suitable for Atomic-Z:

- Activision's [official Open Source page](https://research.activision.com/opensource) publishes versioned Telescope: Activision Webkit middleware archives and matching licence archives for selected titles. Telescope is not the Call of Duty game engine/source.
- [OpenCOD2](https://github.com/opencod2/opencod2) is an incomplete independent C engine reconstruction; its inspected repository has no detected licence file and requires legally owned CoD2 content.
- [OpenCoD1](https://github.com/opencod1/opencod1) is an incomplete independent CoD 1.1 multiplayer reconstruction; no repository licence file was detected.
- [CoDWaW reverse-engineering notes](https://github.com/ItsNoahJ/codwaw-reverse-engineering) are MIT-licensed research notes/data, not Activision game source or game assets; the byte-verification methodology is the transferable part.
- [CoD-Research](https://github.com/primetime43/CoD-Research) is a GPL-3.0 community wiki for CoD4–CoD10, not game source.
- [MW2 reconstruction dashboard](https://mw2.momo5502.com/) tracks a private source-level reconstruction; no public code repository or licence was established.

See the [COD dossier](../research/sources/COD_RECONSTRUCTION.md) and the updated [source registry](../research/source-registry.json). No COD code, proprietary assets or game data have been imported.


### Godot vehicle systems and configurator sources — 2026-11-16

The expanded source review includes five additional pinned repositories. Full implementation notes and exact file links are in [Godot vehicle systems](../research/sources/GODOT_VEHICLE_SYSTEMS.md) and [Motorcycle configurators](../research/sources/MOTORCYCLE_CONFIGURATORS.md).

- `Seerban/godot-vehicle`: MIT Godot 4.6 Forward+ four-wheel RigidBody/raycast racing car, with suspension/grip, VehicleData resources and ghost replay. Useful architecture reference, not motorcycle dynamics.
- `Kurtzmusch/kv-vehicle`: Godot 4 modular vehicle addon with engine, gearbox, clutch, tire response, suspension, ABS and anti-roll. No root licence found; README documents straight-line suspension, shapecast origin sensitivity and feedback oscillations. Study-only.
- `AurickMikleton/ModuVehicle`: CC0 C++ GDExtension prototype, Godot 4.5+, with swappable vehicle resources and a combined slip/tyre-force model, traction control, wheel integration and suspension damping. WIP; no complete motorcycle solver; no GDExtension imported.
- `Whauv/MotoForge`: Next.js/Three.js + FastAPI/SQLite configurator. Useful part-fitment relations, duplicate-safe quote calculation and GLB asset alignment conventions. No repository-level licence; no code reuse.
- `rohithyv/3D-Motorcycle-Showroom`: fictional VOLT R1 Three.js showroom. Useful mobile opt-in/lazy GLB loading, fallback, camera choreography and performance telemetry. No repository-level licence; product figures are fictional and must not be treated as engineering facts.

The machine-readable [registry](../research/source-registry.json) now includes 23 entries and 16 pinned Git commits. Only six pinned repositories with an identified licence are exposed by the local sparse-fetch helper (the two new entries are Godot Vehicle and ModuVehicle). Sources with unclear or mixed rights remain manual-reference only.
