#!/usr/bin/env bash
# Offline env shape check for optional network ops.
# Never prints secret values. Never calls RPC.
set -euo pipefail

# shellcheck source=../lib/root.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/root.sh"
cd "$ROOT"

# Load .env into this shell only if present (same rules as hardhat helper)
if [[ -f "$ROOT/.env" ]]; then
  set -a
  # shellcheck disable=SC1091
  # Parse simply: KEY=VAL lines; no command substitution
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%%#*}"
    line="$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    [[ -z "$line" ]] && continue
    [[ "$line" != *"="* ]] && continue
    key="${line%%=*}"
    val="${line#*=}"
    key="$(echo "$key" | sed 's/[[:space:]]//g')"
    val="$(echo "$val" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    val="${val%\"}"
    val="${val#\"}"
    val="${val%\'}"
    val="${val#\'}"
    if [[ -z "${!key+x}" ]]; then
      export "$key=$val"
    fi
  done < "$ROOT/.env"
  set +a
fi

echo "SECURE PIPELINE — ENV CHECK (offline)"
echo "======================================"
echo "No RPC calls. Values are never printed."
echo

ok=1

status_var() {
  local name="$1"
  local required_for="$2"
  if [[ -n "${!name:-}" ]]; then
    echo "  $name: set ($required_for)"
  else
    echo "  $name: unset ($required_for)"
  fi
}

status_var SEPOLIA_RPC_URL "Sepolia deploy/read"
status_var DEPLOYER_PRIVATE_KEY "sign deploys"
status_var ETHERSCAN_API_KEY "source verify"

echo

# Shape checks only when set
if [[ -n "${SEPOLIA_RPC_URL:-}" ]]; then
  if [[ "$SEPOLIA_RPC_URL" =~ ^https?:// ]]; then
    echo "  ✓ SEPOLIA_RPC_URL looks like http(s) URL"
  else
    echo "  ✗ SEPOLIA_RPC_URL should start with http:// or https://"
    ok=0
  fi
  if [[ "$SEPOLIA_RPC_URL" == *"mainnet"* ]]; then
    echo "  ✗ SEPOLIA_RPC_URL contains 'mainnet' — abort mental model; use Sepolia only"
    ok=0
  fi
else
  echo "  · SEPOLIA_RPC_URL unset — Sepolia network omitted from Hardhat (safe default)"
fi

if [[ -n "${DEPLOYER_PRIVATE_KEY:-}" ]]; then
  key="$DEPLOYER_PRIVATE_KEY"
  if [[ "$key" =~ ^0x[0-9a-fA-F]{64}$ ]]; then
    echo "  ✓ DEPLOYER_PRIVATE_KEY shape OK (0x + 64 hex)"
  elif [[ "$key" =~ ^[0-9a-fA-F]{64}$ ]]; then
    echo "  ~ DEPLOYER_PRIVATE_KEY is 64 hex without 0x — Hardhat may accept; prefer 0x prefix"
  else
    echo "  ✗ DEPLOYER_PRIVATE_KEY shape unexpected (want 0x + 64 hex)"
    ok=0
  fi
else
  echo "  · DEPLOYER_PRIVATE_KEY unset — cannot sign Sepolia txs (fail closed)"
fi

if [[ -n "${ETHERSCAN_API_KEY:-}" ]]; then
  if [[ ${#ETHERSCAN_API_KEY} -ge 8 ]]; then
    echo "  ✓ ETHERSCAN_API_KEY present (length ≥ 8)"
  else
    echo "  ✗ ETHERSCAN_API_KEY too short to be plausible"
    ok=0
  fi
else
  echo "  · ETHERSCAN_API_KEY unset — verify commands will fail if run"
fi

echo
if [[ -f "$ROOT/.env" ]]; then
  perms=$(stat -f '%Lp' "$ROOT/.env" 2>/dev/null || stat -c '%a' "$ROOT/.env" 2>/dev/null || echo "?")
  echo "  .env file: present (mode $perms) — prefer 600"
  if [[ "$perms" != "600" && "$perms" != "400" && "$perms" != "?" ]]; then
    echo "  ~ consider: chmod 600 .env"
  fi
else
  echo "  .env file: absent (OK if using exported shell vars only)"
fi

echo
echo "Secret-pattern scan (contracts/ scripts/ src/ — no values printed)"
echo "----------------------------------------------------------------"
# Fail if a 64-hex private-key-shaped token appears outside .env
# (common accidental commit pattern). Does not print matching lines.
scan_dirs=(contracts scripts src)
hits=0
for d in "${scan_dirs[@]}"; do
  [[ -d "$ROOT/$d" ]] || continue
  # -I skip binary; exclude node_modules if nested
  if command -v rg >/dev/null 2>&1; then
    if rg -n --hidden -I -g '!.git/**' -g '!node_modules/**' \
      -e '0x[a-fA-F0-9]{64}' -e '(?i)(private[_-]?key|secret[_-]?key)\s*[:=]\s*0x' \
      "$ROOT/$d" >/dev/null 2>&1; then
      echo "  ✗ possible key material pattern under $d/"
      hits=$((hits + 1))
      ok=0
    else
      echo "  ✓ no key-shaped patterns in $d/"
    fi
  else
    if grep -R -n -E '0x[a-fA-F0-9]{64}' "$ROOT/$d" 2>/dev/null \
      | grep -v node_modules | grep -q .; then
      echo "  ✗ possible key material pattern under $d/"
      hits=$((hits + 1))
      ok=0
    else
      echo "  ✓ no key-shaped patterns in $d/"
    fi
  fi
done
if [[ "$hits" -gt 0 ]]; then
  echo "  Fix: remove secrets from tracked files; use .env (gitignored) only."
fi

echo
echo "Docs: docs/ops/NETWORK_OPS.md"
echo "Local gate still: make check  (no env required)"
echo "Contracts diff gate: make check-full"
echo

if [[ "$ok" -eq 1 ]]; then
  if [[ -n "${SEPOLIA_RPC_URL:-}" && -n "${DEPLOYER_PRIVATE_KEY:-}" ]]; then
    echo "Result: shape OK for optional Sepolia deploy (still your call to broadcast)."
  else
    echo "Result: OK for local-only work. Fill env only when you opt into testnet."
  fi
  exit 0
else
  echo "Result: fix shape issues above before any network command."
  exit 1
fi
