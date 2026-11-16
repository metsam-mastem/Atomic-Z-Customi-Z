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
- Recursively inventory imported GLB nodes, mesh surfaces and source material slots.
- Bind stable surface IDs to unique mesh/surface targets; duplicate materials before edits and preserve imported PBR resources.
- Complete the bridge from verified asset metadata and surface bindings into BuildDocument material records and the existing garage selection flow.
- Exact vehicle variant/year/market selection.
Exit: asset validator passes; fitment claims limited to verified assets; isolated surface edits cannot mutate unrelated slots.

## Phase 4 — Rendering
- PBR paint/material presets.
- Emissive neon and animated effects.
- Godot glow pipeline with adaptive quality tiers.
- Decals, textures and surface-bound curves.
- Lighting presets and preview capture.
- Frame-time telemetry and graceful quality reduction.
- Keep emissive materials functional with glow disabled; profile Compatibility glow separately and use adaptive low-tier fallbacks.
Exit: desktop visual review and Android profiling meet measured budgets.

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
- Riding physics remains outside the customization garage until an explicit product-scope decision authorizes a rideable simulator.
- Separate fitment/legal evidence.
Exit: each result has traceable input, units, assumptions and status.

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

## Current execution evidence — 2026-11-16

- PASS — the integrated garage now has stable part selection and isolated per-part paint records in the canonical BuildDocument.
- PASS — saved per-part materials, Stock/Exploded assembly mode and global neon visibility restore into the runtime scene.
- PASS — BuildDocument save uses validated temporary writes, retains the previous valid revision as a backup, and recovers after a corrupt or missing primary or a failed backup rotation.
- PASS — Godot 4.4.1 headless import, smoke, neon and BuildDocument tests at feature commit `b773e6911fc30bf20693211ca745c8d7995beae3` (CI run [#43788490715](https://github.com/metsam-mastem/Atomic-Z-Customi-Z/actions/runs/43788490715)).
- PASS — Android Debug APK export at commit `ced48a657dd688d683b9328a97081af7bfad52ac` (CI run [#43788240486](https://github.com/metsam-mastem/Atomic-Z-Customi-Z/actions/runs/43788240486)); root cause was missing ETC2/ASTC texture import in project settings.
- NOT RUN — install and runtime QA on the user's physical Redmi device.
- NOT RUN — verified production GLB motorcycle asset, factory dimensions, UV/surface mapping, undo/redo, responsive touch review, Android FPS/memory/thermal profiling and engineering validation.

The current milestone is a working Godot garage vertical slice with a CI-built debug APK, not a production-ready motorcycle configurator. Do not close Phases 2–7 until their stated exit criteria are met.


## Live integration checkpoint — 2026-11-16

- PASS — GLB surface catalog and stable surface-ID validation integrated through PR #43; Godot smoke, GLB contract, Neon simulator and Android Debug/Release CI passed on exact head.
- PASS — Neon state now migrates into the canonical BuildDocument through PR #45. The parallel skin profile writer is retired; legacy shader values that cannot be safely normalized remain preserved as unmapped extension data.
- PASS — P1 camera gestures integrated through PR #45: one-finger orbit, two-finger pan and pinch zoom. Exact-head CI passed; physical Redmi touch QA remains NOT RUN.
- OPEN — PR #46 carries the research-only source vault; its latest exact-head run #43839645819 adds registry schema/pin checks and shell syntax validation.
- OPEN — issue #49 tracks safe optional AI assistant integration. Draft PR #31 was closed without merge; AI is excluded from P1 release acceptance.
- BLOCKED — Issue #47 tracks GLB runtime import and Android content-URI plugin work after PR #38's Android export failure.
- NOT RUN — physical device installation, production GLB provenance/fitment, performance/thermal profiling, production signing and commercial release acceptance.

The current P1 gate is now a single integrated Godot runtime with one BuildDocument write path. Do not start another parallel Neon store, camera controller, renderer or Android app. Finish the exact-device acceptance and release-hardening gates before expanding scope.
