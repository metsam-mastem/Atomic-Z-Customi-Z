# Graphics Quality Benchmark — COD Mobile-Inspired Bar (Android-First)

**Version:** 1.0  
**Status:** Proposed benchmark and implementation plan; not an achieved quality claim  
**Date:** 2026-11-16  
**Product:** Atomic-Z-Customi-Z  
**Engine:** Godot 4 / GDScript  
**Target experience:** Premium motorcycle customization garage, not a shooter clone

## 1. Intent

The owner requested a quality target comparable in perceived polish to Call of Duty: Mobile (COD Mobile). This document translates that aspiration into a practical, testable quality bar for the project's actual scope.

**Interpretation:** borrow the *quality discipline*—convincing materials, deliberate lighting, high-quality assets, polished animation/UI, stable frame pacing and device-aware optimization—not COD's game genre, content, proprietary assets, source code, or exact visual identity.

A single motorcycle in a curated garage is a much smaller scene than a full COD Mobile level. That makes a premium-looking focused scene plausible, provided the project invests in the right model, material/texture authoring, lighting and device profiling. It does not guarantee parity with COD Mobile's full content, engine pipeline, animation breadth, production scale or device coverage.

## 2. Product quality pillars

### A. Asset quality (the largest current blocker)
- Replace placeholder procedural motorcycle geometry with a professionally authored or legitimately licensed, evidence-tracked GLB.
- Model the visual silhouette, panel gaps, fairings, windscreen, tires, brakes, chain, engine casing, fasteners and cockpit at useful close-up distances.
- Correct mesh normals, smoothing, bevels, pivots, hierarchy, stable part IDs, UV layout and material slots.
- Use separate texture sets or packed ORM maps where appropriate; avoid excessive material slots and draw calls.
- Every asset must carry source, license, author, retrieval date, file hash, scale, variant/year confidence and allowed modifications in the asset register.
- Generic CC0 motorcycles may be used for pipeline prototypes, not mislabeled as factory ZX-25RR geometry.

### B. Materials
- High-quality PBR finishes: clear-coated paint, metallic, matte/satin, rubber, glass, brushed/anodized metal, carbon-like surface only when supported by appropriate maps.
- Correct roughness/metalness and normal detail; believable highlight response matters more than an exaggerated glossy shader.
- Per-part finish changes must stay BuildDocument-driven and isolated from imported source materials.
- Provide a small, curated palette and presets before building a huge material catalog.

### C. Garage lighting and atmosphere
- A designed studio environment with controlled key/fill/rim lighting and a neutral floor/background.
- Use one carefully selected shadow-casting key light as the initial mobile baseline; additional lights should be evaluated by measured cost.
- Use environment reflections/sky and baked or authored lighting where appropriate; dynamic shadowing is a budgeted feature.
- Subtle glow, restrained bloom, tonemapping, color grading and contact cues; avoid neon overload that obscures the motorcycle.
- Lighting should reveal material differences and silhouette from multiple camera angles.
- Do not promise full real-time ray tracing or physically exact reflections on Android.

### D. Camera and animation polish
- Smooth, damped orbit/pan/zoom with sensible limits and touch-safe input.
- Deliberate studio camera presets: hero, front three-quarter, side, rear three-quarter, cockpit/detail.
- Animated transitions when selecting parts, switching Stock/Exploded view, opening panels and resetting a build.
- Small interaction feedback (selection outline/highlight, panel transition, button state) with reduced-motion/accessibility option.
- No animation may interfere with precise part editing or produce camera jitter.

### E. UI/UX polish
- Premium compact HUD, clear typographic hierarchy, responsive layouts and touch targets.
- Customization controls organized around the active vehicle/part; no disconnected windows.
- Show loading, missing-asset, invalid-data, save/recovery and low-quality/performance states honestly.
- UI animation is measured separately from scene rendering; avoid continuous decorative effects that waste battery.

### F. Android performance and reliability
- Performance target is set only after profiling the actual device and build configuration.
- Record frame-time percentiles (median and 1% low FPS/frame time), GPU/CPU bottlenecks when available, memory, temperature, battery/power proxy, draw calls, mesh/texture sizes and shader compilation behavior.
- Test sustained sessions (minimum 10 minutes for release gate), warm/cold launch, app pause/resume, orientation policy, touch, storage, save/reopen and recovery.
- Dynamic quality must be deterministic and hysteresis-based; no rapid flicker between quality tiers.
- Keep a baseline build and compare changes using the same scene, camera, device state, resolution and test duration.

