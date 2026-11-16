# Development Workflow & Engineering Gates

## Branch model
- `main`: reviewed, releasable baseline.
- `feat/<topic>`: feature development.
- `fix/<topic>`: defect correction.
- `docs/<topic>`: documentation-only work.
- Use pull requests; avoid direct pushes to main.

## Standard change flow
1. **Issue:** state user outcome, acceptance criteria, constraints, and risks.
2. **Inspect:** read `AGENTS.md`, architecture, affected source, schema, and tests.
3. **Design:** define state/data ownership and backward compatibility before UI edits.
4. **Implement:** one cohesive change, stable IDs, typed interfaces, error handling.
5. **Validate:** run Godot import/headless smoke tests and focused tests; record exact command and result.
6. **Review:** inspect diff, docs, assets/licensing, security/safety claims, and performance impact.
7. **PR:** summarize rationale, files, test evidence, known limitations, screenshots if available.
8. **Merge:** only after required CI and review; tag release and update changelog.

## Quality gates
- G0 Scope: acceptance criteria and non-goals approved.
- G1 Architecture: one authoritative state schema; no duplicate runtime.
- G2 Correctness: parsers validate type, range, uniqueness, and required fields.
- G3 Tests: unit, schema, round-trip, smoke, and regression tests for changed paths.
- G4 UX: controls work, state reflects controls, touch target and reduced-motion behavior considered.
- G5 Performance: benchmark against target device and quality tiers; do not claim FPS without measured evidence.
- G6 Documentation: user docs, developer docs, decisions, and readiness status updated.
- G7 Release: CI green, assets provenance/license recorded, Android QA report completed if Android release.

## CI workflow expectations
- Pin Godot version and export templates.
- Cache only reproducible engine/import artifacts.
- Run headless editor import before script tests.
- Run GDScript static checks where compatible.
- Run project smoke and neon configuration tests.
- Validate JSON fixtures and document schema.
- Produce Android artifact only on explicit release/CI configuration; label artifact.
- Upload logs/artifacts on failure; never mask failures with unconditional success.

## Debugging protocol
- Reproduce with minimal input and exact engine version.
- Capture error, stack trace, platform, commit, and config.
- Classify: parse/import, runtime, state/schema, rendering, input, performance, packaging.
- Add regression test before or alongside fix.
- Fix root cause, not symptom; rerun focused and full suite.
- Record residual risks and test environment.

## Release readiness template
- Commit / tag:
- Engine version:
- CI run:
- Unit/smoke/schema tests:
- Android device + OS:
- FPS percentile / thermal / memory:
- Known issues:
- Asset license/provenance:
- Approval:
