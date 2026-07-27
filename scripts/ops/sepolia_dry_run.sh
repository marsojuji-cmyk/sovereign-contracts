#!/usr/bin/env bash
# Sepolia dry-run: offline checks + local Ignition exercises. No broadcast unless
# SECURE_PIPELINE_CONFIRM_SEPOLIA_BROADCAST=1 (explicit opt-in).
set -euo pipefail

# shellcheck source=../lib/root.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/root.sh"
cd "$ROOT"

echo "SECURE PIPELINE — SEPOLIA DRY-RUN"
echo "================================="
echo "Default: zero broadcast. Ignition runs on in-process hardhat only."
echo

bash "$ROOT/scripts/gates/check_env.sh"
echo
python3 "$ROOT/scripts/gates/env_probe.py" | tee /tmp/sp_env_probe.txt
tier="$(grep '^PIPELINE_ENV=' /tmp/sp_env_probe.txt | head -1 | cut -d= -f2)"
echo

echo "Compile"
npx hardhat compile
echo

echo "Ignition module exercise (hardhat / ephemeral)"
for mod in SecureVault AccountingVault BuildManifestAnchor; do
  echo "  → $mod"
  npx hardhat ignition deploy "./ignition/modules/${mod}.js" \
    --network hardhat \
    --deployment-id "dryrun-${mod}"
done
echo

if [[ "$tier" == "testnet" ]]; then
  echo "PIPELINE_ENV=testnet — read-only Sepolia probe (chainId):"
  npx hardhat run "$ROOT/scripts/ops/chain_probe_sepolia.js" --network sepolia
  echo
  if [[ "${SECURE_PIPELINE_CONFIRM_SEPOLIA_BROADCAST:-}" == "1" ]]; then
    echo "Broadcast opt-in detected — live Ignition on sepolia (BuildManifestAnchor only)."
    owner="$(node -e "require('./scripts/load_env').loadEnv();const {ethers}=require('ethers');console.log(new ethers.Wallet(process.env.DEPLOYER_PRIVATE_KEY).address);")"
    bal="$(node -e "require('./scripts/load_env').loadEnv();const {ethers}=require('ethers');const p=new ethers.JsonRpcProvider(process.env.SEPOLIA_RPC_URL);const w=new ethers.Wallet(process.env.DEPLOYER_PRIVATE_KEY,p);p.getBalance(w.address).then(b=>console.log(b.toString()));")"
    if [[ "$bal" == "0" ]]; then
      echo "✗ deployer $owner has 0 Sepolia ETH — fund from a faucet, then re-run."
      echo "  export SECURE_PIPELINE_CONFIRM_SEPOLIA_BROADCAST=1"
      echo "  ./scripts/ops/sepolia_dry_run.sh"
      exit 1
    fi
    echo "Deployer: $owner (balance wei: $bal)"
    params="{\"BuildManifestAnchorModule\":{\"initialOwner\":\"$owner\"}}"
    printf 'y\n' | npx hardhat ignition deploy ./ignition/modules/BuildManifestAnchor.js \
      --network sepolia \
      --deployment-id sepolia-BuildManifestAnchor \
      --parameters "$params"
    echo "Optional: anchor bundle on Sepolia — npx hardhat run scripts/ops/publish_local_manifest_anchor.js --network sepolia"
  else
    echo "To broadcast (your responsibility):"
    echo "  export SECURE_PIPELINE_CONFIRM_SEPOLIA_BROADCAST=1"
    echo "  ./scripts/ops/sepolia_dry_run.sh"
    echo "Or explicit one-shot:"
    echo "  npx hardhat ignition deploy ./ignition/modules/BuildManifestAnchor.js --network sepolia \\"
    echo "    --parameters '{\"BuildManifestAnchorModule\":{\"initialOwner\":\"0xYourBurner\"}}'"
  fi
else
  echo "Tier=${tier:-local} — Sepolia RPC not configured. Dry-run complete without remote I/O."
  echo "When ready: cp .env.example .env && chmod 600 .env — then re-run this script."
fi

echo
echo "✓ sepolia dry-run finished (see docs/ops/NETWORK_OPS.md)"