# Project Status — Canonical Resume Checkpoint

**Purpose:** Resume work without relying on any ChatGPT conversation, account memory or individual agent context.  
**Repository:** `metsam-mastem/Atomic-Z-Customi-Z`  
**Product:** Atomic-Z-Customi-Z — one integrated Android-first motorcycle customization workbench.  
**Runtime:** Godot 4 / GDScript. **Canonical editable state:** versioned `BuildDocument`.  
**Last verified:** 2026-11-16 05:37 UTC  
**Verified main:** `4d2cf3b82bd78437541b49da46f522c06d2652b5`  
**Active dependency chain:** PR #28 → PR #29 → PR #30. PR #31 is an independent, unapproved AI feature proposal. No direct changes to `main`.

## Current live snapshot — 2026-11-16 05:37 UTC

- `main` remains at `4d2cf3b82bd78437541b49da46f522c06d2652b5`. No implementation writes were made to `main`.
- PR #28, [Android artifact verification and reproducible build path](https://github.com/metsam-mastem/Atomic-Z-Customi-Z/pull/28), is OPEN / READY FOR REVIEW, head `4bf83ef75d196b8a1259179b034632ebca2ca6bf`, based on current main. Exact-head workflow [#43810187315](https://github.com/metsam-mastem/Atomic-Z-Customi-Z/actions/runs/43810187315) PASS: Godot smoke, Python tests, Android Debug export, and Android Release export with an ephemeral CI keystore. Release signing values are injected only into a temporary project copy; the tracked export preset is not modified. Debug artifact ID `14200147053`, ZIP size 26,823,303 bytes, digest `sha256:6f0108e8de48c5db658cc450d4175cc943bc5a9fecdfa60d3ad0da9f75a2bf45`; expires 2026-11-30. The ephemeral Release APK is not a production release artifact.
- PR #29, [GLB surface catalog to BuildDocument integration](https://github.com/metsam-mastem/Atomic-Z-Customi-Z/pull/29), is OPEN / DRAFT, head `2325738c652733723412e2e1f7b91fd45e20d961`, stacked on PR #28. Exact-head workflow [#43807893732](https://github.com/metsam-mastem/Atomic-Z-Customi-Z/actions/runs/43807893732) PASS for Godot, Python and Android Debug export. It uses a synthetic scene fixture; PR #30 adds an additional imported glTF fixture test.
- PR #30, [Unify legacy neon profile migration with BuildDocument](https://github.com/metsam-mastem/Atomic-Z-Customi-Z/pull/30), is OPEN / DRAFT, head `7571d24f5bca2d6d8806c0a9ee0e7ba1c65a463d`, stacked on PR #29. Exact-head workflow [#43811283663](https://github.com/metsam-mastem/Atomic-Z-Customi-Z/actions/runs/43811283663) PASS for Godot import/smoke, canonical BuildDocument tests, legacy profile migration, first-launch 2026 identity hydration, imported glTF surface inventory, Python tests and Android Debug export. Debug artifact ID `14199943711`, ZIP size 26,850,374 bytes, digest `sha256:26c547ced6f7260d84a77859c3bf57dafe22fd7a8e39569e4be764d04f2f8c2c`; expires 2026-11-30.
- PR #30 retires the unused legacy profile writer and `NeonSkin.save_skin()`; migrates `user://skin_profile.json` only when no valid canonical BuildDocument exists; preserves the original file and unmapped 0..10 glow/pulse values in a versioned extension. Existing valid BuildDocuments take precedence and are not silently rewritten.
- PR #30 sets the default reference identity for new builds to Kawasaki Ninja ZX-25RR, model year 2026, variant ZX-25RR, with market explicitly null. Legacy ZX-25R identity is retained as migration provenance; its old 2D neon paths remain unverified and do not imply geometry or fitment compatibility. This identity is metadata only; it does not validate production geometry.
- PR #31, [Add free-first multi-model AI adapter foundation](https://github.com/metsam-mastem/Atomic-Z-Customi-Z/pull/31), is OPEN / DRAFT, head `d8a26a4a481d454d8a8c2c6e9503426ab5edff5f`, based on main. Exact-head workflow [#43809392394](https://github.com/metsam-mastem/Atomic-Z-Customi-Z/actions/runs/43809392394) passed generic Godot/Python/Android jobs, but there are no dedicated provider/network tests. Review comments identify missing product-scope approval, Android credential handling, hosted HTTPS enforcement, Android endpoint defaults and registry-driven model discovery. Treat as a prototype only; do not merge or enable in the product baseline without explicit owner acceptance and security/test work.
- Live open-issue search returned none.
- Repository branch protection and required-check enforcement remain UNVERIFIED; the integration cannot read the settings endpoint. Governance is documented but not confirmed as technically enforced.
- Physical Redmi installation/launch, touch, persistence, frame-time, memory and thermal QA: NOT RUN. Exact Redmi Note 13 Pro SKU remains unknown.
- Production ZX-25RR GLB/CAD, verified UV/surface registration, regional specification, mechanical fitment, structural validity, calibrated hardware mapping and road legality: NOT RUN. The model year and variant are selected; market remains unresolved.
- The current glTF fixture is a small two-surface test asset only; it is not a motorcycle asset or evidence of Kawasaki geometry.



