# Atomic-Z-Customi-Z — Mandatory Agent Instructions

These rules apply to every human, AI model, coding agent and automation. Read before any repository action. The product owner's latest explicit decision takes precedence over inferred agent preferences.

## Product identity: ONE system

Atomic-Z-Customi-Z is one integrated Android-first motorcycle customization and engineering-preview system. Garage, vehicle model, parts, assembly, Stock/Exploded modes, camera, materials, paint, decals, neon, shaders, glow, UI, persistence, export, diagnostics and future hardware/engineering adapters are capabilities of one product and one user workflow.

Internal modules are allowed as implementation boundaries only. They must share one application lifecycle, active vehicle/build context, navigation, canonical data model and acceptance system. Do not create standalone companion products, duplicate editors, parallel renderers, separate databases or competing configuration stores without explicit owner approval.

## Canonical technology

- Product runtime and Android delivery: Godot 4 / GDScript.
- Rendering baseline: Godot Compatibility renderer until device evidence supports a change.
- Preferred interchange: glTF 2.0 / GLB; Blender is the authoring path.
- One versioned BuildDocument is the source of truth.
- Python/Tkinter and ModernGL are reference/developer tools only. Port useful behavior into Godot; they must not become a second product runtime.
- Keep this repository's project boundary; do not merge unrelated JARYAN workstreams.

## Mandatory preflight before writing

1. Read this file, `docs/CONTEXT_INTEGRITY_PROTOCOL.md`, `docs/UNIFIED_SYSTEM_SPEC.md`, `docs/AGENT_GOVERNANCE.md`, `docs/ROADMAP.md` and `docs/RESEARCH_AND_DECISIONS.md`.
2. Confirm repository identity, target branch and current branch head.
3. Inspect all branches, open/recent PRs, relevant issues, recent commits and CI.
4. Fetch exact current contents and blob SHAs of every file to be edited.
5. Search for existing documents, implementations, contracts and decisions before creating duplicates.
6. Identify owner, scope, dependencies, canonical contracts and acceptance tests.
7. Check for concurrent edits. If ownership is unclear, stop and coordinate; never overwrite another agent's work.
8. Record scope, owned files, interface changes, tests and rollback in the issue/PR.
9. Classify uncertain context as VALID, OUTDATED, CONFLICTED, FOREIGN_CONTEXT, UNVERIFIED, DUPLICATE, MISSING or REQUIRES_REVIEW. Do not turn inference into fact.

## Multi-agent concurrency protocol

- Never write directly to main. Use agent/<agent-id>/<issue>-<task> branches.
- One task = one branch = one PR. No force pushes.
- Declare exact file ownership. Never allow two agents to own the same file concurrently.
- Shared surfaces (project settings, main scene, canonical schemas, assembly IDs, export presets and CI) require integration-owner coordination.
- Before every update, fetch the latest branch head and verify the expected base. Abort on mismatch and reconcile; never blind-replace.
- Parallelize independent research/tests; serialize shared interface and integration changes.
- No self-merge or bypass of required checks.
- If branch protection is unavailable, report that policy is not technically enforced.
- Do not delete, revert or rewrite another agent's commits without explicit authorization.

## Architecture rules

- One Godot application, one scene tree, one navigation model, one shared state and one persistence contract.
- Components communicate through typed interfaces/signals and stable IDs.
- No duplicate source-of-truth JSON. Migrate legacy formats explicitly.
- Record vehicle variant, year, market, units, coordinate frame, asset hash, source and license.
- No inferred fitment or arbitrary projection of 2D paths onto 3D bodywork.
- Visual preview, geometric validation, mass properties, solver simulation, legal fitment and physical hardware deployment are distinct evidence classes.
- Hardware mappings require calibrated profiles; never treat sample LED indices as deployable instructions.
- Expensive effects must be adaptive and measured on target Android hardware.

## Engineering workflow

For behavior changes and bug fixes: write a failing test, run and observe the expected failure, implement the smallest change, run targeted and full relevant suites, run import/build/export checks, review the diff, then open a PR. No production code without a test-first cycle unless the owner explicitly authorizes an exception.

Never claim PASS without fresh command output on the current commit. Status vocabulary: PASS / FAIL / NOT RUN / BLOCKED. Source code existing is not proof of completion.

## Required PR description

Problem/user outcome; architecture and data-flow impact; exact files/interfaces changed; schema migration/compatibility; tests and exact outputs; Android/device evidence; asset provenance/license; risks/limitations/rollback; visual evidence where relevant; acceptance checklist.

## Prohibited shortcuts

- Do not add a second engine/runtime to the product.
- Do not create a second skin/build schema.
- Do not present placeholder geometry as Kawasaki CAD.
- Do not silently treat ZX-25R and ZX-25RR as identical.
- Do not claim LED wiring, fitment, structural safety or road legality without evidence.
- Do not add paid/cloud dependencies without approval.
- Do not bypass tests, CI or review.

## Completion report

Report branch/PR/commit, files, tests actually run, outputs, CI links, acceptance status, limitations, risks and next dependency. If a command could not be run, say so.


## Chat-independent project continuity (mandatory)

- The repository is the durable project memory. No task may require access to a particular chat, chat transcript, account memory or agent session to understand project identity, accepted decisions, current status or next action.
- Before any task, read `docs/PROJECT_STATUS.md` after this file. It is the canonical operational resume checkpoint; then refresh its dated GitHub facts against live `main`, PRs, issues and CI.
- Do not treat a chat summary as source of truth. Conversation history may provide a new product-owner instruction, but once accepted it must be recorded in the appropriate canonical decision/specification and reflected in `docs/PROJECT_STATUS.md`.
- Before handing off or ending a work session, update `docs/PROJECT_STATUS.md` with the merged commit or PR, files changed, exact tests/CI evidence, unresolved items, decisions required and one next action. If no repository change occurred, record why the checkpoint remains unchanged when the work materially affects project state.
- A fresh chat or a different agent must be able to resume by cloning the repository and following the documents above. Never rely on hidden context or imply that memory was transferred automatically.
