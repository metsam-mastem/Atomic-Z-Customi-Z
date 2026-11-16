# Reverse-Engineering Playbook

Use this workflow for public source repositories, owner-supplied binaries, Android packages, and other software that Atomic-Z is authorized to inspect. It is designed to preserve provenance, keep observations separate from assumptions, and avoid importing another product's protected content.

## 1. Admit the target

Record:
- exact project/product name and canonical source URL;
- target platform, version, architecture and build variant;
- owner/authority and scope of permission;
- acquisition date and SHA-256 of every locally supplied binary or archive;
- whether the work is source review, static analysis, runtime observation, or differential testing.

Do not analyze a binary or account/device that the owner has not lawfully supplied or authorized. Do not attempt to defeat DRM, anti-cheat, access controls, licensing checks or online-service protections.

## 2. Isolate the evidence

Use a working copy, never the owner's original install. Separate reference binaries, analyst notes, generated output and implementation source. For proprietary executables, follow the owner's legal and security requirements; prefer an offline VM/snapshot, no network, least privilege and read-only source media. Record any deviation. Do not place binaries, decrypted data, proprietary assets or private dumps in the Atomic-Z repository.

## 3. Inventory before interpreting

Create a file/tree inventory and identify:
- entry points and runtime version;
- subsystem boundaries;
- data models/resources and serialization;
- input and update/physics loops;
- scene/render/audio/network boundaries;
- tests and build/release scripts;
- dependencies, licences, third-party notices and bundled assets.

Classify every observed claim as **observed**, **derived**, **hypothesis**, **unknown**, or **not applicable**. Record the exact file path, function/symbol or observation reference supporting it.

## 4. Write a behavioural specification

Describe externally observable behaviour, inputs, state changes, timing, outputs, error cases and invariants in implementation-independent language. Keep unknowns explicit. Do not copy large source fragments, original comments, proprietary tables or decompiler output into a specification.

For numerical behaviour, record units, coordinate systems, timestep, precision, clamps, rounding and tolerance. Label values as runtime-captured, statically observed, derived from a stated formula, synthetic, or guessed. Never label a synthetic vector as a real game capture.

## 5. Independent review gate

A reviewer who did not produce the analysis checks:
- target hash/version and permissions;
- evidence trail and confidence labels;
- specification completeness and contradictions;
- source/asset contamination;
- licence scope and third-party exceptions;
- test-vector reproducibility and missing cases.

A material change to a specification invalidates its previous approval. Keep analyst-only scratch separate from implementation-facing documents where needed.

## 6. Clean implementation

Implement from the approved behavioural contract, not by copying recovered instructions or proprietary code. Prefer the project's existing engine and data model. Keep adapter boundaries small. Document every deliberate divergence and every unsupported behaviour.

For Atomic-Z:
- Godot/GDScript is the product runtime;
- `BuildDocument` remains canonical editable state;
- references stay outside `res://` and are not loaded at runtime;
- new identifiers and serialized fields require a migration/test plan;
- never import a parallel save database or editor.

## 7. Verify in layers

Minimum evidence:
- static parse/build test;
- unit/contract tests for rules and boundary values;
- synthetic fixtures with clear provenance;
- integration test against project contracts;
- deterministic replay/property tests where applicable;
- authorized runtime comparison only when the owner can lawfully supply the target;
- platform/device validation separately from desktop success.

Report **PASS**, **FAIL**, **NOT RUN**, or **BLOCKED**. A successful unit suite does not establish visual fidelity, original-game equivalence, correct vehicle fitment, Android performance or release readiness.

## 8. Publish a reconstruction ledger

For each subsystem keep:
- claim/requirement ID;
- evidence reference and source hash;
- confidence and unresolved questions;
- implementation commit/path;
- verification command and exact result;
- reviewer, date and approval hash;
- known limitations and rollback plan.

A subsystem is not “complete” merely because it compiles or looks similar. It is complete only against an explicit acceptance contract and disclosed evidence standard.

## REA-specific use

REA is an optional local tool for evidence-producing analysis. Use the official `morluto/rea` repository, review its installation plan, dependencies and permissions, and run it only against targets you are authorized to inspect. Its own documentation distinguishes static findings from runtime observations and warns that analysis does not prove behavioural equivalence. REA is not an Atomic-Z dependency and is not installed by this repository.

## What this workflow does not authorize

This playbook does not grant rights to reverse-engineer third-party products, bypass protections, distribute recovered content, or reuse third-party code. Obtain jurisdiction-specific legal advice for uncertain rights questions. When the licence is absent, mixed, or expressly excludes recovered content, keep the material study-only until permission is clear.