## Resume rule

This file is the operational starting point, not a substitute for live verification. A new contributor or a new chat must:
1. Read `AGENTS.md`, this file, `docs/CONTEXT_INTEGRITY_PROTOCOL.md`, `docs/UNIFIED_SYSTEM_SPEC.md`, `docs/AGENT_GOVERNANCE.md`, `docs/ROADMAP.md` and `docs/RESEARCH_AND_DECISIONS.md`.
2. Fetch the latest `main` SHA and re-check open PRs, issues, branches and CI. This checkpoint is a dated snapshot, never assumed current.
3. Treat repository files, merged commits, approved decisions and CI results tied to exact commits as project memory. Conversation history is optional background only.
4. Before finishing a task, update this checkpoint in the same PR or a dedicated docs PR with the resulting commit, tests, status changes, open work, decisions and next action.
5. If context is incomplete, stop and reconstruct from GitHub. Never invent missing decisions or claim that an unrecorded conversation is authoritative.

## Product identity and constraints

- One integrated product, not multiple companion apps or parallel subsystems.
- Android-first Godot 4 / GDScript; Compatibility renderer is the baseline.
- One application lifecycle, active vehicle/build context, navigation flow and persistence/export path.
- One versioned `BuildDocument` is the only authoritative editable build state.
- Preferred model interchange: glTF 2.0 / GLB, authored/validated through Blender.
- Current vehicle reference: Kawasaki Ninja ZX-25RR model year 2026, variant ZX-25RR; market is not selected. Production geometry, fitment and engineering validity remain evidence-gated.
- ZX-25R and ZX-25RR are not interchangeable without authoritative evidence.
- Procedural geometry is placeholder geometry, not factory CAD or engineering validation.
- Python/Tkinter and ModernGL are research/developer references, not alternate product runtimes.
- Keep unrelated JARYAN projects outside this repository.

## Verified repository baseline

