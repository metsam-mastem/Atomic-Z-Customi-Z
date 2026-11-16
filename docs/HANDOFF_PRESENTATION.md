# Atomic-Z-Customi-Z — Product Handoff Presentation

## Slide 1 — Product
**Atomic-Z-Customi-Z**  
A visual customization lab for motorcycle concepts.  
Tagline: *Ride Your Style. Light Up Your Ride.*

## Slide 2 — Problem
Customization ideas are often scattered across sketches, paint references, and disconnected tools. A unified visual build should make creative decisions inspectable and repeatable.

## Slide 3 — Solution
A Godot-based 3D garage with modular assembly, neon skin controls, data-driven configurations, and a future Android-first workflow.

## Slide 4 — Experience
- Enter the garage
- Orbit and inspect the concept bike
- Select body or neon palette
- Enable/disable skin segments
- Adjust glow and visual effects
- Save a versioned build document
- Export a preview/catalog package

## Slide 5 — Architecture
Godot 4 is the sole product runtime. GDScript owns scene and UX logic. JSON schemas define portable project state. ModernGL/Python remains a segregated research experiment.

## Slide 6 — Current baseline
- Garage and camera prototype
- Placeholder assembly
- Neon segment rendering and color controls
- JSON skin save/load
- Basic adaptive shadow reduction
- CI/export configuration present, but runtime/device validation is required

## Slide 7 — Roadmap
1. Canonical BuildDocument
2. Skin editor undo/redo and part binding
3. Native glow/pulse quality controls
4. Licensed GLB model pipeline
5. Android input/layout/device QA
6. Calibrated LED mapping, conditional on engineering validation

## Slide 8 — Trust and boundaries
This is a customization concept tool. Placeholder geometry is not factory CAD. No fitment, certification, Kawasaki endorsement, or hardware safety is claimed.

## Slide 9 — Handoff checklist
- Repository and branch identified
- Charter, manifesto, catalog, architecture and workflow docs available
- CI and test commands recorded
- Asset provenance/licensing captured
- Open issues and limitations enumerated
- Owner accepts next milestone

## Slide 10 — Closing
**Create a build. Make it yours. Preserve the evidence.**
