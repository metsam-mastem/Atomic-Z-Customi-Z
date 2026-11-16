# Source Dossier: Roadkill and motorcycle visual assets

## 1. Roadkill — pseudo-3D Road Rash-style game

**Canonical repository:** https://github.com/nicolasbize/roadkill  
**Reviewed revision:** `76fcf2b06c2fd1575e7211820f6e3864cd619603`  
**GitHub licence detection:** `NOASSERTION`  
**Game page:** https://gadgaming.itch.io/roadkill  
**Disposition:** `STUDY_ONLY`; do not import code/assets until file-level licence scope is verified.

The README describes a Godot project created for LOWREZJAM 2026. It is a fast-paced, pseudo-3D Road Rash-style racing/fighting game with four tracks, five unlockable bikes, attacks, keyboard/controller/mobile controls and a tiny 64×64 pixel rendering canvas. The source tree contains clear game-flow and presentation responsibilities: bike selection, map selection, race results, world/track, road camera, screen shake, bike definition, player/enemy, traffic, road renderer, sprite renderer, combat solver and track definitions.

**Potential use:** study its arcade racing loop, track selection/results UX, mobile control layout, enemy/traffic separation, and lightweight pseudo-3D road rendering if Atomic-Z ever wants a small arcade mode.

**Not suitable as a primary simulator source:** its pseudo-3D sprite road renderer and combat-oriented gameplay are not a realistic 3D motorcycle physics system, a GLB customizer or an engineering workbench.

The itch.io page says the code, art, music and sound effects are MIT/CC. However, the GitHub repository metadata currently reports NOASSERTION and the inspected repository did not establish a clear licence grant covering every source and asset. This discrepancy is recorded rather than guessed away. Do not copy source, art, sound, fonts or animations until the exact grant and included third-party rights are verified.

## 2. Innerscene Free Parts Library — CC0 GLB models

The library landing page describes public-domain CC0 models and drawings contributed to the platform. Individual model pages also state their own CC0 dedication and identify the source model. These are candidate visual assets, not technical vehicle references.

### Sport motorcycle

- Page: https://www.innerscene.com/tools/library/3d-parts/sport-motorcycle-e21e8303
- Format: GLB; page reports 7.2 MB.
- Stated licence: CC0 / public domain.
- Nominal dimensions: about 2.084 × 0.782 × 1.180 metres.
- Described as an original unbranded model.

### Road motorcycle

- Page: https://www.innerscene.com/tools/library/3d-parts/road-motorcycle-f2519759
- Format: GLB; page reports 627 KB.
- Stated licence: CC0 / public domain.
- Nominal dimensions: overall about 0.8 × 2.1 × 1.4 metres; stated wheelbase 1450 mm, tyre outside diameter 660 mm and nominal seat height 885 mm.
- Described as an unbranded model with a frame, twin-cylinder engine exterior, fork, swingarm, shocks, controls and lamps.
- The page explicitly states that working suspension, transmission, wiring and powertrain internals are omitted, and that nominal visual dimensions do not establish manufacturing tolerance or certification.

### Import gate for any CC0 GLB

Even with CC0, preserve:
- original source page and download date;
- exact downloaded filename, file size and SHA-256;
- explicit licence page/snapshot;
- original author/source attribution when present;
- unit scale, forward/up axes, origin/pivots, wheel centres and bounding dimensions;
- mesh count, material/surface names, UV presence, texture references and polygon budgets;
- validation report and imported asset hash.

Then verify GLB with Khronos glTF Validator, inspect it in Blender, and map stable surfaces into Atomic-Z's existing GLB surface catalogue. Do not claim Kawasaki fitment, factory accuracy or an engineering-validated model from a generic CC0 asset. No model files were downloaded or committed in this research pass.

## 3. Incorrect or unresolved leads from the previous list

- `rishabhsinghio/Godot-Simple-Motorcycle-Physics`: the cited repository URL returned 404 and was already recorded as invalid in Atomic-Z's existing research register. Do not use this citation until a real upstream is identified.
- `alvariusgames/bearcycle`: despite metadata suggesting a motorcycle-related project, the inspected README and tree at that address identify a different bear/platformer Godot C# project. Treat the earlier motorcycle attribution as mismatched and exclude it.
- `ludditegames/bearcycle`: the guessed replacement owner path did not resolve during this audit. No verified motorcycle source was established.
- `nicolasbize/roadkill`: confirmed as a real Godot pseudo-3D Road Rash-style game; this corrects the earlier uncertainty, but the licence remains unresolved at GitHub repository level.
- `nicolasbize/roadkill` should not be confused with an arbitrary project named Roadkill; use the exact canonical link above.

## Asset decision

The two Innerscene pages are the most promising low-risk visual starting points because their individual pages state CC0. The next step is to download only the chosen model, compute a SHA-256, validate it, and add its provenance to the existing asset register before any runtime import. Roadkill remains a gameplay/presentation study only until licence scope is clear.
