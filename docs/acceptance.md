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


## Latest CI evidence
- PASS — Godot 4.4.1 headless project import/parse and smoke test at commit 2f3fb46ef80f6304355a1eb37260ffecfedeee54.
- PASS — smoke assertions: main scene load, named fuel-tank part, exploded transform movement, stock transform restoration and body material update.
- Run: https://github.com/metsam-mastem/Atomic-Z-Customi-Z/actions/runs/43778397883
- NOT RUN — Android export/install, visual review, touch-on-device, thermal/performance profile and manufacturer-model accuracy.

 
## Neon skin utility gates
- [ ] JSON parses and preserves the requested ZX-25R skin configuration.
- [ ] Python unit tests validate color references, geometry point arrays and glow range.
- [ ] Tkinter app opens on a desktop with Tk support.
- [ ] All three layer visibility toggles work.
- [ ] Primary/secondary color selection updates the preview.
- [ ] Glow slider changes layered stroke appearance.
- [ ] Save/reload round-trips valid JSON without losing segment IDs or points.
- [ ] A verified ZX-25R/ZX-25RR reference image and model-year/market mapping exist before claiming physical fitment.

## Godot neon runtime gates

- [ ] Valid JSON loads without changing stable segment IDs or palette values.
- [ ] Duplicate IDs, malformed points, invalid hex colors, unknown named colors, non-positive widths and glow values outside [0, 1] are rejected.
- [ ] Global neon visibility and each segment visibility can be controlled independently.
- [ ] Primary/secondary palette updates rebuild only affected segment visuals.
- [ ] Glow intensity updates emissive energy and remains clamped to [0, 1].
- [ ] Headless Godot contract test passes in CI.
- [ ] Visual appearance is reviewed on desktop and Android; no bloom or frame-rate claim before device verification.
- [ ] 2D-to-3D paths are registered against an exact model-year/market asset before claiming panel alignment or fitment.

- [ ] Neon palette, normalized glow, global visibility and per-segment visibility round-trip through BuildDocument serialization; no runtime API writes a separate skin JSON file.

## Unified-system acceptance gates (2026-11-16)

The following gates supersede any interpretation of the garage, material editor, neon design or renderer as separate products. They must be exercised as one end-to-end workflow in one Godot runtime.

- [ ] One canonical versioned BuildDocument is the source of truth for vehicle, assembly, materials, graphic/neon layers, render settings and export metadata.
- [ ] Legacy neon_skin_config.json imports through an explicit migration and does not create a competing writable state store.
- [ ] Selecting a vehicle, switching Stock/Exploded, selecting a part, changing paint/neon, saving, reopening and exporting works without leaving the application.
- [ ] Stable vehicle/part/surface/layer IDs survive edits, save/load and migration.
- [ ] UI controls update the shared build state; renderer consumes that state; persistence/export serialize the same state.
- [ ] Invalid or incompatible part/surface combinations are rejected before mutating the active build.
- [ ] Undo/redo and reset restore the complete relevant state.
- [ ] Neon/graphic paths are surface-bound to a verified model before any body-fitment claim.
- [ ] Glow/bloom quality is configurable and profiled on Android; low tiers degrade gracefully.
- [ ] Hardware mapping export is disabled unless a calibrated controller/LED profile is present and explicitly approved.
- [ ] One integrated end-to-end test covers selection → edit → render-state update → save → reload → export round trip.
- [ ] Agent collaboration follows AGENTS.md and docs/AGENT_GOVERNANCE.md; all future source changes use branches and reviewed PRs.

Status of these new gates: NOT RUN. Existing headless tests and CI history cover only the specific behaviors named above in their original sections; they do not automatically satisfy this end-to-end contract.

## Part-level customization and persistence hardening

- [x] Garage part selector lists stable part IDs and supports selecting each named assembly part.
- [x] Paint edits affect only the selected part and update its own material record in BuildDocument.
- [x] Existing per-part paint records are restored to the correct runtime mesh after load.
- [x] Saving validates the candidate document before replacing the current save.
- [x] Save replacement uses a temporary file and recoverable backup; failed backup rotation preserves the last valid primary save.
- [x] Loading restores a valid backup if the primary save is corrupt or missing.
- [x] Assembly Stock/Exploded mode and global neon visibility restore from the canonical BuildDocument.
- [x] Godot 4.4.1 CI smoke and BuildDocument tests pass on the current feature head.

Implementation status: PASS — headless import, garage smoke, neon and BuildDocument tests passed at commit `b773e6911fc30bf20693211ca745c8d7995beae3` in CI run [#43788490715](https://github.com/metsam-mastem/Atomic-Z-Customi-Z/actions/runs/43788490715). Android Debug export passed after enabling ETC2/ASTC at commit `ced48a657dd688d683b9328a97081af7bfad52ac` in CI run [#43788240486](https://github.com/metsam-mastem/Atomic-Z-Customi-Z/actions/runs/43788240486). Physical device acceptance remains NOT RUN.


## GLB surface material binding and unified HUD

- [ ] Stable surface IDs resolve to unique MeshInstance3D node paths and valid mesh surface indices.
- [ ] Applying a material changes only the selected surface and duplicates the source resource.
- [ ] Imported base PBR materials and unrelated surface overrides remain unchanged.
- [ ] Binder rejects duplicate IDs, aliased slots, missing nodes, invalid indices and global material_override conflicts atomically.
- [ ] Binder refuses to replace or clear a surface override after ownership transfers to another component.
- [ ] The focused binder contract test runs in the pinned Godot 4.4.1 CI workflow.
- [ ] Binder surface records are connected to imported-asset provenance and canonical BuildDocument material targets before the UI exposes full surface editing.
- [ ] Primary/secondary neon color pickers and glow slider hydrate from the active BuildDocument on garage startup.
- [ ] A saved build reopened in a fresh garage scene displays the same visible HUD values as the canonical BuildDocument.

Implementation status: implementation and focused test additions are present on the unified feature branch. Exact-head CI verification is pending. Android export does not imply physical-device acceptance.
\n\n## Legacy profile migration acceptance\n- [ ] On first launch without a canonical BuildDocument, a valid `user://skin_profile.json` imports its color into the primary BuildDocument palette.\n- [ ] Legacy 0..10 glow and pulse values are preserved unchanged in a versioned `extensions` record; they are not silently coerced to the 0..1 render contract.\n- [ ] The canonical document is saved through `BuildDocumentStore`, and the original legacy profile file is retained.\n- [ ] A valid existing BuildDocument takes precedence over any stale legacy profile and the old file remains untouched.\n- [ ] Invalid legacy values are rejected without mutating the source profile or active document.\n- [ ] Godot contract and first-launch migration tests run in the pinned 4.4.1 CI workflow.\n