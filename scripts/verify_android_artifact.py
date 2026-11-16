#!/usr/bin/env python3
"""Validate the structure and optional signature of a Godot Android APK."""
from __future__ import annotations
import argparse, hashlib, json, subprocess, sys, zipfile
from pathlib import Path

class ArtifactError(Exception):
    """Raised when an APK does not satisfy the project artifact contract."""

def inspect_apk(path: Path) -> dict[str, object]:
    if not path.is_file():
        raise ArtifactError(f"APK does not exist: {path}")
    if path.stat().st_size == 0:
        raise ArtifactError("APK is empty")
    if not zipfile.is_zipfile(path):
        raise ArtifactError("File is not a valid ZIP/APK container")
    try:
        with zipfile.ZipFile(path) as archive:
            corrupt = archive.testzip()
            if corrupt:
                raise ArtifactError(f"Corrupt ZIP entry: {corrupt}")
            names = set(archive.namelist())
    except (OSError, zipfile.BadZipFile) as exc:
        raise ArtifactError(f"Cannot read APK: {exc}") from exc
    required = {"AndroidManifest.xml", "assets/project.binary", "lib/arm64-v8a/libgodot_android.so"}
    missing = sorted(required - names)
    if missing:
        raise ArtifactError("Missing required APK entries: " + ", ".join(missing))
    dex = sorted(n for n in names if n == "classes.dex" or
                 (n.startswith("classes") and n.endswith(".dex") and n[7:-4].isdigit()))
    if not dex:
        raise ArtifactError("APK contains no DEX bytecode")
    if not any(n.startswith("assets/.godot/exported/") and n.endswith(".scn") for n in names):
        raise ArtifactError("Godot exported scene payload is missing")
    sigs = sorted(n for n in names if n.upper().startswith("META-INF/") and
                  n.upper().endswith((".RSA", ".DSA", ".EC")))
    digest = hashlib.sha256(path.read_bytes()).hexdigest()
    return {"file": path.name, "size_bytes": path.stat().st_size, "sha256": digest,
            "dex_files": dex, "arm64_godot_runtime": True, "godot_project_payload": True,
            "signature_block_present": bool(sigs), "signature_entries": sigs,
            "zip_integrity": "PASS", "structure": "PASS"}

def verify_signature(path: Path, apksigner: str) -> str:
    result = subprocess.run([apksigner, "verify", "--verbose", str(path)],
                            check=False, capture_output=True, text=True)
    if result.returncode:
        raise ArtifactError("APK signature verification failed: " +
                            (result.stdout + "\n" + result.stderr).strip())
    return (result.stdout + "\n" + result.stderr).strip()

def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("apk", type=Path)
    parser.add_argument("--apksigner", help="Path to Android SDK apksigner")
    parser.add_argument("--require-signed", action="store_true")
    args = parser.parse_args()
    try:
        report = inspect_apk(args.apk)
        if args.require_signed and not args.apksigner:
            raise ArtifactError("--require-signed requires --apksigner")
        if args.apksigner:
            report["signature_verification"] = verify_signature(args.apk, args.apksigner)
            report["signature"] = "PASS"
        else:
            report["signature"] = "PRESENT_UNVERIFIED" if report["signature_block_present"] else "NOT_CHECKED"
        print(json.dumps(report, indent=2))
        return 0
    except ArtifactError as exc:
        print(f"APK VALIDATION FAILED: {exc}", file=sys.stderr)
        return 1

if __name__ == "__main__":
    raise SystemExit(main())
