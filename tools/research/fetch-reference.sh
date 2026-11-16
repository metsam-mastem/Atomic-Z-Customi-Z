#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CACHE="$ROOT/.research-cache"
SOURCE="${1:-}"

usage() {
  cat <<'EOF'
Usage:
  bash tools/research/fetch-reference.sh --list
  bash tools/research/fetch-reference.sh <source-id>

Downloads a sparse, commit-pinned research checkout into .research-cache/.
It does not modify the Godot project runtime or copy code into res://.
EOF
}

if [[ "$SOURCE" == "--list" || "$SOURCE" == "-l" ]]; then
  printf '%s\n' "Pinned and licence-identified IDs:"
  printf '%s\n' "  danknooner       (AGPL-3.0; study-only, no runtime import)"
  printf '%s\n' "  moto-controller  (AGPL-3.0; study-only, no runtime import)"
  printf '%s\n' "  opennfs          (MIT original code; EA assets excluded)"
  printf '%s\n' "  rea              (MIT canonical upstream; optional analysis tool)"
  printf '%s\n' "  godot-vehicle    (MIT; four-wheel car reference, Godot 4.6)"
  printf '%s\n' "  modu-vehicle     (CC0 code; WIP C++ GDExtension, dependencies separate)"
  printf '%s\n' "Manual-reference only, not auto-fetched: OpenUG2, Roadkill, SPEED RE, kv-vehicle, MotoForge, VOLT showroom (unresolved/mixed rights)."
  printf '%s\n' "COD repositories without a detected reuse licence are intentionally excluded: OpenCOD1, OpenCOD2, CoD-Research."
  printf '%s\n' "Official Activision Telescope archives require per-version licence review; private MW2 reconstruction has no public source checkout."
  printf '%s\n' "CC0 GLBs are not auto-fetched until the downloaded file hash and provenance are recorded."
  exit 0
fi

if [[ -z "$SOURCE" || "$SOURCE" == "--help" || "$SOURCE" == "-h" ]]; then
  usage
  exit 0
fi

case "$SOURCE" in
  danknooner)
    REPO="ssebs/DankNooner"
    SHA="85bb82f1afe88d6baa564a77ab04b0d7aab3429b"
    REF="main"
    PATHS=("/v2/planning_docs/" "/v2/player/controllers/" "/v2/player/player_entity.gd" "/v2/resources/bikes/bike_skin_definition.gd" "/v2/project.godot" "/README.md" "/LICENSE")
    ;;
  moto-controller)
    REPO="ssebs/moto-player-controller-godot"
    SHA="a5bd7699cb58b73dd8f9a79a6e871587693b7604"
    REF="main"
    PATHS=("/scenes/bike/components/" "/scenes/bike/player_controller.gd" "/scenes/bike/resources/" "/README.md" "/Attributions.md" "/LICENSE")
    ;;
  opennfs)
    REPO="OpenNFS/OpenNFS"
    SHA="dcd9197033272f8be307a839105e74185809f9f9"
    REF="main"
    PATHS=("/src/Physics/" "/src/Camera/" "/src/Race/" "/src/Renderer/" "/README.md" "/BUILDING.md" "/LICENSE")
    ;;
  rea)
    REPO="morluto/rea"
    SHA="a10037ef10516cf92653596512932b15f190a5c0"
    REF="main"
    PATHS=("/docs/guides/native/" "/docs/guides/android/" "/docs/development/reconstruction-readiness.md" "/docs/getting-started/installation.md" "/skill-src/reverse-engineer-anything/" "/README.md" "/LICENSE")
    ;;
  godot-vehicle)
    REPO="Seerban/godot-vehicle"
    SHA="935e24c0942df0c0b907dc61512c37b6d64d4f57"
    REF="main"
    PATHS=("/Scripts/vehicle/" "/Scripts/controller/" "/Scripts/sprint/GhostPlayer.gd" "/Resources/" "/README.md" "/LICENSE" "/project.godot")
    ;;
  modu-vehicle)
    REPO="AurickMikleton/ModuVehicle"
    SHA="618e43db7578dcf9d4ca4640d832b45a94ef1ddc"
    REF="main"
    PATHS=("/src/components/" "/src/math/" "/src/resources/" "/demo/presets/components/" "/README.md" "/LICENSE" "/CMakeLists.txt" "/.gitmodules")
    ;;
  *)
    printf 'Unknown, unpinned or rights-unreviewed source ID: %s\n' "$SOURCE" >&2
    usage >&2
    exit 2
    ;;
esac

DEST="$CACHE/$SOURCE"
URL="https://github.com/$REPO.git"

mkdir -p "$CACHE"

if [[ ! -d "$DEST/.git" ]]; then
  git clone --filter=blob:none --no-checkout --depth=1 --single-branch --branch "$REF" "$URL" "$DEST"
fi

# Fetch the immutable audited revision, not the moving branch tip.
git -C "$DEST" fetch --filter=blob:none --depth=1 origin "$SHA"
git -C "$DEST" sparse-checkout init --no-cone
git -C "$DEST" sparse-checkout set --no-cone "${PATHS[@]}"
git -C "$DEST" checkout --detach "$SHA"

printf '\nFetched %s at %s\n' "$REPO" "$SHA"
printf 'Sparse checkout: %s\n' "$DEST"
printf '%s\n' "Review the recorded licence and third-party notices before copying anything."
