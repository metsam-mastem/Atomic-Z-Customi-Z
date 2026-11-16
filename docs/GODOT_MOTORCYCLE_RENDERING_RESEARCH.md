# Godot 4 Motorcycle Rendering and Asset Integration — Technical Review

Date: 2026-11-16
Status: accepted engineering guidance; implementation gates remain open
Scope: Atomic-Z-Customi-Z, one Android-first Godot application
Baseline inspected: `project.godot` declares Godot 4.3 and `gl_compatibility` for desktop/mobile.

## Executive decision

Adopt the useful principles from the supplied proposal, but do not copy its sample scripts as a drop-in patch. The repository already has a canonical `BuildDocument`, a Godot neon runtime, a quality controller, and a Compatibility-renderer baseline. The proposal's `GameData` singleton and independent skin save file would create a competing source of truth. Its bike controller and motorcycle physics are also outside the current garage/customizer product boundary.

The implementation order is: (1) validated GLB import and material-slot inventory, (2) per-surface material adapter preserving imported PBR data, (3) measured emissive/glow tiers, (4) Android profiling, and only then (5) optional riding-physics research if the product scope explicitly expands to a rideable simulator.

## Findings: adopt, adapt, defer, reject

| Proposal item | Decision | Application to this repository |
|---|---|---|
| GLTF surface-level material override | ADAPT | Use `MeshInstance3D.set_surface_override_material()` only for the identified target surface(s); preserve original materials and map stable surface IDs to mesh/surface indices. Do not replace every surface with one neon shader. |
| Imported GLTF material cleanup | ADAPT | Add an import/validation pass that inventories imported scene hierarchy, mesh surfaces, material names, texture references and provenance. Do not mutate shared imported resources blindly. |
| Unshaded emissive neon | ADOPT WITH TIERS | Prototype against the existing neon runtime. Keep a no-bloom emissive baseline; enable glow only in supported quality tiers after profiling. |
| Fresnel/pulsing shader | DEFER | Optional visual enhancement after the base material pipeline and Android shader compatibility tests. Clamp dot products and intensity; avoid making the shader the only neon path. |
| `GameData` Autoload + skin.save | REJECT | `BuildDocument` is the sole authoritative state. Store palette, emissive values, animation and surface binding in its customization/render records; use the existing unified save/load and migration path. Signals may notify UI, but may not introduce duplicate authoritative values. |
| Bike driving controller | OUT OF CURRENT SCOPE | Current product is a customization/engineering-preview garage, not a racing game. Keep camera/inspection controls distinct from throttle/steering simulation. |
| Raycast motorcycle physics add-on | RESEARCH ONLY | Consider only after an explicit rideable-simulator scope decision, Godot-version compatibility review, license/provenance review and isolated benchmark. Do not add it as a current runtime dependency. |
| Kenney racing starter kit | PATTERN REFERENCE ONLY | It is a Godot 4.6 racing template with car-oriented scene conventions, while this repository currently declares Godot 4.3 and is not a racing game. Reuse only general lessons that fit the garage; do not replace the scene tree or import its vehicle controller. |
| Glow / Bloom | ADOPT WITH PROFILED TIERS | Use the existing WorldEnvironment and quality-controller path. Compatibility renderer has a distinct, reduced glow implementation; do not assume Mobile/Forward+ glow blend controls exist there. |
| “GLES3” renderer switch | CORRECT TERMINOLOGY | Godot 4 calls the renderer Compatibility (`gl_compatibility`), not a selectable GLES3 renderer preset. Keep the repository baseline until device evidence supports a renderer change. |

## Technical corrections to the supplied text

1. **There is no universal GLTF material-override bug established by the cited API.** Godot documents both `GeometryInstance3D.material_override` (applies to all surfaces) and `MeshInstance3D.set_surface_override_material(surface, material)` (applies to one surface). The latter is the correct tool when only selected imported material slots should change; it is not a universal fix for every import issue. Inspect `get_active_material()`, mesh surface count, imported hierarchy and material slot assignment before diagnosing.
2. **Do not apply one neon material to every surface.** That would erase the motorcycle's PBR paint, glass, rubber, metal and trim distinctions. Resolve target surfaces by stable asset metadata/part IDs and override only intended slots. Keep imported resources immutable where practical; duplicate materials before per-build edits so shared resources do not leak changes across instances.
3. **“Mobile lighting defaults to per-vertex” is too broad as a project-wide rule.** Lighting behavior depends on renderer, light type and material/shader configuration. An `unshaded` material bypasses scene lighting for that material, but it does not eliminate overdraw, transparency sorting, fill-rate, shader cost or post-processing cost.
4. **Glow blend-mode advice is renderer-dependent.** The Compatibility renderer uses a reduced glow implementation and hides several controls available in Mobile/Forward+. Therefore “set Glow Blend Mode to Additive” is not a portable instruction for this project.
5. **Godot 4.3 is the declared project feature baseline.** The cited motorcycle add-on targets Godot 4.5 and Kenney's racing starter kit targets Godot 4.6. Neither is a verified drop-in dependency for the current branch.
6. **The supplied `GameData` save design conflicts with the current architecture.** The repository's canonical document and unified persistence path must own the state. A second `user://custom_skin.save` file would cause divergence and migration ambiguity.
7. **`depth_draw_never` and additive transparency need occlusion tests.** They can make effects visible through geometry or produce ordering artifacts depending on the mesh and renderer. Do not enable them globally without a scene-level visual regression test.
8. **A shader's visual output is not evidence of correct vehicle mapping.** Existing neon points are legacy 2D coordinates mapped to a generic side plane. Do not claim body-conformal decals/neon until the exact ZX-25RR year/market asset, UVs or registered surface geometry are verified.

