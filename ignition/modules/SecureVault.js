const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

/**
 * Deploy SecureVault with an explicit initial owner.
 * Default: first Hardhat account (local-only). Override via parameters in production.
 */
const SecureVaultModule = buildModule("SecureVaultModule", (m) => {
  const initialOwner = m.getParameter("initialOwner", m.getAccount(0));
  const vault = m.contract("SecureVault", [initialOwner]);
  return { vault };
});

module.exports = SecureVaultModule;
