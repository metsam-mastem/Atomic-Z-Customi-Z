# Android build integration

Atomic-Z-Customi-Z is a Godot 4.4.1 / GDScript application. Godot owns the runtime, rendering, input, scene lifecycle, persistence and Android export. The normal CI path uses matching prebuilt Godot Android export templates; it is not a standalone Android Studio application.

## Why this directory does not contain hand-written Gradle files

A Gradle Android project is generated from the Android build template shipped for the exact Godot editor/export-template version. Copying arbitrary build.gradle, settings.gradle, Gradle wrapper or Android plugin versions into this repository can make the project incompatible with its Godot export template. The current product has no Android Java/Kotlin plugin or third-party SDK integration that requires a custom Gradle build.

## When custom Gradle is justified

- Android App Bundle (AAB) export through the custom build path.
- A Godot Android plugin requiring Gradle.
- A reviewed Android SDK / Java / Kotlin dependency.
- A deliberate change to the Android application template.

## Generate the matching template

1. Open this project in Godot 4.4.1.
2. Install the matching Android export templates.
3. Select Project → Install Android Build Template.
4. Godot generates its template under android/build.
5. Enable Use Gradle Build in the Android export preset only when an accepted requirement above exists.
6. Review the generated wrapper, Android Gradle Plugin, SDK levels, manifest, permissions, package ID and license notices before committing.
7. Run all Godot, Python, Android export, APK metadata and signature checks.

Do not replace the Godot engine or move product logic into a second Android application.

## Tested CI baseline

- Godot editor/export templates: 4.4.1
- JDK: 17
- Android platform: 34
- Android Build Tools: 34.0.0
- Android NDK: 23.2.8568313
- ABI: arm64-v8a
- Renderer: Godot Compatibility

These are the current CI baseline, not proof that every newer SDK or phone is validated.

## Build commands

From the repository root:

    bash scripts/build_android.sh debug
    bash scripts/build_android.sh release

Release requires environment variables GODOT_ANDROID_KEYSTORE_RELEASE_PATH, GODOT_ANDROID_KEYSTORE_RELEASE_USER and GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD. Keep their values in a secret manager, never in Git.

See docs/ANDROID_BUILD_AND_RELEASE.md.
