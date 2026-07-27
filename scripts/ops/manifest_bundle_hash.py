#!/usr/bin/env python3
"""Offline SHA-256 of canonical Grok Build / LIBRARIAN bundle (stdlib only)."""
from __future__ import annotations

import hashlib
import sys
from pathlib import Path

_LIB = Path(__file__).resolve().parent.parent / "lib"
if str(_LIB) not in sys.path:
    sys.path.insert(0, str(_LIB))
from root import project_root  # noqa: E402

ROOT = project_root(Path(__file__))

# Canonical doctrine bundle (content-hashed for BuildManifestAnchor)
DOCS = (
    "docs/doctrine/GROK_BUILD_INSTRUCTIONS.md",
    "docs/doctrine/LIBRARIAN_PROTOCOL.md",
    "docs/doctrine/BUILD_FRAME_NEXUS_PIPELINE.md",
)
BOUNDARY = "\n---MANIFEST_BOUNDARY---\n"


def main() -> int:
    parts: list[str] = []
    for rel in DOCS:
        p = ROOT / rel
        if not p.is_file():
            print(f"missing: {rel}", file=sys.stderr)
            return 1
        parts.append(p.read_text(encoding="utf-8"))
    digest = hashlib.sha256(BOUNDARY.join(parts).encode("utf-8")).hexdigest()
    print(f"MANIFEST_BUNDLE_SHA256=0x{digest}")
    print("docs:", ", ".join(DOCS))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
