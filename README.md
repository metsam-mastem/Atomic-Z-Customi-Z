# Atomic-Z-Customi-Z — Unified Motorcycle Customization Workbench

One Android-first application. One vehicle/build context. One canonical data contract. Internally modular, externally one continuous product.

Atomic-Z-Customi-Z is a 3D motorcycle garage and customization workbench for vehicle inspection, Stock/Exploded assembly, part/material editing, neon and graphic design, persistence and export. Godot 4 / GDScript is the only product runtime and Android delivery engine.

**Asset honesty:** current motorcycle geometry is procedural placeholder geometry, not Kawasaki factory CAD, not a verified ZX-25RR replica and not an engineering-validated model.

## The integrated experience
- Vehicle identity and variant selection.
- Named part assembly with Stock / Exploded views.
- Orbit camera, touch/mouse input and adaptive rendering.
- Part selection and body paint/material editing.
- Neon/graphic layers in the same garage HUD and 3D scene.
- One saved build state and one export pipeline.
- Future asset catalog, parametric geometry, engineering checks and calibrated hardware adapters.

These are integrated capabilities of one application, not separate products or standalone subprojects.

## Run
1. Install the supported Godot 4 editor.
2. Clone this repository.
3. Import the folder containing project.godot.
4. Run the project from the editor.

## Android
An Android arm64 debug export preset and CI export job are present. A CI-generated APK is not equivalent to installation and validation on the target Redmi device. Physical-device acceptance remains separate.

## Verification
Run the current headless checks from the repository root:

    godot --headless --editor --path . --quit
    godot --headless --path . --script res://tests/smoke_test.gd
    godot --headless --path . --script res://tests/neon_skin_test.gd
    python -m unittest discover -s tests -p "test_*.py" -v

The Python tests currently cover the legacy desktop authoring/preview utility. That utility is a development aid and compatibility path, not a separate product experience. Product customization must converge into the Godot runtime and canonical BuildDocument.

## Architecture and governance
Read these before changing code:
- AGENTS.md — mandatory rules for every coding model/agent.
- docs/UNIFIED_SYSTEM_SPEC.md — product and system contract.
- docs/AGENT_GOVERNANCE.md — concurrent agent/branch/PR policy.
- docs/ROADMAP.md — end-to-end phases and exit gates.
- docs/V2_CODE_ASSESSMENT.md — v2 ModernGL feasibility and integration mapping.
- docs/RESEARCH_AND_DECISIONS.md — GitHub, Build Your Own X, Nature research and ADRs.
- docs/architecture.md — technical architecture.
- docs/acceptance.md — testable acceptance gates.

## Technology boundary
Godot owns the product scene, UI, input, materials, effects, persistence and Android export. Blender to GLB/glTF 2.0 to validation to Godot is the preferred asset path. Python/Tkinter and ModernGL are reference/developer tools; useful controls and rendering ideas are ported into Godot, not shipped as parallel product runtimes.

## Vehicle identity
The accepted base vehicle in project decisions is Kawasaki Ninja ZX-25RR. The initial neon document explicitly says ZX-25R. Do not treat these as identical for geometry, parts or fitment until exact year/market/variant evidence resolves the difference.

## Status vocabulary
Use PASS / FAIL / NOT RUN / BLOCKED. Code presence or a green headless test is not proof of Android device performance, factory geometry, fitment or engineering validity.