## 3. Renderer decision: do not flip the project blindly

Current main's `project.godot` declares Godot feature `4.3` and uses `gl_compatibility` for both default and mobile renderer settings. The CI uses Godot 4.4.1 according to existing PR evidence. This renderer configuration is an existing compatibility decision.

Godot 4 offers Compatibility, Mobile and Forward+ renderers. Official guidance describes Mobile as suited to newer mobile hardware and Compatibility as the widest-compatibility choice; Mobile has more advanced features, while Forward+ is primarily desktop-oriented. Renderer support is feature- and hardware-dependent; changing renderer can affect shaders, materials, import settings, visual output and target support.

### Recommended experiment
1. Preserve the existing Compatibility configuration as the known baseline.
2. Create a **separate, reversible renderer experiment branch/profile** using the project's pinned Godot version.
3. Evaluate Mobile renderer on the exact intended Android device(s); do not migrate main based only on desktop editor appearance.
4. Run existing import, smoke, neon, BuildDocument, surface-binding, UI-hydration and Android export tests.
5. Add a deterministic benchmark scene: one vehicle asset, studio environment, fixed camera, same lights, same effects and fixed resolution.
6. Compare Compatibility and Mobile side-by-side using image captures and repeated performance measurements.
7. Adopt Mobile only if it passes visual correctness, CI/export, device install, sustained performance/thermal, memory and lifecycle gates; retain Compatibility fallback only if the product can actually support a renderer selection without creating a second product architecture.

**No renderer switch is authorized by this proposal alone.** Owner approval and exact-head/device evidence are required.

## 4. Open-source code and asset discovery

The following sources are candidates for research, reference or carefully scoped reuse. “Open source” does not mean every included model/texture has the same license; inspect repository license and asset-specific terms before integrating or shipping.

