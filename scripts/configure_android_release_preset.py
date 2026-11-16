#!/usr/bin/env python3
"""Inject release signing values into an isolated, temporary Godot export preset."""
from __future__ import annotations

import argparse
import json
import os
from pathlib import Path


class ReleasePresetError(Exception):
    """Raised when release signing cannot be configured safely."""


_REQUIRED_KEYS = (
    "keystore/release",
    "keystore/release_user",
    "keystore/release_password",
)


def configure_release_preset(
    source_path: Path,
    destination_path: Path,
    keystore_path: str,
    alias: str,
    password: str,
) -> None:
    source = Path(source_path).expanduser().resolve(strict=True)
    destination = Path(destination_path).expanduser().resolve(strict=False)
    if source == destination:
        raise ReleasePresetError("Source preset must not be overwritten; use a separate temporary copy.")
    if not source.is_file():
        raise ReleasePresetError("Source export preset must be a file.")
    if not alias.strip() or not password:
        raise ReleasePresetError("Release alias and password must be non-empty.")

    keystore_text = keystore_path.strip()
    if not keystore_text:
        raise ReleasePresetError("Release keystore file path must be non-empty.")
    try:
        keystore = Path(keystore_text).expanduser().resolve(strict=True)
    except OSError as exc:
        raise ReleasePresetError("Release keystore file does not exist or is inaccessible.") from exc
    if not keystore.is_file():
        raise ReleasePresetError("Release keystore file path must point to a file.")

    lines = source.read_text(encoding="utf-8").splitlines(keepends=True)
    section_name = "[preset.1.options]"
    section_starts = [i for i, line in enumerate(lines) if line.strip() == section_name]
    if len(section_starts) != 1:
        raise ReleasePresetError("Exactly one [preset.1.options] section is required.")

    start = section_starts[0] + 1
    end = len(lines)
    for index in range(start, len(lines)):
        if lines[index].lstrip().startswith("["):
            end = index
            break

    replacements = {
        "keystore/release": str(keystore),
        "keystore/release_user": alias,
        "keystore/release_password": password,
    }
    key_positions: dict[str, list[int]] = {key: [] for key in _REQUIRED_KEYS}
    for index in range(start, end):
        stripped = lines[index].strip()
        if not stripped or stripped.startswith(";") or "=" not in stripped:
            continue
        key = stripped.split("=", 1)[0].strip()
        if key in key_positions:
            key_positions[key].append(index)

    for key, positions in key_positions.items():
        if len(positions) != 1:
            raise ReleasePresetError(f"Expected exactly one {key} entry in [preset.1.options].")

    for key, value in replacements.items():
        index = key_positions[key][0]
        newline = "\n" if lines[index].endswith("\n") else ""
        lines[index] = f"{key}={json.dumps(value)}{newline}"

    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_text("".join(lines), encoding="utf-8")
    destination.chmod(0o600)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path)
    parser.add_argument("destination", type=Path)
    args = parser.parse_args()
    try:
        configure_release_preset(
            args.source,
            args.destination,
            os.environ.get("GODOT_ANDROID_KEYSTORE_RELEASE_PATH", ""),
            os.environ.get("GODOT_ANDROID_KEYSTORE_RELEASE_USER", ""),
            os.environ.get("GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD", ""),
        )
    except (OSError, ReleasePresetError) as exc:
        parser.exit(2, f"Release preset configuration failed: {exc}\n")
    print("ANDROID_RELEASE_PRESET=CONFIGURED_IN_TEMPORARY_COPY")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
