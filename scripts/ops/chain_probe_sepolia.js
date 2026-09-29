/**
 * Read-only Sepolia chainId probe. No deploy, no keys printed.
 */
import hre from "hardhat";

async function main() {
  const { ethers } = await hre.network.create("sepolia");
  const net = await ethers.provider.getNetwork();
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
