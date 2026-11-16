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
- `neon_skin_config.json` is read-only migration input; runtime edits never write it. The former `NeonSkin.save_skin()` writer is retired.
- Any migration must preserve stable IDs and include schema validation and round-trip tests.
- The historical PR #4 `SkinProfileStore` writer and its independent `user://skin_profile.json` persistence have been retired. On first launch only, when no canonical BuildDocument exists, the legacy file is imported: color enters the primary palette and old 0..10 glow/pulse values are preserved unchanged in a versioned `extensions` record. The original user file is retained; existing BuildDocument data always takes precedence. `NeonSkin.save_skin()` is also retired; runtime save/load uses BuildDocument.
- Python/Tkinter and ModernGL are development/research aids, not alternate product runtimes. Port selected ideas into Godot only after compatibility, value and license review.

## 5. Repository implementation/evidence notes

The current repository state is authoritative. The following results are tied to named PR heads and CI runs, not a blanket claim that every current-main gate passes.

- PR #10 is merged. It adds isolated part paint, BuildDocument persistence with backup/recovery, and the ETC2/ASTC Android export prerequisite.
- Godot 4.4.1 import, smoke, neon, BuildDocument, Exploded reload and persistence failure/recovery tests passed on named PR #10 commits.
- Android Debug APK export and artifact upload passed on PR #10 commit 253029faaecc358e7e3c98d52255a8cb63ee9db1 in workflow run 43788395328. Physical Redmi device installation and QA remain NOT RUN.
- PR #7 remains open/draft. Its focused Surface Material Binder test and end-to-end GLB/BuildDocument/UI integration remain NOT RUN.
- PR #8 is closed without merge. PR #11 and PR #12 remain open at the latest snapshot; re-evaluate their overlap with the Android export fix already merged through PR #10 before further action.
- Current geometry remains procedural placeholder geometry. No verified factory CAD, ZX-25RR replica, physical fitment, engineering validity or road legality is established.
- The only verified visual asset in the repository is assets/product-concept.svg. It is concept/UI artwork, not a runtime screenshot. See docs/VISUAL_ASSET_REGISTER.md.

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
