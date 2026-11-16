# Source Dossier: Godot vehicle-physics systems

This dossier compares three Godot vehicle references with different trade-offs: a MIT-licensed 4-wheel RigidBody arcade racer, a modular-but-unlicensed vehicle addon, and a CC0 C++ GDExtension prototype. None is a complete motorcycle simulation.

## 1. Seerban/godot-vehicle

**Repository:** https://github.com/Seerban/godot-vehicle  
**Reviewed revision:** 935e24c0942df0c0b907dc61512c37b6d64d4f57  
**Licence:** MIT  
**Project:** Godot 4.6 / Forward Plus, GDScript; approximately 844 tracked paths and a sizeable (about 132 MB) project with terrain, maps, models, textures and demos.  
**Disposition:** STUDY_ONLY for Atomic-Z; MIT permits consideration of original code, but no source or assets were imported.

### Architecture

- Vehicle.gd derives from RigidBody3D and composes a VehicleController, VehicleData, axle nodes and RayCast-based wheels.
- VehicleController exposes throttle, brake, steering and a custom process hook, giving a clean input/controller seam.
- VehicleData.gd groups Resources for chassis, engine, transmission, aspiration, suspension, tires, brakes, drivetrain, weight and aero. Setters update the attached body and recompute derived performance values.
- Wheel.gd is a RayCast3D; it computes contact point, spring compression/damping, grip left, longitudinal/lateral friction and skid particles.
- Race code includes sprint checkpoints, ghost recording/replay, race previews, minimap/path data, car shop and performance/grip UI.

### Physics findings

The wheel node:
1. raycasts for ground contact;
2. estimates suspension compression from current travel;
3. uses the compression difference as a simple damping term;
4. uses paired left/right spring compression for anti-roll force;
5. estimates contact-point velocity from chassis linear velocity plus angular velocity crossed with wheel offset;
6. projects velocity onto local forward/side directions;
7. limits longitudinal/lateral tire forces using remaining grip;
8. feeds grip usage into UI and tyre-mark particle effects.

The vehicle is a four-wheel car. It relies on authored axles and mirrored wheels; steering and grip are configured for a conventional car. Its code includes an explicit grip-forgiveness control to trade physical coupling for arcade behaviour. This is a gameplay vehicle implementation, not proof of real tyre dynamics or a motorcycle balance solution.

### Test/usefulness assessment

Strong candidates to study:
- clear controller input contract;
- VehicleData/Resource composition;
- wheel contact and spring/grip separation;
- independent UI telemetry for grip usage;
- ghost replay and checkpoint/race structures.

Cautions:
- the project targets Godot 4.6 Forward Plus, while Atomic-Z's baseline is Godot 4.4.1 Compatibility;
- the repo is large and bundles non-core assets/addons, each needing its own notice and performance review;
- the car's four-corner suspension and anti-roll model cannot be reinterpreted as a two-wheel motorcycle solver;
- runtime and Android performance were not executed by this audit.

