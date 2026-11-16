# Neon Shader Experiment and Legacy Profile Migration

**Status:** Research artifact; shader not integrated into the product runtime  
**Product boundary:** One Godot 4 application and one canonical BuildDocument

## Current disposition

- `shaders/neon_glow.gdshader` is an experimental visual shader. It is not wired into the garage's `NeonSkin` runtime, has no verified imported-surface binding, and has not passed target-Android visual/performance acceptance.
- The former `scripts/skin_profile_store.gd` writer has been retired and removed. It was not registered in `project.godot` as an Autoload and had no product-code callers.
- The old `NeonSkin.save_skin()` writer has also been removed. Neither `user://skin_profile.json` nor `neon_skin_config.json` is an active runtime save target.
- Editable neon palette, visibility, and normalized glow state belong to the canonical BuildDocument and use `BuildDocumentStore`.
- Hardware mapping/export remains disabled until a calibrated controller profile, validated segment mapping, and explicit hardware acceptance exist.

## Legacy user-data migration

When no valid `user://atomic_z_build.json` exists, first launch checks for `user://skin_profile.json` after reading the repository's legacy neon configuration. The migration:

1. Imports the old shader profile's color into `BuildDocument.customization.palette.primary`.
2. Preserves legacy `glow_intensity` and `pulse_speed` values unchanged in their original 0..10 ranges in a versioned `extensions` record with status `preserved_unmapped`.
3. Does not reinterpret those values as the canonical renderer's normalized 0..1 glow parameter.
4. Persists the canonical BuildDocument through `BuildDocumentStore` and retains the original legacy profile file.

A valid existing BuildDocument always takes precedence and prevents re-import. Invalid profile data is rejected and left untouched. This migration does not generate hardware-ready JSON.

## Neon runtime persistence

`NeonSkin` is an in-memory renderer/controller for neon layers. Its snapshot API returns a defensive copy of the shared BuildDocument. Palette, segment visibility, global visibility, and normalized glow changes are serialized and restored through that document. No separate skin JSON writer is provided.

## Future shader integration gate

Only resume shader integration after all of the following are met:

- A surface/part binding exists for the active provenance-tracked GLB asset.
- Shader controls read and write the same BuildDocument used by paint and neon.
- A reviewed mapping exists between legacy 0..10 parameters and normalized render parameters.
- Compatibility-renderer visual, occlusion, import, and Android performance tests pass.
- No second profile store, Autoload, or independent writer is introduced.

The shader is an artistic effect, not physical lighting simulation, body-fitment evidence, or engineering validation.
