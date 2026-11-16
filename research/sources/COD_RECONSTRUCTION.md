# Source Dossier: Call of Duty — official middleware, independent reconstructions and RE notes

This dossier answers the specific question “does Call of Duty source code exist?” precisely. There is no single answer: Activision publishes some third-party open-source components used by selected Call of Duty products; community projects independently reconstruct older game engines; and researchers publish subsystem-level reverse-engineering notes. None of those is the complete official source tree of a current Call of Duty game.

## 1. Official Activision source publication: Telescope / Activision Webkit

**Official page:** https://research.activision.com/opensource  
**Publisher:** Activision Research  
**What is published:** versioned source archives and separate licence archives for Telescope: Activision Webkit, a software component included in some games.

The official page lists version pairs for products including Black Ops 6, Modern Warfare III, Modern Warfare II, Vanguard, Black Ops Cold War and Warzone. The source archive for a product/version is accompanied by a matching licence archive. The page describes the included software as being under a mix of BSD, MPL 1.1, LGPL 2.0, LGPL 2.1 or other open-source licences.

**Crucial scope distinction:** Telescope is not the Call of Duty gameplay engine or the full game source. It is an open-source webkit/middleware component used by selected games. Its per-version licence archive must be reviewed before reusing any individual component. Do not assume a blanket MIT/BSD licence for the entire archive.

