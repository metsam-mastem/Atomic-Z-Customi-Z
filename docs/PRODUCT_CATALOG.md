# Product Catalog

**Catalog status:** planned/current-state distinction maintained. The repository's current source is the authority; roadmap items are not marketed as implemented.

## Core product
| Module | Current source/evidence | Status |
|---|---|---|
| 3D Garage | `scripts/main.gd`, `scripts/bike_assembly.gd` | Prototype |
| Bike Assembly | `scripts/bike_assembly.gd` | Placeholder geometry; not factory CAD |
| Neon Skin | `scripts/neon_skin.gd`, `neon_skin_config.json` | Implemented baseline |
| Palette editor | HUD ColorPickerButton callbacks | Implemented baseline |
| Segment visibility | stable segment IDs in config/HUD | Implemented baseline |
| Glow control | emission-based ribbon layers | Implemented baseline; not custom HDR bloom pipeline |
| Camera orbit | `scripts/main.gd` input handling | Baseline; desktop wheel zoom, touch drag |
| Save skin | NeonSkin save/load JSON | Implemented baseline |
| Adaptive quality | `scripts/quality_controller.gd` | Basic FPS-driven shadow toggle |
| Android export | `export_presets.cfg`, CI workflow | Build pathway exists; physical device validation required |
| ModernGL experiment | `experiments/modern_gl_neon/` | Research-only; not runtime |
| LED integration | design concept | Not hardware-calibrated; not deployment ready |

## Planned capability catalog
1. Versioned BuildDocument and legacy migration.
2. Skin editor with undo/redo and per-part selection.
3. Godot native environment glow/bloom with quality tiers.
4. Pulse effect with reduced-motion control.
5. Import pipeline for licensed GLB/glTF vehicle assets and provenance metadata.
6. Android gesture separation, responsive HUD, orientation testing.
7. LED mapping designer only after calibrated profiles and engineering review.
8. Export validation, preview render, and shareable catalog build.

## Non-claims
No product claim of Kawasaki affiliation, verified ZX-25R dimensions, homologation, factory CAD accuracy, certified LED installation, or Android device performance is made by this catalog.
