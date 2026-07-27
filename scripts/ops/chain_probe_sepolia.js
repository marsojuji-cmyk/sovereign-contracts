/**
 * Read-only Sepolia chainId probe. No deploy, no keys printed.
 */
const hre = require("hardhat");

async function main() {
  const net = await hre.ethers.provider.getNetwork();
  const chainId = Number(net.chainId);
  if (chainId !== 11155111) {
    throw new Error(`unexpected chainId ${chainId} — expected Sepolia 11155111`);
  }
  console.log(`  ✓ RPC reachable, chainId=${chainId} (Sepolia)`);
}

main().catch((err) => {
  console.error("  ✗ chain probe failed:", err.message);
  process.exit(1);
});