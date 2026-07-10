#!/usr/bin/env python3
"""
Assert 100% statement coverage on production vault contracts.

Reads Istanbul/nyc coverage-final.json (or coverage.json).
Does NOT re-run hardhat coverage — call after `make coverage`.

Usage:
  python3 scripts/coverage_floor.py
  python3 scripts/coverage_floor.py --min 100
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PRODUCTION = (
    "contracts/SecureVault.sol",
    "contracts/AccountingVault.sol",
)


def _load_report() -> tuple[Path, dict]:
    for rel in ("coverage/coverage-final.json", "coverage.json"):
        path = ROOT / rel
        if path.is_file():
            data = json.loads(path.read_text(encoding="utf-8"))
            if not isinstance(data, dict):
                raise SystemExit(f"unexpected coverage format: {path}")
            return path, data
    raise SystemExit(
        "no coverage report found — run: make coverage\n"
        "expected coverage/coverage-final.json or coverage.json"
    )


def _stmt_pct(entry: dict) -> float | None:
    s = entry.get("s")
    if not isinstance(s, dict) or not s:
        return None
    hits = sum(1 for v in s.values() if isinstance(v, (int, float)) and v > 0)
    return 100.0 * hits / len(s)


def production_scores(data: dict) -> dict[str, float]:
    scores: dict[str, float] = {}
    for _key, entry in data.items():
        if not isinstance(entry, dict):
            continue
        rel = str(entry.get("path") or _key).replace("\\", "/")
        if "/test/" in rel:
            continue
        for t in PRODUCTION:
            if rel.endswith(t):
                pct = _stmt_pct(entry)
                if pct is not None:
                    scores[t] = pct
    return scores


def main() -> int:
    ap = argparse.ArgumentParser(description="Production vault coverage floor")
    ap.add_argument("--min", type=float, default=100.0, help="Minimum stmt %% (default 100)")
    args = ap.parse_args()

    path, data = _load_report()
    scores = production_scores(data)
    print(f"coverage report: {path.relative_to(ROOT)}")
    print(f"floor: {args.min:g}% statement coverage on production vaults")
    print()

    missing = [t for t in PRODUCTION if t not in scores]
    if missing:
        print("✗ missing coverage entries for:")
        for m in missing:
            print(f"  - {m}")
        return 1

    failed = False
    for t in PRODUCTION:
        pct = scores[t]
        mark = "✓" if pct + 1e-9 >= args.min else "✗"
        if pct + 1e-9 < args.min:
            failed = True
        print(f"  {mark} {t}: {pct:.2f}%")

    print()
    if failed:
        print("Result: FAIL — restore tests/coverage before merging contracts/")
        return 1
    print("Result: OK — production vault statement coverage meets floor")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
