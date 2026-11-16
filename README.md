# Atomic Z — Customization Lab

Android-first, modular 3D motorcycle customization and engineering-preview workbench.

**Asset honesty:** the first scene uses procedural geometric placeholders. It is not a Kawasaki factory CAD model, a ZX-25RR-accurate replica, or a validated engineering model. Real model assets require clear licensing and verified dimensions.

## First vertical slice
- Godot 4 / GDScript project foundation.
- Procedural sport-motorcycle placeholder with independently movable named parts.
- Stock ↔ exploded assembly toggle.
- Live body-color editing.
- Touch/mouse orbit camera.
- Adaptive low-cost rendering policy based on measured frame rate.
- Architecture, research register and acceptance gates.

## Run
1. Install the current stable Godot 4 editor.
2. Clone this repository.
3. Import the folder containing project.godot.
4. Run the project from the editor.

No third-party runtime plugin is required for this slice.

## Android
Use the official Godot Android export guide:
https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html

This repository does not yet contain an APK/AAB or a device-tested export. Device profiling is a required acceptance gate, not an assumed result.

## Planned modules
| Module | Responsibility | Status |
|---|---|---|
| Garage scene | Showroom, camera, lighting, touch input | Foundation |
| Assembly graph | Named parts, parent/child and explode offsets | Foundation |
| Material lab | PBR presets and texture sets | Basic color control |
| Asset pipeline | Blender → glTF/GLB → validation → Godot | Planned |
| Part catalog | Fitment rules, dimensions, metadata, licensing | Planned |
| Geometry lab | Parametric and procedural part generation | Planned |
| Engineering checks | Interference, mass properties, solver adapters | Planned |
| Plugin system | Versioned manifests and capability contracts | Planned |
| Android profile | Device tiers, frame-time and memory budgets | Not run |

## Project principles
1. Mobile-first and offline-capable runtime.
2. Visual preview is separate from engineering validation.
3. Every imported model/material has provenance and license metadata.
4. Parts use stable IDs, not display names.
5. Prefer reusable modules and data-driven catalogs.
6. No feature is complete until its acceptance checks pass on target hardware.

See docs/architecture.md, docs/research-register.md and docs/acceptance.md.


## Verification
The repository includes a headless smoke test for scene loading, stock/exploded transform restoration and body-material updates:

```bash
godot --headless --editor --path . --quit
godot --headless --path . --script res://tests/smoke_test.gd
```

GitHub Actions runs these checks on pushes and pull requests. A green CI run proves only the tested headless behaviors; it does not prove visual quality, Android export, device performance or engineering validity.


## Neon Cyberpunk skin preview (Python / Tkinter)

This is a separate 2D design-preview utility alongside the Godot 3D garage:
- `neon_skin_config.json` is the editable, data-only skin definition. It stores the bike label, skin name, two palette colors, glow intensity and three polyline overlays.
- `neon_simulator.py` reads that JSON and opens a desktop Tkinter window. It draws a stylized side-profile guide, renders the three neon line layers with stacked strokes to approximate glow, lets you toggle layers, change colors, adjust glow intensity, reload the JSON and save edits.
- `tests/test_neon_simulator.py` validates the config, named color references and input ranges.

### Run on Windows / macOS / Linux

Python 3.10+ is recommended. Tkinter is normally included with the standard Python distribution.

```bash
python neon_simulator.py
```

Run automated checks:

```bash
python -m unittest discover -s tests -p "test_*.py" -v
python -m py_compile neon_simulator.py
```

The simulator is a 2D concept tool, not a 3D renderer, not a measured ZX-25R/ZX-25RR body template and not a factory CAD viewer. The supplied line coordinates are canvas pixels and must be aligned to a verified motorcycle side-view template before manufacturing or claiming model-specific fitment.

**Model naming:** this skin JSON intentionally preserves the requested label `Kawasaki Ninja ZX-25R`. The main product brief currently targets ZX-25RR. These names must not be treated as interchangeable for exact fitment; the skin-to-vehicle compatibility remains unverified.
