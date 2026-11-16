# Atomic Z / JARYAN Virtual Fab Lab — Project Context Brief

Last reconciled: 2026-11-16

## Project identity and boundary

- Project: JARYAN Virtual Fab Lab / Atomic-Z-Customi-Z.
- Canonical repository: https://github.com/metsam-mastem/Atomic-Z-Customi-Z
- Product direction: Android-first cinematic motorcycle garage, customization, fabrication and engineering-preview lab; modular and extensible.
- This is a dedicated project stream. Do not merge unrelated JARYAN or other project repositories/workstreams without an explicit instruction.

## User decisions recovered from project conversations

- Accepted base motorcycle: Kawasaki Ninja ZX-25RR.
- Entry modes: Stock and Exploded.
- Graphics quality: Adaptive.
- Primary platform: Android.
- Earlier architecture direction: Godot 4 with Compatibility renderer and modular asset packs.

## Existing implementation and evidence boundaries

- Godot 4 garage / assembly foundation is present in the repository.
- The first scene uses procedural placeholder geometry. It is not a factory-accurate Kawasaki model or validated engineering asset.
- Stock/Exploded assembly and neon skin functionality have code and headless test coverage as described in the root README and acceptance documents.
- A Python/Tkinter 2D neon design-preview utility exists and consumes neon_skin_config.json.
- Godot neon runtime consumes the shared JSON, with provisional mapping onto a generic side plane. It is not UV-mapped or conformed to verified motorcycle body panels.
- CI/headless PASS claims apply only to the named checks and commit/run recorded in docs/acceptance.md. They do not establish Android export, physical-device behavior, fitment, or engineering validity.
- Exact ZX-25RR model, APK/device validation, and engineering simulation remain unresolved.

## Motorcycle identity / fitment constraint

A prior user request explicitly named ZX-25R for the neon skin configuration, while the accepted project base is ZX-25RR. Preserve both labels in their respective contexts until the user or authoritative model-year/market documentation resolves compatibility. Do not silently treat ZX-25R and ZX-25RR as interchangeable for exact body geometry, dimensions, parts, or fitment.

## Neon renderer decision (2026-11-16)

- User supplied a Python 3.10+ ModernGL / moderngl-window / GLFW shader prototype labelled Atomic-Z-Customi-Z v1.0.
- It has been preserved under experiments/modern_gl_neon/ with a separate audit and dependency declaration.
- Its "Production Release" header is not accepted as a verified release status.
- The code has known initialization-order, shader falloff, matrix upload, model-loader contract, geometry fidelity, camera-control, post-processing and Android-delivery gaps.
- ModernGL remains an isolated desktop rendering experiment. Godot 4 remains the product runtime and Android path.
- Keep neon_skin_config.json as the shared design-data contract; future adapters should use a versioned schema and stable segment IDs.

## Next work, in dependency order

1. Resolve exact target vehicle variant/year/market for model-specific assets and skin fitment.
2. Acquire or author a properly licensed model; record source, license, dimensions, coordinate frame and asset hash.
3. Validate the current Godot garage and neon subsystem against the repository acceptance gates.
4. Improve shared skin schema versioning and map neon paths onto verified 3D surfaces / UVs.
5. Keep ModernGL work isolated; first fix and test its startup fallback, shader math, matrix convention and model import before visual or performance claims.
6. Export and profile Android on the target device; record exact device SKU, GPU, Android version, build hash, frame-time, memory and thermal evidence.
7. Treat engineering simulation, road legality and mechanical fitment as separate validated capabilities, not visual-preview features.

## Status vocabulary

Use PASS / FAIL / NOT RUN / BLOCKED. Do not report a feature as complete without corresponding test or device evidence. Visual preview is not engineering validation.
