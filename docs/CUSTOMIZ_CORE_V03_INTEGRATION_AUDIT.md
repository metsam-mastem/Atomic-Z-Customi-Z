# Customi-Z Core v0.3 — donor package audit and Atomic-Z integration map

**Status:** inspected; integration candidates classified; runtime port NOT RUN  
**Date:** 2026-11-16  
**Source artifact:** user-uploaded `customiz-core-v0.3.zip`  
**SHA-256:** `5b64659a59b77931185f738a79466701e11e0be821e0aa0a08d9d6aa5f44c0be`  
**Repository baseline:** `metsam-mastem/Atomic-Z-Customi-Z`, `main` at `db532efa725e6f54df54a707ce7b5be585d589d6`  
**Tracking:** [Issue #41](https://github.com/metsam-mastem/Atomic-Z-Customi-Z/issues/41)

## Executive finding

The archive is a Godot 4.4 motorcycle customization app core, with 34 filesystem entries (30 non-empty files) and approximately 95.8 KB uncompressed payload. It is a **donor implementation, not a clean plug-in**. Atomic-Z already has canonical counterparts for its principal editor features. Copying the archive wholesale would introduce a competing main scene/controller, a second BuildDocument-like schema and parallel persistence; this conflicts with the repository's mandatory one-runtime / one-canonical-BuildDocument contract.

Recommended disposition: port selected donor-only UX/system hardening into existing Atomic-Z scripts after contract tests, while retaining current Atomic-Z implementations as canonical. Do not vendor a second product tree.

## Package inventory

| Donor path | Responsibility (source-level) | Atomic-Z disposition |
|---|---|---|
| `project.godot`, `scenes/main.tscn`, `scenes/boot_splash.tscn` | Godot app settings, garage entry, boot shell | CONFLICT: current project settings and `scenes/main.tscn` are canonical; boot shell may be adapted only after scene/lifecycle review |
| `scripts/main_garage.gd` | 22 KB garage controller: procedural/GLB assembly, HUD, saves, settings, photo, undo/redo hooks | CONFLICT/DUPLICATE: current `scripts/main.gd` owns garage experience; compare behavior, port narrow deltas, never replace wholesale |
| `scripts/build_history_manager.gd` | 40-step in-memory Undo/Redo, local named-build files, schema-v1 defaults and legacy neon migration | REQUIRES ADAPTATION: valuable history concept, but donor schema is flat and incompatible with canonical `scripts/build_document.gd`; its direct JSON save lacks the current store's validated temp/backup recovery |
| `scripts/build_presets_catalog.gd` | Four factory presets and AZ1 clipboard share code | DUPLICATE/POTENTIAL: compare with existing BuildDocument presets and serialization; share-code behavior may be ported if it validates canonical documents |
| `scripts/codm_garage_camera.gd` | inertial orbit, touch pan/pinch, tap-to-focus/raycast | DUPLICATE: existing camera/input path is in `scripts/main.gd`; compare UX and touch regression coverage before selective port |
| `scripts/codm_surface_binder.gd` | per-part shader/material binding, finish modes, neon/floor material | DUPLICATE: current `scripts/surface_material_binder.gd` is the safer canonical surface ownership binder; donor shader is an input, not replacement |
| `scripts/quality_director.gd` | adaptive quality, startup tier, shader warm-up | DUPLICATE/CONFLICT: current `scripts/quality_controller.gd` has measured FPS hysteresis; do not replace with donor thresholds without benchmarks |
| `scripts/garage_showcase_director.gd` | deterministic exploded view and haptic helpers | DUPLICATE: existing assembly and UI state already handle exploded mode; haptic helper is a candidate only after capability/platform check |
| `scripts/photo_mode_director.gd` | HUD-hidden PNG capture plus build spec | DUPLICATE: compare with current export/preview capabilities; ensure output references canonical BuildDocument |
| `scripts/android_safe_area.gd` | Android inset margins for HUD | POTENTIAL: likely useful UX gap; port into existing HUD and test cutouts/gesture bars rather than wrap a second UI |
| `scripts/localization_manager.gd` | EN/FA dictionary strings, RTL hint, optional Vazirmatn font | HIGH PRIORITY POTENTIAL: current repo documentation identifies localization/accessibility as a gap; needs integration with existing HUD and correct RTL/font fallback. Font asset itself is absent from archive |
| `scripts/app_settings_store.gd` | settings.cfg persistence plus clean-boot crash-loop quality downgrade | HIGH PRIORITY POTENTIAL: current canonical settings lifecycle should absorb this protocol; test recovery, atomic save and tier bounds |
| `scripts/commercial_modals.gd` | garage slots, settings/about, exit confirmation dialogs | POTENTIAL: UI features may be ported into existing shell, but do not create a separate navigation/application lifecycle |
| `scripts/tactical_sfx.gd` | synthesized click/mechanical UI sounds | POTENTIAL: procedural sound is lightweight; gate on settings and headless/mobile audio availability |
| `scripts/boot_splash.gd` | splash UI, shader warmup and threaded garage load | POTENTIAL/CONFLICT: startup UX can be adapted only if it preserves existing entry scene and prevents unsafe threaded scene/resource access |
| `scripts/tools/validate_vehicle_glb.gd` | GLB node names, UV, scale and triangle-budget checks | POTENTIAL: compare with existing GLB/model validation pipeline; align stable part IDs and vehicle evidence schema before adoption |
| `scripts/tools/build_commercial_release.sh`, `export_presets.cfg` | signed APK/AAB export wrapper | CONFLICT: current export preset and CI are canonical; script is not ready for direct adoption (see release risks below) |
| `tests/build_history_manager_test.gd`, `tests/garage_integration_test.gd` | donor history/migration and garage integration tests | DONOR TESTS: useful behavioral cases, but must be rewritten against canonical BuildDocument/store; do not import tests that assume donor schema |
| `shaders/moto_aaa_surface.gdshader`, `shaders/studio_garage_floor.gdshader` | paint/clearcoat/flakes/rim/exhaust heat tint/neon mask and studio floor | POTENTIAL ART INPUT: inspect shader feature-by-feature against current `shaders/neon_glow.gdshader`; compatibility renderer/mobile performance and parameter ownership need validation |
| `README.md` | setup, package claims, release gates and missing items | SOURCE DOCUMENT: archive's README itself calls package “Core v0.1 — not yet device-tested” while describing v0.2/v0.3; treat release claims as unverified |
| `.github/workflows/android_ci.yml` | donor Android workflow | CONFLICT: Atomic-Z has its own `.github/workflows/godot-ci.yml`; do not add a competing workflow |

## Existing canonical overlap confirmed in Atomic-Z

- Garage and lifecycle: `scenes/main.tscn`, `scripts/main.gd`.
- Assembly and stable part IDs: `scripts/bike_assembly.gd`.
- Canonical editable schema: `scripts/build_document.gd`; persistence/recovery: `scripts/build_document_store.gd`.
- Per-surface ownership: `scripts/surface_material_binder.gd`.
- Neon renderer and migration: `scripts/neon_skin.gd` plus BuildDocument migration.
- Adaptive quality: `scripts/quality_controller.gd`.
- Existing automated gates: `tests/smoke_test.gd`, neon, BuildDocument, surface binder and UI-state tests; Python tests cover legacy authoring utility; Android export is in CI.

These are the designated target surfaces; the donor must not become an alternate writer or app entry.

## Integration sequence (proposal; not yet implemented)

1. **P0 — contracts first:** establish canonical BuildDocument operations for undo/redo snapshots, named save slots, preset import/share, settings values and validation. Add failing round-trip, malformed input, migration, filename/path and bounded-history tests.
2. **P1 — low-coupling UX ports:** localization EN/FA (including actual RTL layout behavior), safe-area support, procedural SFX toggle, exit confirmation/about/settings UI. Wire into the current HUD/navigation and canonical settings; use explicit signals/typed boundaries.
3. **P2 — recovery protocol:** adapt clean-boot marker and tier fallback into current startup lifecycle; persist safely, validate tiers, ensure healthy mark only after the garage is genuinely ready. Add crash-loop protocol tests.
4. **P3 — editor capability comparison:** review donor preset/share, camera, showcase, photo mode and shader features against current implementations; port only non-duplicated behaviors and test against existing APIs.
5. **P4 — asset/release hardening:** unify GLB validator checks and metadata with the project's provenance/evidence contract. Keep current Android export/CI authoritative; address release-script safety before any use.
6. Update unified spec, acceptance, roadmap and project status only when the relevant feature and exact-head evidence are available.

## Source-level risk findings

- **Schema divergence:** donor `BuildHistoryManager` declares its own schema version 1 and fields such as `paint`, `parts`, `neon`, `exploded`; Atomic-Z's nested versioned BuildDocument includes vehicle, customization and render contracts. A direct merge would silently bifurcate state.
- **Persistence safety regression:** donor named-build save writes JSON directly to final file, with no temp-file validation, backup rotation or recovery. Atomic-Z's current store already implements guarded persistence; preserve that implementation.
- **Release wrapper masks import failure:** `build_commercial_release.sh` uses `godot --import ... || true`, so import failure is swallowed before tests/export.
- **Keystore default path:** release script defaults to `build/keystore/atomicz-release.keystore` inside the repository workspace. README says back up outside repo, but the default invites accidental secret material in working tree. A safe default should be external/ignored and validated.
- **Export preset mutation:** script temporarily copies and rewrites `export_presets.cfg`; trap restores it, but interruption/recovery and concurrent invocation need testing.
- **No model asset/font:** archive inventory has no `assets/models/*.glb` or `assets/fonts/Vazirmatn-Regular.ttf`; startup falls back to procedural geometry and Persian glyph availability is not guaranteed.
- **Device readiness:** archive README explicitly says not device-tested. Neither archive code presence nor static review establishes Android performance, crash-free startup or commercial readiness.
- **Potential app-scope drift:** donor's sport-250 naming and bundled package identity differ from the accepted ZX-25RR target/evidence-gated identity; preserve provenance and do not infer variant equivalence.

## Acceptance evidence required before any runtime port is called complete

- Godot 4.4.1 editor import and parse checks on the exact PR head.
- New targeted tests fail-before/fix-after for each integrated behavior.
- Current smoke, neon, BuildDocument, binder and HUD hydration suites.
- Python legacy suite only if shared paths are affected.
- Android Debug export and artifact metadata/signature CI where export settings are touched.
- Android device QA remains a separate status: cutout/gesture safe area, FA RTL/font rendering, save/load, boot recovery, pause/resume, audio/haptics and thermal/performance profiling.
- No claim of physical device, geometry/fitment, or commercial release validation without evidence.

## Rollback

The integration is staged in one reviewable PR. Revert the feature commit/PR if canonical schema tests, smoke/import, or Android export regress; no donor data store or second runtime is introduced. Preserve user-generated legacy files and migrations during any future schema work.

## Verification record

- Archive SHA-256 computed locally: above.
- Archive inventory and source-level declarations inspected.
- Repository tree, project charter, architecture, mandatory agent instructions, unified specification, context protocol, governance, roadmap, research/decision register, workflow and status checkpoint reviewed; live main/PR/issue/CI state refreshed.
- Godot executable/runtime tests against this donor package: **NOT RUN** (Godot runtime not invoked in this audit).
- Android device tests: **NOT RUN**.
- Integration code: **NOT RUN / NOT YET PORTED**. This document records the source audit and implementation plan, not a claim that the donor package is already integrated.
