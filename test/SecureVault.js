const { expect } = require("chai");
const { ethers } = require("hardhat");
const { loadFixture } = require("@nomicfoundation/hardhat-toolbox/network-helpers");

describe("SecureVault", function () {
  async function deployFixture() {
    const [owner, alice, bob] = await ethers.getSigners();
    const Vault = await ethers.getContractFactory("SecureVault");
    const vault = await Vault.deploy(owner.address);
    await vault.waitForDeployment();
    return { vault, owner, alice, bob };
  }

  describe("deployment", function () {
    it("sets the initial owner", async function () {
      const { vault, owner } = await loadFixture(deployFixture);
      expect(await vault.owner()).to.equal(owner.address);
    });

    it("rejects zero-address owner", async function () {
      const Vault = await ethers.getContractFactory("SecureVault");
      await expect(Vault.deploy(ethers.ZeroAddress)).to.be.revertedWithCustomError(
        Vault,
        "ZeroAddress"
      );
    });
  });

  describe("deposit", function () {
    it("accepts deposit() and updates balance", async function () {
      const { vault, alice } = await loadFixture(deployFixture);
      const amount = ethers.parseEther("1");

      await expect(vault.connect(alice).deposit({ value: amount }))
        .to.emit(vault, "Deposited")
        .withArgs(alice.address, amount);

      expect(await vault.balance()).to.equal(amount);
    });

    it("accepts plain ETH via receive()", async function () {
      const { vault, alice } = await loadFixture(deployFixture);
      const amount = ethers.parseEther("0.5");

      await expect(
        alice.sendTransaction({ to: await vault.getAddress(), value: amount })
      )
        .to.emit(vault, "Deposited")
        .withArgs(alice.address, amount);

      expect(await vault.balance()).to.equal(amount);
    });

    it("rejects zero-value deposit", async function () {
      const { vault, alice } = await loadFixture(deployFixture);
      await expect(vault.connect(alice).deposit({ value: 0 })).to.be.revertedWithCustomError(
        vault,
        "ZeroAmount"
      );
    });
  });

  describe("withdraw", function () {
    it("lets owner withdraw to a recipient", async function () {
      const { vault, owner, bob } = await loadFixture(deployFixture);
      const amount = ethers.parseEther("1");
      await vault.connect(owner).deposit({ value: amount });

      const before = await ethers.provider.getBalance(bob.address);
      await expect(vault.connect(owner).withdraw(bob.address, amount))
        .to.emit(vault, "Withdrawn")
        .withArgs(bob.address, amount);

      expect(await vault.balance()).to.equal(0n);
      expect(await ethers.provider.getBalance(bob.address)).to.equal(before + amount);
    });

    it("reverts when non-owner withdraws", async function () {
      const { vault, owner, alice, bob } = await loadFixture(deployFixture);
      await vault.connect(owner).deposit({ value: ethers.parseEther("1") });

      await expect(
        vault.connect(alice).withdraw(bob.address, ethers.parseEther("1"))
      ).to.be.revertedWithCustomError(vault, "NotOwner");
    });

    it("reverts on insufficient balance", async function () {
      const { vault, owner, bob } = await loadFixture(deployFixture);
      await expect(
        vault.connect(owner).withdraw(bob.address, ethers.parseEther("1"))
      ).to.be.revertedWithCustomError(vault, "InsufficientBalance");
    });

    it("reverts on zero amount or zero recipient", async function () {
      const { vault, owner, bob } = await loadFixture(deployFixture);
      await vault.connect(owner).deposit({ value: ethers.parseEther("1") });

      await expect(vault.connect(owner).withdraw(bob.address, 0)).to.be.revertedWithCustomError(
        vault,
        "ZeroAmount"
      );
      await expect(
        vault.connect(owner).withdraw(ethers.ZeroAddress, ethers.parseEther("0.1"))
      ).to.be.revertedWithCustomError(vault, "ZeroAddress");
    });
  });

  describe("ownership", function () {
    it("transfers ownership", async function () {
      const { vault, owner, alice } = await loadFixture(deployFixture);

      await expect(vault.connect(owner).transferOwnership(alice.address))
        .to.emit(vault, "OwnershipTransferred")
        .withArgs(owner.address, alice.address);

      expect(await vault.owner()).to.equal(alice.address);
    });

    it("rejects zero-address ownership transfer", async function () {
      const { vault, owner } = await loadFixture(deployFixture);
      await expect(
        vault.connect(owner).transferOwnership(ethers.ZeroAddress)
      ).to.be.revertedWithCustomError(vault, "ZeroAddress");
    });
  });
});
