# Research-to-Atomic-Z Integration Map

This is a translation of external findings into Atomic-Z design opportunities. It is not an approval to add a riding mode, replace the existing garage architecture, or introduce another engine.

## Preserve the existing product

Atomic-Z's current product contract is a motorcycle customization and engineering workbench:

- Godot 4 / GDScript is the only product runtime.
- Android-first delivery; Compatibility renderer is the baseline.
- `BuildDocument` is the only authoritative editable build state.
- Existing assembly, part identity, GLB surface catalog, material binder and adaptive quality systems remain authoritative.
- A reference project must not create a parallel bike database, save format, customization editor, renderer or Android shell.

A rideable simulator has been explored in prior product discussions, but this research PR only establishes references and an integration plan. No rideable runtime has been implemented or approved by this document.

## What each source contributes

| Source | Strongest contribution | What it does not provide | Atomic-Z disposition |
|---|---|---|---|
| DankNooner v2 | Controller composition, gear/RPM, tricks, crash/wobble, camera, IK, combo/boost, race loop, server-authoritative rollback patterns | A drop-in plugin; an Android-ready renderer; verified factory motorcycle dynamics | Study controller boundaries and gameplay contracts; do not vendor its AGPL project |
| moto-player-controller-godot | Smaller, easier-to-follow component implementation: input, state, physics, gearing, tricks, crash, animation and camera | A physically rigorous two-wheel tire/suspension solver; current Godot 4.4 Compatibility target | Compare as predecessor/teaching example; code is AGPL and Godot 4.5 Forward+ |
| OpenNFS | Raycast vehicle contacts, suspension impulses, wheel rotation/slip, camera/race/render separation, per-vehicle physics data | Motorcycle dynamics or Godot nodes; legal rights to EA models/tracks/audio | Study algorithms and data ownership; original code is MIT, but dependencies and EA content are separate |
| SPEED RE / OpenUG2 | Evidence-driven subsystem reconstruction, behavioural specifications, test vectors, provenance, uncertainty tracking | A complete NFSU2 engine or reusable Atomic-Z components; blanket redistribution rights | Use methodology only; recovered game content is explicitly excluded or rights-unclear |
| REA (Reverse Engineer Anything) | Local evidence-producing analysis workflows for binaries, Android packages, apps and runtime observation | A simulation engine or a source-code-free guarantee of game-mechanic equivalence | Optional research tool, not a product dependency |
| Roadkill | Lightweight pseudo-3D racing loop, mobile control surface, track selection, bikes, enemies and combat flow | Realistic 3D vehicle physics, modular bike assembly, a verified reuse licence | Behaviour/UI reference only; rights remain unresolved at repository level |
| Innerscene CC0 motorcycle GLBs | Downloadable visual seed meshes with stated nominal dimensions and CC0 dedication | OEM CAD, correct model-year fitment, rigs, working suspension, validated geometry or mechanical internals | Candidate placeholder/viewer models after hash, source page and import validation |

## If a rideable prototype is separately authorized

A sensible sequence would be:

1. **Input contract:** introduce a platform-neutral control resource for throttle, front/rear brake, steering, body lean, clutch and gear request. Map Android touch controls and keyboard/controller inputs into the same contract.
2. **Movement model:** choose a deliberate arcade/sim target. A CharacterBody-based controller can deliver accessible, responsive gameplay; it should not be presented as a tire-accurate motorcycle simulation.
3. **Wheel/suspension model:** only if the product needs grounded wheel contacts, suspension travel, wheel slip, braking transfer and collision response, build a Godot-native prototype with two wheel probes and a validated state model. OpenNFS is a four-wheel car reference, not a copyable motorcycle solver.
4. **Per-bike tuning:** keep simulation parameters distinct from cosmetic skin data. Store validated, versioned values in a dedicated type definition or future build contract; do not duplicate part/material state outside `BuildDocument`.
5. **Visual rig:** separate physical root, lean/pitch visual root, wheel pivots, rider skeleton/IK targets and camera. Never let decorative lean transforms corrupt collision or saved assembly transforms.
6. **Tricks and safety:** implement wheelie/stoppie/drift/crash as explicit state transitions with hysteresis, cooldowns and deterministic tests. Do not copy undocumented constants as real-world physics.
7. **Progression:** treat races, scoring and upgrades as a separate product decision. Any awarded part must resolve through existing part catalogue and build validation.

## Transferable engineering requirements

- Fixed-step simulation with frame-independent integration.
- Explicit owner for every mutable state variable.
- Stable identifiers and versioned serializable data.
- Deterministic reset/respawn behaviour.
- Hysteresis for threshold-based state changes.
- Camera smoothing and effects driven from gameplay events, not tangled into physics.
- Data-driven per-bike tuning with validation ranges.
- Automated tests for state transitions, boundary values and save/load.
- Low-end Android profiling before raising renderer or asset budgets.

## Do not transplant

- The DankNooner AGPL codebase or bundled assets without an explicit licensing decision.
- The moto-player-controller AGPL code without accepting and satisfying its obligations.
- NFS retail executables, reverse-engineered proprietary code, models, tracks, sounds, UI packages or data tables.
- OpenUG2 recovered material while the project-wide licence and rights scope remain unclear.
- Any CC0 GLB as if it were a manufacturer CAD model or fitment proof.
- A parallel Three.js/React showroom or Python/ModernGL renderer into the Godot product.

## Recommended near-term technical order

For the existing garage, the highest-value transfers are not riding physics. They are: (a) pin and audit verified GLB model provenance, (b) complete the GLB surface catalogue and material workflows, (c) strengthen touch-first camera/selection ergonomics, (d) benchmark material and mesh budgets on Android, and (e) preserve the build-document/assembly contract through import/export. Riding prototype work should be a separately scoped next phase after the owner accepts a concrete gameplay brief.


## Call of Duty source findings

COD-related GitHub repositories do exist, but they are not one official, freely reusable Call of Duty source release:

- Activision's official [Open Source page](https://research.activision.com/opensource) publishes versioned **Telescope: Activision Webkit** middleware source and paired licence archives for selected products. This is a Webkit component, not the game engine or gameplay source.
- [OpenCOD2](https://github.com/opencod2/opencod2) is an incomplete independent C/CMake reconstruction. Its README says the build may crash or miss features, and its repository has no detected licence in the inspected tree. It requires lawful user-supplied CoD2 data.
- [OpenCoD1](https://github.com/opencod1/opencod1) is an incomplete 2003 multiplayer reconstruction, requires original CoD 1.1 data and has no detected repository licence in the inspected tree.
- [CoDWaW reverse-engineering notes](https://github.com/ItsNoahJ/codwaw-reverse-engineering) carry an MIT licence for the published notes/data, not rights to proprietary Activision binaries or game content. They are valuable for byte-exact evidence methodology.
- [CoD-Research](https://github.com/primetime43/CoD-Research) is a GPL-3.0 community knowledge base for CoD4–CoD10, not game source.
- [MW2 2009 reconstruction progress](https://mw2.momo5502.com/) is a mutable dashboard for a private source-level reconstruction; no public source checkout or licence was established.

**Atomic-Z disposition:** no COD engine/source, shooter gameplay, maps, textures, audio or game data is a candidate for product integration. Only generic concepts such as subsystem separation, asset-loading boundaries and evidence-led reverse engineering are worth studying. The full source/rights distinctions are recorded in [COD_RECONSTRUCTION.md](sources/COD_RECONSTRUCTION.md).
