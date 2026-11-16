# Project Status — Canonical Resume Checkpoint

**Purpose:** Resume work without relying on conversation history or individual agent context.  
**Repository:** `metsam-mastem/Atomic-Z-Customi-Z`  
**Product:** Atomic-Z-Customi-Z — one integrated Android-first motorcycle customization workbench.  
**Runtime:** Godot 4 / GDScript. **Canonical editable state:** versioned `BuildDocument`.  
**Last verified:** 2026-11-16 — latest live GitHub API snapshot  
**Verified main:** `db532efa725e6f54df54a707ce7b5be585d589d6`  
**Current research branch:** `agent/research/atomic-z-reference-vault`  
**Current research PR:** [#40 — Pinned reverse-engineering and source vault](https://github.com/metsam-mastem/Atomic-Z-Customi-Z/pull/40)  
**Research PR HEAD:** always resolve the live head from [PR #40](https://github.com/metsam-mastem/Atomic-Z-Customi-Z/pull/40); this checkpoint is part of that PR and its own update creates a new commit

## Resume rule

1. Read `AGENTS.md`, this file, `docs/CONTEXT_INTEGRITY_PROTOCOL.md`, `docs/UNIFIED_SYSTEM_SPEC.md`, `docs/AGENT_GOVERNANCE.md`, `docs/ROADMAP.md` and `docs/RESEARCH_AND_DECISIONS.md`.
2. Fetch the live `main` SHA and re-check open PRs, issues, branches and CI before acting; this checkpoint is a dated snapshot.
3. Treat repository files, merged commits, approved decisions and exact-commit CI as project memory. Conversation history is optional context.
4. Use a task branch and reviewed PR. No direct-main writes, force pushes, self-merges or bypass of required checks.
5. Update this checkpoint in the same PR or a dedicated docs PR after material status changes.

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

## Verified live repository state — 2026-11-16

### Main branch

- `main` observed at `db532efa725e6f54df54a707ce7b5be585d589d6`.
- Latest observed main `Godot CI` run: [#43814661860](https://github.com/metsam-mastem/Atomic-Z-Customi-Z/actions/runs/43814661860) — completed / success on the exact main SHA.
- Independent open issue [#41](https://github.com/metsam-mastem/Atomic-Z-Customi-Z/issues/41) tracks the Customi-Z Core v0.3 donor-package audit; re-check its current state before taking action.
- GitHub branch-protection/ruleset enforcement remains **UNVERIFIED**; prior integration read returned 403. The owner should inspect Settings → Branches / Rulesets.

### Open pull requests

| PR | Scope | State / dependency | Next action |
|---|---|---|---|
| [#42](https://github.com/metsam-mastem/Atomic-Z-Customi-Z/pull/42) | Audit/reconcile Customi-Z Core v0.3 donor package | OPEN, non-draft; base `main` | Review donor provenance, source rights and architecture before any integration |
| [#40](https://github.com/metsam-mastem/Atomic-Z-Customi-Z/pull/40) | Pinned reverse-engineering and source vault (documentation/tooling only) | OPEN, non-draft; base `main`; head `93797f54...`; mergeable true / state unstable; latest exact-head CI queued | Review source/licence labels and wait for exact-head CI result; no external source is merged into product runtime |
| [#39](https://github.com/metsam-mastem/Atomic-Z-Customi-Z/pull/39) | Revert unintended Android plugin files from main | OPEN, non-draft; base `main` | Review governance diff and verify no required Android plugin file is removed |
| [#38](https://github.com/metsam-mastem/Atomic-Z-Customi-Z/pull/38) | Import verified GLB models into integrated garage | OPEN / DRAFT; stacked on PR #30 | Resolve GLB provenance, compatibility and dependency chain before review |
| [#37](https://github.com/metsam-mastem/Atomic-Z-Customi-Z/pull/37) | Android two-finger pan and pinch zoom | OPEN / DRAFT; stacked on PR #30 | Review touch behaviour and reconcile after stack dependencies |
| [#31](https://github.com/metsam-mastem/Atomic-Z-Customi-Z/pull/31) | Free-first multi-model AI adapter foundation | OPEN / DRAFT; base `main` | Check current base SHA, scope and integration with the existing product |
| [#30](https://github.com/metsam-mastem/Atomic-Z-Customi-Z/pull/30) | Unify legacy neon state with BuildDocument | OPEN / DRAFT; stacked on PR #29 | Review schema/migration contract and reconcile stack |
| [#29](https://github.com/metsam-mastem/Atomic-Z-Customi-Z/pull/29) | Connect GLB surface catalog to BuildDocument | OPEN / DRAFT; stacked on PR #28 | Review asset catalogue contract and verify stack order |
| [#28](https://github.com/metsam-mastem/Atomic-Z-Customi-Z/pull/28) | Android APK verification and reproducible release path | OPEN, non-draft; base `main` | Independent review, physical-device acceptance and release-signing gate remain outstanding |

This live list supersedes the older PR snapshot and statuses retained in earlier revisions of this file. Re-fetch live PR metadata before merging or rebasing any stacked branch.

### Research PR #40 — current task

- Branch: `agent/research/atomic-z-reference-vault`.
- Base SHA: `db532efa725e6f54df54a707ce7b5be585d589d6`.
- Head SHA and ahead/behind counts: resolve live from PR #40 immediately before action; earlier snapshots are historical and go stale as this checkpoint is updated.
- Scope: source registry, per-project dossiers, integration map, reverse-engineering playbook, third-party policy, sparse local source retrieval helper and README/checkpoint references.
- Registry: 23 unique sources, 16 pinned immutable Git revisions; statuses identify study-only, reuse-candidate, private/no-source and recheck items.
- Research files: `research/README.md`, `research/source-registry.json`, `research/INTEGRATION_MAP.md`, `research/sources/`, `research/reverse-engineering/PLAYBOOK.md`.
- The fetch helper supports six pinned/licence-identified checkouts (`danknooner`, `moto-controller`, `opennfs`, `rea`, `godot-vehicle`, `modu-vehicle`) and stores them locally in ignored `.research-cache/`. Unlicensed or mixed-rights sources remain manual-reference only.
- No external code, game assets or binaries were vendored into the product repository or imported into Godot's `res://` runtime. The research cache is not a product dependency.
- PR metadata at last read: OPEN, non-draft, `mergeable=true`, `mergeable_state=unstable`; the latest check-runs were queued.
- Exact-head CI is triggered by each new branch commit and can show multiple push/PR runs. Resolve the latest run for the live PR head from [GitHub Actions](https://github.com/metsam-mastem/Atomic-Z-Customi-Z/actions); older successful runs do not prove the current head. At the last live read, the current head's smoke, neon and Android export checks were **QUEUED**.
- Other intermediate documentation commits on the branch completed CI successfully, but that is not a substitute for the exact PR HEAD result.
- Godot runtime tests and Android device/thermal QA were not run manually for this docs-only task. Source retrieval helper was not executed.

## Source research decisions

The detailed, pinned audit lives in the [Atomic-Z Research Vault](../research/README.md). Important conclusions:
- DankNooner and its standalone controller are AGPL-3.0 and target newer Godot/renderer configurations; study architecture only, do not copy into Atomic-Z.
- OpenNFS's original code is MIT, but it is a desktop C++/Bullet four-wheel car engine; dependencies and EA game content retain separate rights.
- OpenUG2 and SPEED RE are methodology/architecture references; licence/recovered-content restrictions prevent blind reuse.
- REA's canonical upstream is `morluto/rea`, not similarly named third-party forks; it remains an optional separate analysis tool, not a product runtime dependency.
- Activision's official Open Source page publishes selected versioned Telescope Webkit middleware sources and paired licence archives, not complete Call of Duty game source.
- OpenCOD1/OpenCOD2 are incomplete independent reconstructions with no detected repository licence in the inspected trees; they require separately supplied lawful game data and are study-only.
- CoDWaW's MIT repository contains reverse-engineering research notes/data, not proprietary Activision source or game assets. CoD-Research is GPL-3.0 community documentation. The MW2 reconstruction dashboard is not a public source repository.
- Roadkill has an itch.io MIT/CC statement but GitHub repository metadata reports NOASSERTION; treat as study-only pending file-level rights verification.
- Two Innerscene model pages state CC0, but no downloaded GLB, SHA-256 or import validation has been recorded. They are visual placeholder candidates, not OEM CAD or fitment evidence.
- The previously cited `rishabhsinghio/Godot-Simple-Motorcycle-Physics` URL returned 404. The cited `alvariusgames/bearcycle` repository contents did not match a motorcycle project.


- Seerban/godot-vehicle and ModuVehicle are additional pinned Godot vehicle references; the first is a four-wheel MIT car implementation on Godot 4.6 Forward+, the second a CC0 WIP C++ GDExtension for Godot 4.5+. Neither is a completed motorcycle solver.
- KV Vehicle is study-only because no repository licence was established; MotoForge and VOLT R1 Showroom also lack a root repository licence. Their patterns inform fitment validation, build summaries, mobile lazy-loading, fallbacks and camera/telemetry, but no web runtime or code is imported.
- The registry contains 23 entries / 16 pinned Git revisions. The helper provides six sparse checkouts only; other references with unresolved/mixed rights remain manual.

No COD, NFS retail assets, executables, maps, sounds, textures, recovered game data or proprietary source are candidates for Atomic-Z integration.

## Current evidence and release gaps

| Area | Status | Evidence / limitation |
|---|---|---|
| Canonical BuildDocument baseline | PASS (historical merged work) | Current exact-head regressions still required after integration branches merge |
| Part-isolated paint and safe persistence | PASS (historical merged work) | Backup/recovery behaviour covered by prior CI; re-run on current integration chain |
| Main Godot/Python/Android CI | PASS | Main SHA `db532efa...`, run #43814661860 |
| Research Vault source registry and docs | PASS — structural validation | JSON parses; 23 unique IDs and 16 valid pinned SHAs; exact PR HEAD CI queued |
| Research fetch helper | NOT RUN | Pinned sparse-checkout helper exists; no external source checkout downloaded in this task |
| Production ZX-25RR GLB/CAD and provenance | NOT RUN | Current runtime geometry is procedural placeholder |
| Verified part IDs/pivots/material slots/UVs for production asset | NOT RUN | Surface binder prototype still needs verified production asset |
| Physical Redmi installation/launch and touch review | NOT RUN | Requires exact target device |
| Android sustained FPS/frame-time/memory/thermal profiling | NOT RUN | Record exact phone SKU, SoC/GPU, RAM and Android version first |
| Mechanical fitment, collision/interference, mass properties, structural/thermal/CFD and road legality | NOT RUN | Requires authoritative inputs, defined methods and specialist validation |
| Calibrated LED/controller mapping | NOT RUN | Disabled until controller and LED profile are calibrated and evidenced |

## Priority next actions

1. Check exact-head CI for PR #40; review and merge only through the repository's normal approval path if all required checks and governance gates pass.
2. Independently review PR #39's rollback of unintended Android plugin files.
3. Review PR #28, #29 and #30 in dependency order; preserve the Android build and canonical BuildDocument contracts.
4. Reconcile PR #37 and #38 only after PR #30's base is stable; verify GLB provenance, touch ergonomics and Android performance.
5. Re-check PR #31 base and scope before integration.
6. Obtain a licence-verified, provenance-tracked ZX-25RR model for an exact declared year/market, then validate part IDs, pivots, coordinate frame, material slots and UV/surface mapping.
7. Run physical Redmi QA and record exact device identity, install/launch, touch, persistence, frame time, memory and thermals.
8. Owner: verify/configure GitHub branch protection and required checks; API access could not confirm current settings.

## Decision and change control

- Accepted architecture decisions live in `docs/RESEARCH_AND_DECISIONS.md` and `docs/UNIFIED_SYSTEM_SPEC.md`.
- Research Vault entries are leads and evidence, not automatic product decisions or legal advice.
- New product direction or unresolved ZX-25RR/year/market decisions require explicit product-owner approval.
- Keep changes on dedicated task branches and reviewed PRs. No direct-main writes, force-push, self-merge or bypass of required checks.
- Status vocabulary: PASS / FAIL / NOT RUN / BLOCKED. Every PASS points to evidence for the exact commit.
- This checkpoint is the portable handoff. Do not depend on chat history or an AI-generated recap.
