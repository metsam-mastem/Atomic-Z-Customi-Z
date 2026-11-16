# Project Status — Canonical Resume Checkpoint

**Purpose:** Resume work without relying on any ChatGPT conversation, account memory, or individual agent context.  
**Repository:** `metsam-mastem/Atomic-Z-Customi-Z`  
**Product:** Atomic-Z-Customi-Z — one integrated Android-first motorcycle customization workbench.  
**Runtime:** Godot 4 / GDScript. **Canonical editable state:** versioned `BuildDocument`.  
**Last verified:** 2026-11-16 09:35 UTC
**Verified main:** `0f0f419b2d561e1180720c13a55f4a707af3856b`  
**Current release track:** P1 integrated garage; research vault and optional AI remain separate workstreams.

## Current live snapshot — 2026-11-16 09:35 UTC

- Main SHA: `0f0f419b2d561e1180720c13a55f4a707af3856b`.
- Merged PR #28 — Android reproducible build and artifact verification.
- Merged PR #39 — revert of unintended Android ContentUri plugin residue.
- Merged PR #42 — Customi-Z Core v0.4 integration audit (documentation only).
- Merged PR #43 — GLB surface catalog, canonical BuildDocument validation, PBR-preserving surface binder and exact Godot CI test.
- Merged PR #45 — Neon legacy migration into BuildDocument, retirement of the parallel profile store, P1 one-finger orbit/two-finger pan/pinch gestures. Exact-head CI run [#43838993070](https://github.com/metsam-mastem/Atomic-Z-Customi-Z/actions/runs/43838993070): smoke/GLB/Neon/UI hydration, simulator and Android Debug/Release export jobs all PASS.
- Merged PR #46 — research source vault. Exact-head CI run [#43839645819](https://github.com/metsam-mastem/Atomic-Z-Customi-Z/actions/runs/43839645819): registry contract tests, helper shell syntax, Godot smoke/contract, Python simulator and Android Debug/Release export all PASS. Registry contains 23 unique source IDs, 16 immutable 40-character commit pins and six licence-identified sparse checkout entries.
- PR #50 — refreshed project-status/roadmap checkpoint (OPEN; exact-head CI queued).
- PR #52 — project-management operating plan (OPEN; docs only; exact-head checks are still queued).
- PR #53 — optional in-garage free-first AI assistant (OPEN; exact head `7691e713b8ff6f0d5f7993a05595f6723da956ed`). It lazy-loads only after the user presses AI ASSIST, uses a shared provider registry, requires HTTPS for hosted endpoints, blocks Android cleartext pending device verification, disables Android hosted API keys, and verifies INTERNET permission in the exported APK. Exact-head Godot/Python/Android CI is QUEUED; merge only after all checks pass. Physical Android network QA and live provider integration remain NOT RUN.
- PR #51 — closed without merge as a superseded duplicate of PR #53; its initial CI workflow syntax issue was corrected in the replacement branch.
- Open issue #47 — P2 GLB runtime import and Android content-URI plugin. PR #38 was closed after exact-head Android export failure; plugin descriptor/AAR/template and project configuration must be resolved before implementation resumes.
- Open issue #49 — safe optional multi-model AI assistant integration; implementation is tracked in PR #53. The unsafe prototype PR #31 is closed without merge.
- Open issue #54 — P1 Redmi Note 13 Pro device acceptance and production signing. CI Release currently uses an ephemeral key; physical install/touch/performance/thermal tests and owner production signing remain NOT RUN.
- Superseded stacked PRs #29, #30, #37 and #44 are closed. Their approved code was selectively transplanted into #43/#45; do not reopen those branches.
- CI-generated Android artifacts are Debug/test exports. Production signing, Play Store readiness and commercial release approval are NOT RUN.
- Physical Redmi Note 13 Pro install/launch, real touch interaction, pause/resume, persistence, performance and thermal QA: NOT RUN.
- Production Kawasaki geometry, provenance-verified GLB, UV mapping, factory fitment and engineering validation: NOT RUN.
- Independent GitHub approval by a second reviewer is NOT recorded. CI success is not a substitute for human review.

## Integration rules

- One product runtime: Godot 4 / GDScript. One authoritative editable state: BuildDocument.
- No parallel writable Neon/profile store. Legacy inputs are migration-only and preserved; they are not ongoing write targets.
- P1 release scope: garage, part selection, paint/material, Neon, canonical save/load and touch camera. Keep AI and native Android content-URI import outside this release gate.
- P2 asset import must use a complete, version-matched, reproducible Godot Android plugin only if built-in file import is insufficient.
- Every source change uses a branch and PR. Require exact-head CI and file ownership review; never bypass failed checks.
- Status vocabulary: PASS / FAIL / NOT RUN / BLOCKED. Do not claim physical-device acceptance from CI exports.
- Do not merge independent research or AI workstreams into the product runtime without an explicit architecture decision.

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
- Current vehicle target: Kawasaki Ninja ZX-25RR; exact year, market, variant and geometry remain evidence-gated.
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


## Historical next action — PR #28 (superseded by merged build-hardening work)

1. Wait for exact-head Godot/Python/Android CI and inspect logs if any job fails.
2. Review the APK verifier against the actual CI-produced artifact; fix any mismatch before merge.
3. Merge PR #28 only after review and green required checks.
4. Publish a durable, versioned GitHub Release artifact only after release signing and device acceptance are approved.
5. Run physical Redmi Note 13 Pro installation/launch and interaction QA; record the exact device SKU and APK SHA.
