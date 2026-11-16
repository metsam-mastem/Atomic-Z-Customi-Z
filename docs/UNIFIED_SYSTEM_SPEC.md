# Atomic-Z-Customi-Z — Unified System Specification

Status: architecture baseline. Date: 2026-11-16. Runtime: Godot 4 / GDScript. Target: Android.

## 1. Product definition
Atomic-Z-Customi-Z is one interactive motorcycle customization workbench. A user selects a vehicle definition, inspects and disassembles its assembly, changes parts and finishes, authors neon/graphic designs, previews all changes in one 3D garage, saves a complete build and exports a portable project package. Future engineering and hardware capabilities attach to the same build document with explicit evidence boundaries.

Modular means replaceable internal components with stable interfaces. It does not mean multiple products, separate apps, independent editors, databases or runtimes.

## 2. Unified user journey
1. Open garage and select vehicle variant.
2. Inspect vehicle identity, asset provenance and verification state.
3. View Stock assembly and switch to deterministic Exploded mode.
4. Select a part or surface by stable ID.
5. Edit paint/material/finish or attach a graphic/neon layer to a verified surface.
6. Change color, emissive intensity, animation, visibility and quality in the same HUD.
7. See the same 3D scene update immediately.
8. Save the complete build as one versioned document.
9. Reopen and verify exact restoration.
10. Export project data, asset references and preview images.
11. Optionally generate a hardware mapping proposal from a calibrated controller profile.
12. Optionally run geometric/engineering checks with assumptions and evidence.

Every step operates on one active BuildDocument and vehicle context.

## 3. Components of the ONE runtime
- Application shell: lifecycle, navigation, global state, responsive HUD, input routing, diagnostics.
- Vehicle registry: variant, year, market, units, coordinate frame, provenance, license and verification.
- Asset/geometry pipeline: GLB import, node normalization, mesh/material metadata, stable part IDs and validation.
- Assembly graph: parent/child, mount points, pivots, home transforms, explode offsets and compatibility rules.
- Customization state: selected part/surface, paint, material, decals, textures, neon paths, palette and effect settings.
- Unified renderer: garage, vehicle, camera, lights, emissive materials, optional glow and adaptive quality.
- Interaction: touch/mouse orbit, pan, zoom, selection and transform controls.
- Persistence: versioned save/load, migration, autosave, undo/redo and snapshots.
- Export: project document, GLB references, previews and optional hardware proposal.
- Validation: schema, geometry, asset provenance, performance telemetry and evidence ledger.
- Extension registry: optional capabilities loaded into the same runtime after manifest/API/permission checks.

All components share the same active build state. No parallel authoritative data stores.

## 4. Runtime decisions
Godot 4 owns Android application, scene, renderer, UI, input, persistence and export. Compatibility renderer is baseline; higher quality tiers require measured device evidence. Python/Tkinter and ModernGL are research/developer inputs; port useful concepts into Godot rather than shipping a second runtime. Blender → GLB/glTF 2.0 → validation → Godot is the preferred asset path. OBJ is limited and not preferred for PBR/assembly metadata.

## 5. Canonical BuildDocument
Required domains:
- schema_version, project_id, revision, timestamps
- vehicle: vehicle_id, display_name, model_year, market, variant, units, coordinate_system
- asset: uri, sha256, license, source, validation_status
- assembly: stable part_id, parent, mount_points, home_transform, exploded_transform, compatibility_rules
- customization: per-part material/finish, decal/graphic layers, neon segments, surface bindings
- render: quality tier, environment, lights and effect parameters
- hardware_profiles: optional calibrated controller and segment mapping; no inferred defaults
- validation: evidence references, checks, timestamps, tool versions and status
- extensions: versioned IDs and declared capabilities

The existing `neon_skin_config.json` is a read-only legacy migration input. Migrate it explicitly and test round-trip behavior; product code must not write it. Existing `user://skin_profile.json` data from the retired shader-profile store is imported only on first launch when no valid canonical BuildDocument exists. All subsequent neon edits are stored only in the canonical BuildDocument through the unified persistence path.

IDs—not display names or array positions—identify vehicles, parts, surfaces, layers, presets, assets and capabilities. IDs are immutable once published.

Use SI internally and record coordinate conventions. Proposed standard: meters, kilograms, Y-up, longitudinal axis X, wheel pivots at axle centers. Validate each imported asset before applying this convention.

## 6. Integrated neon and rendering
Neon is a material/graphic capability of the selected vehicle and belongs to the same build as paint and parts. A layer includes stable layer_id, target part_id/surface_id, path/texture, color, emissive intensity, visibility, animation and mapping evidence. 2D points must not be projected onto an arbitrary plane and called body-aligned; use verified UVs, decals or curve meshes attached to validated surfaces.

Bloom is a renderer effect in the same runtime. Prefer Godot WorldEnvironment glow where supported. Reduce/disable it on low tiers. Profile on Android.

## 7. Assembly and edit invariants
- Stock restores exact home transforms and materials.
- Exploded uses deterministic offsets without changing IDs or canonical transforms.
- Per-part edits affect only selected targets.
- Surface graphics follow their target mesh.
- Selection remains valid through explode/hide transitions.
- Compatibility rules reject impossible combinations.
- Undo/redo and save/load preserve the complete build.

## 8. Evidence classes
Separate visual preview, asset/coordinate validation, geometric measurement/interference, mass properties, structural/thermal/CFD, mechanical fitment/road legality and physical LED deployment. Each result states evidence class, source data, assumptions, method and status. A render is not proof of safety or legal fitment.

## 9. First integrated acceptance
One Godot app must load a documented vehicle/assembly, switch Stock/Exploded, select parts, edit body materials and neon in the same HUD, update one 3D scene, save/close/reload complete state, export a versioned project and pass headless plus Android interaction checks. Visual quality, fitment and performance are separate gates.