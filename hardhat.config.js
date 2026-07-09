/**
 * Secure Pipeline — Hardhat 2 config
 * Local-first: default network is hardhat (in-process). No remote RPC required.
 * Sepolia appears only when SEPOLIA_RPC_URL is set (see docs/NETWORK_OPS.md).
 */
const { loadEnv } = require("./scripts/load_env");
loadEnv();

require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-ignition");
require("solidity-coverage");

/** @type import('hardhat/config').HardhatUserConfig */
const config = {
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
    hardhat: {
      chainId: 31337,
    },
    localhost: {
      url: "http://127.0.0.1:8545",
      chainId: 31337,
    },
  },
  // Verify stays inert until ETHERSCAN_API_KEY is set (never commit secrets)
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY || "",
  },
  mocha: {
    timeout: 60_000,
  },
  // Attack helpers are test fixtures — do not pollute production coverage numbers
  solidityCoverage: {
    skipFiles: ["contracts/test/"],
  },
};

// Optional Sepolia — omitted entirely when RPC URL unset (offline-safe default)
if (process.env.SEPOLIA_RPC_URL) {
  const accounts = process.env.DEPLOYER_PRIVATE_KEY
    ? [process.env.DEPLOYER_PRIVATE_KEY]
    : [];
  config.networks.sepolia = {
    url: process.env.SEPOLIA_RPC_URL,
    chainId: 11155111,
    accounts,
  };
}

module.exports = config;
