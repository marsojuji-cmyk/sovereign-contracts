const { expect } = require("chai");
const { ethers } = require("hardhat");
const { loadFixture } = require("@nomicfoundation/hardhat-toolbox/network-helpers");

/**
 * Phase 2 safety extras for SecureVault:
 * reentrancy probe, transfer-failure path, owner-as-contract edge cases.
 */
describe("SecureVault safety extras", function () {
  async function deployWithAttackerOwner() {
    const [funder, other] = await ethers.getSigners();
    // Deploy attacker first with a temporary vault address placeholder — need two-step.
    // Pattern: deploy vault with funder as owner, transfer ownership to attacker after attacker exists.
    const Vault = await ethers.getContractFactory("SecureVault");
    const vault = await Vault.deploy(funder.address);
    await vault.waitForDeployment();

    const Attacker = await ethers.getContractFactory("SecureVaultReentrancyAttacker");
    const attacker = await Attacker.deploy(await vault.getAddress());
    await attacker.waitForDeployment();

    await vault.connect(funder).transferOwnership(await attacker.getAddress());
    return { vault, attacker, funder, other };
  }

  it("blocks reentrant withdraw when owner is a malicious contract", async function () {
    const { vault, attacker, funder } = await loadFixture(deployWithAttackerOwner);
    const amount = ethers.parseEther("1");
    await vault.connect(funder).deposit({ value: amount });

    // nonReentrant trips inside receive; ETH call fails → TransferFailed at outer withdraw
    await expect(attacker.attack(amount)).to.be.revertedWithCustomError(vault, "TransferFailed");
    // Funds remain; no drain
    expect(await vault.balance()).to.equal(amount);
  });

  it("reverts TransferFailed when recipient rejects ETH", async function () {
    const [owner] = await ethers.getSigners();
    const Vault = await ethers.getContractFactory("SecureVault");
    const vault = await Vault.deploy(owner.address);
    await vault.waitForDeployment();

    const Reject = await ethers.getContractFactory("RejectEther");
    const reject = await Reject.deploy();
    await reject.waitForDeployment();

    const amount = ethers.parseEther("0.5");
    await vault.deposit({ value: amount });

    await expect(
      vault.withdraw(await reject.getAddress(), amount)
    ).to.be.revertedWithCustomError(vault, "TransferFailed");

    expect(await vault.balance()).to.equal(amount);
  });
});
