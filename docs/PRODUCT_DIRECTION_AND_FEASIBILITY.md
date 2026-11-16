# Atomic-Z-Customi-Z — Product Direction, Manifesto & Feasibility Charter

**Version:** 1.0  
**Status:** Product-direction proposal for owner ratification  
**Prepared:** 2026-11-16  
**Repository:** `metsam-mastem/Atomic-Z-Customi-Z`  
**Authority:** Product owner is the principal decision-maker. This document records the proposed direction; it does not silently authorize risky implementation, external asset use, schema changes, or claims beyond evidence.

> This document supplements—not replaces—`docs/PROJECT_CHARTER.md`, `docs/UNIFIED_SYSTEM_SPEC.md`, `docs/ROADMAP.md`, `docs/acceptance.md`, `AGENTS.md`, or the canonical `BuildDocument` contract.

## 1. Executive decision

**Keep the project identity and core architecture. Sharpen the product promise and sequence delivery around a demonstrable, high-quality customization experience.**

Atomic-Z-Customi-Z should evolve into an **Android-first Motorcycle Customization Workbench / Digital Garage**: a user can inspect one motorcycle, customize its verified parts and surfaces, compose a visual identity, save a reproducible build, and present/share it. Engineering inspection and riding simulation may become later capabilities, but they must not displace the customization workbench as the product's center.

The immediate strategy is **one complete vertical slice, not a breadth-first feature explosion**.

### Product thesis

A beautiful, usable, honest motorcycle build studio is a stronger and more distinctive first product than a premature all-in-one motorcycle simulator. Its value is the continuity between design intent, structured build data, 3D preview, persistence, and shareable presentation.

## 2. Product identity and manifesto

### Mission

Give motorcycle enthusiasts a coherent digital garage where they can create, inspect, personalize, save, and present motorcycle builds—with clear boundaries between visual concepts and verified engineering data.

### Vision

A mobile-first workbench that feels like a premium motorcycle design studio: direct manipulation in a 3D garage, meaningful part-level customization, a portable build identity, and a credible path from concept asset to evidence-backed vehicle configuration.

### Manifesto

1. **The motorcycle is the product; the architecture serves it.** Internal engineering is valuable only when it improves the user's experience, product reliability, or ability to deliver.
2. **One garage, one workflow, one source of truth.** The user should not feel that separate tools or subsystems have been stitched together.
3. **Make the build tangible.** A change to a part, finish, or graphic should visibly update the same active 3D vehicle.
4. **A build is an identity, not a screenshot.** Preserve structured, versioned configuration so the user can reopen, compare, export, and share it.
5. **Visual ambition, evidence honesty.** Placeholder geometry is a concept; visual preview is not CAD fidelity, physical fitment, road legality, or engineering validation.
6. **Android-first means measured on Android.** Touch usability, performance, memory, thermal behavior, lifecycle and installation must be evidenced on target devices.
7. **Depth before breadth.** Finish and polish one compelling vehicle and a small, coherent set of customization options before expanding the catalog.
8. **Open-source reuse is due diligence.** License, provenance, compatibility, maintenance, security and integration cost must be reviewed before adoption.
9. **No architecture theater.** Governance, CI, documentation and abstractions are essential, but cannot substitute for an observable, usable product.
10. **Owner intent is supreme.** The assistant is a senior advisor and execution partner; proposals remain proposals until the owner approves them.

### Product tagline (working)

**Build it. Personalize it. Own the design.**

This tagline is provisional and may be revised by the owner.

## 3. What the product is—and is not

### Core product

- One Android-first Godot 4 application.
- One integrated 3D motorcycle garage and customization workbench.
- Vehicle identity/evidence display; Stock and Exploded assembly inspection.
- Stable part selection and part/surface editing.
- Paint/material finishes, graphics/decals and neon effects in one HUD.
- A canonical versioned BuildDocument with save/load, migration, history and export.
- Preview capture and a build presentation card; sharing/import based on portable build data.
- Adaptive rendering and diagnostics supported by measured device evidence.

### Future extensions, not first-release blockers

- A constrained, evidence-labelled performance estimator (e.g., virtual dyno) using declared assumptions.
- Build comparison and curated design challenges.
- More vehicle variants and verified component catalogs.
- Geometric inspection/collision checks, solver adapters and calibrated hardware profiles.
- Riding/handling simulation, if the owner later chooses it as a distinct roadmap milestone within the same product.

