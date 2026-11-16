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


## Neon skin subsystem (new)

The neon skin is a data-driven design layer, intentionally separated from the Godot runtime:
- JSON owns palette, glow scalar, named polyline IDs, point sequences and stroke widths.
- The Tkinter desktop utility is a fast 2D authoring/preview companion; it does not become an Android runtime dependency.
- A future Godot importer can read the same JSON and map design paths onto verified 3D surfaces using UV coordinates, decal meshes or curve meshes.
- Keep stable segment IDs so revisions, visibility toggles and material bindings survive palette changes.

### Required conversion before 3D application
The current points are 2D canvas pixels. To project them onto the motorcycle, first acquire a correctly scaled side-view reference for the exact model year/market, register image coordinates to the vehicle coordinate system, then map each path to a 3D surface/UV region. Do not project from the current stylized Tkinter silhouette or infer dimensions from these sample points.

### Color and rendering semantics
The JSON stores sRGB hex colors and a normalized glow intensity in [0, 1]. The Tkinter preview approximates glow using layered 2D strokes. The Godot implementation should convert colors consistently, use emissive materials and a restrained bloom/glow post-process only on capable device tiers. Tkinter's glow is not physically based light emission.

## Godot neon runtime implementation

`scripts/neon_skin.gd` is the runtime consumer of the shared skin JSON. It validates input before replacing the active visual state, keeps segment IDs stable, resolves named palette keys, exposes per-segment visibility and global visibility, and generates emissive ribbon meshes in three stacked passes. The glow scalar is clamped to [0, 1] and controls emission energy. The 2D points are mapped to a generic XY side plane with a fixed depth offset.

This mapping is intentionally provisional. It is not a surface projection, UV mapping, decal attachment or fitment system. Before using a skin on a production vehicle asset, define a versioned coordinate-frame/reference-image contract and map the curves to verified body-surface coordinates. The current placeholder vehicle and skin points are not geometrically registered.

Macroquad remains an isolated Rust rendering experiment, not a dependency of the Godot application. The Godot runtime already owns the scene graph, materials, renderer and Android export path; a second renderer would duplicate lifecycle, input and packaging responsibilities without measured evidence of benefit. Reconsider only if a reproducible benchmark identifies a specific capability or performance gap.
