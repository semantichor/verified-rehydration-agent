#!/usr/bin/env python3
"""Verify this supplement against the VRA package Manifest supplied by the reader."""

import hashlib
import json
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parent
SUPPLEMENT_MANIFEST = ROOT / "VRA_Supplement_Manifest.json"


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: python verify_anchor.py PATH_TO_VRA_PACKAGE_MANIFEST", file=sys.stderr)
        return 2

    vra_manifest = Path(sys.argv[1])
    data = json.loads(SUPPLEMENT_MANIFEST.read_text(encoding="utf-8"))
    if data.get("schema") != "vra-supplement-manifest-v1":
        raise ValueError("Unexpected supplement manifest schema")
    target = data["vra_package_manifest"]
    if vra_manifest.name != target["filename"]:
        raise ValueError("Wrong VRA package Manifest filename")
    if sha256(vra_manifest) != target["sha256"]:
        raise ValueError("VRA package Manifest SHA-256 mismatch")

    entries = data["files"]
    listed = set()
    for entry in entries:
        relative = Path(entry["path"])
        if relative.is_absolute() or ".." in relative.parts:
            raise ValueError(f"Unsafe path: {relative}")
        path = (ROOT / relative).resolve()
        if not path.is_relative_to(ROOT):
            raise ValueError(f"Path escapes supplement: {relative}")
        if entry["path"] in listed:
            raise ValueError(f"Duplicate path: {relative}")
        listed.add(entry["path"])
        if not path.is_file() or path.stat().st_size != entry["size_bytes"]:
            raise ValueError(f"Missing file or size mismatch: {relative}")
        if sha256(path) != entry["sha256"]:
            raise ValueError(f"SHA-256 mismatch: {relative}")

    actual = {
        path.relative_to(ROOT).as_posix()
        for path in ROOT.rglob("*")
        if path.is_file() and path != SUPPLEMENT_MANIFEST
    }
    if listed != actual:
        raise ValueError(f"File inventory mismatch: missing={listed - actual}, extra={actual - listed}")

    print(f"VRA package Manifest: MATCH ({target['sha256']})")
    print(f"Supplement files: {len(entries)}/{len(entries)} MATCH")
    print(f"Supplement Manifest SHA-256: {sha256(SUPPLEMENT_MANIFEST)}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, KeyError, ValueError, json.JSONDecodeError) as error:
        print(f"Verification failed: {error}", file=sys.stderr)
        raise SystemExit(1)