## Target implementation design

### A. GLB import and material binding

- Treat GLB as the asset interchange format; keep asset hash, source, license, vehicle variant, year, market and validation status in the asset/build records.
- Traverse the imported scene recursively. Record each `MeshInstance3D`, mesh resource, surface index, source material name and active material.
- Create a stable binding table from `surface_id` / `part_id` to imported node path + surface index. Do not use array order or display names as persistent identifiers.
- Preserve the original PBR material as the base. Apply a per-instance surface override only when the user edits that material slot.
- Duplicate the target material before editing it; never mutate a shared imported material resource that may be reused by another vehicle/build.
- Fail closed when a requested surface ID is missing or ambiguous. Report a diagnostic; do not silently apply a material to all surfaces.
- Add fixtures with multiple surfaces/materials, missing IDs, duplicate IDs and nested GLB nodes.

### B. Neon and glow

- Keep neon parameters in `BuildDocument`: stable layer ID, target part/surface ID, palette token or color, normalized emissive intensity, visibility, animation settings and mapping evidence/status.
- Maintain a fallback unshaded emissive material that works without bloom. Glow is an optional enhancement, not a correctness dependency.
- Use a small number of reusable material/shader resources; avoid creating multiple independent glow meshes/materials per frame.
- Keep bloom/glow controlled by the existing quality controller. Compatibility's glow path must be tested separately from Mobile/Forward+.
- Add quality tiers such as `low` (emission only), `balanced` (emission + restrained glow) and `high` (enhanced glow) only when the settings map cleanly to the current renderer.
- Test occlusion, alpha blending, depth sorting, pulse animation, pause/resume and low-tier fallback on actual Android hardware.

### C. Performance and diagnostics

- Measure baseline before optimizing: frame time, median FPS, 1% low FPS, memory, draw calls/material count where available, thermal behavior and sustained performance.
- Profile on the exact Redmi Note 13 Pro variant and record SoC/GPU, RAM, Android version and Godot build.
- Do not infer a performance win from `unshaded`, `blend_add` or a renderer name alone.
- Avoid real-time shadows and expensive glow on low tier; keep the existing adaptive-quality path as the single owner of runtime quality decisions.
- Record the active renderer and quality tier in diagnostics.

### D. Optional motorcycle dynamics

The current app does not need a driving controller to deliver its accepted garage workflow. If a future product decision adds a rideable preview, evaluate the RayCast-based add-on as a research candidate, not as a dependency:
- Verify supported Godot version and porting delta against the project's pinned engine.
- Inspect full source, license, update history, open issues and known limitations.
- Separate simulation body/collision from the visual GLB hierarchy; use explicit wheel pivots and suspension/raycast geometry.
- Validate stability, low-speed balance, steering/lean coupling, braking and fixed-timestep behavior with repeatable test scenes.
- Profile on Android and retain an inspection-only mode that does not instantiate physics.
- Do not describe it as realistic motorcycle engineering simulation without validation data.

## Test-first acceptance gates

- [ ] A multi-surface GLB fixture imports and reports stable node/surface/material metadata.
- [ ] Editing one selected surface changes only that surface; other PBR slots remain unchanged.
- [ ] Shared imported materials are not mutated across two instances/builds.
- [ ] Missing/ambiguous surface IDs fail safely with diagnostics.
- [ ] Neon works with glow disabled; glow tiers do not break Compatibility rendering.
- [ ] Effects respect occlusion and do not bleed through opaque body geometry.
- [ ] Neon/material/render edits save and restore through the single BuildDocument path.
- [ ] Headless tests pass on the exact branch/commit; Android profiling is separately recorded.
- [ ] No driving-physics dependency is added unless the product scope is explicitly amended.

## Source references

- Godot 4 MeshInstance3D API: https://docs.godotengine.org/en/stable/classes/class_meshinstance3d.html
- Godot renderer comparison: https://docs.godotengine.org/en/stable/tutorials/rendering/renderers.html
- Godot Environment and Glow: https://docs.godotengine.org/en/stable/tutorials/3d/environment_and_post_processing.html
- Godot system requirements / Compatibility renderer support: https://docs.godotengine.org/en/stable/about/system_requirements.html
- Motorcycle physics candidate (Godot 4.5, MIT): https://github.com/rishabhsinghio/Godot-Simple-Motorcycle-Physics
- Kenney racing starter kit (Godot 4.6): https://github.com/KenneyNL/Starter-Kit-Racing

References are leads, not proof of compatibility or production readiness. Re-check their current revisions and licenses before any code reuse.