### Explicit non-goals for the first compelling release

- A full open-world motorcycle game, career, races, traffic, multiplayer or economy.
- A universal motorcycle CAD/engineering suite.
- Factory-grade fidelity for unverified vehicles.
- Actual mechanical performance prediction without validated geometry, physical parameters and test data.
- Hardware/LED deployment instructions without calibrated mappings and safety review.
- Multiple companion applications, parallel editors, alternate renderers, or a second writable build database.

## 4. Feasibility assessment

Ratings below are strategic estimates, not test results. **High** means achievable within the current project architecture; **Medium** means dependent on design/asset/test work; **Low / gated** means substantial evidence or specialist input is required.

| Capability | Feasibility | Main dependency / risk | Recommendation |
|---|---|---|---|
| Integrated garage HUD and camera interaction | High | Touch UX and scene integration | Continue; make this the daily product surface |
| BuildDocument-driven state and save/reopen | High | Schema discipline, migrations, round-trip coverage | Treat as a core invariant |
| Part selection and per-part paint/material | High–Medium | Stable IDs, imported asset material slots, ownership-safe edits | Deliver in vertical slice |
| Premium PBR paint/finish presets | Medium | Real GLB UVs/material authoring, Android rendering budget | Stage presets; profile on device |
| Verified decals/graphics/Livery Lab | Medium | UV/surface registration; cannot project arbitrary 2D art blindly | Start with a small verified surface set |
| Neon and animated visual effects | Medium | Shader/renderer compatibility, adaptive quality and UI integration | Keep; polish rather than multiply effect types |
| Exploded assembly view | Medium | Real part hierarchy, pivots, deterministic transforms | Keep as inspection feature; placeholders do not prove fitment |
| Build presentation card / preview export | High | Capture pipeline and stable metadata | High-value low-risk differentiator; prioritize |
| Build compare / share-import | High–Medium | Portable schema, validation, untrusted import handling | Plan after save/export stability |
| Build DNA / visual build identity | High–Medium | BuildDocument-derived metadata and presentation rules | Implement as a product layer, not a new data store |
| Virtual Dyno / stat deltas | Medium–Low | Credible parameters, model assumptions, validation | Optional game-like estimate only; label clearly |
| Accurate ZX-25RR production geometry | Low / gated | Licensed/authorized asset or high-quality modeling, exact year/market, provenance | Critical external asset dependency; do not fake |
| UV-aligned body graphics and true part fitment | Low / gated until asset | Validated geometry, UVs, part IDs and review | Block claims until verified |
| Physical motorcycle dynamics / riding simulation | Medium–Low | Two-wheel balance model, validated parameters, controls, substantial QA | Later extension; not current critical path |
| Engineering mass/collision/interference analysis | Low / gated | Verified geometry, units, materials/density, validation fixtures | Separate evidence-led milestone |
| Calibrated hardware mapping/deployment | Low / gated | Hardware-specific calibration, electrical and safety review | Keep opt-in and non-blocking |
| Android-first release hardening | Medium | Exact target-device installation and telemetry | Mandatory before release claims |

### Main feasibility conclusion

The product is **technically feasible as a focused customization workbench** using the existing Godot 4 + BuildDocument architecture. The largest bottleneck is not choosing another framework or adding more architectural layers. It is obtaining/authoring a credible vehicle asset with correct hierarchy, material slots and UVs, then validating the actual experience on Android.

## 5. Architecture: what changes and what stays

### Preserve (non-negotiable)

- Godot 4 / GDScript as the sole product runtime.
- Android-first delivery and Compatibility renderer baseline until measured evidence justifies change.
- One app lifecycle, scene/navigation flow, active vehicle/build context and HUD.
- One versioned BuildDocument as the sole authoritative editable build state.
- GLB/glTF 2.0 with Blender authoring/validation as the preferred asset pipeline.
- Stable IDs, explicit schema migration, source/license/hash and evidence classification.
- Branch/PR, test-first, exact-commit CI and review governance.
- Separation of visual-preview evidence from geometric, mechanical, legal and hardware evidence.

### Refine

- **Roadmap order:** product-facing vertical slice and real asset quality become the decisive milestones; new capability work is sequenced behind them.
- **Acceptance:** add end-to-end user outcome gates (edit → visible update → save → reopen → export/present), not only unit/contract tests.
- **Product status:** make a clear distinction among concept, implemented, CI-verified, device-verified, asset-verified and engineering-verified.
- **Scope control:** use explicit milestone gates and owner-approved exceptions to prevent unbounded feature additions.
- **BuildDocument:** enrich only when an actual user capability requires it; never create a separate Build DNA database or stats store.

