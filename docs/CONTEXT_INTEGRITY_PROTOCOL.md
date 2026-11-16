# Project Context Integrity Protocol

**Status:** Active governance document  
**Reconciled:** 2026-11-16  
**Repository:** https://github.com/metsam-mastem/Atomic-Z-Customi-Z  
**Product:** Atomic-Z-Customi-Z — Unified Motorcycle Customization Workbench

## 1. Purpose

This document is the repository-level control for keeping project identity, decisions, architecture, evidence and agent handoffs coherent across conversations and contributors. It supplements (and does not replace) `AGENTS.md`, `docs/UNIFIED_SYSTEM_SPEC.md`, `docs/AGENT_GOVERNANCE.md`, `docs/RESEARCH_AND_DECISIONS.md` and `docs/acceptance.md`.

It governs repository work. It cannot rewrite ChatGPT conversation history, erase account memory, or change Project-level chat settings. Conversation cleanup must use this document as the trusted project reference rather than claiming that old chats have been modified.

## 2. Canonical project identity

- Repository: `metsam-mastem/Atomic-Z-Customi-Z`
- Product: one integrated, Android-first motorcycle customization workbench / virtual garage.
- Runtime and Android delivery: Godot 4 / GDScript.
- Rendering baseline: Godot Compatibility renderer, subject to measured device evidence.
- Canonical editable state: one versioned `BuildDocument`.
- Preferred asset interchange: glTF 2.0 / GLB, with provenance and license recorded.
- Product experience: one application, one scene/navigation lifecycle, one active vehicle/build context, one HUD/workflow and one persistence/export pipeline.
- Current vehicle target in accepted project decisions: Kawasaki Ninja ZX-25RR; exact year/market/variant and geometry compatibility remain evidence-gated.

The words "JARYAN Virtual Fab Lab" may describe the broader creative context, but the repository and product identity for implementation work is Atomic-Z-Customi-Z. Do not infer that other JARYAN workstreams belong here.

## 3. Non-negotiable architecture boundaries

1. Internal modules are implementation boundaries inside the same Godot product, not independent products.
2. No second runtime, parallel editor, duplicate renderer, separate product database or competing writable customization store without explicit product-owner approval.
3. All editable vehicle, assembly, material, graphic/neon and render state converges on the canonical `BuildDocument`.
4. `neon_skin_config.json` is a legacy/migration input or compatibility format only; it must not become a second authoritative writer.
5. Python/Tkinter and ModernGL are development/research aids. Useful concepts may be ported into Godot; they are not alternate product runtimes.
6. Procedural geometry is placeholder geometry, not factory Kawasaki CAD. Visual preview is not proof of fitment, structural safety, road legality or engineering validity.
7. ZX-25R and ZX-25RR must not be treated as interchangeable for dimensions, geometry, parts or fitment without authoritative year/market evidence.

## 4. Evidence hierarchy

When sources conflict, use this order and record the conflict:

1. Latest explicit product-owner decision.
2. Current repository state on the target branch (files, commits, branches and PRs).
3. Canonical contracts and tests that are present and applicable to that state.
4. CI results tied to the exact commit under review.
5. Approved architecture/decision documents.
6. Older project briefs and historical conversation summaries.
7. Agent inference, suggestions or unverified notes.

A document does not outrank the current code merely because it sounds authoritative. A green historical CI run does not prove the current commit passes. A PR description is evidence of intent, not proof of merged or functioning behavior.

## 5. Context classification

Every discovered instruction, claim, requirement or artifact that could affect implementation must be classified as one of:

| Label | Meaning | Handling |
|---|---|---|
| `VALID` | Current and supported by an authoritative source | May guide work |
| `OUTDATED` | Once relevant, superseded by newer evidence/decision | Retain as history; do not execute |
| `CONFLICTED` | Conflicts with another credible source | Stop affected work; record and resolve |
| `FOREIGN_CONTEXT` | Belongs to another project/workstream | Exclude from this repository's scope |
| `UNVERIFIED` | Plausible but not evidenced | Do not present as fact or acceptance |
| `DUPLICATE` | Repeats an existing canonical record | Link to canonical record |
| `MISSING` | Required information is absent | Record as a gap |
| `REQUIRES_REVIEW` | Needs product-owner or specialist judgment | Escalate; do not silently decide |

Do not delete historical information solely because it is outdated or foreign. Preserve provenance where it helps explain why a decision changed.

## 6. Required preflight for every task

Before implementation, research integration or repository mutation:

1. Read `AGENTS.md` and the relevant canonical specifications.
2. Confirm repository identity and target branch.
3. Inspect the current branch head, recent commits, relevant branches, open PRs/issues and CI.
4. Fetch the exact current contents and blob SHAs of every file to be changed.
5. Search for existing documents, contracts, implementations and decisions before creating duplicates.
6. State the user outcome, scope, non-goals, owned files, dependencies and acceptance evidence.
7. Classify uncertain or conflicting context.
8. Use a dedicated task branch; never write directly to `main`.
9. If another PR owns the same files or interface, coordinate or stop.

