#!/usr/bin/env bash
# Secure Pipeline — Python bootstrap
# Local-first · project venv only · no system site-packages pollution
set -euo pipefail

# shellcheck source=../lib/root.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/root.sh"
cd "$ROOT"

WITH_OPTIONAL=0
WITH_SLITHER=0
FORCE=0

usage() {
  cat <<'EOF'
Usage: ./scripts/bootstrap/setup_python.sh [--with-optional] [--with-slither] [--force]

  Creates .venv with stdlib venv (no pyenv/conda required).
  Core pipeline scripts need zero pip packages.

  --with-optional   pip install -r requirements.txt (e.g. rich)
  --with-slither    pip install -r requirements-slither.txt (Phase 4)
  --force           recreate .venv even if it exists
EOF
}

for arg in "$@"; do
  case "$arg" in
    --with-optional) WITH_OPTIONAL=1 ;;
    --with-slither) WITH_SLITHER=1 ;;
    --force) FORCE=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $arg" >&2; usage; exit 2 ;;
  esac
done

if ! command -v python3 >/dev/null 2>&1; then
  echo "ERROR: python3 not found on PATH" >&2
  exit 1
fi

PY_SYS="$(command -v python3)"
echo "==> Host interpreter: $PY_SYS"
"$PY_SYS" -c 'import sys; print("==> Version:", sys.version.split()[0])'
"$PY_SYS" -c 'import ensurepip, venv; print("==> ensurepip + venv: ok")'

# Detect broken dual-boot venvs (e.g. python → missing Framework 3.14 on Sonoma)
VENV_PY="$ROOT/.venv/bin/python"
if [[ -e "$VENV_PY" || -L "$VENV_PY" ]]; then
  if ! "$VENV_PY" -c 'import sys' >/dev/null 2>&1; then
    echo "==> .venv interpreter broken (cross-boot / missing framework) — recreating"
    FORCE=1
  fi
fi

if [[ -x "$ROOT/.venv/bin/python" && "$FORCE" -eq 0 ]]; then
  if "$ROOT/.venv/bin/python" -c 'import sys' >/dev/null 2>&1; then
    echo "==> .venv already present (use --force to recreate)"
  else
    FORCE=1
  fi
fi

if [[ ! -x "$ROOT/.venv/bin/python" || "$FORCE" -eq 1 ]]; then
  if [[ -d "$ROOT/.venv" ]]; then
    echo "==> Removing existing .venv"
    rm -rf "$ROOT/.venv"
  fi
  echo "==> Creating .venv (stdlib venv) with $PY_SYS"
  if ! "$PY_SYS" -m venv "$ROOT/.venv"; then
    echo "ERROR: venv creation failed. On some builds try: python3 -m venv .venv" >&2
    exit 1
  fi
fi

PY="$ROOT/.venv/bin/python"
PIP="$ROOT/.venv/bin/pip"

echo "==> Upgrading pip inside venv only"
"$PY" -m pip install --upgrade pip

if [[ "$WITH_OPTIONAL" -eq 1 ]]; then
  echo "==> Installing optional requirements (rich)"
  "$PIP" install -r "$ROOT/requirements.txt"
else
  echo "==> Skipping optional UI deps. Pass --with-optional for rich."
fi

if [[ "$WITH_SLITHER" -eq 1 ]]; then
  echo "==> Installing Slither stack (pinned for Python 3.14 / no Rust cbor2)"
  "$PIP" install -r "$ROOT/requirements-slither.txt"
  echo "==> Slither: $("$ROOT/.venv/bin/slither" --version 2>/dev/null || true)"
else
  echo "==> Skipping Slither. Pass --with-slither for static analysis."
fi

mkdir -p "$ROOT/data" "$ROOT/logs"
chmod 700 "$ROOT/data" "$ROOT/logs" 2>/dev/null || true

echo
echo "==> Bootstrap complete"
echo "    Interpreter: $PY"
"$PY" -c 'import sys; print("    Version:    ", sys.version.split()[0])'
echo "    Preflight:   ./pipeline.sh preflight"
echo "    Optional:    ./scripts/bootstrap/setup_python.sh --with-optional"
echo "    Slither:     ./scripts/bootstrap/setup_python.sh --with-slither && make slither"
