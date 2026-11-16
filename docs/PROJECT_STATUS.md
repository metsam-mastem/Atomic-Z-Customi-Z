# Project Status — Canonical Resume Checkpoint

**Purpose:** Resume work without relying on any ChatGPT conversation, account memory, or individual agent context.
**Repository:** `metsam-mastem/Atomic-Z-Customi-Z`
**Product:** Atomic-Z-Customi-Z — one integrated Android-first motorcycle customization workbench.
**Runtime:** Godot 4 / GDScript. **Canonical editable state:** versioned `BuildDocument`.
**Last verified:** 2026-11-16 03:11 UTC
**Verified main:** `dccd4020f9feef522b94b36bf2b326380d6e7af1`
**Checkpoint update branch:** `agent/governance/refresh-resume-checkpoint-after-pr16` (PR #17; documentation-only update)

## Resume rule

This file is the operational starting point, not a substitute for live verification. A new contributor or a new chat must:
1. Read `AGENTS.md`, this file, `docs/CONTEXT_INTEGRITY_PROTOCOL.md`, `docs/UNIFIED_SYSTEM_SPEC.md`, `docs/AGENT_GOVERNANCE.md`, `docs/ROADMAP.md` and `docs/RESEARCH_AND_DECISIONS.md`.
2. Fetch the latest `main` SHA and re-check open PRs, issues, branches and CI. This checkpoint is a dated snapshot, never assumed current.
3. Treat repository files, merged commits, approved decisions and exact-commit CI evidence as project memory. Conversation history is optional background only.
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

- `main`: `dccd4020f9feef522b94b36bf2b326380d6e7af1`.
- Latest merge: PR #16, “Make project continuity independent of chat history”.
- PR #16 is merged. It adds this canonical checkpoint, mandatory chat-independent handoff rules in `AGENTS.md`, and README entry points.
- PASS — exact main commit `dccd...` CI: Android Debug Export, Neon Simulator Tests and Smoke Test; workflow [#43793273703](https://github.com/metsam-mastem/Atomic-Z-Customi-Z/actions/runs/43793273703).
- PASS — consolidated PR #20 head `39241192c66077e7e1daa82d65ad47680bd9e30b`: Godot import, smoke, neon runtime, BuildDocument contract, surface binder ownership test and HUD hydration test; Python simulator tests; Android Debug APK export, package metadata and signature verification. Exact PR workflow [#43795128113](https://github.com/metsam-mastem/Atomic-Z-Customi-Z/actions/runs/43795128113) completed with all three jobs successful.
- PASS — companion push workflow [#43795120047](https://github.com/metsam-mastem/Atomic-Z-Customi-Z/actions/runs/43795120047) uploaded `atomic-z-android-debug` (26,815,218 bytes; SHA-256 `c3e2bb430e225148f47ec9484591790b2fdfc67ab2bbc6205444d36cba97f833`).
- PR #20 is ready for review and mergeable, but remains unmerged. No self-merge or bypass of review is permitted.
- PRs #7, #11, #18 and #19 were closed as superseded by PR #20. Their compatible binder, rendering guidance, verbose export diagnostics and HUD hydration changes were consolidated into the single main-based PR.
- Physical Redmi installation and runtime QA: NOT RUN.
- Earlier merged work includes PR #3 (BuildDocument contract), #4 (Neon profile store), #6 (research audit), #9 (context integrity), #10 (part paint/safe persistence), #12 (Android export preflight/signature verification), #14 (project charter/visual asset handoff) and #16 (chat-independent continuity).

## Open pull requests — live refresh 2026-11-16 03:11 UTC

| PR | Scope | Current state | Next action |
|---|---|---|---|
| #20 | Unified safe surface-material prototype and BuildDocument-driven neon HUD hydration | OPEN / READY FOR REVIEW; exact-head CI run #43796301513 completed successfully; mergeable | Independent code review; merge only through normal review process; physical-device QA remains separate |
| #21 | Retire parallel neon profile persistence and migrate legacy profile into BuildDocument | OPEN / DRAFT; stacked on PR #20; exact PR-head CI run #43795781816 completed successfully | Do not retarget/merge before PR #20; review migration semantics and preserve legacy user data |
| #17 | Refresh this canonical resume checkpoint | OPEN; documentation-only; exact-head CI run #43795689102 completed successfully | Review and merge this checkpoint update |

PRs #7, #8, #11, #18 and #19 are closed (superseded or diagnostic-only). PR #10, #12, #14 and #16 are merged. Re-fetch all PRs and CI before acting.

## Open issues — live refresh 2026-11-16 03:11 UTC

- Issue #1: “[Architecture] Deliver the unified Atomic-Z-Customi-Z system”.
- Issue #5: “[Research] Verify external engineering sources and sequence safe integration”.

Re-fetch both and inspect comments/labels before selecting work.

## Current evidence and release gaps

| Area | Status | Evidence / limitation |
|---|---|---|
| BuildDocument baseline | PASS | PR #3 merged; validate exact current implementation before schema changes |
| Part paint and safe persistence | PASS | PR #10 merged; backup/recovery tests recorded in CI |
| Main Android Debug CI export | PASS | Main commit `dccd402...`, run #43793273703 |
| Integrated garage smoke, neon and BuildDocument contract tests | PASS | PR #20 exact head, run #43795128113 |
| Surface binder ownership contract test | PASS on PR head | PR #20 run #43795128113; prototype is not yet connected to a verified production GLB asset |
| Neon HUD state hydration | PASS on PR head | PR #20 run #43796301513; PR review/merge pending |
| Python neon simulator tests | PASS | PR #20 exact head, run #43796301513 |
| Android Debug APK export, package metadata and signature | PASS on PR head | PR #20 exact head, run #43796301513; prior artifact upload confirmed by run #43795120047 |
| Legacy Neon profile migration to BuildDocument | PASS on PR #21 head | PR #21 exact head, run #43795781816; PR is stacked on #20 and remains draft |\n| GLB production asset/material integration | NOT RUN | No verified, provenance-tracked ZX-25RR model imported into the garage yet |
| Physical Redmi installation/launch | NOT RUN | Requires target device test |
| Production ZX-25RR GLB/CAD | NOT RUN | Current geometry remains placeholder |
| Verified UV/surface mapping | NOT RUN | Do not claim body-aligned graphics |
| Android performance/thermal profile | NOT RUN | Record exact device SKU/SoC/RAM/Android first |
| Mechanical fitment / structural / road legality | NOT RUN | Requires authoritative data and specialist validation |

## Repository governance enforcement

- The repository policy requires task branches and reviewed PRs; no direct-main writes, force pushes or self-merges.
- Live branch listing showed `main` as **not protected**. Branch protection / required-review enforcement is therefore NOT ENFORCED at GitHub settings level in this snapshot. The written policy is active, but technical enforcement needs owner configuration.
- Do not claim required checks or reviews are enforced until the repository settings confirm it.

## Priority next actions

1. Review and merge PR #17 so this current portable checkpoint is committed to `main`.
2. Complete independent code review of PR #20; merge only through normal review, then refresh PR #21's base and reconcile its stack.
3. Review PR #21's migration/data-preservation semantics and ensure only the canonical BuildDocument remains writable.
4. Integrate the surface binder with the imported-asset manifest and canonical BuildDocument material records after the surface-ID/schema contract is reviewed.
5. Obtain a licensed, provenance-tracked ZX-25RR model for a declared year/market, then validate part IDs, pivots, material slots, coordinate frame and UV/surface mapping.
6. Run physical Redmi QA and record exact device identity, install/launch, touch, persistence, frame time, memory and thermals.
7. Configure GitHub branch protection and required checks. Current `main` remains unprotected; the documented policy is not technically enforced.
8. Update this file after every meaningful merged task.

## Decision and change control

- Accepted architecture decisions live in `docs/RESEARCH_AND_DECISIONS.md` and `docs/UNIFIED_SYSTEM_SPEC.md`.
- New product direction or unresolved ZX-25RR/year/market decisions require explicit product-owner approval; agents may propose but must not silently accept them.
- Keep changes on a dedicated branch and PR. No direct writes to `main`, no force-push, no self-merge and no bypass of required checks.
- Status vocabulary: PASS / FAIL / NOT RUN / BLOCKED. Every PASS must point to fresh evidence for the exact commit.
- This checkpoint is the portable handoff. Do not depend on this chat, old chats, saved memory or an AI-generated recap.
