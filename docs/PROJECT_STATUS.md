# Project Status — Canonical Resume Checkpoint

**Purpose:** Resume work without relying on any ChatGPT conversation, account memory, or individual agent context.
**Repository:** `metsam-mastem/Atomic-Z-Customi-Z`
**Product:** Atomic-Z-Customi-Z — one integrated Android-first motorcycle customization workbench.
**Runtime:** Godot 4 / GDScript. **Canonical editable state:** versioned `BuildDocument`.
**Last verified:** 2026-11-16 02:50 UTC
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
- PASS — exact main commit `dccd402...` CI: Android Debug Export, Neon Simulator Tests and Smoke Test; workflow [#43794305180](https://github.com/metsam-mastem/Atomic-Z-Customi-Z/actions/runs/43794305180).
- PASS — PR #19 head `7c90e639741d30cb3a57f1b4bc1d3ad7acd745e4`: Godot tests, Python neon tests and Android Debug APK export/signature verification; workflow [#43793453211](https://github.com/metsam-mastem/Atomic-Z-Customi-Z/actions/runs/43793453211). PR remains open and requires review/merge.
- PASS — latest PR #7 head `da8429568074ccb275e08a5a71ab7a2b8a9bcd79` CI run [#43794347731](https://github.com/metsam-mastem/Atomic-Z-Customi-Z/actions/runs/43794347731); this does not by itself prove full GLB surface integration or physical-device rendering.
- FAIL — PR #18 CI runs on its current head `922b140edbc616f33c039769ca58c5d7ffe5be23`; runs [#43793397539](https://github.com/metsam-mastem/Atomic-Z-Customi-Z/actions/runs/43793397539) and [#43793392380](https://github.com/metsam-mastem/Atomic-Z-Customi-Z/actions/runs/43793392380) concluded failure. Inspect job logs and correct before treating the binder ownership guard as accepted.
- Physical Redmi installation and runtime QA: NOT RUN.
- Earlier merged work includes PR #3 (BuildDocument contract), #4 (Neon profile store), #6 (research audit), #9 (context integrity), #10 (part paint/safe persistence), #12 (Android export preflight/signature verification), #14 (project charter/visual asset handoff) and #16 (chat-independent continuity).

## Open pull requests — live refresh 2026-11-16 02:50 UTC

| PR | Scope | Current state | Next action |
|---|---|---|---|
| #19 | Hydrate neon HUD controls from canonical BuildDocument | OPEN; all three CI jobs PASS on head | Review and merge only after code review; physical-device QA remains separate |
| #18 | Guard external surface material ownership; stacked on #7 | OPEN / DRAFT; current CI FAIL | Inspect failing jobs/logs, fix and rerun exact-head CI; retain #7 dependency |
| #17 | Refresh this canonical resume checkpoint | OPEN; documentation-only; mergeable | Review and merge this checkpoint update |
| #11 | Older Android export diagnostic workflow | OPEN | Compare against merged #10/#12; close as superseded if no unique value remains |
| #7 | GLB surface/material binding and mobile rendering guidance | OPEN / DRAFT; latest branch CI PASS | Review current diff and dependency on #18; require focused binder test and end-to-end GLB integration evidence before merge |

PR #8 was closed without merge. PR #10, #12, #14 and #16 are merged. Always refresh states before acting.

## Open issues — live refresh 2026-11-16 02:50 UTC

- Issue #1: “[Architecture] Deliver the unified Atomic-Z-Customi-Z system”.
- Issue #5: “[Research] Verify external engineering sources and sequence safe integration”.

Re-fetch both and inspect comments/labels before selecting work.

## Current evidence and release gaps

| Area | Status | Evidence / limitation |
|---|---|---|
| BuildDocument baseline | PASS | PR #3 merged; validate exact current implementation before schema changes |
| Part paint and safe persistence | PASS | PR #10 merged; backup/recovery tests recorded in CI |
| Android Debug CI export | PASS | Main commit `dccd402...`, run #43794305180 |
| Smoke test | PASS | Same exact-main workflow run |
| Neon simulator tests | PASS | Same exact-main workflow run |
| Neon HUD saved-control hydration | PASS on PR head | PR #19 run #43793453211; PR review/merge pending |
| External surface binder ownership guard | FAIL / NOT ACCEPTED | PR #18 latest CI failed; inspect logs and rerun |
| GLB material/surface integration | NOT RUN | PR #7/#18 still open; real asset integration and end-to-end acceptance unproven |
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

1. Review and merge PR #17 so this refreshed checkpoint becomes part of `main`.
2. Review PR #19; merge only after code review (CI already PASS on its exact head).
3. Diagnose and fix PR #18 CI failures before accepting the surface binder ownership guard; coordinate with parent PR #7.
4. Review PR #7 and prove focused binder tests plus end-to-end GLB surface/material behavior; do not infer integration from CI alone.
5. Compare PR #11 with merged Android export work and close as superseded if redundant.
6. Continue the integrated garage vertical slice against the canonical BuildDocument; avoid parallel stores or editors.
7. Obtain a licensed, provenance-tracked ZX-25RR model for a declared year/market, then validate part IDs, pivots, materials and UV/surface mapping.
8. Run physical Redmi QA and record device identity, install/launch, touch, persistence, frame time, memory and thermals.
9. Update this file after every meaningful merged task.

## Decision and change control

- Accepted architecture decisions live in `docs/RESEARCH_AND_DECISIONS.md` and `docs/UNIFIED_SYSTEM_SPEC.md`.
- New product direction or unresolved ZX-25RR/year/market decisions require explicit product-owner approval; agents may propose but must not silently accept them.
- Keep changes on a dedicated branch and PR. No direct writes to `main`, no force-push, no self-merge and no bypass of required checks.
- Status vocabulary: PASS / FAIL / NOT RUN / BLOCKED. Every PASS must point to fresh evidence for the exact commit.
- This checkpoint is the portable handoff. Do not depend on this chat, old chats, saved memory or an AI-generated recap.
