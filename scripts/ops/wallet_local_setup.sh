#!/usr/bin/env bash
# Local wallet/env prep for secure_pipeline + optional Solana import.
# Does not contain or accept secrets on the command line.
set -euo pipefail

# shellcheck source=../lib/root.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/root.sh"
cd "$ROOT"

echo "== secure_pipeline env =="
if [[ ! -f .env ]]; then
  cp .env.example .env
  chmod 600 .env
  echo "Created .env from .env.example (chmod 600)."
else
  chmod 600 .env 2>/dev/null || true
  echo ".env already exists (left unchanged)."
fi

./scripts/gates/check_env.sh

echo ""
echo "== offline gate =="
make check

echo ""
echo "== Solana directory =="
mkdir -p "${HOME}/.config/solana"
chmod 700 "${HOME}/.config/solana"
echo "Ready: ${HOME}/.config/solana (mode 700)"

if command -v solana >/dev/null 2>&1; then
  echo "solana CLI: $(solana --version | head -1)"
else
  echo "solana CLI: not installed (brew install solana or see docs.solanalabs.com/cli/install)"
fi

echo ""
echo "== Ethereum deploy vars =="
echo "Edit .env locally for SEPOLIA_RPC_URL, DEPLOYER_PRIVATE_KEY (0x+64 hex), ETHERSCAN_API_KEY."
echo "Docs: docs/ops/NETWORK_OPS.md"

echo ""
echo "== Solana import (interactive, local only) =="
echo "Run:  ./scripts/ops/solana_import_local.sh"
echo "Then: solana config set --url devnet   # optional, for experiments"