- `main` is at `9780969ac432758f78f0928fab73e4e979aa1891`.
- This is merge commit for PR #17, “[Governance] Refresh canonical resume checkpoint after PR 16”, merged on 2026-11-16 at 03:19 UTC. PR #17 is closed and merged.
- PASS — exact source commit `9780969...` was exercised by Godot CI workflow [#43797564422](https://github.com/metsam-mastem/Atomic-Z-Customi-Z/actions/runs/43797564422): Godot smoke, Python simulator tests and Android Debug export all completed successfully. The workflow was triggered from the quality branch at the same exact commit SHA, not by a `main` push event.
- PASS — PR #20 head `39241192c66077e7e1daa82d65ad47680bd9e30b`: Godot import, smoke, neon runtime, BuildDocument contract, surface binder ownership test and HUD hydration test; Python simulator tests; Android Debug APK export, package metadata and signature verification. Exact PR workflow [#43796301513](https://github.com/metsam-mastem/Atomic-Z-Customi-Z/actions/runs/43796301513) completed with all three jobs successful.
- PASS — PR #21 head `e42f083b77481aa48f40bbbee21a2be02dc819bb`: Godot, Python and Android Debug export jobs all passed in exact-head workflow [#43795781816](https://github.com/metsam-mastem/Atomic-Z-Customi-Z/actions/runs/43795781816). The PR remains stacked on PR #20 and is not merged.
- PASS — PR #23 head `e58aaa388f66d4f862e185d040fd83a19c839746`: Godot import/smoke/contract tests, Python simulator tests, Android Debug APK export, package metadata and signature checks all passed in exact-head workflow [#43797749406](https://github.com/metsam-mastem/Atomic-Z-Customi-Z/actions/runs/43797749406).
- CLOSED / NOT MERGED — PR #22 was a parallel duplicate of PR #23 and was closed to leave one active adaptive-quality implementation path. Its head `f41205d40dd22a424618f794fe0bfd62bb79a5eb` independently passed all three CI jobs, including Android export, in [#43797651440](https://github.com/metsam-mastem/Atomic-Z-Customi-Z/actions/runs/43797651440). Its additional ideas (diagnostic getters/signal and long-pause sampling guard) were documented as suggestions on PR #23; no code from PR #22 was merged.
- PR #20 is open, non-draft and reported mergeable/clean by GitHub, but its recorded base SHA is `dccd4020f9feef522b94b36bf2b326380d6e7af1`, behind current `main`. Re-check/update its base before merge.
- PR #21 is open/draft and stacked on PR #20. GitHub currently reports its mergeability as dirty; reconcile conflicts after PR #20 is integrated.
- Physical Redmi installation and runtime QA: NOT RUN.
- Production Kawasaki ZX-25RR geometry, verified UV/surface registration, mechanical fitment, structural/thermal validation and calibrated hardware mapping: NOT RUN.
- Earlier merged work includes PR #2 (charter/workflow/catalog/manifesto/docs), #3 (BuildDocument contract), #4 (Neon profile store), #6 (research audit), #9 (context integrity), #10 (part paint/safe persistence), #12 (Android export preflight/signature verification), #14 (visual asset/charter handoff), #16 (chat-independent continuity) and #17 (canonical project checkpoint).

## Historical open-pull-request snapshot — 2026-11-16 03:24 UTC (superseded)

| PR | Scope | Current state | Next action |
|---|---|---|---|
| #20 | Safe surface-material binder and BuildDocument-driven neon HUD hydration | OPEN / READY FOR REVIEW; exact-head CI run #43796301513 passed; GitHub reports clean, but base SHA is behind current main | Independently review; update/reconcile with current main; merge only through normal review |
| #21 | Retire parallel neon profile persistence and migrate legacy profile into BuildDocument | OPEN / DRAFT; stacked on PR #20; exact-head CI run #43795781816 passed; GitHub currently reports dirty | Wait for #20 integration, then rebase/reconcile; preserve source legacy user data |
| #23 | Deterministic adaptive shadow-quality hysteresis and smoke regression test | OPEN / DRAFT; current base main SHA; exact-head CI run #43797749406 passed; GitHub reports clean | Review logic and decide whether to include diagnostic getters/telemetry and long-pause guard noted in PR comments |

PR #22 is closed without merge as a duplicate of #23. PRs #7, #8, #11, #18 and #19 are closed (superseded or diagnostic-only). PRs #2, #3, #4, #6, #9, #10, #12, #14, #16 and #17 are merged. Refresh all statuses before acting.

## Historical open-issue snapshot — 2026-11-16 03:24 UTC (superseded)

- Issue #1: “[Architecture] Deliver the unified Atomic-Z-Customi-Z system”.
- Issue #5: “[Research] Verify external engineering sources and sequence safe integration”.

Both issues were confirmed open; inspect comments/labels again before selecting work.

## Current evidence and release gaps

| Area | Status | Evidence / limitation |
|---|---|---|
| Canonical BuildDocument baseline | PASS | PR #3 merged; current contract and migrations still require exact-head regression tests |
| Part-isolated paint and safe persistence | PASS | PR #10 merged; backup/recovery behavior covered in CI |
| Main commit import/smoke/Python/Android CI | PASS | Exact source SHA `9780969...`, run #43797564422 (triggered from a branch at the same SHA) |
| Integrated garage, neon and BuildDocument contract tests | PASS on PR head | PR #20 run #43796301513; PR review/base reconciliation pending |
| Surface binder ownership contract test | PASS on PR head | PR #20 run #43796301513; still a prototype, not connected to a verified production GLB |
| Neon HUD state hydration | PASS on PR head | PR #20 run #43796301513; PR review/base reconciliation pending |
| Legacy profile migration and BuildDocument-only neon persistence | PASS on PR head | PR #21 run #43795781816; PR remains stacked/draft and dirty |
| Adaptive shadow-quality hysteresis | PASS on PR head | PR #23 run #43797749406; only key-light shadows are controlled |
| Android Debug APK export, package metadata and signature | PASS on PR heads | Exact PR runs #43796301513, #43795781816 and #43797749406; this is CI evidence, not physical-device QA |
| Production ZX-25RR GLB/CAD and provenance | NOT RUN | Current runtime geometry is procedural placeholder |
| Verified part IDs/pivots/material slots/UVs for production asset | NOT RUN | Surface binder prototype has no verified target asset |
| Physical Redmi installation/launch and touch review | NOT RUN | Requires exact target device |
| Android sustained FPS/frame-time/memory/thermal profiling | NOT RUN | Record exact phone SKU, SoC/GPU, RAM and Android version first |
| Mechanical fitment, collision/interference, mass properties, structural/thermal/CFD and road legality | NOT RUN | Requires authoritative inputs, defined methods and specialist validation |
| Calibrated LED/controller mapping | NOT RUN | Disabled until a controller and LED profile is calibrated and evidenced |

## Repository governance enforcement

- Repository policy requires task branches and reviewed PRs; no direct-main writes, force pushes or self-merges.
- The previous checkpoint recorded `main` as unprotected. A fresh branch-protection API read during this refresh returned 403 (Resource not accessible by integration), so current technical enforcement is **UNVERIFIED**. The repository owner must inspect Settings → Branches / Rulesets and configure required reviews/checks.
- Do not claim required checks or reviews are enforced until repository settings confirm it.

## Historical priority next actions (superseded by current live snapshot)

1. Independently review PR #20 and reconcile its base from `dccd402...` to current `main` before any merge decision.
2. Review PR #23; consider whether the diagnostics and app-resume sampling guard suggested in the PR discussion improve the proposed controller without expanding beyond measured evidence.
3. After PR #20 is integrated, reconcile PR #21's stacked base and dirty merge state; verify BuildDocument remains the only writable customization store and original legacy data remains preserved.
4. Integrate the surface binder with the imported-asset manifest and canonical BuildDocument material records after the surface-ID/schema contract is reviewed.
5. Obtain a licensed, provenance-tracked ZX-25RR model for a declared year/market, then validate part IDs, pivots, material slots, coordinate frame and UV/surface mapping.
6. Run physical Redmi QA and record exact device identity, install/launch, touch, persistence, frame time, memory and thermals.
7. Owner: verify/configure GitHub branch protection and required checks; current integration permissions did not allow a fresh API read.
8. Update this checkpoint after each meaningful merge or material status change.

## Decision and change control

- Accepted architecture decisions live in `docs/RESEARCH_AND_DECISIONS.md` and `docs/UNIFIED_SYSTEM_SPEC.md`.
- New product direction or unresolved ZX-25RR/year/market decisions require explicit product-owner approval; agents may propose but must not silently accept them.
- Keep changes on a dedicated task branch and reviewed PR. No direct-main writes, force-push, self-merge or bypass of required checks.
- Status vocabulary: PASS / FAIL / NOT RUN / BLOCKED. Every PASS must point to fresh evidence for the exact commit.
- This checkpoint is the portable handoff. Do not depend on this chat, old chats, saved memory or an AI-generated recap.


## Current next action — PR #28

1. Wait for exact-head Godot/Python/Android CI and inspect logs if any job fails.
2. Review the APK verifier against the actual CI-produced artifact; fix any mismatch before merge.
3. Merge PR #28 only after review and green required checks.
4. Publish a durable, versioned GitHub Release artifact only after release signing and device acceptance are approved.
5. Run physical Redmi Note 13 Pro installation/launch and interaction QA; record the exact device SKU and APK SHA.


## Live integration checkpoint — 2026-11-16 (release-path reconciliation)

- Main remains unchanged at `4d2cf3b82bd78437541b49da46f522c06d2652b5`. No PR has been merged and no direct-main write was made.
- PR #28 remains OPEN / READY FOR REVIEW at `4bf83ef75d196b8a1259179b034632ebca2ca6bf`. Exact-head workflow [#43810187315](https://github.com/metsam-mastem/Atomic-Z-Customi-Z/actions/runs/43810187315) PASS: Godot smoke, Python tests, Android Debug export and Android Release export with an ephemeral CI keystore. This does not create a production-signed release.
- PR #29 remains OPEN / DRAFT. Its branch now contains a two-parent integration commit `0795b86eff0f8041366a33989cd307851d64800f` whose parents are the prior PR #29 head and latest PR #28 head. This carries the verified temporary release-preset injection, its unit tests and the release CI path into the GLB catalog work. The exact-head workflow [#43812665434](https://github.com/metsam-mastem/Atomic-Z-Customi-Z/actions/runs/43812665434) was QUEUED at checkpoint time; do not claim PASS until completed.
- PR #30 remains OPEN / DRAFT. Its branch now contains two-parent integration commit `2563e654fdd399d0ee29065f4dca62a22671741e`, combining the prior PR #30 work with the reconciled PR #29 head. It carries the same release-signing fix and combined GLB integration test workflow. Exact-head workflow [#43812702829](https://github.com/metsam-mastem/Atomic-Z-Customi-Z/actions/runs/43812702829) was QUEUED at checkpoint time; do not claim PASS until completed.
- The release-path discrepancy was verified and corrected in the PR chain: PR #28's latest `scripts/build_android.sh` uses an isolated temporary project copy and `scripts/configure_android_release_preset.py`; the tracked `export_presets.cfg` is not mutated. The fix and its tests are now present on PR #29 and PR #30 branches.
- PR #31, the independent Draft AI adapter proposal, remains outside this release task and is not part of the product release baseline.
- Commercial release blockers: production ZX-25RR GLB/CAD and verified UV/surface mapping are MISSING; market is unset; physical Redmi Note 13 Pro SKU/device QA is NOT RUN; owner-controlled production keystore is NOT PROVIDED; repository LICENSE file is MISSING; legal/trademark and distribution review are NOT RUN. CI ephemeral signing is test-only. The current APK is a debug artifact, not a commercial release.
- Next sequence: wait for exact-head PR #29/#30 CI; review and merge PR #28 → #29 → #30 only through normal owner review; then obtain production asset provenance/license, market decision, owner-managed signing secrets and device acceptance evidence before tagging a release.
