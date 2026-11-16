# Android Build, Verification and Release Guide

**Product:** Atomic-Z-Customi-Z  
**Engine:** Godot 4.4.1 / GDScript  
**Delivery:** Android arm64 APK for development; signed release artifact only after release gates  
**Source of truth:** this repository and the exact commit used by the build

## 1. Build architecture

This is a Godot application. project.godot, export_presets.cfg, GDScript scenes/resources and the matching Godot Android export templates define the Android package. The supported default build uses Godot's prebuilt Android templates. Gradle is an optional Godot-managed custom-build path, not a second application runtime.

The CI toolchain is pinned in .github/workflows/godot-ci.yml: Godot 4.4.1, JDK 17, Android platform 34, Build Tools 34.0.0, NDK 23.2.8568313 and arm64-v8a. Upgrade this matrix only through a dedicated PR with fresh import, test and export evidence.

## 2. Local prerequisites

- Godot 4.4.1 with matching Android export templates.
- Java JDK 17.
- Android SDK platform 34 and Build Tools 34.0.0.
- Android NDK 23.2.8568313.
- Python 3.12 or compatible Python 3.
- Bash on Linux/macOS/WSL; Windows users may use WSL.

Configure Godot's Android SDK and Java paths in Editor Settings. Do not commit local SDK paths, keystores, passwords, signing keys or machine-specific editor settings.

## 3. Reproducible build

Run:

    bash scripts/build_android.sh debug

The script imports the project, exports with the Android Debug preset and validates the resulting APK. Output: build/Atomic-Z-debug.apk.

For the signed release preset:

    export GODOT_ANDROID_KEYSTORE_RELEASE_PATH=/secure/path/release.keystore
    export GODOT_ANDROID_KEYSTORE_RELEASE_USER=release_alias
    export GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD='provided-by-secret-manager'
    bash scripts/build_android.sh release

Release signing values must come from a secure secret store. They are never stored in Git. The release export is not equivalent to store readiness: package identity, versioning, privacy, permissions, licensing, crash behavior and device QA remain separate gates.

## 4. Artifact contract

A deliverable APK must:

1. Be a non-empty ZIP/APK container with no corrupt entries.
2. Contain AndroidManifest.xml.
3. Contain Godot's assets/project.binary.
4. Contain the exported Godot scene payload.
5. Contain lib/arm64-v8a/libgodot_android.so.
6. Contain DEX bytecode.
7. Pass Android apksigner verify in CI.
8. Have a recorded SHA-256 hash and exact source commit.

The verifier is scripts/verify_android_artifact.py. It checks package structure and can invoke the Android SDK apksigner. Unit tests are in tests/test_android_artifact.py.

Manual verification:

    python3 scripts/verify_android_artifact.py build/Atomic-Z-debug.apk \
      --apksigner "$ANDROID_HOME/build-tools/34.0.0/apksigner" \
      --require-signed

ZIP integrity is necessary but not sufficient: it does not prove Android can install or launch the APK.

## 5. Gradle policy

Do not add a free-standing Gradle project just to make the repository resemble a conventional Android Studio app. Godot generates its Gradle template from the matching export-template package when Project → Install Android Build Template is selected. Enable Use Gradle Build only for AAB export, Android plugins, approved SDK integrations or deliberate template customization.

If custom Gradle becomes necessary, commit the exact Godot-generated android/build template and document:
- Godot editor/export-template version and template provenance.
- Gradle wrapper version and distribution checksum.
- Android Gradle Plugin and Kotlin plugin versions, if used.
- JDK, compile SDK, target SDK, min SDK and NDK versions.
- Manifest permissions and exported components.
- Plugin/dependency coordinates, licenses and vulnerability review.
- APK/AAB output, signing path and CI reproduction command.

The generated template's native Godot runtime remains precompiled unless the engine export template itself is rebuilt. See the official [Godot 4.4 Gradle build documentation](https://docs.godotengine.org/en/4.4/tutorials/export/android_gradle_build.html) and [Android export documentation](https://docs.godotengine.org/en/4.4/tutorials/export/exporting_for_android.html).

## 6. CI and artifact retention

GitHub Actions is the authoritative build record. Every artifact should be tied to repository, branch, full source SHA, workflow run URL and ID, artifact ID and expiry, APK filename, byte size, SHA-256, structural validation and signature verification.

GitHub Actions artifacts expire according to workflow retention settings. They are temporary build outputs, not permanent releases. For a stable download, publish a versioned GitHub Release asset only after release acceptance and signing-key governance are in place.

## 7. Device acceptance

Before calling a build device-validated:
- Install and launch on the exact Redmi Note 13 Pro SKU.
- Record model code, SoC/GPU, RAM, Android version, display resolution and free storage.
- Verify first launch, permissions, touch, orientation, pause/resume and persistence.
- Run a 10-minute representative session and record frame time/FPS, memory and thermal behavior.
- Capture logs/screenshots and attach them to the exact build SHA.

Until this evidence exists, device acceptance remains NOT RUN.

## 8. Release gate

| Gate | Required evidence | Status |
|---|---|---|
| Godot import and script parsing | CI log on exact commit | PASS on current main CI run |
| Godot contract/smoke tests | CI log on exact commit | PASS on current main CI run |
| Python tests | CI log on exact commit | PASS on current main CI run |
| Android Debug export | APK artifact from exact commit | PASS on current main CI run |
| APK structure | New verifier output | PENDING PR CI |
| APK signature | apksigner verify output | PASS in current main CI workflow; verifier integration pending |
| Redmi installation and launch | Device log and test record | NOT RUN |
| Production release signing | Owner-controlled keystore | NOT RUN |
| Commercial release approval | Acceptance and legal review | NOT RUN |

No debug artifact is a commercial release. No successful CI export proves physical-device compatibility or engineering accuracy.
