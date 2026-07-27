"""Resolve secure_pipeline repo root (stdlib only).

Walks up from a starting path until hardhat.config.js + AGENTS.md are found.
"""
from __future__ import annotations

import os
from pathlib import Path


def project_root(start: Path | str | None = None) -> Path:
    """Return the repo root, or raise SystemExit if not found."""
    env = os.environ.get("SECURE_PIPELINE_ROOT")
    if env:
        p = Path(env).resolve()
        if (p / "hardhat.config.js").is_file() and (p / "AGENTS.md").is_file():
            return p

    here = Path(start).resolve() if start else Path.cwd()
    if here.is_file():
        here = here.parent

    for p in [here, *here.parents]:
        if (p / "hardhat.config.js").is_file() and (p / "AGENTS.md").is_file():
            return p

    raise SystemExit(
        "secure_pipeline root not found (looking for hardhat.config.js + AGENTS.md)"
    )
