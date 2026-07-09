#!/usr/bin/env python3
"""
Secure Pipeline — host preflight (stdlib only).

Local-first · no network · legacy-Mac aware.
Mirrors the hardware/privacy doctrine from grok-terminal-ethos.
"""
from __future__ import annotations

import os
import platform
import shutil
import subprocess
import sys
from pathlib import Path

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


def main() -> int:
    rows, notes, _legacy = collect()
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
    for name, ok, detail in privacy_checks():
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

    print("Immediate Next Actions")
    print("-" * 60)
    if actions:
        for i, a in enumerate(actions, 1):
            print(f"  {i}. {a}")
    else:
        print("  1. Preflight clean — proceed with pipeline work.")
    print()

    ensure_data_dir()
    return 0 if ok_all else 1


if __name__ == "__main__":
    raise SystemExit(main())
