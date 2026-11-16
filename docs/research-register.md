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
- Innerscene sport motorcycle (CC0, GLB, 7.2 MB): https://www.innerscene.com/tools/library/3d-parts/sport-motorcycle-e21e8303
- Innerscene race-replica superbike (CC0, GLB, 20.1 MB): https://www.innerscene.com/tools/library/3d-parts/race-replica-superbike-fully-faired-badbd83b
- Innerscene naked sport motorcycle (CC0, GLB, 19.1 MB): https://www.innerscene.com/tools/library/3d-parts/sport-motorcycle-naked-sport-bike-fc4c9758
- Innerscene road motorcycle (CC0, GLB, 627 KB): https://www.innerscene.com/tools/library/3d-parts/road-motorcycle-f2519759

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
