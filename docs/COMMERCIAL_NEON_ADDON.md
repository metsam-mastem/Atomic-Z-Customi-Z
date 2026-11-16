# Neon Shader Research Artifact and Legacy Profile Retirement

**Status:** The shader is a research artifact, not integrated into the product runtime.  
**Product boundary:** One Godot 4 application and one canonical versioned `BuildDocument`.

## Current disposition

- `shaders/neon_glow.gdshader` remains an experimental visual shader. It is not wired into the garage's `NeonSkin` runtime, has no verified imported-surface binding, and has not passed target-Android visual or performance acceptance.
- The former `scripts/skin_profile_store.gd` profile writer is retired. It was not registered as an Autoload in `project.godot` and had no product-code callers.
- `NeonSkin.save_skin()` is retired as well. Runtime palette, per-segment visibility, global neon visibility and normalized glow state are held in the active `BuildDocument` and persisted through `BuildDocumentStore`.
- `neon_skin_config.json` is a read-only legacy import source. It is not an active user-data save target.
- `user://skin_profile.json` is accepted only as a one-time legacy migration input when no valid canonical BuildDocument exists. The original file is retained after migration.
- Legacy shader `glow_intensity` and `pulse_speed` values in the 0..10 range are preserved unchanged in a versioned `extensions` record with status `preserved_unmapped`. They are not converted into the canonical renderer's 0..1 glow value.
- A valid existing `user://atomic_z_build.json` always takes precedence. All subsequent edits and saves use the canonical BuildDocument path.

## Migration safety

The first-launch migration validates the legacy schema, color and numeric ranges before importing. Invalid files remain untouched. If canonical persistence fails, the profile is retained and the migration remains in memory only for that session; no claim of successful migration is made.

The legacy profile migration does not generate hardware-ready JSON. Hardware mapping remains disabled until a calibrated controller profile, validated segment mapping and explicit hardware acceptance exist.

## Future shader integration gate

Resume shader integration only after all of the following are met:

- A surface/part binding exists for the active provenance-tracked GLB asset.
- Shader controls read and write the same BuildDocument used by paint and neon.
- A reviewed mapping exists between legacy 0..10 parameters and normalized render parameters.
- Compatibility-renderer visual, occlusion, import and Android performance tests pass.
- No second profile store, Autoload or independent writer is introduced.

The shader is an artistic effect, not physical lighting simulation, body-fitment evidence or engineering validation.
