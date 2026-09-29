/**
 * Secure Pipeline — Hardhat 3 config (ESM).
 * Local-first: default network is the in-process EDR simulation. No remote RPC required.
 * Sepolia appears only when SEPOLIA_RPC_URL is set (see docs/ops/NETWORK_OPS.md).
 *
 * Secrets and URLs resolve lazily via configVariable(): unset values never break
 * config load — they only error if a task actually connects to that network.
 * Hardhat does not auto-load .env; source it at the shell when you need secrets:
 *   set -a; source .env 2>/dev/null; set +a
 */
import { defineConfig, configVariable } from "hardhat/config";
import hardhatToolboxMochaEthers from "@nomicfoundation/hardhat-toolbox-mocha-ethers";

export default defineConfig({
  // The toolbox bundles ethers, chai matchers, ignition (+ethers), keystore,
  // mocha, network helpers, typechain, and verify.
  plugins: [hardhatToolboxMochaEthers],
  solidity: {
    version: "0.8.28",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
      // Extra safety on overflow is default since 0.8; via-IR off for legacy Mac compile speed
      viaIR: false,
    },
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
  },
  networks: {
    default: {
      type: "edr-simulated",
      chainId: 31337,
    },
    localhost: {
      type: "http",
      url: "http://127.0.0.1:8545",
      chainId: 31337,
    },
    // Offline-safe: declared always, resolved lazily only when used.
    sepolia: {
      type: "http",
      chainType: "l1",
      url: configVariable("SEPOLIA_RPC_URL"),
      accounts: [configVariable("DEPLOYER_PRIVATE_KEY")],
    },
  },
  verify: {
    etherscan: {
      // Inert until ETHERSCAN_API_KEY is set (never commit secrets)
      apiKey: configVariable("ETHERSCAN_API_KEY"),
    },
  },
  test: {
    mocha: {
      timeout: 60_000,
    },
  },
  coverage: {
    // Attack helpers are test fixtures — do not pollute production coverage numbers
    skipFiles: ["contracts/test/**"],
  },
});
