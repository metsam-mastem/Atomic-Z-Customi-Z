# Commercial Neon Shader & Skin Profile Add-on

This add-on is an incremental enhancement for the Android-first Godot 4 customization lab. It does **not** replace the existing procedural bike assembly, neon segment configuration, touch orbit camera, or quality controller.

## Added assets

- `shaders/neon_glow.gdshader`: reusable additive spatial shader with adjustable color, intensity, pulse, core contribution, Fresnel rim falloff, and opacity.
- `scripts/skin_profile_store.gd`: optional Autoload profile store using versioned JSON, bounded numeric validation, user:// persistence, a profile_changed signal, and JSON export suitable for a hardware bridge.

## Integration steps (Godot 4)

1. Open Project > Project Settings > Autoload.
2. Add `res://scripts/skin_profile_store.gd` with the singleton name `SkinProfileStore`.
3. For a mesh-based neon tube/strip, create a ShaderMaterial using `res://shaders/neon_glow.gdshader`. Set `neon_color`, `glow_intensity`, and `pulse_speed` from the profile.
4. Listen to `SkinProfileStore.profile_changed` in the presentation controller and update the material parameters. Existing ribbon overlay visuals remain supported; apply this material only to suitable tube/strip meshes.
5. Save with `SkinProfileStore.save_profile()`; inspect its Error result. Copy/export `SkinProfileStore.export_hardware_json()` only where clipboard/export UI is implemented.

## Mobile rendering notes

- Existing project is configured for Godot 4.3 GL Compatibility. This shader uses standard spatial built-ins and additive blending; validate it on the target Android GPU and Godot version.
- Glow bloom is a WorldEnvironment post-process and is separate from shader emission. Enable it only after profiling on target hardware.
- Fresnel is view-angle based, not a physical tube cross-section or distance falloff. The visual is an artistic neon effect, not lighting simulation.
- No real ZX-25R model, hardware transport, Play Billing, or APK validation is included in this add-on.
