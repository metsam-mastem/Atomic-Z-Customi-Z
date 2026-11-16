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
Exit: asset validator passes; fitment claims limited to verified assets.

## Phase 4 — Rendering
- PBR paint/material presets.
- Emissive neon and animated effects.
- Godot glow pipeline with adaptive quality tiers.
- Decals, textures and surface-bound curves.
- Lighting presets and preview capture.
- Frame-time telemetry and graceful quality reduction.
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
