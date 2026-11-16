# Multi-Agent Governance and Change Control

## Repository snapshot: 2026-11-16
GitHub inspection found only main in branch search, no pull requests in PR search, and no open issues in issue search. Recent commits show rapid/interleaved edits to Godot neon runtime, tests, persistence, Android export and docs. The available commit response did not expose reliable identity for every agent. This is a snapshot, not proof that no other work exists. Direct-main writes are a material race risk.

## Mandatory policy
1. main is integration-only; agents must not write directly to it.
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
Branch: agent/<agent-id>/<issue>-<task>. PR title: [Area] imperative outcome. Commit prefixes: feat, fix, test, docs, build, refactor, chore. Use draft PRs while contracts are unsettled.

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

## Agent handoff template
Task/issue; branch/base SHA; files owned/changed; interfaces/schema changed; tests and exact outputs; CI URL; limitations; conflicts; commit/PR; next owner.

## Conflict resolution
Choose the semantically correct integrated result, not simply the newest or largest patch. Compare both versions, preserve independent behavior, run contract tests and record resolution. If a conflict changes product direction or a user decision, stop for owner decision.

## Enforcement status
Policy is documented, but branch protection and required-review settings were not verified or changed in this task. Do not represent the policy as technically enforced until repository settings prove it.