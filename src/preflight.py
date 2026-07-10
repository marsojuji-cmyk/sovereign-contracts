#!/usr/bin/env python3
"""
Secure Pipeline — host preflight (stdlib only).

Local-first · no network · legacy-Mac aware.
Mirrors the hardware/privacy doctrine from grok-terminal-ethos.

Emits data/health.json (gitignored under data/) for machine-readable status.
"""
from __future__ import annotations

import json
import os
import platform
import shutil
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

ROOT = Path(__file__).resolve().parent.parent


def _ram_gb() -> float | None:
    try:
        out = subprocess.check_output(["sysctl", "-n", "hw.memsize"], text=True).strip()
        return round(int(out) / (1024**3), 1)
    except Exception:
        pass
    try:
        with open("/proc/meminfo") as f:
            for line in f:
                if line.startswith("MemTotal:"):
                    return round(int(line.split()[1]) / (1024**2), 1)
    except Exception:
        pass
    return None


def _in_venv() -> bool:
    return getattr(sys, "base_prefix", sys.prefix) != sys.prefix or bool(
        os.environ.get("VIRTUAL_ENV")
    )


def _project_venv() -> Path:
    return ROOT / ".venv"


def collect() -> tuple[list[tuple[str, str]], list[str], bool]:
    ram = _ram_gb()
    machine = platform.machine()
    system = platform.system()
    mac_ver = platform.mac_ver()[0] if system == "Darwin" else ""
    legacy = False
    notes: list[str] = []

    if system == "Darwin" and mac_ver:
        try:
            major = int(mac_ver.split(".")[0])
            if major < 13:
                legacy = True
                notes.append(f"macOS {mac_ver} — prefer light tooling / ANSI paths")
        except ValueError:
            pass
        if machine in ("x86_64", "i386"):
            notes.append("Intel Mac — avoid heavy GUI / multi-GB ML stacks by default")

    if ram is not None and ram <= 16:
        notes.append(f"{ram} GB RAM — keep Python deps minimal; profile before adding tools")

    venv_path = _project_venv()
    venv_ready = (venv_path / "bin" / "python").is_file()

    rows = [
        ["System", f"{system} {platform.release()}"],
        ["macOS", mac_ver or "n/a"],
        ["Machine", machine],
        ["Legacy profile", "yes" if legacy else "no"],
        ["RAM (GB)", str(ram if ram is not None else "?")],
        ["CPUs", str(os.cpu_count() or 1)],
        ["Python", sys.version.split()[0]],
        ["Executable", sys.executable],
        ["In venv", "yes" if _in_venv() else "no"],
        ["Project .venv", "ready" if venv_ready else "missing (run scripts/setup_python.sh)"],
        ["VIRTUAL_ENV", os.environ.get("VIRTUAL_ENV") or "(unset)"],
        ["PIP_REQUIRE_VIRTUALENV", os.environ.get("PIP_REQUIRE_VIRTUALENV") or "(unset)"],
        ["TERM", os.environ.get("TERM", "unknown")],
        ["Shell", os.environ.get("SHELL", "unknown")],
        ["python3 on PATH", shutil.which("python3") or "missing"],
        ["node on PATH", shutil.which("node") or "missing"],
        ["npm on PATH", shutil.which("npm") or "missing"],
        ["Hardhat package.json", "yes" if (ROOT / "package.json").is_file() else "no"],
        ["hardhat.config.js", "yes" if (ROOT / "hardhat.config.js").is_file() else "no"],
        ["contracts/", "yes" if (ROOT / "contracts").is_dir() else "no"],
        ["node_modules", "yes" if (ROOT / "node_modules").is_dir() else "no"],
    ]
    return rows, notes, legacy


def privacy_checks() -> list[tuple[str, bool, str]]:
    return [
        (
            "Core preflight is local-only",
            True,
            "No network calls in this script",
        ),
        (
            "System site-packages not required",
            True,
            "Stdlib-only critical path; optional deps live in .venv",
        ),
        (
            "Secrets not in repo defaults",
            not (ROOT / ".env").exists(),
            ".env absent (good) or gitignored if present",
        ),
        (
            "data/ not assumed world-readable",
            True,
            "Create data/ with chmod 700 when logging lineage",
        ),
    ]


def ensure_data_dir() -> Path:
    data = ROOT / "data"
    data.mkdir(parents=True, exist_ok=True)
    try:
        os.chmod(data, 0o700)
    except OSError:
        pass
    return data


