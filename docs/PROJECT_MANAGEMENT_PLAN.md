# Atomic-Z-Customi-Z — Project Management Operating Plan

**Version:** 1.0  
**Created:** 2026-11-16  
**Repository:** https://github.com/metsam-mastem/Atomic-Z-Customi-Z  
**Project Owner / final product authority:** Repository owner (metsam-mastem)  
**Project Manager / technical coordination:** ChatGPT (acting in this conversation; advisory and execution scope bounded by GitHub permissions and repository policy)

## 1. Purpose and authority

This plan activates a lightweight, evidence-driven management process for Atomic-Z-Customi-Z. The repository remains the single durable source of truth. The project owner retains final authority over product direction, scope, trade-offs, release approval, and exceptional policy decisions. The project manager coordinates priorities, dependencies, risks, acceptance criteria, review readiness, and status reporting; does not bypass AGENTS.md, CI, review, or merge safeguards.

## 2. Product north star

Deliver one integrated Android-first motorcycle customization workbench using Godot 4 / GDScript, one garage lifecycle, and one versioned BuildDocument. Preserve offline-first core customization. Do not drift into a second runtime, separate editor/store, unverified vehicle CAD/fitment claims, or a riding simulator without explicit owner approval.

## 3. Operating rules

- Every work item has a user outcome, priority, owner, scope, dependencies, acceptance checklist, test evidence, risk and rollback.
- Work proceeds by issue → dedicated branch → PR → review → exact-head CI → merge; never direct-to-main.
- Serialize shared-file work; identify file ownership before implementation.
- Status vocabulary is PASS / FAIL / NOT RUN / BLOCKED. Code presence is not proof.
- Maintain the canonical checkpoint in docs/PROJECT_STATUS.md through a reviewed PR when materially changed.
- Owner approval is required for scope expansion, product-architecture changes, release readiness, security-sensitive decisions, or acceptance of evidence gaps.
- Weekly/each-session cadence: reconcile open PRs/issues and CI; pick the highest-priority unblocked item; review risks; report next action.

## 4. Priority framework

- **P0 — Governance/release blockers:** repository integrity, broken CI, data loss, security/privacy issues, canonical contract drift.
- **P1 — Core garage MVP:** usable integrated customization flow, part selection, materials/neon, touch, persistence and repeatable Android debug build.
- **P2 — Verified asset pipeline:** GLB import/catalog, provenance, stable part/surface mapping; only when P1 remains stable.
- **P3 — Visual quality and export hardening:** measured rendering improvements, save/export robustness, preview capture.
- **P4 — Engineering-preview features:** dimensional/collision/mass/solver adapters only with explicit assumptions and validated fixtures.
- **P5 — Release/commercial readiness:** device QA, performance/thermal budgets, packaging, licensing, support and release evidence.

Priority is not permission to merge: gates still apply.

## 5. Delivery roadmap and exit gates

### Stage A — Baseline and governance (NOW)
- Read mandatory project policies and refresh live main/PR/issues/CI.
- Establish a current work inventory and dependency graph.
- Resolve stale/stacked branches and document file ownership.
- Exit: current main/CI evidence recorded; no unclear ownership or stale checkpoint driving execution.

### Stage B — P1 release-candidate stabilization (NEXT)
- Review and reconcile open governance checkpoint PR #50 with live main; ensure it does not replace current facts with stale status.
- Review optional AI assistant PR #51 against its privacy, transport, credential and offline-first boundaries; require exact-head Godot/Python/Android CI and test results.
- Validate existing garage flows and canonical BuildDocument integration, save/recovery, touch controls and test suite.
- Exit: reviewed changes merged only after exact-head CI passes; release-scope checklist current.

### Stage C — P1 Android device acceptance
- Install/launch on the owner's Redmi device; record exact SKU, Android version and relevant hardware.
- Verify touch/orbit/pan/zoom, garage UI, save/reload/recovery, pause/resume, and network/privacy behavior for optional AI if tested.
- Capture FPS/frame-time, memory and thermals over a defined test run; derive budgets from measured baseline.
- Exit: device evidence recorded; blockers triaged; no production-readiness claim beyond proven gates.

