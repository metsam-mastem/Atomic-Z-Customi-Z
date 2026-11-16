# Runtime GLB Import and Surface Editing

**Status:** Runtime import workflow implemented in an unmerged feature branch; device acceptance remains NOT RUN.  
**Runtime:** Godot 4.4.1 / GDScript  
**Canonical state:** `BuildDocument`  
**Scope:** Import one motorcycle GLB into the existing garage; do not create a second editor or asset database.

## In-app import workflow

1. In the garage, select **IMPORT GLB**.
2. Choose a local `.glb` file from the system file picker.
3. Enter a display label, the exact license identifier and the original source/provenance record. The display label is not proof of manufacturer identity; the app does not independently verify ownership or license terms.
4. The selected file is copied into the app's private `user://vehicle_assets/` directory under a filename derived from its full SHA-256.
5. Import is limited to 128 MiB. The runtime rechecks the pinned SHA-256 before parsing the file.
6. Godot's `GLTFDocument.append_from_file()` and `generate_scene()` load the local GLB. If a surface catalog is absent, the runtime generates one from the imported mesh inventory and stores it in the existing BuildDocument.
7. The existing part selector exposes stable per-mesh part IDs; the color picker edits the mapped mesh surface materials.
8. Save Project persists the asset URI, hash, source/license record, display label, generated surface catalog and material edits in the canonical document.

On asset replacement, the active vehicle identity is reset to an asset-hash-derived ID and the supplied display label. Manufacturer variant, model year and market are cleared because the GLB filename and user-entered display label do not prove what motorcycle it depicts. The previous vehicle identity is preserved in a versioned `replaced_vehicle_identity` extension for traceability, but is not treated as the new asset's identity.

The application performs no network download. A selected file is copied into private app storage and remains local to the device.

## Surface catalog contract

For each imported `MeshInstance3D` surface, the initial auto-catalog uses:
- `node_path`: root-relative path returned by the imported scene inventory
- `part_id`: normalized snake_case mesh node path
- `surface_id`: `<part_id>.surface_<surface_index>`
- `surface_index`: exact index in the imported mesh

All surface slots on the same mesh node belong to the same initial part selection. Painting that part updates all its catalogued surfaces. A more refined authored part/surface map can later split panels, trims, fasteners and mechanical assemblies into separate selections. IDs remain stable for the same pinned GLB bytes and imported node hierarchy; replacing/re-exporting an asset requires revalidation.

Per-surface color edits are delegated to the existing `SurfaceMaterialBinder`. It duplicates owned `StandardMaterial3D` resources and changes albedo only, preserving the imported material's other PBR properties. Unsupported material types or unsafe ownership conflicts fail closed.

## Safety and behavior gates

- Local URI must use `res://` or `user://`, end in `.glb`, and contain no parent-directory traversal.
- Display name, license and source fields are mandatory. User-entered text is recorded as metadata/provenance, not independently certified.
- Importing a new asset cannot silently inherit the previous vehicle's manufacturer variant, model year or market. Those fields are cleared and previous identity is kept separately as unmapped provenance.
- GLB copy is chunked in 1 MiB blocks to avoid holding a second full-size copy in Android memory; the maximum accepted source size remains 128 MiB.
- The on-disk file's SHA-256 must exactly match the BuildDocument value.
- GLB files over 128 MiB or malformed imports are rejected.
- A hash/catalog/import/binder failure leaves the existing procedural garage available.
- Imported assets do not enable Exploded mode because verified part pivots and explode offsets are not yet part of the catalog contract.
- Neon controls and the legacy 2D overlay are disabled for imported assets until paths/UVs are registered to the imported surfaces. This prevents floating or incorrectly projected graphics.
- BuildDocument material records targeting a replaced asset are preserved in a versioned `replaced_asset_surface_materials` extension with their prior catalog and are removed from active surface targets rather than being silently applied to unrelated geometry.
- The UI labels imported GLB previews as not factory CAD and not engineering-validated.

## Validation evidence

The new headless integration test uses a tiny synthetic GLB fixture and checks:
- Godot runtime GLB parse and scene generation
- automatic surface catalog generation
- stable part IDs and distinct surface edits
- independent body and rim colors
- PBR metallic/roughness preservation
- BuildDocument save/reload and model re-import
- existing garage HUD startup with imported GLB
- Neon/Exploded control suppression until their mapping contracts exist
- SHA-256 tamper rejection and safe placeholder fallback

A synthetic fixture proves the loader contract only. It does not prove production bike geometry, Kawasaki ZX-25RR identity, UV accuracy, fitment, engineering validity or visual quality parity.

## Current asset status

No production Kawasaki ZX-25RR GLB/CAD is bundled by this change. The runtime workflow accepts a locally obtained GLB with recorded license/source and will auto-catalog it, but exact model year/market fitment and manufacturer geometry remain evidence-gated. A generic CC0 motorcycle may be used for visual prototyping only and must remain labelled generic.

## Android acceptance still required

- Validate system file-picker URI access on the exact target Android device.
- Import a known CC0 GLB, verify copy/hash and save/reopen.
- Review node naming and auto-generated part groups.
- Profile import time, peak memory, frame-time and sustained thermals.
- Review PBR appearance and touch interaction on device.
- Confirm license/provenance and asset redistribution rights before shipping.

No Android physical-device result is claimed by the automated CI tests.