Other officially linked projects on that page include:
- [Activision USDShellExtension](https://github.com/Activision/USDShellExtension) — a Windows shell extension for USD file interaction, thumbnails, previews and metadata.
- [Activision Structpact](https://github.com/Activision/structpack) — a standalone software-development tool, described as not linked into or shipped with a game.

These may be useful general graphics/pipeline tooling references, but they are not game source or motorcycle simulation code.

## 2. OpenCOD2 — independent Call of Duty 2 engine reconstruction

**Repository:** https://github.com/opencod2/opencod2  
**Reviewed revision:** `410342a82da1b2e8286c290274aeb0f1731a6859`  
**Language/build:** C, CMake, SDL2/OpenGL; Linux and Windows x86 paths are described  
**Repository licence:** no root LICENSE file or GitHub-detected repository licence was present in the inspected tree/API metadata  
**Disposition:** `STUDY_ONLY`; no source import or redistribution.

The README describes an independent source-level reconstruction of the Call of Duty 2 engine. It is explicitly an incomplete work in progress: it builds and boots but is expected to crash and omit features. It does not include executables, archives, maps, models, textures, sounds or scripts; the README requires the user to supply data from a legally owned copy of the game.

The README also warns that older engines have security-sensitive network, parser, content-loading and memory-safety issues. It states the project is not production-hardened and discourages exposing test servers to untrusted networks.

**Technical relevance:** source-level architecture, renderer separation, build structure, engine/client/server modularity and legacy engine maintenance.

**Not transferable to Atomic-Z:** it is a first-person shooter engine, written in C and tied to 32-bit PC game data, SDL/OpenGL and native build infrastructure. It is not a Godot plugin, not Android-first, and contains no motorcycle mechanics or modular motorcycle customization system.

No code or game content from this repository was copied into Atomic-Z.

## 3. OpenCoD1 — independent Call of Duty (2003) multiplayer reconstruction

**Repository:** https://github.com/opencod1/opencod1  
**Reviewed revision:** `718e994af62ca2cbc79d911bab73c445637b94e7`  
**Language/build:** C, Premake/Visual Studio, Windows  
**Repository licence:** no root LICENSE file or GitHub-detected repository licence was present in the inspected tree/API metadata  
**Disposition:** `STUDY_ONLY`; no source import or redistribution.

The README describes a reconstruction of the Call of Duty (2003) multiplayer engine. It says the engine, dedicated server and game/cgame/UI modules build and link, while some subsystems (especially effects) remain incomplete. It requires a legitimate Call of Duty 1 version 1.1 installation and its assets; no game content is included.

**Technical relevance:** legacy multiplayer engine boundaries, game/cgame/UI modules, server/client separation and staged reconstruction.

**Limitations:** the README calls the project incomplete, the documented build is Windows/Visual Studio, and no clear source reuse licence was established in the repository tree. A build that links is not evidence of full gameplay compatibility or production readiness.

No code or game content from this repository was copied into Atomic-Z.

## 4. World at War T4 reverse-engineering notes

**Repository:** https://github.com/ItsNoahJ/codwaw-reverse-engineering  
**Reviewed revision:** `a329baa38fd8595ee8fd5d0b800f29af29b903fe`  
**Licence:** MIT for this repository's original documentation/data tables; upstream library and third-party components retain their own licences  
**Disposition:** study methodology and evidence model only.

The repository is a compact set of notes about the cryptography stack bundled with Call of Duty: World at War T4 (SP 1.7.1263), MSVC8 toolchain fingerprints and byte-verification methodology. Its README says the repository contains analysis, addresses and per-function identity claims, not proprietary Activision game source or redistributed game assets/bytes. It records exact/relocation-exact, identified and open findings and preserves negative results and uncertainties.

**What is valuable for Atomic-Z:** rigorous claims linked to binary identity, byte-match oracles, compiler/toolchain analysis, evidence tiers, explicit unknowns and reproducible verification. This is a methodology reference, not a gameplay system.

**Boundary:** the MIT file in this repository does not grant rights to Activision binaries, game content or upstream libraries beyond their own terms. Do not copy game data, private binaries, memory dumps or proprietary source.

## 5. CoD-Research — community technical wiki

**Repository:** https://github.com/primetime43/CoD-Research  
**Reviewed revision:** `133813620e28c997fd57cc149b3f1d81c03f9b94`  
**Licence:** GPL-3.0  
**Disposition:** research/documentation reference; no copied text or code.

This is a community knowledge base covering CoD4 through CoD10, including engine families, formats, modding and reverse-engineering pointers. It is not the game source. Its GPL-3.0 terms apply to its own published material; avoid reproducing wiki content in Atomic-Z beyond concise factual references and links.

## 6. MW2 (2009) reconstruction progress — private source

**Progress page:** https://mw2.momo5502.com/  
**Public description:** source-level reconstruction and decompilation progress dashboard  
**Public source repository:** none established during this audit  
**Disposition:** `PRIVATE_NO_SOURCE`; not a source dependency.

The public dashboard reports progress for a private source-level reconstruction of the 2009 Modern Warfare 2 multiplayer executable. Dashboard counts are mutable and represent that project's own progress metrics, not independently verified game completeness. The source itself was not established as publicly available from a canonical repository in this audit.

The dashboard is useful as a case study in reconstruction tracking, especially the separation of byte-exact functions from functions that are merely decompiled. It is not a source-code download, a permission to use Activision IP, or a reusable Atomic-Z engine.

## 7. What Call of Duty does and does not offer Atomic-Z

| Source | Can teach | Cannot be used as |
|---|---|---|
| Official Telescope Webkit archives | mixed third-party licence handling and middleware integration | full CoD game source or engine |
| OpenCOD2 | legacy engine/client/renderer architecture | a licensed, production-ready Godot/mobile game engine |
| OpenCoD1 | client/server/game-module separation | complete CoD source or licensed drop-in code |
| CoDWaW RE notes | reverse-engineering evidence, byte-matching and toolchain methodology | proprietary game code or motorcycle physics |
| CoD-Research | technical topic discovery and community references | a freely reusable code library (GPL documentation) |
| Private MW2 progress dashboard | reconstruction progress taxonomy | downloadable source or licence grant |

For Atomic-Z, the actionable material is limited to general engineering practices: separation of gameplay/UI/network/rendering, explicit reconstruction evidence, and robust data-ingestion boundaries. COD-specific assets, game mechanics and shooter subsystems do not solve Atomic-Z's current motorcycle garage requirements.

## Atomic-Z decision

- Do not import any COD engine, mod, asset, executable, map, texture, sound, script, recovered data or memory dump into Atomic-Z.
- Official Telescope components may be considered independently only if Atomic-Z develops a specific webview/middleware need and the exact package's versioned licence archive, dependency graph, security posture and Android compatibility are reviewed.
- Keep all other Call of Duty references in the research vault.
- No gameplay scope change or runtime integration is proposed by this dossier.
