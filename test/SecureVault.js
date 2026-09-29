import { expect } from "chai";
import hre from "hardhat";

// Single shared connection for the whole file (Hardhat 3: no global hre.ethers).
// create() gives this file its own connection; the deprecated connect() is avoided.
const connection = await hre.network.create();
const ethers = connection.ethers;
const networkHelpers = connection.networkHelpers;

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
      const { vault, owner } = await networkHelpers.loadFixture(deployFixture);
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
      const { vault, alice } = await networkHelpers.loadFixture(deployFixture);
      const amount = ethers.parseEther("1");

      await expect(vault.connect(alice).deposit({ value: amount }))
        .to.emit(vault, "Deposited")
        .withArgs(alice.address, amount);

      expect(await vault.balance()).to.equal(amount);
    });

    it("accepts plain ETH via receive()", async function () {
      const { vault, alice } = await networkHelpers.loadFixture(deployFixture);
      const amount = ethers.parseEther("0.5");

      await expect(
        alice.sendTransaction({ to: await vault.getAddress(), value: amount })
      )
        .to.emit(vault, "Deposited")
        .withArgs(alice.address, amount);

      expect(await vault.balance()).to.equal(amount);
    });

    it("rejects zero-value deposit", async function () {
      const { vault, alice } = await networkHelpers.loadFixture(deployFixture);
      await expect(vault.connect(alice).deposit({ value: 0 })).to.be.revertedWithCustomError(
        vault,
        "ZeroAmount"
      );
    });

    it("rejects zero-value plain ETH transfer via receive()", async function () {
      const { vault, alice } = await networkHelpers.loadFixture(deployFixture);
      await expect(
        alice.sendTransaction({ to: await vault.getAddress(), value: 0 })
      ).to.be.revertedWithCustomError(vault, "ZeroAmount");
    });
  });

  describe("withdraw", function () {
    it("lets owner withdraw to a recipient", async function () {
      const { vault, owner, bob } = await networkHelpers.loadFixture(deployFixture);
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
      const { vault, owner, alice, bob } = await networkHelpers.loadFixture(deployFixture);
      await vault.connect(owner).deposit({ value: ethers.parseEther("1") });

      await expect(
        vault.connect(alice).withdraw(bob.address, ethers.parseEther("1"))
      ).to.be.revertedWithCustomError(vault, "NotOwner");
    });

    it("reverts on insufficient balance", async function () {
      const { vault, owner, bob } = await networkHelpers.loadFixture(deployFixture);
      await expect(
        vault.connect(owner).withdraw(bob.address, ethers.parseEther("1"))
      ).to.be.revertedWithCustomError(vault, "InsufficientBalance");
    });

    it("reverts on zero amount or zero recipient", async function () {
      const { vault, owner, bob } = await networkHelpers.loadFixture(deployFixture);
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

  describe("ownership (two-step)", function () {
    it("proposes then accepts ownership", async function () {
      const { vault, owner, alice } = await networkHelpers.loadFixture(deployFixture);

      await expect(vault.connect(owner).transferOwnership(alice.address))
        .to.emit(vault, "OwnershipTransferStarted")
        .withArgs(owner.address, alice.address);

      expect(await vault.owner()).to.equal(owner.address);
      expect(await vault.pendingOwner()).to.equal(alice.address);

      await expect(vault.connect(alice).acceptOwnership())
        .to.emit(vault, "OwnershipTransferred")
        .withArgs(owner.address, alice.address);

      expect(await vault.owner()).to.equal(alice.address);
      expect(await vault.pendingOwner()).to.equal(ethers.ZeroAddress);
    });

    it("rejects accept from non-pending and zero-address propose", async function () {
      const { vault, owner, alice, bob } = await networkHelpers.loadFixture(deployFixture);

      await expect(
        vault.connect(owner).transferOwnership(ethers.ZeroAddress)
      ).to.be.revertedWithCustomError(vault, "ZeroAddress");

      await vault.connect(owner).transferOwnership(alice.address);
      await expect(vault.connect(bob).acceptOwnership()).to.be.revertedWithCustomError(
        vault,
        "NotPendingOwner"
      );
    });

    it("owner can cancel pending transfer", async function () {
      const { vault, owner, alice } = await networkHelpers.loadFixture(deployFixture);
      await vault.connect(owner).transferOwnership(alice.address);

      await expect(vault.connect(owner).cancelOwnershipTransfer())
        .to.emit(vault, "OwnershipTransferCancelled")
        .withArgs(owner.address, alice.address);

      expect(await vault.pendingOwner()).to.equal(ethers.ZeroAddress);
      await expect(vault.connect(alice).acceptOwnership()).to.be.revertedWithCustomError(
        vault,
        "NotPendingOwner"
      );
    });

    it("rejects cancel when nothing pending", async function () {
      const { vault, owner } = await networkHelpers.loadFixture(deployFixture);
      await expect(vault.connect(owner).cancelOwnershipTransfer()).to.be.revertedWithCustomError(
        vault,
        "ZeroAddress"
      );
    });
  });

  describe("pause", function () {
    it("blocks deposit and withdraw while paused; unpause restores", async function () {
      const { vault, owner, alice, bob } = await networkHelpers.loadFixture(deployFixture);
      const amount = ethers.parseEther("1");
      await vault.connect(alice).deposit({ value: amount });

      await expect(vault.connect(owner).pause())
        .to.emit(vault, "Paused")
        .withArgs(owner.address);
      expect(await vault.paused()).to.equal(true);

      await expect(
        vault.connect(alice).deposit({ value: ethers.parseEther("0.1") })
      ).to.be.revertedWithCustomError(vault, "EnforcedPause");

      await expect(
        alice.sendTransaction({ to: await vault.getAddress(), value: ethers.parseEther("0.1") })
      ).to.be.revertedWithCustomError(vault, "EnforcedPause");

      await expect(
        vault.connect(owner).withdraw(bob.address, ethers.parseEther("0.1"))
      ).to.be.revertedWithCustomError(vault, "EnforcedPause");

      await expect(vault.connect(owner).withdrawAll(bob.address)).to.be.revertedWithCustomError(
        vault,
        "EnforcedPause"
      );

      await expect(vault.connect(owner).unpause())
        .to.emit(vault, "Unpaused")
        .withArgs(owner.address);

      await vault.connect(owner).withdraw(bob.address, ethers.parseEther("0.1"));
      expect(await vault.balance()).to.equal(ethers.parseEther("0.9"));
    });

    it("rejects double pause / unpause and non-owner pause", async function () {
      const { vault, owner, alice } = await networkHelpers.loadFixture(deployFixture);

      await expect(vault.connect(alice).pause()).to.be.revertedWithCustomError(vault, "NotOwner");
      await expect(vault.connect(owner).unpause()).to.be.revertedWithCustomError(
        vault,
        "ExpectedPause"
      );

      await vault.connect(owner).pause();
      await expect(vault.connect(owner).pause()).to.be.revertedWithCustomError(
        vault,
        "ExpectedPause"
      );
    });
  });

  describe("withdrawAll", function () {
    it("owner empties the vault to a recipient", async function () {
      const { vault, owner, alice, bob } = await networkHelpers.loadFixture(deployFixture);
      await vault.connect(alice).deposit({ value: ethers.parseEther("1.5") });
      await vault.connect(owner).deposit({ value: ethers.parseEther("0.5") });

      const before = await ethers.provider.getBalance(bob.address);
      await expect(vault.connect(owner).withdrawAll(bob.address))
        .to.emit(vault, "Withdrawn")
        .withArgs(bob.address, ethers.parseEther("2"));

      expect(await vault.balance()).to.equal(0n);
      expect(await ethers.provider.getBalance(bob.address)).to.equal(
        before + ethers.parseEther("2")
      );
    });

    it("reverts when empty or zero recipient or non-owner", async function () {
      const { vault, owner, alice, bob } = await networkHelpers.loadFixture(deployFixture);

      await expect(vault.connect(owner).withdrawAll(bob.address)).to.be.revertedWithCustomError(
        vault,
        "ZeroAmount"
      );

      await vault.connect(alice).deposit({ value: ethers.parseEther("1") });
      await expect(
        vault.connect(owner).withdrawAll(ethers.ZeroAddress)
      ).to.be.revertedWithCustomError(vault, "ZeroAddress");
      await expect(vault.connect(alice).withdrawAll(bob.address)).to.be.revertedWithCustomError(
        vault,
        "NotOwner"
      );
    });
  });
});
