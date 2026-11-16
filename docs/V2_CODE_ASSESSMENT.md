# Atomic-Z-Customi-Z v2.0 — Feasibility and Integration Assessment

Input: user-supplied Python / ModernGL / moderngl-window / Pyrr / ImGui prototype. Decision: reuse suitable concepts in the existing Godot runtime; do not add a second product runtime. Status: source review only; no execution or GPU validation.

## Reusable ideas and product mapping
| v2 idea | Decision | Integrated implementation |
|---|---|---|
| Primary/secondary color pickers | Adopt | Existing garage HUD and shared build state |
| Glow strength/falloff | Adopt with schema mapping | Godot emissive material and WorldEnvironment glow, clamped and quality-tiered |
| Animated pulse | Adopt optionally | Godot shader/material parameter driven by shared animation state |
| Horizontal/vertical blur | Concept only | Prefer built-in Godot glow; custom blur only if profiling proves need |
| Orbit camera | Adopt | Existing garage camera rig; add pan/zoom/touch bounds |
| Framebuffer resize | Do not port literally | Godot viewport owns resizing |
| ImGui panel | Do not port literally | Native responsive Godot Controls |
| JSON export | Adopt intent, replace format | Canonical BuildDocument with tested legacy migration |
| LED mapping | Conditional | Calibrated hardware profile only; no sample index assumptions |

## Blocking defects in submitted v2
1. Initialization failure: fallback geometry is created before neon_prog, but uses neon_prog to create its VAO.
2. model_path is declared but never loaded; renderer always uses fallback geometry.
3. Fallback vertices are a line sketch, not motorcycle mesh or Kawasaki geometry.
4. Scene FBO has no depth attachment and depth testing is not enabled; 3D occlusion is not established.
5. Bloom blurs the entire scene, not bright pixels; likely whole-scene haze rather than controlled bloom.
6. Texture format is not explicitly HDR floating-point; highlights above 1 may be clamped.
7. Blur offsets are hardcoded 0.004 and do not scale with resolution; use inverse texture-size uniforms.
8. A composite VAO is created every frame and never released; create once and reuse.
9. Resize callback/resource lifecycle must be checked against the exact moderngl-window version.
10. import imgui and wnd.imgui APIs may belong to different integrations; pin and verify exact packages.
11. Pyrr matrix layout and ModernGL upload convention must be validated with a known transform.
12. Export writes neon_skin_export.json using primary_hex/hardware_mapping; current product reads neon_skin_config.json using colors.primary/secondary/glow_intensity/line_segments. These schemas are incompatible.
13. LED ranges and controller/strip assumptions are illustrative, not measured or safe deployment instructions.
14. Export writes to process working directory and does not save/load complete vehicle build state.
15. Python/GLFW has no Android delivery path in this Godot product.
16. No automated tests, runtime evidence, GPU validation or target-device performance data were supplied.

## Integration rules
- Godot remains the only product runtime.
- Port camera interaction into the existing camera rig.
- Bind all controls to one shared build state.
- Prefer Godot native glow first; avoid duplicate post-processing pipeline.
- Export canonical BuildDocument, not a competing skin JSON.
- Hardware mapping requires calibrated controller, LED type, wiring, power, current, thermal and segment profile plus human approval.
- ModernGL may remain a research reference only; it owns no product UX or authoritative data.

## Required tests before accepting ports
- Palette updates only selected target and survives save/reload.
- Glow values reject NaN, infinity and out-of-range input.
- Pulse can be disabled and respects reduced-motion/quality settings.
- Camera orbit/zoom/pan bounds and touch/UI gesture separation work.
- Resize/orientation preserves viewport and controls.
- Glow does not haze whole scene or clip unexpectedly.
- Export validates and round-trips canonical schema.
- No hardware mapping emitted without calibrated profile.
- Target Android performance measured at every tier.

Feature concepts are feasible. Submitted v2 as production runtime is not acceptable. Porting concepts into Godot is the preferred path. No v2 code was executed for this assessment.