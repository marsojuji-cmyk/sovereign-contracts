#!/usr/bin/env bash
# Phase 4 — optional Slither static analysis (venv-local).
# Local-first: uses Hardhat artifacts when present; no network required for analysis.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if [[ -x "$ROOT/.venv/bin/slither" ]]; then
  SLITHER="$ROOT/.venv/bin/slither"
elif command -v slither >/dev/null 2>&1; then
  SLITHER="$(command -v slither)"
else
  cat >&2 <<'EOF'
ERROR: slither not found.

Install into the project venv (never system Python):

  ./scripts/setup_python.sh --with-slither

Docs: docs/STATIC_ANALYSIS.md
EOF
  exit 2
fi

if [[ ! -d "$ROOT/artifacts/contracts" ]]; then
  if command -v npx >/dev/null 2>&1; then
    echo "==> No artifacts — running hardhat compile"
    npx hardhat compile
  fi
fi

mkdir -p "$ROOT/reports"
OUT_MD="$ROOT/reports/slither-checklist.md"
OUT_JSON="$ROOT/reports/slither.json"

echo "==> Slither: $SLITHER"
"$SLITHER" --version
echo "==> Analyzing production contracts (test helpers filtered)"
echo

set +e
"$SLITHER" . \
  --config-file "$ROOT/slither.config.json" \
  --hardhat-ignore-compile \
  --filter-paths "(contracts/test/|node_modules/)" \
  --fail-medium \
  --checklist \
  --json "$OUT_JSON" \
  | tee "$OUT_MD"
code=${PIPESTATUS[0]}
set -e

echo
echo "==> Reports"
echo "    checklist: $OUT_MD"
echo "    json:      $OUT_JSON"
echo "    triage:    docs/STATIC_ANALYSIS.md"
echo

if [[ "$code" -eq 0 ]]; then
  echo "✓ Slither gate passed (no medium/high findings)"
else
  echo "✗ Slither reported medium/high findings or failed (exit $code)" >&2
fi
exit "$code"
