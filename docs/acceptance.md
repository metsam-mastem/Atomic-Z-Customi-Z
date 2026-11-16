# Vertical Slice Acceptance Gates

Status vocabulary: PASS / FAIL / NOT RUN / BLOCKED. Source code existing is not proof of completion.

## Runtime checks
- [ ] Project imports in selected stable Godot 4 release without parse errors.
- [ ] Main garage scene opens and camera frames the procedural motorcycle.
- [ ] Every named placeholder part is independently addressable.
- [ ] Stock mode restores every part to its home transform.
- [ ] Exploded mode applies deterministic offsets without changing part IDs.
- [ ] Body color control changes only designated body panels.
- [ ] Mouse drag and Android touch drag orbit the camera.
- [ ] Zoom remains within configured distance bounds.
- [ ] Adaptive quality disables shadows only after sustained low FPS and restores them only after sustained high FPS.

## Device checks
- [ ] Export Android debug APK using official Godot export templates.
- [ ] Install and launch on the target Redmi Note 13 Pro SKU.
- [ ] Record exact SoC/GPU, RAM, Android version, resolution and free storage.
- [ ] Measure median and 1% low FPS, frame time, memory and thermal behavior over 10 minutes.
- [ ] Verify touch input, UI scaling, pause/resume and orientation behavior.
- [ ] Capture evidence and retain build hash.

## Asset checks
- [ ] Model source and license documented.
- [ ] GLB passes Khronos glTF Validator.
- [ ] Named nodes and coordinate system match the asset contract.
- [ ] Dimensions checked against authoritative drawings or measurements.
- [ ] No factory-accuracy claim until geometry is verified.

## Engineering checks
- [ ] Geometric checks have unit tests and known-answer fixtures.
- [ ] Mass values identify density and geometry source.
- [ ] Structural/thermal/CFD features identify solver, assumptions, boundary conditions and validation cases.
- [ ] Visual-only previews are labeled visual-only.

## Verification record
No Godot editor/runtime, Android export or physical-device test has been run during this GitHub bootstrap. Runtime and device gates remain NOT RUN until executed in the project environment.
