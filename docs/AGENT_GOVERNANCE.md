# Multi-Agent Governance and Change Control

## Repository snapshot: 2026-11-16

A connected GitHub inspection during the context-recovery task returned the following branches: `main`, `agent/integration/1-build-document-contract`, `agent/integration/5-android-export-diagnostics`, `agent/research/godot-mobile-rendering-integration`, `agent/research/5-verified-source-audit`, `docs/product-charter-workflows-handoff`, and `feat/commercial-neon-shader-skin-data`.

Open-PR search returned:
- PR #7 — GLB material and mobile neon rendering guidance.
- PR #8 — detailed Android export diagnostics.

Closed-PR search returned #2, #3, #4 and #6; recent commits on `main` include merge commits for #2, #3, #4 and #6. Refresh this snapshot before every task. Search results are point-in-time evidence, not permanent repository state.

PR #8 documents a generic Android Debug export configuration failure and adds verbose diagnostic capture; it does not establish the root cause or a successful APK export.

## Mandatory policy

1. `main` is integration-only; agents must not write directly to it.
2. Every task uses a short-lived branch and PR.
3. Each PR declares exact file ownership.
4. Before editing, inspect branches, PRs, issues, latest commits, workflows and CI.
5. Fetch current file contents and blob SHA before updating; abort if the file changed since inspection.
6. Never force-push, blind-replace, discard another agent's changes or self-merge.
7. One integration owner reconciles interfaces and merges reviewed PRs in dependency order.
8. Parallelize independent research/tests; serialize canonical schema, main scene, project settings, assembly IDs, export presets and CI changes.
9. Out-of-scope edits are reported, not cleaned up.
10. Every merge is traceable to an issue, tests and acceptance evidence.

## Naming

Branch: `agent/<agent-id>/<issue>-<task>`. PR title: [Area] imperative outcome. Commit prefixes: feat, fix, test, docs, build, refactor, chore. Use draft PRs while contracts are unsettled.

## Default file ownership

| Surface | Owner |
|---|---|
| project.godot, export_presets.cfg | integration owner |
| canonical vehicle/build/skin schemas | data-contract owner |
| scenes/main.tscn, scripts/main.gd | experience-shell owner |
| scripts/bike_assembly.gd, vehicle definitions | vehicle-domain owner |
| scripts/neon_skin.gd and skin controls | customization/rendering owner |
| tests/** | test owner; feature owner adds scoped tests |
| .github/workflows/** | build/CI owner |
| docs/** | documentation owner |

These are role boundaries, not claims that specific agents currently exist.

## Shared-interface change procedure

Identify all callers and serialized consumers; specify migration and compatibility; add contract tests; update spec; obtain integration-owner review; implement migration/adapter; remove legacy support only after proving no remaining consumers.

The canonical editable state is the versioned `BuildDocument`. Legacy skin JSON may be read through an explicit migration/compatibility adapter, but must not become a competing authoritative writer.

## Agent handoff template

Task/issue; branch/base SHA; files owned/changed; interfaces/schema changed; tests and exact outputs; CI URL; limitations; conflicts; commit/PR; next owner.

## Conflict resolution

Choose the semantically correct integrated result, not simply the newest or largest patch. Compare both versions, preserve independent behavior, run contract tests and record resolution. If a conflict changes product direction or a user decision, stop for owner decision.

## Enforcement status

Policy is documented, but branch protection and required-review settings were not verified or changed in this task. Do not represent the policy as technically enforced until repository settings prove it.
