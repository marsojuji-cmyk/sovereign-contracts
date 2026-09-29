/**
 * Deploy BuildManifestAnchor on current network and anchor the canonical doc bundle.
 * Local default: in-process Hardhat. No secrets. Stdlib crypto for SHA-256 → bytes32.
 */
import hre from "hardhat";
import fs from "node:fs";
import path from "node:path";
import crypto from "node:crypto";
import { projectRoot } from "../lib/root.js";

const BUNDLE_DOCS = [
  "docs/doctrine/GROK_BUILD_INSTRUCTIONS.md",
  "docs/doctrine/LIBRARIAN_PROTOCOL.md",
  "docs/doctrine/BUILD_FRAME_NEXUS_PIPELINE.md",
];

const LABEL = process.env.MANIFEST_LABEL || "NEXUS_PIPELINE_BUNDLE";
const VERSION = process.env.MANIFEST_VERSION || "2026-07-10";

function bundleContentHash() {
  const root = projectRoot(import.meta.dirname);
  const parts = BUNDLE_DOCS.map((rel) => {
    const p = path.join(root, rel);
    if (!fs.existsSync(p)) throw new Error(`missing bundle doc: ${rel}`);
    return fs.readFileSync(p, "utf8");
  });
  const joined = parts.join("\n---MANIFEST_BOUNDARY---\n");
  const hex = crypto.createHash("sha256").update(joined, "utf8").digest("hex");
  return "0x" + hex;
}

async function main() {
  const { ethers } = await hre.network.create();
  const hash = bundleContentHash();
  const [owner] = await ethers.getSigners();
  const Factory = await ethers.getContractFactory("BuildManifestAnchor");
  const anchor = await Factory.deploy(owner.address);
  await anchor.waitForDeployment();
  const addr = await anchor.getAddress();
  const tx = await anchor.anchor(hash, LABEL, VERSION);
  const receipt = await tx.wait();
  console.log("MANIFEST_ANCHOR_LOCAL");
  console.log("contract:", addr);
  console.log("contentHash (sha256 bundle):", hash);
  console.log("label:", LABEL);
  console.log("version:", VERSION);
  console.log("tx:", receipt.hash);
  console.log("docs:", BUNDLE_DOCS.join(", "));
}

main().catch((err) => {
  console.error(err.message || err);
  process.exit(1);
});
