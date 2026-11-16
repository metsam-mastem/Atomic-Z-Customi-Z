# Third-Party and Reference Sources

**No external game's source tree or proprietary game asset is vendored in this folder by this PR.**

The research vault and pinned source registry live in `research/`. To retrieve selected, inspected files for local review, use:

```bash
bash tools/research/fetch-reference.sh --list
bash tools/research/fetch-reference.sh danknooner
bash tools/research/fetch-reference.sh opennfs
```

The helper writes sparse checkouts into `.research-cache/`, which is ignored by Git and is outside Godot's `res://` runtime content. The checked-out code does not become an Atomic-Z dependency. It is a local research copy only.

## Why full source trees are not committed here

- **DankNooner / moto-player-controller:** AGPL-3.0; code and bundled asset obligations need an explicit project/legal decision. DankNooner is approximately 1.19 GB and uses a newer Godot/renderer baseline.
- **OpenNFS:** MIT covers its original code, but its dependencies and EA game assets have separate rights. It is a desktop C++/Bullet engine, not an Atomic-Z runtime plug-in.
- **OpenUG2 / SPEED RE:** no blanket source/content reuse grant was established; NFS recovered code, original binaries and assets are expressly limited or excluded.
- **REA:** canonical upstream is MIT, but it is a sizeable analysis-tool project with a separate Node/MCP/tool-provider stack. It must remain a separate optional tool.
- **Roadkill:** GitHub metadata reports NOASSERTION despite an itch.io page's MIT/CC claim. File-level rights must be reconciled before reuse.
- **Innerscene GLBs:** individual pages state CC0, but downloaded asset bytes and SHA-256 have not yet been acquired/recorded; each GLB needs its own provenance and validation record.

## Rules before any vendor import

1. Approve the exact repository and commit, not just its project name.
2. Confirm the licence applies to the exact files and dependencies.
3. Retain copyright, attribution, notice and licence files.
4. Record a third-party inventory/SBOM and the files copied.
5. Check Godot version, renderer, APIs, platform support and dependency weight.
6. Keep the import isolated, with tests and a rollback path.
7. Never add EA/Activision retail assets, executables, extracted data, proprietary sounds, textures, maps or decompilation dumps.

A public repository is not automatically a permissive licence, and a permissive code licence does not grant rights to assets inside that repository.
