# Project Status — Canonical Resume Checkpoint

**Purpose:** Resume work without relying on any ChatGPT conversation, account memory, or individual agent context.
**Repository:** `metsam-mastem/Atomic-Z-Customi-Z`
**Product:** Atomic-Z-Customi-Z — one integrated Android-first motorcycle customization workbench.
**Runtime:** Godot 4 / GDScript. **Canonical editable state:** versioned `BuildDocument`.
**Last verified:** 2026-11-16 02:33 UTC
**Checkpoint base:** `dccd4020f9feef522b94b36bf2b326380d6e7af1`

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

- `main` at checkpoint: `dccd4020f9feef522b94b36bf2b326380d6e7af1`.
- Latest merge at checkpoint: PR #16, “Make project continuity independent of chat history”.
- PR #16 merged successfully by squash; merge commit equals the main SHA above. PR #16 adds this canonical checkpoint, mandatory chat-independent handoff rules, and direct README entry points. PR #12 remains the latest Android export implementation change.
- PR #16 head CI: `android-debug-export` PASS, `neon-simulator-tests` PASS, `smoke-test` PASS (workflow run [43792862879](https://github.com/metsam-mastem/Atomic-Z-Customi-Z/actions/runs/43792862879)). The post-merge `main` workflow for `dccd402...` was still running at checkpoint refresh; re-check it before relying on main CI.
- These are GitHub CI results only. Physical Redmi installation and runtime QA: NOT RUN.
- Earlier merged work includes PR #3 (BuildDocument contract), #4 (Neon profile store), #6 (research audit), #9 (context integrity), and #10 (part paint / safe persistence).
- PR #12 corrects Android export preflight, configures debug signing in CI and verifies APK metadata/signature. Do not infer physical-device acceptance from CI export.

## Open pull requests at checkpoint

| PR | Scope | State at checkpoint | Next action |
|---|---|---|---|
| #7 | GLB surface/material binding and mobile rendering guidance | OPEN / DRAFT; previously reported merge conflict; focused binder test and end-to-end integration NOT RUN | Keep unmerged until conflict is reconciled, focused test is wired into CI and passes, and integration/data-contract ownership approves |
| #11 | Older Android export diagnostic workflow change | OPEN; older than merged #10/#12 export fixes | Compare diff with current main; if redundant, close as superseded with a clear explanation; do not merge blindly |

PR #8 was closed without merge. PR #12 and PR #16 are merged. Always refresh these states from GitHub before acting.

## Open issues at checkpoint

- Issue #1: “[Architecture] Deliver the unified Atomic-Z-Customi-Z system”.
- Issue #5: “[Research] Verify external engineering sources and sequence safe integration”.

Re-fetch both and inspect comments/labels before selecting work.

## Current evidence and release gaps

| Area | Status | Evidence / limitation |
|---|---|---|
| BuildDocument baseline | PASS | PR #3 merged; validate exact current implementation before schema changes |
| Part paint and safe persistence | PASS on recorded CI | PR #10 merged; CI history includes round-trip and backup/recovery tests |
| Android Debug CI export | PASS on PR #16 head; main recheck pending | PR #16 head run #43792862879 passed; post-merge main run must be rechecked |
| Smoke test | PASS on PR #16 head | Run #43792862879; post-merge main recheck pending |
| Neon simulator tests | PASS on PR #16 head | Run #43792862879; post-merge main recheck pending |
| Physical Redmi installation/launch | NOT RUN | Requires target device test |
| Production ZX-25RR GLB/CAD | NOT RUN | Current geometry is placeholder |
| Verified UV/surface mapping | NOT RUN | Do not claim body-aligned graphics |
| Android performance/thermal profile | NOT RUN | Record exact device SKU/SoC/RAM/Android first |
| Mechanical fitment / structural / road legality | NOT RUN | Requires authoritative data and specialist validation |

## Priority next actions

1. Refresh live GitHub state and confirm post-merge CI on `dccd402...`; do not rely on the dated PR/issue list above.
2. Review PR #11 against merged Android export work and close it as superseded if no unique value remains.
3. Reconcile PR #7 only after reading the current diff and resolving the reported conflict; require its focused test in pinned Godot CI before merge.
4. Continue the integrated garage vertical slice against the canonical BuildDocument; avoid parallel stores or editors.
5. Obtain a licensed, provenance-tracked ZX-25RR model for a declared year/market, then validate part IDs, pivots, materials and UV/surface mapping.
6. Run physical Redmi QA and record device identity, install/launch, touch, persistence, frame time, memory and thermals.
7. Update this file after every meaningful merged task.

## Decision and change control

- Accepted architecture decisions live in `docs/RESEARCH_AND_DECISIONS.md` and `docs/UNIFIED_SYSTEM_SPEC.md`.
- New product direction or unresolved ZX-25RR/year/market decisions require explicit product-owner approval; agents may propose but must not silently accept them.
- Keep changes on a dedicated branch and PR. No direct writes to `main`, no force-push, no self-merge and no bypass of required checks.
- Status vocabulary: PASS / FAIL / NOT RUN / BLOCKED. Every PASS must point to fresh evidence for the exact commit.
- This checkpoint is the portable handoff. Do not depend on the current chat, old chats, saved memory or an AI-generated recap.
