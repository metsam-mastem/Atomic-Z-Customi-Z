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


## 4. Additional CC0 motorcycle models and complete scene pack

These are the exact Innerscene model pages that were mentioned earlier or surfaced during the expanded audit. They are distinct assets; do not confuse the 7.2 MB generic sport bike with the separate 19.1 MB naked-sport model.

### Innerscene naked sport motorcycle

- Page: https://www.innerscene.com/tools/library/3d-parts/sport-motorcycle-naked-sport-bike-fc4c9758
- Format/size: GLB, 19.1 MB.
- Stated licence: CC0 / public domain.
- Page description: generic naked sport bike with inline-four exterior, trellis frame, fork, twin front discs, wheels, chain and side silencer.
- Nominal overall dimensions: approximately 1.009 × 2.055 × 1.304 metres.
- This is a visual reference model, not verified Kawasaki/Ninja CAD or mechanically complete.

### Innerscene adventure motorcycle

- Page: https://www.innerscene.com/tools/library/3d-parts/adventure-motorcycle-3de675e4
- Format/size: GLB, 7.2 MB.
- Stated licence: CC0 / public domain.
- Nominal overall dimensions: approximately 2.275 × 0.922 × 1.405 metres.
- Generic unbranded Adventure motorcycle; useful as a second form-factor/LOD/import test.

### 3DAssets.dev — Motorcycle Racing and Street Bikes pack

- Demo: https://3dassets.dev/demos/motorcycle-racing-and-street-bikes
- Pack manifest: https://3dassets.dev/api/v1/packs/motorcycle-racing-and-street-bikes
- Demo placement JSON: https://3dassets.dev/api/v1/demos/motorcycle-racing-and-street-bikes
- The demo page describes 69 distinct GLB models, 202 placements and a walkable race paddock/workshop/hairpin scene.
- Stated licence: CC0 1.0 Universal for the pack/models.
- Documented scene axes/units: metres, +Y up.
- The demo page says all 69 published pack designs are placed, and says colliders, navigation and gameplay are left for the consuming project to add.
- Contents include road-bike archetypes, showroom/plinth pieces, paddock garages, workshop benches, bike transport, a hairpin, track timing equipment, racing bikes and small garage props.
- Useful for a garage/paddock prototype, background dressing, visual benchmark and GLB import/instancing tests. Not a physics simulator or finished playable racing level.

### Asset selection and mobile trade-offs

| Candidate | Best role | Main caution |
|---|---|---|
| Innerscene Road Motorcycle (627 KB) | low-cost import/material and geometry tests | visual-only; working mechanical systems omitted |
| Innerscene Sport Motorcycle (7.2 MB) | generic full-bike showroom placeholder | no OEM fitment proof |
| Innerscene Adventure (7.2 MB) | alternate silhouette and scale/LOD test | different use case and geometry budget |
| Innerscene Naked Sport (19.1 MB) | richer close-up customization/showcase candidate | materially heavier GLB; inspect polygon/texture budget |
| 3DAssets Motorcycle Racing and Street Bikes | garage/paddock/workshop environment kit | 69 assets still require mobile LOD, collision, draw-call, texture and streaming budgets |

Before any model enters Atomic-Z, acquire the exact GLB, hash the bytes, save the source page and CC0 snapshot, inspect in Blender and run Khronos glTF Validator. Record mesh/surface count, textures, UVs, scale, wheel centres, origins/pivots, polygon count, animation clips and dependencies. Only then create a BuildDocument-compatible surface catalogue. Do not enable the complete 69-model pack on mobile without a measured asset budget and staged loading plan.
