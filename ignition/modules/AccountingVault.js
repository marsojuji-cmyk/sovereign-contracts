const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

/**
 * Deploy AccountingVault (no constructor args — pure pull ledger).
 */
const AccountingVaultModule = buildModule("AccountingVaultModule", (m) => {
  const vault = m.contract("AccountingVault");
  return { vault };
});

module.exports = AccountingVaultModule;
