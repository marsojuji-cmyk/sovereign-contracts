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

    // Two-step ownership: propose then attacker accepts.
    await vault.connect(funder).transferOwnership(await attacker.getAddress());
    await attacker.acceptOwnership();
    return { vault, attacker, funder, other };
  }

  it("blocks reentrant withdraw when owner is a malicious contract", async function () {
    const { vault, attacker, funder } = await loadFixture(deployWithAttackerOwner);
    // Deposit 2 ETH and reenter with 1 ETH each time. Without nonReentrant, the
    // attacker can pull twice (balance-only accounting); CEI-on-balance alone
    // does NOT stop that when amount < full balance. Use 2x so missing guard fails.
    const total = ethers.parseEther("2");
    const slice = ethers.parseEther("1");
    await vault.connect(funder).deposit({ value: total });

    // nonReentrant trips inside receive; ETH call fails → TransferFailed at outer withdraw
    await expect(attacker.attack(slice)).to.be.revertedWithCustomError(vault, "TransferFailed");
    // Funds remain; no partial drain
    expect(await vault.balance()).to.equal(total);
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

  it("reverts TransferFailed on withdrawAll to rejecting recipient", async function () {
    const [owner] = await ethers.getSigners();
    const Vault = await ethers.getContractFactory("SecureVault");
    const vault = await Vault.deploy(owner.address);
    await vault.waitForDeployment();

    const Reject = await ethers.getContractFactory("RejectEther");
    const reject = await Reject.deploy();
    await reject.waitForDeployment();

    const amount = ethers.parseEther("0.25");
    await vault.deposit({ value: amount });

    await expect(
      vault.withdrawAll(await reject.getAddress())
    ).to.be.revertedWithCustomError(vault, "TransferFailed");

    expect(await vault.balance()).to.equal(amount);
  });
});
