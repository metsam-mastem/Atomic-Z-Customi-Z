# Source Dossier: Motorcycle configurators and 3D showroom UX

These two repositories show useful product patterns for motorcycle part configuration and high-quality 3D presentation. They are web stacks, not Godot applications, and their repository-level reuse licences were not established in the inspected trees.

## 1. Whauv/MotoForge

**Repository:** https://github.com/Whauv/MotoForge  
**Reviewed revision:** f21a554256dff308dcafc069a666c13b1b56de25  
**Tree:** approximately 120 paths; JavaScript/TypeScript frontend with Python backend.  
**Licence:** no root LICENSE file was found; GitHub reports no licence grant.  
**Disposition:** STUDY_ONLY; no code reuse.

### Product architecture

MotoForge is a full-stack configurator:
- Next.js 14 / React / Three.js / React Three Fiber viewer;
- FastAPI backend, SQLAlchemy data model, SQLite MVP and migrations;
- separate motorcycle, mod-part and compatibility records;
- parts grouped into categories, with base-bike compatibility checked server-side;
- quotation service computes total price, HP delta and weight delta;
- URL can encode selected part IDs and “owns bike” state for shareable builds;
- GLB model manifest and naming/alignment rules are documented, but README says current seeded models still use placeholders and procedural fallbacks.

### Source-level observations

- Compatibility is a unique pair of motorcycle ID and mod-part ID with relational foreign keys.
- parts_service validates that each selected part exists and is compatible with the selected motorcycle.
- quote_service deduplicates repeated part IDs before summing price/weight/HP deltas, then returns ordered line items.
- The model library README requires one GLB per base bike and ideally one per mod part; it specifies a common coordinate frame/origin and consistent scale.

### What Atomic-Z can learn

- explicit compatibility matrices and part fitment constraints;
- part metadata such as category, SKU, brand, asset status and supported segment;
- shareable build serialization;
- derived build summaries/quotes with idempotent part selection;
- clear GLB naming/origin/axis conventions and a catalog of mesh provenance.

### What not to copy

- No licence grant was found, so the code cannot be copied into Atomic-Z without permission.
- Its React/Three.js + FastAPI + SQLite architecture creates a second runtime/database and conflicts with Atomic-Z's one Godot product and canonical BuildDocument.
- MotoForge's currently seeded real GLB files are placeholders according to its own model-library README. Do not present its fitment/pricing data as validated vehicle engineering facts.

