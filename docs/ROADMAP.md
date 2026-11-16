# Atomic-Z-Customi-Z — End-to-End Roadmap

Strategy: one integrated Godot application, delivered through tested vertical slices. Planning baseline: 2026-11-16.

## Product outcome
An Android-first motorcycle customization workbench where one user can inspect a vehicle, disassemble it, customize parts/surfaces, design visual effects, save complete builds and export portable project assets. Internal modularity must not fragment UX or canonical state.

## Phase 0 — Governance and baseline
- Apply AGENTS.md and PR-only workflow.
- Inventory branches, PRs, commits, workflows and CI at task start.
- Identify canonical scene, scripts, schemas, tests and Android export.
- Record baseline test output and commit SHA.
- Assign integration owner and file ownership.
Exit: current baseline and ownership map; no undocumented direct-main work accepted going forward.

## Phase 1 — Canonical product/build model
- Define versioned BuildDocument, vehicle, part, surface, material, graphic/neon and render records.
- Define stable IDs, units, coordinate frame and asset provenance.
- Add migration from legacy neon_skin_config.json.
- Add schema, invalid-data and save/load round-trip tests.
Exit: garage, editor controls and export use one validated build state.

## Phase 2 — Integrated garage vertical slice
- Vehicle selection and identity/evidence panel.
- Stock/Exploded assembly and deterministic transforms.
- Part selection and selected-part editing.
- Paint/material and neon/graphic controls in the same HUD.
- Touch-safe orbit/pan/zoom and responsive layout.
- Shared undo/redo/reset.
Exit: product customization requires no external Tkinter/Python window.

## Phase 3 — Geometry and assets
- Blender-to-GLB authoring/import.
- Provenance/license/hash manifest.
- Stable part IDs, pivots, mount points and material slots.
- UV/surface registration for graphics.
- Exact vehicle variant/year/market selection.
- Recursively inventory imported GLB nodes, mesh surfaces and source material slots.
- Prototype stable surface bindings and a safe per-surface override adapter; preserve imported PBR materials and fail closed on ambiguous IDs.
- Complete integration with the GLB asset manifest, BuildDocument material records and garage selection before exposing the editor.
Exit: asset validator passes; fitment claims limited to verified assets; one-surface edits cannot alter unrelated slots.

## Phase 4 — Rendering
- PBR paint/material presets.
- Emissive neon and animated effects.
- Godot glow pipeline with adaptive quality tiers.
- Decals, textures and surface-bound curves.
- Lighting presets and preview capture.
- Frame-time telemetry and graceful quality reduction.
- Keep emission functional with glow disabled; test Compatibility glow separately and verify occlusion/alpha sorting before enabling additive/depth overrides.
Exit: desktop visual review and Android profiling meet measured budgets; low-tier fallback remains usable.

## Phase 5 — Persistence and export
- Save/load full BuildDocument.
- Atomic writes, recovery and schema migration.
- Undo/redo and named revisions.
- Export project data, assets and previews.
- Validate imports/exports and hashes.
- Hardware mapping only from calibrated profiles.
Exit: save-close-reopen preserves full state; exported document validates.

## Phase 6 — Engineering preview
- Dimension/coordinate inspection.
- Collision/interference with known-answer fixtures.
- Mass properties only with verified geometry and density.
- Optional solver adapters with assumptions, versions and validation cases.
- Separate fitment/legal evidence.
- Motorcycle riding physics remains out of scope unless a separate product-scope decision authorizes a rideable preview; evaluate candidate add-ons before any dependency is introduced.
Exit: each result has traceable input, units, assumptions, method and status.

## Phase 7 — Android release candidate
- Reproducible arm64 APK/AAB pipeline.
- Install/launch and touch verification.
- Record exact Redmi Note 13 Pro SKU, SoC/GPU, RAM, Android version and display.
- Measure median/1% low FPS, frame time, memory and thermals over 10 minutes.
- Verify pause/resume, orientation, storage and recovery.
- Archive build hash and evidence.
Exit: critical checks PASS on recorded device; limitations published.

## Priority
P0 governance, baseline, canonical schema and tests.
P1 integrated garage, selection, assembly, materials and neon.
P2 verified vehicle assets and surface mapping.
P3 rendering quality, persistence and export.
P4 engineering adapters and calibrated hardware.
P5 release hardening and commercial packaging.

Do not invent FPS/memory targets before profiling the exact device. Measure baseline, then set regression budgets.

## Project operating cadence
Every task has owner, scope, dependencies, acceptance criteria and estimate. Every merge requires review and current CI evidence. A milestone closes only when exit gates and evidence are recorded. Maintain decision and risk logs. When a dependency fails, re-plan rather than creating a parallel workaround.

## Technical research decisions
See [Godot motorcycle rendering and asset integration review](GODOT_MOTORCYCLE_RENDERING_RESEARCH.md) for the GLB material-slot strategy, neon/glow tiering, renderer-specific constraints, physics scope boundary and test-first acceptance gates.
