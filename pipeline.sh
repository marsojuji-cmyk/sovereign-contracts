#!/usr/bin/env bash
# Secure Pipeline — sovereign entrypoint
# Local-first · stdlib core · venv when present · legacy Mac safe
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

# Prefer project venv if present, else system python3 (stdlib scripts still work)
if [[ -x "$ROOT/.venv/bin/python" ]]; then
  PY="$ROOT/.venv/bin/python"
elif command -v python3 >/dev/null 2>&1; then
  PY="$(command -v python3)"
else
  echo "ERROR: python3 not found. Run: ./scripts/setup_python.sh" >&2
  exit 1
fi

export PYTHONPATH="$ROOT/src${PYTHONPATH:+:$PYTHONPATH}"
export SECURE_PIPELINE_ROOT="$ROOT"

usage() {
  cat <<'EOF'
Secure Pipeline

  ./pipeline.sh                 Interactive help
  ./pipeline.sh preflight       Hardware + Python + privacy checks
  ./pipeline.sh python          Print active interpreter
  ./pipeline.sh setup           Bootstrap .venv (stdlib)
  ./pipeline.sh setup-optional  Bootstrap .venv + optional rich
  ./pipeline.sh compile         Hardhat compile
  ./pipeline.sh test            Hardhat unit tests
  ./pipeline.sh coverage        solidity-coverage
  ./pipeline.sh check           preflight + compile + test
  ./pipeline.sh deploy-local    Ignition SecureVault (hardhat net)
  ./pipeline.sh env-check       Offline env shape check (no RPC)
  ./pipeline.sh slither         Static analysis (optional Phase 4)
  ./pipeline.sh hardhat ...     Proxy to npx hardhat

Ethos: local-first · no global pip · optional deps only in .venv
Sepolia ops: docs/NETWORK_OPS.md (explicit commands only)
Slither:     docs/STATIC_ANALYSIS.md
EOF
}

need_npx() {
  if ! command -v npx >/dev/null 2>&1; then
    echo "ERROR: npx not found (install Node via nvm)" >&2
    exit 1
  fi
}

cmd="${1:-help}"
shift || true

case "$cmd" in
  help|-h|--help)
    usage
    echo
    echo "Active Python: $PY"
    "$PY" -c 'import sys; print("Version:      ", sys.version.split()[0])'
    ;;
  preflight|hw)
    exec "$PY" "$ROOT/src/preflight.py" "$@"
    ;;
  python|py|which)
    echo "$PY"
    "$PY" -c 'import sys; print(sys.version)'
    ;;
  setup)
    exec bash "$ROOT/scripts/setup_python.sh" "$@"
    ;;
  setup-optional)
    exec bash "$ROOT/scripts/setup_python.sh" --with-optional "$@"
    ;;
  compile)
    need_npx
    exec npx hardhat compile "$@"
    ;;
  test)
    need_npx
    exec npx hardhat test "$@"
    ;;
  coverage)
    need_npx
    exec npx hardhat coverage "$@"
    ;;
  check)
    need_npx
    "$PY" "$ROOT/src/preflight.py"
    npx hardhat compile
    npx hardhat test
    echo ""
    echo "✓ check passed (preflight + compile + test)"
    ;;
  deploy-local)
    need_npx
    exec npx hardhat ignition deploy ./ignition/modules/SecureVault.js "$@"
    ;;
  env-check)
    exec bash "$ROOT/scripts/check_env.sh" "$@"
    ;;
  slither|static)
    exec bash "$ROOT/scripts/run_slither.sh" "$@"
    ;;
  hardhat|hh)
    need_npx
    exec npx hardhat "$@"
    ;;
  *)
    echo "Unknown command: $cmd" >&2
    usage >&2
    exit 2
    ;;
esac
