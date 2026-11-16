# Atomic-Z Research Vault

This directory is the maintained, evidence-led entry point for external source research, reverse-engineering notes, asset provenance, and future integration decisions.

**Project boundary:** Atomic-Z remains one Android-first Godot/GDScript product. This vault is a research workspace, not a second runtime, not a second editor, and not permission to import another game's assets or code.

## Start here

| Need | File |
|---|---|
| Searchable source list, exact revisions, licence status and adoption decisions | [source-registry.json](source-registry.json) |
| What each source can contribute to Atomic-Z, and what must not be copied | [Integration map](INTEGRATION_MAP.md) |
| Repeatable and lawful reverse-engineering process | [Reverse-engineering playbook](reverse-engineering/PLAYBOOK.md) |
| Motorcycle game architecture and controller findings | [DankNooner dossier](sources/DANKNOONER.md) and [standalone motorcycle controller dossier](sources/MOTO_CONTROLLER.md) |
| NFS reconstruction and automotive physics references | [NFS research dossier](sources/NFS_RECONSTRUCTION.md) |
| Reverse Engineer Anything tooling | [REA dossier](sources/REA_TOOLING.md) |
| Call of Duty source, reconstruction and RE methodology | [COD dossier](sources/COD_RECONSTRUCTION.md) |
| Godot vehicle physics references and modular vehicle solvers | [Godot vehicle systems dossier](sources/GODOT_VEHICLE_SYSTEMS.md) |
| Motorcycle configurator and 3D showroom architecture | [Configurator/showroom dossier](sources/MOTORCYCLE_CONFIGURATORS.md) |
| Pseudo-3D mobile motorcycle game and model assets | [Roadkill and asset dossier](sources/ROADKILL_AND_ASSETS.md) |
| Third-party source acquisition policy | [third_party/README.md](../third_party/README.md) |

## How to retrieve inspected source code

The source registry records immutable commit IDs where the repository API exposed them. To obtain selected external source files without placing them in Godot's `res://` resource tree, run:

```bash
bash tools/research/fetch-reference.sh --list
bash tools/research/fetch-reference.sh danknooner
bash tools/research/fetch-reference.sh opennfs
```

The helper uses sparse checkouts into the ignored `.research-cache/` directory. It is intended for reading and local investigation only. It does **not** add downloaded code to the Atomic-Z build, enable it in Godot, or change any external licence. Some sources are intentionally excluded from automatic fetching because their rights or revision state are unresolved.

For a single file, prefer the pinned GitHub URL in the relevant dossier or registry entry. Never treat an unpinned `main` branch as a stable source reference.

## Evidence labels

- **PINNED** — exact upstream commit was retrieved and recorded.
- **STUDY_ONLY** — architecture or behaviour may be studied; code/assets are not cleared for reuse.
- **REUSE_CANDIDATE** — licence appears compatible for the identified source scope, but file-level notices, dependencies, compatibility and attribution still need review.
- **BLOCKED_LICENSE** — no clear licence or rights grant for the relevant content.
- **MISMATCHED** — repository does not match the described project.
- **NOT_FOUND** — cited location could not be verified.
- **NEEDS_RECHECK** — mutable page, third-party claim, or incomplete source evidence.

A licence on a repository does not automatically cover game assets, recovered code, bundled dependencies, screenshots, music, fonts, or user-contributed content. Every asset still needs provenance and a rights check.

## Audit scope and limitations

Research performed on 2026-11-16 covered public repository metadata, current default-branch trees, READMEs, licences/attribution statements, design documents, and selected implementation files. The most relevant controller, physics, input, state, camera, crash, trick, gearbox, rollback and rendering paths were inspected. Exact revisions are recorded where available.

This was **not** a line-by-line audit of every file in the 1.19 GB DankNooner repository, a complete decompilation of Need for Speed or Call of Duty, a dynamic trace of proprietary game binaries, or a runtime/device test of Atomic-Z. No external project was executed or imported into the Atomic-Z runtime during this research pass. Findings are engineering research, not claims of behavioural equivalence or legal advice.

## Change control

Keep research separate from product decisions:
1. Add evidence and a pinned revision here.
2. Record compatibility, licence and integration consequences.
3. Propose an architecture decision in `docs/RESEARCH_AND_DECISIONS.md`.
4. Only then implement an isolated, tested adapter in a dedicated branch/PR.
5. Do not merge code, data or assets from a reference repository solely because they are public on GitHub.

The current Atomic-Z source of truth remains `AGENTS.md`, `docs/UNIFIED_SYSTEM_SPEC.md`, `docs/ROADMAP.md`, and the canonical `BuildDocument` contract.