Pinned files:
- [README](https://github.com/Whauv/MotoForge/blob/f21a554256dff308dcafc069a666c13b1b56de25/README.md)
- [Compatibility model](https://github.com/Whauv/MotoForge/blob/f21a554256dff308dcafc069a666c13b1b56de25/apps/api/app/models/compatibility.py)
- [Parts service](https://github.com/Whauv/MotoForge/blob/f21a554256dff308dcafc069a666c13b1b56de25/apps/api/app/services/parts_service.py)
- [Quote service](https://github.com/Whauv/MotoForge/blob/f21a554256dff308dcafc069a666c13b1b56de25/apps/api/app/services/quote_service.py)
- [GLB model library contract](https://github.com/Whauv/MotoForge/blob/f21a554256dff308dcafc069a666c13b1b56de25/apps/web/public/models/README.md)

## 2. rohithyv/3D-Motorcycle-Showroom (VOLT R1)

**Repository:** https://github.com/rohithyv/3D-Motorcycle-Showroom  
**Reviewed revision:** fa6d6d94005a76f6bc1d51126075ee2641a5e494  
**Tree:** approximately 95 paths; Next.js / React / TypeScript / React Three Fiber / Three.js / GSAP / Zustand.  
**Licence:** no root LICENSE file was found; GitHub reports no licence grant.  
**Disposition:** STUDY_ONLY; no code or fictional product data reuse.

### Product and architecture

The project is explicitly a fictional electric-motorcycle portfolio concept, not an OEM product. Its claims, prices, charging and performance details are fictional and the site has no checkout/payment integration.

The code is organised around:
- Viewport with lazy-loaded 3D scene, visibility gating and a mobile opt-in control;
- Scene with dynamic import, error boundary and image fallback if 3D fails;
- CameraRig with named camera presets, chapter choreography and smoothed target interpolation;
- GLB model loader with Draco decoder/preload and procedural fallback;
- separate Zustand stores for configuration, environment, engineering, experience and developer diagnostics;
- deterministic configuration domain and URL serialization;
- opt-in metrics for FPS, draw calls, triangles, textures and pixel ratio;
- texture anisotropy caps that use lower settings on mobile;
- Vitest and Playwright test coverage.

### Technical findings

1. Mobile-first 3D loading: the Viewport only mounts the 3D scene when visible; on small screens, it leaves the static fallback until the user explicitly enables 3D. Desktop preloads GLB near the viewport.
2. Resilient failure path: a scene error boundary preserves the rest of the experience and displays a static image fallback.
3. Camera choreography: camera targets are selected from named poses and blended over the timeline; target vectors are smoothed in the frame loop rather than forcing React re-render for every camera tick.
4. Configurator integrity: domain types/defaults constrain selections, parsing sanitizes query values and serialization produces a shareable query string. The specification values are explicitly fictional.
5. Performance visibility: developer panel tracks renderer information and texture optimisation reduces anisotropy on mobile; this is useful as a monitoring pattern, not proof of target-device performance.

### What Atomic-Z can learn

- static fallback before loading expensive GLB;
- load 3D only when visible and/or explicitly requested on mobile;
- scene failure boundary so the garage UI remains usable;
- camera presets for front, rear, detail, whole bike and exploded components;
- developer telemetry measuring FPS, triangles, draw calls, texture count and DPR;
- camera movement outside the main UI state store.

### What not to copy

- no repository-level licence grant was found;
- web/Three.js rendering is not compatible with Atomic-Z's single Godot runtime;
- all VOLT R1 specifications and product details are fiction, not engineering data;
- its 3D model represents a fictional product and does not validate any Kawasaki/ZX-25RR geometry or assembly.

Pinned files:
- [README](https://github.com/rohithyv/3D-Motorcycle-Showroom/blob/fa6d6d94005a76f6bc1d51126075ee2641a5e494/README.md)
- [Viewport](https://github.com/rohithyv/3D-Motorcycle-Showroom/blob/fa6d6d94005a76f6bc1d51126075ee2641a5e494/src/features/motorcycle/Viewport.tsx)
- [Scene](https://github.com/rohithyv/3D-Motorcycle-Showroom/blob/fa6d6d94005a76f6bc1d51126075ee2641a5e494/src/features/motorcycle/Scene.tsx)
- [CameraRig](https://github.com/rohithyv/3D-Motorcycle-Showroom/blob/fa6d6d94005a76f6bc1d51126075ee2641a5e494/src/features/motorcycle/camera/CameraRig.tsx)
- [Configurator domain](https://github.com/rohithyv/3D-Motorcycle-Showroom/blob/fa6d6d94005a76f6bc1d51126075ee2641a5e494/src/features/configurator/config/domain.ts)
- [Three.js texture optimisation](https://github.com/rohithyv/3D-Motorcycle-Showroom/blob/fa6d6d94005a76f6bc1d51126075ee2641a5e494/src/lib/three/optimize.ts)

## Atomic-Z integration decision

Use design lessons only:
- encode part-fitment constraints as validation against the canonical project part/vehicle catalogue;
- serialize a build from BuildDocument rather than creating a duplicate backend catalogue or URL as the source of truth;
- provide a fast static/low-cost fallback for heavy GLB scenes;
- load detailed meshes only when needed and instrument actual Android GPU/memory performance;
- create camera presets and detail/exploded-view choreography driven by current selected part IDs;
- keep all performance and engineering claims evidence-backed.

No React, Three.js, FastAPI, SQLite or web application code should be imported into the Atomic-Z runtime.
