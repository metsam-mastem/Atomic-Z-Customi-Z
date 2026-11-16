# ModernGL Neon Renderer Experiment

**Status: EXPERIMENTAL / NOT VERIFIED / NOT PRODUCTION**

This folder preserves the user-submitted Atomic-Z-Customi-Z v1.0 ModernGL/GLFW code as a separate desktop rendering experiment. The source is retained for traceability; it is not wired into the Godot runtime and is not an Android implementation.

## Purpose

Explore a desktop GLSL rendering path for animated neon materials and compare it with the existing Godot neon skin subsystem. The shared product direction remains data-driven skins, stable segment IDs, and eventual use in the Godot garage.

## Source provenance

- Original source: supplied in the project conversation on 2026-11-16.
- Preserved source file: \`neon_skin_simulator.py\`.
- The original header says "Production Release"; that label is not an engineering status assessment. This repository records it as experimental until the acceptance gates below pass.

## Initial code audit

Known issues in the submitted source:

1. In the missing-OBJ fallback path, \`_create_fallback_geometry()\` is called before \`self.program\` is created, but the fallback creates a VAO using \`self.program\`. This causes initialization failure.
2. The fragment shader evaluates \`pow(1.0 - dist * 2.0, u_glow_falloff)\` before clamping. The base can be negative, which is undefined for a non-integer exponent and can produce invalid shader results.
3. The CPU matrix arrays are passed directly to GLSL with \`write(mvp)\`. Matrix storage/transpose conventions must be verified; the current code does not establish that the uploaded matrix is interpreted as intended.
4. The code calls \`self.load_scene(model_path)\` and \`scene.draw(program)\` without establishing a loader contract, vertex format, attribute binding, or OBJ material handling. Compatibility with the installed moderngl-window version is unverified.
5. The fallback geometry is six vertices rendered as lines, not a motorcycle mesh and not a ZX-25R/ZX-25RR representation.
6. The shader derives its pseudo-UV coordinate from object-space XY positions. It does not use authored UVs, panel masks, decals, or surface registration.
7. The shader emits bright color but does not implement a bloom post-process, HDR framebuffer pipeline, tone mapping, or physically based material integration.
8. Camera position is fixed; orbit/pan/zoom controls and resize-aware projection updates are absent.
9. FPS logging is not a performance acceptance test and has no target-device, percentile, thermal, or memory evidence.
10. There is no Android packaging path in this Python/GLFW experiment.

## Architecture decision

- Godot 4 remains the product runtime and Android path.
- \`neon_skin_config.json\` remains the shared data contract; future renderer adapters must consume a versioned schema rather than duplicate design state.
- ModernGL stays isolated in this experiment folder. Do not add it as a dependency of the Android app or Godot runtime.
- Do not claim ZX-25R/ZX-25RR fitment until a licensed, verified model asset and a coordinate/UV mapping contract exist.

## Dependencies

Install from the repository root:

\`\`\`bash
python -m pip install -r experiments/modern_gl_neon/requirements.txt
\`\`\`

The dependency declaration is a starting point only; installation and runtime compatibility have not been verified in CI.

## Acceptance gates

- [ ] Fix initialization order and add a regression test for missing-model fallback.
- [ ] Replace the unsafe glow expression with a mathematically bounded falloff function.
- [ ] Establish and test matrix upload convention with a known transform.
- [ ] Implement and test a documented OBJ/glTF loader and explicit vertex attributes.
- [ ] Add resize-aware projection and camera orbit/pan/zoom.
- [ ] Add a real HDR/bloom pipeline if bloom is a product requirement.
- [ ] Consume the shared, versioned neon skin schema.
- [ ] Add headless tests for configuration, shader compilation, geometry creation and fallback behavior.
- [ ] Add a reproducible desktop runtime test and performance benchmark.
- [ ] Keep Android feature parity in Godot; no Python/GLFW Android claim.
- [ ] Review licensing and provenance for all vehicle assets.

Until these gates are passed, status remains **NOT RUN / BLOCKED**, not production-ready.
