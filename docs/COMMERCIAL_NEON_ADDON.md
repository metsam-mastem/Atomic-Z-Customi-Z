# Neon Shader Experiment and Legacy Profile Migration

**Status:** Research artifact; shader not integrated into the product runtime  
**Product boundary:** one Godot 4 application and one canonical BuildDocument

## Current disposition

- `shaders/neon_glow.gdshader` is an experimental visual shader. It is not currently wired into the garage's `NeonSkin` runtime, has no verified surface binding, and has not passed target-Android visual/performance acceptance.
- The former `scripts/skin_profile_store.gd` writer has been retired and removed. Do not recreate it as an Autoload, introduce `user://skin_profile.json` as an active save path, or create a parallel skin database.
- Editable neon palette, visibility, and normalized glow state belong to the canonical `BuildDocument`, saved through `BuildDocumentStore`.
- Hardware mapping/export remains blocked until a calibrated controller profile, validated mapping, and explicit hardware acceptance exist.

## Legacy user-data handling

A first launch with no valid `user://atomic_z_build.json` checks for an old `user://skin_profile.json` after loading the repository's legacy neon configuration. The migration:

1. Imports the old profile color into `BuildDocument.customization.palette.primary`.
2. Preserves the old shader's `glow_intensity` and `pulse_speed` values, still in their original 0..10 ranges, in a versioned `extensions` record with status `preserved_unmapped`.
3. Does not reinterpret those values as the canonical renderer's normalized 0..1 glow contract.
4. Writes the canonical BuildDocument through the existing validated store and retains the original legacy file. An existing canonical BuildDocument always takes precedence and is never overwritten by the legacy profile.

Invalid legacy input is rejected and left untouched. The migration does not generate a hardware-ready JSON payload.

## Future shader integration gate

Only resume shader integration after all of the following are true:

- A surface/part binding exists for the active, provenance-tracked GLB asset.
- Shader controls are read from and written to the same BuildDocument used by paint and neon.
- A documented conversion maps legacy 0..10 values to the normalized render contract without losing meaning.
- Compatibility-renderer visual, occlusion, import, and Android performance tests pass.
- No second profile store, Autoload, or independent writer is introduced.

## Rendering constraints

The Compatibility renderer is the baseline. Emission without bloom must remain available as a fallback. Glow, transparency, depth behavior, Fresnel response, and fill-rate must be verified in the integrated garage and on the target Android device before any performance or visual-quality claim.

The shader is an artistic effect, not physical lighting simulation, body-fitment evidence, or engineering validation.