### Remove or retire?

**No existing product capability should be deleted merely because this strategy is adopted.** The direction is a narrowing of priority, not a destructive rewrite.

Retirement policy:
- Retire parallel writable stores only through reviewed, tested migration with legacy user data preserved (the existing Neon migration work is aligned with this principle).
- Keep Python/Tkinter and ModernGL as developer/research references for now. Do not ship them as alternate product runtimes. Consider removal only after useful capabilities have been ported, dependencies are audited, and the owner approves.
- Do not delete neon, shaders, exploded view, diagnostics, engineering adapters or hardware concepts. Keep them as integrated/optional capabilities, but they are not all release blockers.
- Do not replace Godot, rewrite the application, or introduce a second engine.
- Do not remove placeholder geometry until a replacement asset is sourced and validated; instead label it persistently and avoid fidelity claims.

## 6. Proposed delivery sequence (gated)

### Gate A — Make the current garage feel like a product

Deliver one end-to-end slice:
1. Open the integrated garage on Android.
2. Select the active vehicle and a stable part.
3. Change a supported part finish/color (and one additional supported customization such as a neon palette or graphic).
4. Observe immediate, correct visual feedback in the same scene/HUD.
5. Save the build, close/reopen, and restore the exact configuration.
6. Export a build document and a presentation-ready preview/card.
7. Handle invalid input/import safely and preserve recovery behavior.

**Exit evidence:** automated contract/round-trip tests, CI export, reviewable runtime screenshots/video, and physical-device install/touch/persistence checks. No claim of premium fidelity until the asset gate is met.

### Gate B — Asset and surface credibility

- Select a specific ZX-25RR year/market/variant only when provenance is sufficient.
- Acquire or create an asset with documented license/source, SHA-256, coordinate frame, hierarchy, stable part IDs, pivots, material slots and UVs.
- Validate GLB import, mesh/material mapping and surface registration.
- Review against references without claiming factory CAD unless that is the actual licensed/evidenced asset.

**Exit evidence:** asset manifest, validation report, visual review, part/surface mapping checks and provenance/license approval.

### Gate C — Premium customization and build identity

- PBR finish catalog (paint, matte, metallic, gloss, carbon-like appearance only where the material supports it).
- Limited Livery Lab for verified surfaces.
- Build DNA as derived presentation metadata (palette, selected components, visual theme, name/description and document revision).
- Build card and preview export; compare two builds.
- Import/share portable build data with validation and safe asset references.

**Exit evidence:** end-to-end tests, Android performance profiling and visual acceptance.

### Gate D — Performance and release hardening

- Profile exact target device SKU, SoC/GPU, RAM, Android version and display.
- Measure frame times/FPS, memory, thermals, pause/resume, storage, touch and recovery.
- Set regression budgets from measured baseline, not invented target numbers.
- Publish a reproducible debug/release pipeline and truthful release readiness.

### Gate E — Optional advanced systems

Prioritize only after Gates A–D:
- Virtual Dyno (explicitly approximate and assumption-driven).
- Expanded catalog and build challenges.
- Geometric/engineering preview with traceable evidence.
- Riding simulation or calibrated hardware support only after owner approval, separate feasibility, and acceptance plan.

## 7. Proposed priority matrix

| Priority | Work | Why |
|---|---|---|
| P0 | Resolve current PR integration/review dependencies; preserve single-state architecture | Avoid building atop unmerged/overlapping work |
| P1 | Finish edit → preview → save/reopen → export/presentation vertical slice | Proves product value |
| P1 | Source/author and validate a suitable licensed motorcycle GLB | Unlocks actual visual customization |
| P1 | Physical Android smoke/touch/persistence test | Proves Android-first claim |
| P2 | Verified material slots, UV/surface registration and small finish/graphic catalog | Makes customization trustworthy |
| P2 | Build card, Build DNA derived metadata, compare/share-import | Distinctive, relatively achievable product value |
| P3 | Premium rendering polish and measured adaptive quality | Visual quality without unmeasured performance cost |
| P4 | Virtual Dyno and other estimate-based game-like feedback | Optional engagement; avoid false engineering claims |
| P5 | Engineering solvers, riding dynamics, calibrated hardware deployment | Highest evidence/specialist burden; only after owner approval |