def _iso_now() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def _file_mtime_iso(path: Path) -> Optional[str]:
    if not path.is_file():
        return None
    try:
        ts = path.stat().st_mtime
        return datetime.fromtimestamp(ts, tz=timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    except OSError:
        return None


def _stmt_pct(entry: Dict[str, Any]) -> Optional[float]:
    """Istanbul statement coverage fraction for one file entry."""
    s = entry.get("s")
    if not isinstance(s, dict) or not s:
        return None
    hits = sum(1 for v in s.values() if isinstance(v, (int, float)) and v > 0)
    return hits / len(s)


def coverage_snapshot() -> Dict[str, Any]:
    """Summarize production-contract coverage if a report is present (no recompute)."""
    candidates = [
        ROOT / "coverage" / "coverage-final.json",
        ROOT / "coverage.json",
    ]
    path = next((p for p in candidates if p.is_file()), None)
    out: Dict[str, Any] = {
        "present": path is not None,
        "path": str(path.relative_to(ROOT)) if path else None,
        "mtime": _file_mtime_iso(path) if path else None,
        "production": {},
    }
    if not path:
        return out
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        out["error"] = "unreadable coverage report"
        return out

    targets = ("contracts/SecureVault.sol", "contracts/AccountingVault.sol")
    for _key, entry in data.items():
        if not isinstance(entry, dict):
            continue
        rel = str(entry.get("path") or _key).replace("\\", "/")
        if "/test/" in rel:
            continue
        for t in targets:
            if rel.endswith(t):
                pct = _stmt_pct(entry)
                if pct is not None:
                    out["production"][t] = round(pct * 100.0, 2)
    return out


def write_health_manifest(
    rows: List[List[str]],
    notes: List[str],
    privacy: List[Tuple[str, bool, str]],
    ok_all: bool,
    legacy: bool,
) -> Path:
    """Write data/health.json — local lineage only; never secrets."""
    data_dir = ensure_data_dir()
    cov = coverage_snapshot()
    # Prefer last test signal: hardhat cache or coverage mtime
    last_test = (
        cov.get("mtime")
        or _file_mtime_iso(ROOT / "cache" / "solidity-files-cache.json")
        or _file_mtime_iso(ROOT / "artifacts" / "build-info")
    )
    # build-info may be a dir
    bi = ROOT / "artifacts" / "build-info"
    if last_test is None and bi.is_dir():
        mtimes = []
        try:
            for p in bi.iterdir():
                if p.is_file():
                    mtimes.append(p.stat().st_mtime)
        except OSError:
            pass
        if mtimes:
            last_test = datetime.fromtimestamp(max(mtimes), tz=timezone.utc).strftime(
                "%Y-%m-%dT%H:%M:%SZ"
            )

    manifest: Dict[str, Any] = {
        "schema": "secure-pipeline.health.v1",
        "generated_at": _iso_now(),
        "ok": ok_all,
        "legacy_profile": legacy,
        "python": sys.version.split()[0],
        "executable": sys.executable,
        "node": shutil.which("node") or None,
        "npm": shutil.which("npm") or None,
        "venv_ready": (_project_venv() / "bin" / "python").is_file(),
        "in_venv": _in_venv(),
        "fields": {k: v for k, v in rows},
        "notes": notes,
        "privacy": [
            {"check": name, "ok": ok, "detail": detail} for name, ok, detail in privacy
        ],
        "coverage": cov,
        "last_build_or_test_at": last_test,
        "gates": {
            "make_check": "preflight + compile + test",
            "make_check_full": "check + slither (required for contracts/ diffs)",
            "make_coverage_gate": "coverage report + 100% stmt floor on production vaults",
        },
    }
    out_path = data_dir / "health.json"
    out_path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    try:
        os.chmod(out_path, 0o600)
    except OSError:
        pass
    return out_path


def main() -> int:
    rows, notes, legacy = collect()
    print("=" * 60)
    print("SECURE PIPELINE — PREFLIGHT")
    print("Local-first · stdlib · venv-scoped optional deps")
    print("=" * 60)
    print()
    print(f"{'Field':<28} Value")
    print("-" * 60)
    for k, v in rows:
        print(f"{k:<28} {v}")
    print()
    print("Notes")
    print("-" * 60)
    for n in notes or ["Profile nominal for pipeline work"]:
        print(f"  • {n}")
    print()
    print("Privacy / ethos checks")
    print("-" * 60)
    print(f"{'Check':<40} {'OK':<4} Detail")
    ok_all = True
    priv = privacy_checks()
    for name, ok, detail in priv:
        ok_all = ok_all and ok
        print(f"{name:<40} {('✓' if ok else '✗'):<4} {detail}")
    print()

    # Soft recommendations
    actions: list[str] = []
    if not (_project_venv() / "bin" / "python").is_file():
        actions.append("Create project venv: ./scripts/setup_python.sh")
    if not _in_venv() and (_project_venv() / "bin" / "python").is_file():
        actions.append("Prefer launcher: ./pipeline.sh preflight  (uses .venv)")
    if os.environ.get("PIP_REQUIRE_VIRTUALENV", "").lower() not in ("1", "true", "yes"):
        actions.append(
            "Optional shell guard: export PIP_REQUIRE_VIRTUALENV=1  "
            "(blocks accidental global pip installs)"
        )
    if not (ROOT / "node_modules").is_dir():
        actions.append("Install Hardhat stack: npm install")
    if (ROOT / "hardhat.config.js").is_file() and (ROOT / "node_modules").is_dir():
        actions.append("Local gate: make check  (or ./pipeline.sh check)")
        actions.append("Contracts diff: make check-full  (includes Slither)")

    print("Immediate Next Actions")
    print("-" * 60)
    if actions:
        for i, a in enumerate(actions, 1):
            print(f"  {i}. {a}")
    else:
        print("  1. Preflight clean — proceed with pipeline work.")
    print()

    health_path = write_health_manifest(rows, notes, priv, ok_all, legacy)
    print(f"Health manifest: {health_path.relative_to(ROOT)} (local; not committed)")
    print()
    return 0 if ok_all else 1


if __name__ == "__main__":
    raise SystemExit(main())
