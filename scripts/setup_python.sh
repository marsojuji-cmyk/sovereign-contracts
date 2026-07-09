#!/usr/bin/env bash
# Secure Pipeline — Python bootstrap
# Local-first · project venv only · no system site-packages pollution
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

WITH_OPTIONAL=0
WITH_SLITHER=0
FORCE=0

usage() {
  cat <<'EOF'
Usage: ./scripts/setup_python.sh [--with-optional] [--with-slither] [--force]

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

if [[ -x "$ROOT/.venv/bin/python" && "$FORCE" -eq 0 ]]; then
  echo "==> .venv already present (use --force to recreate)"
else
  if [[ -d "$ROOT/.venv" && "$FORCE" -eq 1 ]]; then
    echo "==> Removing existing .venv (--force)"
    rm -rf "$ROOT/.venv"
  fi
  echo "==> Creating .venv (stdlib venv)"
  "$PY_SYS" -m venv "$ROOT/.venv"
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
echo "    Optional:    ./scripts/setup_python.sh --with-optional"
echo "    Slither:     ./scripts/setup_python.sh --with-slither && make slither"
