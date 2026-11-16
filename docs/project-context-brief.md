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

The root README and canonical specifications describe the intended product and developer workflow. Current source presence, historical PR descriptions and older CI runs must not be interpreted as proof that the current main commit passes all gates.

Known evidence boundaries from inspected repository documentation and PR descriptions:

- Godot headless import/smoke/neon/BuildDocument checks have been reported PASS on named historical runs; verify exact current commit before relying on them.
- Android Debug export has been reported failing with a generic preset-configuration error. PR #8 adds verbose diagnostics; root cause and successful export are not established by that PR description.
- Android installation and physical Redmi Note 13 Pro validation remain separate gates.
- Surface-aligned neon paths require a verified model/UV/surface binding; approximate 2D-to-3D mapping is not fitment evidence.
- No mechanical fitment, mass, stress, structural safety or road-legality claim is established by a visual model.

## 6. Current GitHub snapshot — 2026-11-16

- Default branch: `main`.
- Branch search returned seven branches: `main`, `agent/integration/1-build-document-contract`, `agent/integration/5-android-export-diagnostics`, `agent/research/godot-mobile-rendering-integration`, `agent/research/5-verified-source-audit`, `docs/product-charter-workflows-handoff`, and `feat/commercial-neon-shader-skin-data`.
- PR #7 and PR #8 were returned by the open-PR search.
- PR #2, #3, #4 and #6 were returned by the closed-PR search; recent main history includes merge commits for #2, #3, #4 and #6.
- This snapshot is temporary. Recheck GitHub before each task; do not rely on these branch/PR states indefinitely.

## 7. Work sequence (dependency-aware)

1. Confirm exact target vehicle year/market/variant before model-specific assets or fitment.
2. Audit canonical BuildDocument readers/writers and reconcile historical skin persistence paths.
3. Verify the current Godot baseline and all applicable headless/contract tests.
4. Diagnose Android export from the detailed CI logs; do not mutate export settings speculatively.
5. Acquire or author licensed geometry; validate GLB structure, dimensions, coordinate frame, IDs and surface/material bindings.
6. Bind customization layers to verified surfaces and preserve the one-document save/load/export flow.
7. Profile and validate on the exact target Android device; record device SKU, SoC/GPU, OS, build hash, frame time, memory and thermal evidence.
8. Add engineering/hardware capabilities only with explicit assumptions, calibrated inputs and separate acceptance gates.

## 8. Status vocabulary

Use `PASS` / `FAIL` / `NOT RUN` / `BLOCKED`. Never infer a passing test from code presence, a PR title, a previous commit or an unrelated CI job.

For conflict classification, evidence hierarchy and recovery procedure, follow [CONTEXT_INTEGRITY_PROTOCOL.md](CONTEXT_INTEGRITY_PROTOCOL.md).
