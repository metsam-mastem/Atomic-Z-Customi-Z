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
    ;;
  *)
    echo "Usage: $0 [debug|release]" >&2
    exit 2
    ;;
esac

echo "Godot: $("$GODOT_BIN" --version)"
echo "Preset: $PRESET"
echo "Output: $OUTPUT"

"$GODOT_BIN" --headless --editor --path "$ROOT" --quit
"$GODOT_BIN" --headless --path "$ROOT" "$EXPORT_FLAG" "$PRESET" "$OUTPUT"
[[ -s "$OUTPUT" ]] || { echo "Export produced no APK: $OUTPUT" >&2; exit 1; }

VERIFY_ARGS=("$ROOT/scripts/verify_android_artifact.py" "$OUTPUT")
if [[ -n "${ANDROID_HOME:-}" && -x "$ANDROID_HOME/build-tools/34.0.0/apksigner" ]]; then
  VERIFY_ARGS+=(--apksigner "$ANDROID_HOME/build-tools/34.0.0/apksigner" --require-signed)
fi
python3 "${VERIFY_ARGS[@]}"
echo "ANDROID_EXPORT=PASS"