For documentation-only changes, do not run or claim runtime tests unless runtime behavior was changed and tests were actually executed.

## 7. Decision record rules

Record decisions in `docs/RESEARCH_AND_DECISIONS.md` or the existing canonical decision location. Each new decision should include:

- Stable decision ID.
- Date and status: proposed / accepted / rejected / superseded.
- Decision statement and rationale.
- Evidence/source and relevant commit/PR.
- Scope and affected interfaces.
- Consequences, migration and rollback where applicable.
- Owner decision required, if unresolved.

Never promote an agent suggestion to an accepted decision without approval. Supersede old decisions explicitly; do not silently rewrite history.

## 8. Shared state and schema control

The `BuildDocument` contract is the sole authoritative editable build state. Before changing it:

- Identify every reader, writer, serialized consumer and migration path.
- Preserve stable IDs; do not rely on display names or array positions.
- Specify schema versioning, defaults, validation and backward compatibility.
- Add or update contract and round-trip tests.
- Update the unified specification and acceptance gates.
- Coordinate with the integration owner before changing shared interfaces.

A legacy adapter may exist during migration, but there must be one authoritative state and one canonical write path.

## 9. Multi-agent and PR handoff

Every task has one branch, one declared file owner and one reviewable PR. A handoff must report:

- Task and user outcome.
- Base branch and base commit SHA.
- Files owned and changed.
- Contracts/interfaces changed.
- Decisions relied on and conflicts discovered.
- Tests/CI run with exact commit and result.
- Android/device evidence or explicit NOT RUN.
- Risks, limitations, rollback and next dependency.

Do not assume a branch is merged because a similarly named PR exists. Verify merge state against GitHub. Do not merge, close, delete or rewrite another contributor's work without explicit authorization.

## 10. Status and claim discipline

Use only:

- `PASS` — fresh evidence on the exact commit demonstrates the criterion.
- `FAIL` — an executed check failed.
- `NOT RUN` — no check was executed.
- `BLOCKED` — execution is prevented by a named dependency or access issue.

Keep evidence classes separate: source presence, static/import checks, headless runtime tests, CI, Android export, physical-device behavior, visual fidelity, asset/fitment validation and engineering validation. Passing one class does not imply another.

## 11. Recovery procedure when context is contaminated

1. Freeze scope expansion and avoid speculative implementation.
2. Reconfirm the repository and product identity from this document and `README.md`.
3. Collect current repository evidence; do not rely on an unverified conversation summary.
4. Classify conflicting/foreign/outdated claims using Section 5.
5. Reconcile accepted decisions and architecture using Sections 2–4.
6. Update only the canonical documents that are genuinely stale.
7. Create a recovery report listing evidence, unresolved conflicts and owner decisions required.
8. Resume implementation only after the task scope and source of truth are clear.

This procedure repairs the working context and repository documentation. It does not modify or delete previous conversation messages.

## 12. Repository snapshot — 2026-11-16 handoff refresh

Snapshot refreshed after PR #9, #10 and #14 were merged. Latest verified main commit: c1a25db35112dc7b1a69c945e2c789c9a99cfe11.

- PR #9 merged: project context integrity and recovery controls.
- PR #10 merged: part-level paint, canonical BuildDocument persistence with backup/recovery, and Android Debug export fix.
- PR #14 merged: README and Project Charter visual presentation plus Visual Asset Register.
- PR #7 remains open/draft; focused binder test and end-to-end integration are NOT RUN.
- PR #8 is closed without merge. PR #11 and #12 remain open and require overlap/relevance review against the Android export fix already merged in PR #10.
- PR #10 CI evidence: Godot 4.4.1 import/smoke/neon/BuildDocument/persistence tests PASS; Android Debug APK export and artifact upload PASS on commit 253029faaecc358e7e3c98d52255a8cb63ee9db1, workflow run 43788395328.
- Physical Android installation and Redmi device QA remain NOT RUN.
- Only verified visual asset: assets/product-concept.svg. It is a concept/UI illustration, not a runtime screenshot or factory motorcycle render. The README and Project Charter embed it; docs/VISUAL_ASSET_REGISTER.md records the inventory.
- No transferable user-uploaded or generated image attachment from the current chat was available during the visual handoff audit.

This is a point-in-time snapshot. Re-query GitHub before relying on branch, PR or CI status.
## 13. Change log

- 2026-11-16: Initial context-integrity protocol added. No runtime source, project settings, schemas, assets or CI workflows changed.
- 2026-11-16: Handoff snapshot refreshed after PR #9, #10 and #14 merges; recorded Android export evidence and visual asset inventory.