This sequence does not automatically supersede the canonical roadmap; it is a proposed product-direction overlay. Upon owner ratification, reconcile it into `docs/ROADMAP.md` through a separate reviewed change.

## 8. Target final product experience

The envisioned first strong product release should open directly into a polished, responsive digital garage—not a technical demo or documentation-driven workflow.

### Primary screen
- A premium studio environment with one well-authored motorcycle model.
- Responsive orbit/pan/zoom and clear touch controls.
- Vehicle identity and asset verification status.
- A compact, well-organized customization HUD with part selection, color/material presets, supported graphic/neon controls, Stock/Exploded toggle and reset/undo/redo where implemented.
- Immediate visible feedback with no second editor or external tool.

### Build workflow
- Name and save a build.
- Reopen it with exact state restoration.
- See structured metadata and selected parts.
- Compare builds without corrupting the active build.
- Export portable build data and a visually appealing preview card.
- Import a shared build only after validation and with safe handling of missing/unknown assets.

### Product feel
- Premium visual hierarchy, deliberate lighting, restrained motion and legible controls.
- Fast initial interaction, robust persistence, clear empty/error/recovery states.
- No fictional stats presented as measured engineering results.
- No fake factory details or fitment claims.
- A user should be able to produce a satisfying design artifact in a short session.

### Later, if selected by the owner
The same product can grow toward an integrated engineering-preview studio and motorcycle simulator. These extensions remain attached to the same build context and BuildDocument; they do not redefine the first product or require a parallel app.

## 9. Risks and mitigations

| Risk | Severity | Mitigation |
|---|---|---|
| Scope grows faster than product quality | High | Gate work; defer non-critical features; owner approves scope exceptions |
| Placeholder model limits perceived quality | High | Prioritize licensed/provenance-tracked GLB or professional authoring |
| Surface graphics do not align to bodywork | High | Require verified UVs/surface registration; no arbitrary projection claims |
| Architecture/governance becomes the visible product | High | Every milestone must demonstrate a user-facing vertical slice |
| Android rendering overload | High | Profile actual device; adaptive quality and explicit budgets |
| Stats imply real-world engineering accuracy | High | Separate estimated/game feedback from validated measurements |
| Import/share content corrupts or references unsafe/missing assets | Medium–High | Schema validation, versioning, safe asset references and recovery |
| External source licensing conflicts with distribution | High | License/provenance audit before copying or shipping |
| Existing state is lost during store consolidation | High | Test-first migration, retain source data, canonical writer only |

## 10. Success metrics (evidence-based)

Do not assign numeric performance targets until the actual device baseline is measured. Product success gates should include:

- A user can complete the primary customization workflow without leaving the Godot application.
- A saved build reopens with the same validated state.
- Exported build data validates and can be re-imported safely.
- Build preview/card corresponds to the actual active build revision.
- All shipped vehicle assets have provenance and license records.
- All displayed vehicle/engineering claims carry the appropriate evidence status.
- The target Android device passes install, launch, touch, persistence, lifecycle, performance and thermal checks with recorded measurements.
- A release milestone is closed only with CI, device, visual and asset evidence appropriate to that milestone.

## 11. Governance and owner decisions

The product owner remains the final authority on product scope, naming, trade-offs, feature priority, asset purchases/licensing, and release decisions.

### Decisions requested for ratification

- [ ] Ratify “Motorcycle Customization Workbench / Digital Garage” as the sharpened product positioning.
- [ ] Ratify “depth before breadth” and the vertical-slice-first delivery order.
- [ ] Confirm that riding simulation, Virtual Dyno, engineering solvers and hardware deployment are optional later-stage capabilities, not first-release blockers.
- [ ] Approve Build DNA as derived presentation metadata (not a parallel data store).
- [ ] Approve the target final experience described in Section 8.
- [ ] Approve reconciling this overlay into the canonical charter, roadmap and acceptance criteria.

Until checked by the owner, these items are proposals. Existing accepted architecture constraints remain in force.

## 12. Document maintenance

- This document is the canonical record of the product-direction proposal and its feasibility rationale.
- Approved changes must be reflected in the relevant charter/specification/roadmap/acceptance documents; avoid copy-pasting divergent versions.
- Update status and evidence only from repository and CI/device facts.
- A future agent must read this document alongside the existing canonical project documents and must not assume this proposal was ratified if the owner decision checklist remains unchecked.
