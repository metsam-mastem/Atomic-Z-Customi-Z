# Atomic Z — Architecture

## Product boundary
Atomic Z is a mobile-first 3D motorcycle customization and engineering-preview workbench. The first experience is a garage, not a racing game. Android is the target; desktop Godot editor is the development environment.

## Runtime layers
1. Experience shell — garage, camera rig, touch controls, panels and navigation.
2. Vehicle domain — vehicle definition, assembly graph, stable part IDs, fitment and variants.
3. Geometry layer — imported meshes and procedural/parametric generators.
4. Material layer — PBR definitions, texture sets and finish presets.
5. Engineering adapters — measurement, interference, mass properties and external solvers.
6. Extension layer — versioned modules, capability declarations and dependency checks.
7. Persistence layer — local project/build documents, asset provenance and revision history.

The first slice implements the experience shell and a procedural placeholder assembly only. Other layers are contracts or planned modules, not completed features.

## Data contracts
A vehicle definition should contain vehicle_id, display_name, model_year, market, units, asset_uri, asset_hash, asset_license, asset_source, coordinate_system, parts, mount_points, compatibility_rules, mass_kg, material_id, provenance and verification status.

A part definition must use a stable part_id. Localized display labels must never be primary keys. Fitment rules must be explicit and testable.

## Asset contract
Preferred interchange: glTF 2.0 / GLB. Authoring: Blender. Preserve independently moving/removable assemblies. Proposed convention:
- SI units (meters, kilograms)
- Y-up in engine
- vehicle longitudinal axis = X
- wheel pivots at axle centers
- stable node names matching part_id
- separate meshes only where independent customization or animation is required

## Extension manifest (draft)
Each extension package will contain unique reverse-DNS id, semantic version, supported app/API range, capabilities, dependencies, entrypoint, asset list, license, author, provenance, content hashes, permission scope and optional network requirement.

Unknown capabilities fail closed. Extensions cannot silently replace vehicle geometry or alter engineering values without explicit user action and an audit record.

## Engineering integrity
Keep result classes separate:
- Visual preview: appearance only.
- Geometric check: dimensions, transforms, collisions/interference.
- Mass properties: only with known geometry and material density.
- Structural/thermal/CFD: only with a defined solver, boundary conditions, mesh quality and validation.
- Road/legal fitment: requires jurisdiction-specific authoritative data.

A rendered result is never evidence of structural safety or road legality.

## Mobile performance
Start with Compatibility renderer and modest scene complexity. Use few real-time lights, avoid expensive post-processing, and enable quality only after device profiling. Adaptive quality uses measured frame time and should expose its active tier in diagnostics.

Do not lock FPS or memory budgets until the exact phone SKU, SoC/GPU, RAM and Android version are confirmed and measured.

## Build sequence
1. Garage vertical slice and input loop.
2. Vehicle/part data contracts and model import.
3. Assembly graph and exploded-view constraints.
4. Material variants and reusable finish packs.
5. Parametric customization and export.
6. Geometric validation and solver adapters.
7. Plugin package manager and local library.
8. Android profiling, packaging and regression gates.