Pinned files:
- [Vehicle.gd](https://github.com/Seerban/godot-vehicle/blob/935e24c0942df0c0b907dc61512c37b6d64d4f57/Scripts/vehicle/Vehicle.gd)
- [Wheel.gd](https://github.com/Seerban/godot-vehicle/blob/935e24c0942df0c0b907dc61512c37b6d64d4f57/Scripts/vehicle/Wheel.gd)
- [VehicleController.gd](https://github.com/Seerban/godot-vehicle/blob/935e24c0942df0c0b907dc61512c37b6d64d4f57/Scripts/controller/VehicleController.gd)
- [VehicleData.gd](https://github.com/Seerban/godot-vehicle/blob/935e24c0942df0c0b907dc61512c37b6d64d4f57/Resources/VehicleData.gd)
- [GhostPlayer.gd](https://github.com/Seerban/godot-vehicle/blob/935e24c0942df0c0b907dc61512c37b6d64d4f57/Scripts/sprint/GhostPlayer.gd)

## 2. Kurtzmusch/kv-vehicle

**Repository:** https://github.com/Kurtzmusch/kv-vehicle  
**Reviewed revision:** e37b7ea335a45a2f6d220a4fea3603a248aaac08  
**Licence:** GitHub metadata reports NOASSERTION; no root LICENSE file was found in the inspected tree.  
**Disposition:** STUDY_ONLY; do not copy until rights are clarified.

### Architecture and components

The README describes a modular Godot 4 physics-based vehicle addon with:
- engine and drivetrain, including analogue clutch;
- a basic torque-limited LSD and an inter-differential LSD;
- brakes with ABS toggle;
- input handling for mouse steering, keyboard and gamepad;
- sway-bar/anti-roll support;
- KVVehicle, KVWheel, TireResponse resources;
- spring and tyre forces, raycast or shapecast contact;
- optional tyre sounds, bump response, debug vectors, centre-of-mass tools and Ackermann steering.

### Documented limitations (important)

Its own README states:
- suspension travels in a straight line and does not model real or fake suspension geometry;
- Godot shapecast becomes less reliable farther from world origin;
- wheel/engine feedback uses previous-frame values and can oscillate; substeps and tuning are used to mitigate this;
- sim-racing hardware support was not implemented.

The inspected TireResponse.gd is data-driven by surface metadata, with configurable friction, load influence, tyre audio and optional noise-sampled bumps. This is useful for understanding surface-dependent grip/audio, but the missing licence and known simulation limitations make it reference-only.

Pinned files:
- [README](https://github.com/Kurtzmusch/kv-vehicle/blob/e37b7ea335a45a2f6d220a4fea3603a248aaac08/README.md)
- [TireResponse.gd](https://github.com/Kurtzmusch/kv-vehicle/blob/e37b7ea335a45a2f6d220a4fea3603a248aaac08/addons/kv-vehicle/TireResponse.gd)

## 3. AurickMikleton/ModuVehicle

**Repository:** https://github.com/AurickMikleton/ModuVehicle  
**Reviewed revision:** 618e43db7578dcf9d4ca4640d832b45a94ef1ddc  
**Licence:** CC0-1.0 (repository LICENSE; third-party godot-cpp and other dependencies retain separate licences).  
**Project:** Godot 4.5+ C++ GDExtension, CMake/C++17; WIP, README explicitly says no completion ETA.  
**Disposition:** STUDY_ONLY for current Atomic-Z architecture; CC0 is permissive, but native-extension build/version/platform burden is not justified for the current prototype.

### Modular data architecture

The project represents vehicle subsystems as swappable Resource types. VehicleAssembly contains identity/kind and separate chassis, engine, gearbox, differential, aero, assist, audio and wheel-module resources, plus vehicle control/brake configuration. Dedicated specifications exist for engine, gearbox, tyre, suspension, differential, chassis, assist and audio.

This is a useful example of separating authored tuning data from the vehicle runtime. It also explicitly includes a vehicle_kind enum containing motorcycle, although the inspected demo and physics paths are primarily an early generic/car implementation, not a completed motorcycle.

### Physics implementation findings

- tire_math.cpp computes combined longitudinal and lateral tyre demand using slip ratio and slip angle, load-sensitive stiffness, a friction coefficient times normal load, hyperbolic-tangent response curves, and a combined-force magnitude limit.
- Slip ratio is normalised against a minimum reference ground speed; slip angle uses longitudinal/lateral contact velocity.
- Optional traction control limits drive torque against a target drive-slip ratio.
- Wheel angular motion is integrated from drive torque, tyre reaction torque, rolling resistance and brake resistance; a bounded iterative solve (22 bisection iterations in the inspected code) estimates the next wheel angular velocity.
- suspension_math.cpp uses compression velocity, distinct compression/rebound damping and spring rate, clamping negative normal force to zero.
- car.cpp gathers wheel contact kinematics, wheel angular speed, drive torque and force application at contact offsets.
- transmission.cpp models clutch engagement with a smoothstep curve and clamps clutch torque to an RPM-dependent capacity.

These are much richer than a simple forward-speed arcade controller. However, a mathematically coherent car tyre model is not a validated motorcycle model. The constants, load assumptions, coordinate choices and solver require unit tests and calibration before any product use.

### Integration blockers

- C++ GDExtension, Godot 4.5+, CMake and godot-cpp submodule; it creates a separate native build matrix for Android, desktop and Godot ABI/version.
- README says WIP with no ETA; the project still includes TODOs and an example-focused demo.
- No evidence in this audit that a full motorcycle, rider balance, two-wheel steering/self-stability or production handling has been delivered.
- CC0 applies to this repository's original contribution; dependency notices remain separate.
- No build, binary, Android export or runtime was executed as part of this source audit.

### Atomic-Z decision

Use the resource-boundary and validation ideas, and treat the tyre/suspension mathematics as research only. Do not add a C++ GDExtension to Atomic-Z now. A GDScript prototype with explicit tests is the smaller path compatible with current Android export and Godot baseline. Only consider a native extension later if profiling shows a real bottleneck and the owner approves a versioned Android/Desktop build matrix.

Pinned files:
- [README](https://github.com/AurickMikleton/ModuVehicle/blob/618e43db7578dcf9d4ca4640d832b45a94ef1ddc/README.md)
- [CC0 licence](https://github.com/AurickMikleton/ModuVehicle/blob/618e43db7578dcf9d4ca4640d832b45a94ef1ddc/LICENSE)
- [Wheel math](https://github.com/AurickMikleton/ModuVehicle/blob/618e43db7578dcf9d4ca4640d832b45a94ef1ddc/src/math/tire_math.cpp)
- [Suspension math](https://github.com/AurickMikleton/ModuVehicle/blob/618e43db7578dcf9d4ca4640d832b45a94ef1ddc/src/math/suspension_math.cpp)
- [VehicleAssembly resource](https://github.com/AurickMikleton/ModuVehicle/blob/618e43db7578dcf9d4ca4640d832b45a94ef1ddc/src/resources/vehicle_assembly.cpp)

## Transferable Atomic-Z ideas

If a future riding prototype is approved, combine the strongest design lessons rather than selecting a car solver and pretending it is a motorcycle:
1. One normalized input resource for touch, keyboard and controllers.
2. Explicit wheel/contact/suspension/tyre signals with measured units.
3. Per-bike spec resources with validation, distinct from the existing cosmetic BuildDocument and GLB surface catalog.
4. Deterministic fixed-step/substep policy documented with tests.
5. Separate simulation, camera, animation, sound and telemetry.
6. State-transition and physics-boundary tests (zero speed, airborne, high slip, contact loss, inverted bike, save/load).
7. Keep simulation parameters out of product claims or manufacturing documentation until calibrated.

This dossier is not an approval to change Atomic-Z's current product scope or import a vehicle engine.