| Source | Potential value | License / caution | Decision |
|---|---|---|---|
| [Godot demo projects](https://github.com/godotengine/godot-demo-projects) | Official renderer, 3D, mobile, UI and effect examples | Repository says MIT; individual demo assets should still be checked | **Reference library**, cherry-pick learning only |
| [ssebs/moto-player-controller-godot](https://github.com/ssebs/moto-player-controller-godot) | Godot 4 motorcycle controls, riding physics, bike/world sample | AGPL-3.0; repo author says it is a final pre-release and future work moved to DankNooner. AGPL obligations can be incompatible with proprietary distribution absent compliance | **Research only; do not copy into product without legal/license decision** |
| [ssebs/DankNooner](https://github.com/ssebs/DankNooner) | Current motorcycle gameplay research: balance, tricks, physics and animation architecture | AGPL repository; open-world game scope is far beyond this workbench | **Architecture/behavior study only** |
| [rishabhsinghio/Godot-Simple-Motorcycle-Physics](https://github.com/rishabhsinghio/Godot-Simple-Motorcycle-Physics) | Raycast motorcycle physics, lean/steering/braking; described as MIT in its README | Repo and exact license commit should be rechecked before reuse; model link is a separate asset and has its own terms | **Promising candidate for later riding prototype, not current garage dependency** |
| [Godot Easy Vehicle Physics](https://github.com/DAShoe1/Godot-Easy-Vehicle-Physics) | Raycast vehicle architecture and handling ideas | MIT, but designed as generic vehicle physics, not two-wheel dynamics | **Reference only; do not substitute car controller for motorcycle physics** |
| [Innerscene CC0 generic sport motorcycle](https://www.innerscene.com/tools/library/3d-parts/sport-motorcycle-e21e8303) | GLB prototype asset, real-world nominal scale and materials; public-domain CC0 dedication | Generic unbranded naked sport bike; not ZX-25RR, not factory CAD, not guaranteed part-level editability | **Possible pipeline/garage test asset after downloading, hashing and inspecting hierarchy** |
| [Innerscene CC0 race-replica superbike](https://www.innerscene.com/tools/library/3d-parts/race-replica-superbike-fully-faired-badbd83b) | Fully faired generic sportbike visual reference/prototype asset | CC0 page; still inspect model structure, texture quality, poly count, UVs and attribution/provenance | **Candidate for visual pipeline prototype only** |
| [3DAssets.dev Motorcycle Racing and Street Bikes pack](https://3dassets.dev/packs/motorcycle-racing-and-street-bikes) | CC0 pack of 69 motorcycle/paddock assets, coordinated scene | Site declares CC0; pack describes AI use in asset creation. Inspect individual model fidelity and asset provenance before production use | **Environment/benchmark prototyping candidate** |
| [Calinou/godot-sponza-4](https://github.com/Calinou/godot-sponza-4) | Renderer testing and scene-lighting reference | MIT code; Sponza scene assets public domain per README; heavy scene and not motorcycle-specific | **Renderer lab reference, not shipped garage** |

### Asset sourcing policy
- Prioritize an exact or professionally modeled motorcycle asset with documented provenance over a random high-poly download.
- A CC0 generic asset may help test GLB import, material binding, camera and lighting. It does not resolve the ZX-25RR asset/fitment gap.
- Do not copy COD Mobile art, maps, models, shaders, UI, extracted content or proprietary source. Benchmark its perceived polish, not its protected content.
- Do not bulk-import an open-source project. Extract only a narrow, necessary component after license, maintenance, dependencies, compatibility, security and architecture review.
- Do not introduce another renderer/runtime, independent build store or external customization editor.

## 5. Quality ladder (evidence gates)

### Q0 — Functional prototype (current broad state)
- Placeholder geometry, basic garage interactions and canonical build state.
- CI evidence does not imply device visual quality.

### Q1 — Polished garage prototype
- One credible motorcycle asset (clearly labeled generic or licensed), studio lighting, refined camera, UI hierarchy and basic PBR finish selection.
- End-to-end edit → preview → save/reopen.
- Android APK install and visual review.

### Q2 — Premium visual slice
- Close-up-capable production-quality model with stable parts and verified material slots/UVs.
- Coherent paint/metal/rubber/glass material library.
- Hero camera transitions, selected-part presentation, studio environment and polished HUD.
- Image comparison and device profiling with recorded evidence.

### Q3 — High-end mobile polish
- Renderer decision based on benchmark evidence.
- Robust adaptive quality, controlled shadows/effects, shader warmup and asset streaming/load strategy as warranted.
- Sustained frame pacing, memory/thermal and lifecycle validation on declared target device matrix.
- Visual fidelity maintained across supported quality tiers, not just one screenshot.

### Q4 — Product-grade release
- Exact asset provenance and scope claims.
- Install/update, persistence/recovery, accessibility/reduced motion, error handling, performance and QA gates.
- Reproducible release artifact and complete evidence package.

Do not mark any rung achieved until its exit criteria are recorded in CI, asset register and device evidence.

## 6. First benchmark scene specification

Create only after the owner accepts the benchmark plan and after a test asset is selected:
- Scene: single motorcycle centered in a neutral premium studio garage.
- Camera: fixed three-quarter hero view; a separate repeatable close-up view.
- Environment: same world/environment map and floor for all renderer comparisons.
- Lighting: one shadow-casting key light, fixed fill/rim lights without shadows unless benchmarked.
- Effects: controlled glow/tonemapping; one profile with effects off and one with intended effects.
- Asset: immutable source file identified by SHA-256 and license/provenance manifest.
- Resolution: actual target device resolution with a defined render scale; record any variation.
- Runs: warm-up then repeated timed capture; minimum 10-minute sustained run for device gate.
- Output: screenshot set, capture conditions, frame-time/FPS statistics, memory/thermal observations, import/export logs and exact commit SHA.

This benchmark is a diagnostic harness, not a separate product scene/runtime. The garage remains the single product experience.

## 7. Proposed acceptance checklist

- [ ] Owner approves COD Mobile-inspired quality as an aspiration benchmark, not a parity claim.
- [ ] Asset license/provenance approved and manifest completed.
- [ ] Benchmark scene and repeatable camera conditions committed.
- [ ] Existing Compatibility baseline captured.
- [ ] Mobile renderer experiment conducted on the declared Android target.
- [ ] Godot tests and Android export pass on exact experiment head.
- [ ] Device visual review completed.
- [ ] Frame-time, memory and sustained thermal observations recorded.
- [ ] Renderer choice documented with trade-offs and rollback path.
- [ ] Q-level achieved only with evidence; no unsupported “COD-level” product claim.

## 8. Decision requested

The recommendation is to ratify a **COD Mobile-inspired quality bar** and prioritize Q1/Q2—credible model, materials, lighting, camera and HUD—before building expansive gameplay or engineering systems.

This document is a proposal. It does not change project renderer settings, runtime, asset inventory, BuildDocument schema, product identity, or release status.
