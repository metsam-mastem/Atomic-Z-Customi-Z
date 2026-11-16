#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT_BIN="${GODOT_BIN:-godot}"
MODE="${1:-debug}"
OUT_DIR="${ANDROID_OUTPUT_DIR:-$ROOT/build}"
mkdir -p "$OUT_DIR"

if ! command -v "$GODOT_BIN" >/dev/null 2>&1; then
  echo "Godot executable not found: $GODOT_BIN" >&2
  exit 2
fi

PROJECT_DIR="$ROOT"
TEMP_PROJECT_DIR=""

case "$MODE" in
  debug)
    PRESET="Android Debug"
    OUTPUT="$OUT_DIR/Atomic-Z-debug.apk"
    EXPORT_FLAG="--export-debug"
    ;;
  release)
    PRESET="Android Release"
    OUTPUT="$OUT_DIR/Atomic-Z-release.apk"
    EXPORT_FLAG="--export-release"
    [[ -n "${GODOT_ANDROID_KEYSTORE_RELEASE_PATH:-}" ]] || { echo "Missing release keystore path" >&2; exit 2; }
    [[ -n "${GODOT_ANDROID_KEYSTORE_RELEASE_USER:-}" ]] || { echo "Missing release keystore alias" >&2; exit 2; }
    [[ -n "${GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD:-}" ]] || { echo "Missing release keystore password" >&2; exit 2; }
    TEMP_PROJECT_DIR="$(mktemp -d)"
    trap 'rm -rf "$TEMP_PROJECT_DIR"' EXIT
    tar -C "$ROOT" --exclude=.git --exclude=.godot --exclude=build -cf - . | tar -C "$TEMP_PROJECT_DIR" -xf -
    python3 "$ROOT/scripts/configure_android_release_preset.py" \
      "$ROOT/export_presets.cfg" "$TEMP_PROJECT_DIR/export_presets.cfg"
    PROJECT_DIR="$TEMP_PROJECT_DIR"
    ;;
  *)
    echo "Usage: $0 [debug|release]" >&2
    exit 2
    ;;
esac

echo "Godot: $("$GODOT_BIN" --version)"
echo "Preset: $PRESET"
echo "Output: $OUTPUT"

"$GODOT_BIN" --headless --editor --path "$PROJECT_DIR" --quit
"$GODOT_BIN" --headless --path "$PROJECT_DIR" "$EXPORT_FLAG" "$PRESET" "$OUTPUT"
[[ -s "$OUTPUT" ]] || { echo "Export produced no APK: $OUTPUT" >&2; exit 1; }

VERIFY_ARGS=("$ROOT/scripts/verify_android_artifact.py" "$OUTPUT")
if [[ -n "${ANDROID_HOME:-}" && -x "$ANDROID_HOME/build-tools/34.0.0/aapt" ]]; then
  BADGING="$("$ANDROID_HOME/build-tools/34.0.0/aapt" dump badging "$OUTPUT")"
  grep -q "package: name='com.atomicz.customizationlab'" <<< "$BADGING"
  grep -q "versionName='0.1.0'" <<< "$BADGING"
fi
if [[ -n "${ANDROID_HOME:-}" && -x "$ANDROID_HOME/build-tools/34.0.0/apksigner" ]]; then
  VERIFY_ARGS+=(--apksigner "$ANDROID_HOME/build-tools/34.0.0/apksigner" --require-signed)
fi
python3 "${VERIFY_ARGS[@]}"
echo "ANDROID_EXPORT=PASS"
