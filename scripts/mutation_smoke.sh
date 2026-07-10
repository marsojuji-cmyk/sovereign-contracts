#!/usr/bin/env bash
# Mutation smoke — prove the suite catches a deliberate safety regression, then restore.
# Local-only. Never commits. Restores contracts/ via git even on failure.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
export PATH="${HOME}/.local/bin:${PATH}"

TARGET="contracts/SecureVault.sol"
MARKER="// MUTATION_SMOKE: nonReentrant stripped — DO NOT COMMIT"

cleanup() {
  # Always restore production sources
  git checkout -- "$TARGET" 2>/dev/null || true
  if grep -q "MUTATION_SMOKE" "$TARGET" 2>/dev/null; then
    echo "ERROR: mutation still present after cleanup" >&2
    exit 3
  fi
}
trap cleanup EXIT

echo "SECURE PIPELINE — MUTATION SMOKE"
echo "================================"
echo "Mutation: remove nonReentrant from SecureVault.withdraw"
echo "Expect:   safety test FAILS under mutation, PASSES after restore"
echo

if ! command -v npx >/dev/null 2>&1; then
  echo "ERROR: npx/node not on PATH (export PATH=\"\$HOME/.local/bin:\$PATH\")" >&2
  exit 2
fi

echo "==> 1/4 Baseline (must pass)"
npx hardhat test test/SecureVault.safety.js
echo

echo "==> 2/4 Apply mutation"
python3 - <<'PY'
from pathlib import Path
p = Path("contracts/SecureVault.sol")
t = p.read_text(encoding="utf-8")
old = "function withdraw(address payable to, uint256 amount) external onlyOwner nonReentrant {"
new = (
    "function withdraw(address payable to, uint256 amount) external onlyOwner { "
    "// MUTATION_SMOKE: nonReentrant stripped — DO NOT COMMIT"
)
if old not in t:
    raise SystemExit("mutation target string not found — update scripts/mutation_smoke.sh")
p.write_text(t.replace(old, new, 1), encoding="utf-8")
print("    applied:", old)
print("    ->", new)
PY
echo

echo "==> 3/4 Mutated suite (must FAIL)"
set +e
npx hardhat test test/SecureVault.safety.js
mut_code=$?
set -e
if [[ "$mut_code" -eq 0 ]]; then
  echo
  echo "✗ MUTATION NOT DETECTED — suite still green; strengthen tests" >&2
  exit 1
fi
echo
echo "✓ mutation detected (hardhat exit $mut_code)"
echo

echo "==> 4/4 Restore + baseline again (must pass)"
git checkout -- "$TARGET"
npx hardhat test test/SecureVault.safety.js
echo
echo "✓ mutation smoke passed (bite confirmed + restored)"
echo "  Optional full gate: make check"