### Stage D — P2 verified GLB import and vehicle asset pipeline (BLOCKED/DEFERRED)
- Reassess issue #47: first decide whether Android content-URI native plugin is necessary or Godot built-in picker suffices.
- If native plugin required, produce version-matched source/build/AAR/license and reproducible optional CI; fail closed if missing.
- Validate provenance/license/hash/size, cancellation, stable IDs/surface mapping and BuildDocument linkage.
- Exit: CI export plus physical-device import QA pass; no unverified fitment/CAD claims.

### Stage E — P3 polish and durable export
- Improve materials, decal/graphic workflow, adaptive effects and preview capture using profiling.
- Validate atomic persistence, recovery, portable export, hashes and migration coverage.
- Exit: regression suites and target-device performance budgets pass.

### Stage F — P4 engineering preview (OWNER DECISION GATE)
- Add inspectable dimensions and coordinate frame; collision/interference fixtures; mass properties only from verified geometry/material density; solver adapters with traceable assumptions.
- Keep hardware mapping calibration-gated and safety claims out of scope absent evidence.
- Exit: each calculation reports inputs, units, assumptions, version and validation status. Requires explicit owner approval to start.

### Stage G — P5 release readiness
- Reproducible arm64 APK/AAB path, signing and licensing review, release notes, install/update/recovery/device matrix, artifact hashes and evidence archive.
- Exit: owner-approved release checklist fully evidenced.

## 6. Live work snapshot (2026-11-16; refresh before execution)

- **PR #50 — governance/status checkpoint:** OPEN. Validate freshness and reconcile against current GitHub inventory before merge.
- **PR #51 — optional free-first AI assistant integration:** OPEN. Require exact-head CI and security/privacy acceptance; Android hosted secrets remain unsupported by stated design.
- **Issue #47 — Android GLB content-URI support:** BLOCKED/deferred; decision on necessity and plugin reproducibility precedes implementation.
- **Issue #49 — AI assistant capability:** linked to PR #51; track through PR review and acceptance.
- Research vault PR #46 is merged; do not re-import its source or create a parallel research cache.

This snapshot is intentionally provisional; docs/PROJECT_STATUS.md and live GitHub facts must be reconciled as the first operational step.

## 7. Risk register

| Risk | Level | Mitigation / trigger |
|---|---|---|
| Stale status docs or branch snapshots | High | Re-fetch main, PR heads, issues and exact CI each session |
| Stacked/diverged PRs and shared-file conflicts | High | One integration owner; rebase/transplant only through scoped branch and reviewed PR |
| AI endpoint, credential or privacy exposure | High | HTTPS hosted; local cleartext explicit-consent and private-network limits; no Android secrets; bounded/cancelable requests |
| Native Android plugin artifact absent or Godot-version mismatch | High | Plugin optional/fail-closed; reproducible source/AAR/CI; device tests |
| Placeholder geometry treated as factory CAD | High | Persistent asset honesty and provenance gates |
| Mobile effects/performance assumptions unmeasured | Medium-high | Device baseline first, then measurable regression budgets |
| Parallel persistent state stores | High | Enforce single BuildDocument and migration policy |
| Scope creep toward simulator or standalone modules | High | Owner decision gate; keep one integrated product |

## 8. Definition of Ready / Done

**Ready:** clear user outcome; aligned with product charter; priority; dependencies and file ownership; acceptance tests; evidence requirements; risk/rollback; owner approval where needed.

**Done:** reviewed PR; exact-head relevant CI PASS; docs/status/checkpoint updated where material; no unresolved acceptance blockers; limitations explicitly recorded; owner sign-off for release/scope decisions.

## 9. Project-manager session report format

1. Current main SHA and CI state.
2. Open PR/issue inventory with dependencies and blockers.
3. Completed work and evidence (links, exact commits).
4. Risks/decisions needed from owner.
5. One recommended next action.

## 10. Immediate next action

Refresh the current main head, exact-head CI for PRs #50 and #51, and issue #47; then produce a review decision/order of operations before any merge.