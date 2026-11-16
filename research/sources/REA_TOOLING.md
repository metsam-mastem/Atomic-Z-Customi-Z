# Source Dossier: REA — Reverse Engineer Anything

**Canonical repository:** https://github.com/morluto/rea  
**Reviewed revision:** `a10037ef10516cf92653596512932b15f190a5c0`  
**Licence:** MIT (REA project code; dependencies and bundled submodules retain their own notices)  
**Disposition:** optional research tool; not an Atomic-Z runtime dependency and not installed by this repository.

## Resolve the repository name correctly

The project the user referred to as “Reverse Engineering Everything” is the REA project (“Reverse Engineer Anything”). During the audit:
- `edaneshi/ReversEngineeringEverything` was confirmed as a GitHub fork of `morluto/rea`.
- `JunchaoMeiNCTS/Reverse-Engineering-Everything` was also confirmed as a fork of `morluto/rea`.
- The canonical upstream is `morluto/rea`. Its README explicitly tells users to obtain REA from that canonical repository, its website or the official `rea-agents` npm package; a similar name or copied README does not establish that a download is official.

Use the canonical repository and pinned revision, not a stale third-party fork.

## What it does

REA connects an AI coding agent to local analysis tools using MCP and CLI workflows. Its documentation describes workflows for:
- native executable inspection, procedure inventory, disassembly, pseudocode, calls, references and bounded traces;
- Android APK inspection through JADX and related tooling;
- JavaScript/Electron application graph and runtime inspection;
- managed/.NET applications;
- web applications, module tracing, runtime observation and network captures;
- evidence bundles that preserve what was observed, where it came from and what remains incomplete.

The project is TypeScript-based. Native analysis can use an existing Ghidra, Hopper or IDA installation. Android analysis uses a JADX engine. Static JavaScript analysis can be performed without a native disassembler.

## Useful workflow concepts

- Start with an exact binary/application inventory and identify the correct entry point; do not assume a symbol named `entry`.
- Use focused procedure, instruction, pseudocode and reference queries rather than dumping an entire program.
- Preserve evidence identity and the selected target revision.
- Distinguish static analysis from runtime observation.
- Record provider limits, truncation, missing symbols and unresolved behaviour.
- For reconstruction, require a separate readiness/evidence evaluation; passing synthetic evaluator tests does not prove the target's runtime equivalence.

REA's own reconstruction-readiness documentation explicitly distinguishes observed journeys from synthetic evaluator conformance and states that an overall passing check is not an end-to-end reconstruction verdict.

## How it could help Atomic-Z

Possible later research uses:
1. Inspect an APK that Atomic-Z's owner has the right to analyze, to understand its declared components, resources, SDK use and packaged dependencies.
2. Inspect an owner-supplied Android build of Atomic-Z and compare its package inventory with the intended export contract.
3. Analyze a lawfully obtained reference application's static architecture or declared resources, where permission and law allow it.
4. Produce structured evidence for a clean-room behavioural specification.

It cannot automatically infer correct motorcycle dynamics, create source code for a proprietary product, or prove that a Godot implementation is equivalent to another game.

## Installation and safety notes

REA's official setup guide documents `npx rea-agents setup` and requires explicit review/approval of proposed agent-configuration changes and optional external tool installation. Native providers such as Ghidra/Hopper/IDA are separate dependencies. Installation should be done from a trusted directory outside the target project, after reviewing package origin, version, permissions and provider requirements.

This audit did not install or execute REA. It only reviewed its public source and documentation. If it is later installed, run it against lawful, owner-authorized targets; do not use it to bypass DRM, anti-cheat, licensing checks or access controls.

## Acquisition decision

- Official source: `morluto/rea`, MIT.
- Third-party forks: not authoritative.
- Keep REA outside the Godot project and build pipeline.
- Install only for a defined reverse-engineering task and remove/review agent registrations when no longer needed.

Pinned links:
- [Canonical README](https://github.com/morluto/rea/blob/a10037ef10516cf92653596512932b15f190a5c0/README.md)
- [Native investigation guide](https://github.com/morluto/rea/blob/a10037ef10516cf92653596512932b15f190a5c0/docs/guides/native/native-investigation.md)
- [Android APK analysis guide](https://github.com/morluto/rea/blob/a10037ef10516cf92653596512932b15f190a5c0/docs/guides/android/android-analysis.md)
- [Reconstruction readiness guide](https://github.com/morluto/rea/blob/a10037ef10516cf92653596512932b15f190a5c0/docs/development/reconstruction-readiness.md)
- [Installation guide](https://github.com/morluto/rea/blob/a10037ef10516cf92653596512932b15f190a5c0/docs/getting-started/installation.md)
