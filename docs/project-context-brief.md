# Atomic-Z-Customi-Z — Project Context Brief

**Last reconciled:** 2026-11-16  
**Canonical repository:** https://github.com/metsam-mastem/Atomic-Z-Customi-Z  
**Context governance:** [CONTEXT_INTEGRITY_PROTOCOL.md](CONTEXT_INTEGRITY_PROTOCOL.md)

## 1. Project identity and boundary

- Product: Atomic-Z-Customi-Z — one integrated, Android-first motorcycle customization workbench / virtual garage.
- Runtime and Android delivery: Godot 4 / GDScript.
- Rendering baseline: Godot Compatibility renderer until measured device evidence justifies a change.
- Canonical editable state: one versioned `BuildDocument`.
- Preferred asset interchange: glTF 2.0 / GLB with recorded provenance, license, coordinate frame and validation.
- Experience: one application, one active vehicle/build context, one HUD/workflow and one persistence/export pipeline.
- Accepted target identity in project decisions: Kawasaki Ninja ZX-25RR. Exact model year, market and geometry compatibility remain unresolved/evidence-gated.

This repository is a dedicated project stream. Do not merge unrelated JARYAN workstreams or other projects without explicit product-owner direction.

## 2. User decisions and accepted architecture

- Android-first product direction.
- Godot 4 is the only product runtime and Android delivery engine.
- Compatibility renderer is the baseline; adaptive quality must be measured on target hardware.
- Internal modules are allowed, but they are components of one product, not independent apps or subprojects.
- One canonical BuildDocument owns vehicle, assembly, materials, graphic/neon and render settings.
- Stock and Exploded are views of the same assembly/build context.
- Use stable vehicle, part, surface and layer IDs.
- Hardware mapping requires calibrated controller/LED profiles and explicit validation.
- Visual preview, geometry checks, engineering simulation, mechanical fitment, road legality and physical hardware deployment are separate evidence classes.

## 3. Vehicle identity and asset boundary

A prior neon design input names ZX-25R, while the accepted base vehicle is ZX-25RR. Preserve the distinction until authoritative model-year/market documentation establishes compatibility. Do not silently transfer dimensions, body geometry, parts or fitment between variants.

The current procedural motorcycle geometry is placeholder geometry. It is not factory Kawasaki CAD, a verified ZX-25RR replica or an engineering-validated model. Record asset source, license, hash, dimensions, coordinate frame and validation status before elevating an asset's evidence level.

## 4. Unified state and legacy data

- `BuildDocument` is the single authoritative editable build state.
- `neon_skin_config.json` is a legacy/migration input or compatibility format only; it must not become a second authoritative writer.
- Any migration must preserve stable IDs and include schema validation and round-trip tests.
- The historical PR #4 skin-profile store and its independent `user://skin_profile.json` persistence require reconciliation against the canonical BuildDocument before any further integration. Do not treat its existence or prior merge as approval for a parallel source of truth.
- Python/Tkinter and ModernGL are development/research aids, not alternate product runtimes. Port selected ideas into Godot only after compatibility, value and license review.

## 5. Repository implementation/evidence notes

The live repository state is authoritative. This snapshot is tied to the exact refs and CI runs below; refresh GitHub before relying on it.

- Verified `main`: `4d2cf3b82bd78437541b49da46f522c06d2652b5`. The main Godot import/smoke, Python simulator and Android Debug Export jobs passed in workflow [#43806740044](https://github.com/metsam-mastem/Atomic-Z-Customi-Z/actions/runs/43806740044).
- PR #20 is merged. Its ownership-safe SurfaceMaterialBinder prototype and BuildDocument-driven neon HUD hydration passed exact-head Godot/Python/Android CI; merge commit `75df0367e11422f6169d5cc9af774900cc65807f`. This proves the binder contract test, not production GLB integration.
- PR #28, [Android artifact verification and reproducible build path](https://github.com/metsam-mastem/Atomic-Z-Customi-Z/pull/28), is OPEN on branch `agent/build/android-artifact-hardening`, head `092d84c975bed159b244eb552a2b76efd16a41a7`. Its exact-head Godot, Python and Android CI passed in runs [#43807090339](https://github.com/metsam-mastem/Atomic-Z-Customi-Z/actions/runs/43807090339) and [#43807085346](https://github.com/metsam-mastem/Atomic-Z-Customi-Z/actions/runs/43807085346). It adds a common debug/release build entrypoint and APK structural/signature verification. Release export itself remains NOT RUN because no owner-controlled release keystore was supplied.
- PR #29, [GLB surface catalog to BuildDocument integration](https://github.com/metsam-mastem/Atomic-Z-Customi-Z/pull/29), is a DRAFT stacked on PR #28. It adds recursive surface inventory, stable manifest validation, BuildDocument catalog storage and per-surface material edits in the existing binder. Its latest head is `923f07e5bd7b9af69a2722b0a999f5a55b19bad5`; exact-head CI is queued/pending. Do not merge it before PR #28.
- PRs #7, #11, #18 and #19 are closed as superseded by PR #20. PR #17 and PR #20 are merged.
- Current geometry remains procedural placeholder geometry. No verified factory CAD, ZX-25RR replica, production UV map, physical fitment, engineering validity or road legality is established.
- The only verified visual asset in the repository is `assets/product-concept.svg`. It is concept/UI artwork, not a runtime screenshot. See `docs/VISUAL_ASSET_REGISTER.md`.
- Physical Redmi installation, touch/persistence QA and performance/thermal profiling remain NOT RUN.

## 7. Work sequence (dependency-aware)

1. Complete independent review of PR #28 and merge it only after the exact-head Godot/Python/Android checks and APK verifier review remain green.
2. After PR #28 merges, retarget PR #29 to `main`, rerun exact-head CI and review the BuildDocument surface-catalog contract before merging.
3. Reconcile the historical skin-profile persistence path against the canonical BuildDocument; do not introduce a second writable store.
4. Obtain a licensed, provenance-tracked GLB for an explicitly selected ZX-25RR year/market. Validate its hash, license, dimensions, coordinate frame, node hierarchy, part IDs, material slots and UVs.
5. Connect verified asset surface IDs to the existing garage selection/HUD workflow; preserve one BuildDocument save/load/export path.
6. Profile and validate on the exact target Android device; record device SKU, SoC/GPU, OS, build hash, frame time, memory and thermal evidence.
7. Add engineering/hardware capabilities only with explicit assumptions, calibrated inputs and separate acceptance gates.

## 8. Status vocabulary

Use `PASS` / `FAIL` / `NOT RUN` / `BLOCKED`. Never infer a passing test from code presence, a PR title, a previous commit or an unrelated CI job.

For conflict classification, evidence hierarchy and recovery procedure, follow [CONTEXT_INTEGRITY_PROTOCOL.md](CONTEXT_INTEGRITY_PROTOCOL.md).
