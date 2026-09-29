import { expect } from "chai";
import hre from "hardhat";

// Single shared connection for the whole file (Hardhat 3: no global hre.ethers).
// create() gives this file its own connection; the deprecated connect() is avoided.
const connection = await hre.network.create();
const ethers = connection.ethers;
const networkHelpers = connection.networkHelpers;

describe("AccountingVault", function () {
  async function deployFixture() {
    const [alice, bob, carol] = await ethers.getSigners();
    const Vault = await ethers.getContractFactory("AccountingVault");
    const vault = await Vault.deploy();
    await vault.waitForDeployment();
    return { vault, alice, bob, carol };
  }

  describe("deposit", function () {
    it("credits the caller via deposit()", async function () {
      const { vault, alice } = await networkHelpers.loadFixture(deployFixture);
      const amount = ethers.parseEther("1");

      await expect(vault.connect(alice).deposit({ value: amount }))
        .to.emit(vault, "Deposited")
        .withArgs(alice.address, amount);

      expect(await vault.credit(alice.address)).to.equal(amount);
      expect(await vault.totalCredit()).to.equal(amount);
      expect(await vault.nativeBalance()).to.equal(amount);
    });

    it("credits via receive()", async function () {
      const { vault, bob } = await networkHelpers.loadFixture(deployFixture);
      const amount = ethers.parseEther("0.25");

      await expect(bob.sendTransaction({ to: await vault.getAddress(), value: amount }))
        .to.emit(vault, "Deposited")
        .withArgs(bob.address, amount);

      expect(await vault.balanceOf(bob.address)).to.equal(amount);
    });

    it("depositTo credits a third party", async function () {
      const { vault, alice, bob } = await networkHelpers.loadFixture(deployFixture);
      const amount = ethers.parseEther("2");

      await vault.connect(alice).depositTo(bob.address, { value: amount });
      expect(await vault.credit(bob.address)).to.equal(amount);
      expect(await vault.credit(alice.address)).to.equal(0n);
    });

    it("rejects zero deposits and zero depositTo target", async function () {
      const { vault, alice } = await networkHelpers.loadFixture(deployFixture);
      await expect(vault.connect(alice).deposit({ value: 0 })).to.be.revertedWithCustomError(
        vault,
        "ZeroAmount"
      );
      await expect(
        vault.connect(alice).depositTo(ethers.ZeroAddress, { value: ethers.parseEther("1") })
      ).to.be.revertedWithCustomError(vault, "ZeroAddress");
    });
  });

  describe("withdraw", function () {
    it("lets a user pull their own credit only", async function () {
      const { vault, alice, bob } = await networkHelpers.loadFixture(deployFixture);
      const amount = ethers.parseEther("1");
      await vault.connect(alice).deposit({ value: amount });
      await vault.connect(bob).deposit({ value: ethers.parseEther("3") });

      await expect(vault.connect(alice).withdraw(amount))
        .to.emit(vault, "Withdrawn")
        .withArgs(alice.address, amount);

      expect(await vault.credit(alice.address)).to.equal(0n);
      expect(await vault.credit(bob.address)).to.equal(ethers.parseEther("3"));
      expect(await vault.totalCredit()).to.equal(ethers.parseEther("3"));
      expect(await vault.nativeBalance()).to.equal(ethers.parseEther("3"));
    });

    it("reverts on over-withdraw and zero amount", async function () {
      const { vault, alice } = await networkHelpers.loadFixture(deployFixture);
      await vault.connect(alice).deposit({ value: ethers.parseEther("1") });

      await expect(vault.connect(alice).withdraw(0)).to.be.revertedWithCustomError(
        vault,
        "ZeroAmount"
      );
      await expect(
        vault.connect(alice).withdraw(ethers.parseEther("2"))
      ).to.be.revertedWithCustomError(vault, "InsufficientCredit");
    });

    it("blocks reentrancy on withdraw", async function () {
      const { vault } = await networkHelpers.loadFixture(deployFixture);
      const Attacker = await ethers.getContractFactory("AccountingVaultReentrancyAttacker");
      const attacker = await Attacker.deploy(await vault.getAddress());
      await attacker.waitForDeployment();

      const amount = ethers.parseEther("1");
      // Inner nonReentrant reverts inside receive → outer call fails → TransferFailed
      await expect(attacker.seedAndAttack(amount, { value: amount })).to.be.revertedWithCustomError(
        vault,
        "TransferFailed"
      );
      expect(await vault.totalCredit()).to.equal(0n);
      expect(await vault.nativeBalance()).to.equal(0n);
    });

    it("reverts TransferFailed when pull recipient rejects ETH", async function () {
      const { vault } = await networkHelpers.loadFixture(deployFixture);
      const Rejector = await ethers.getContractFactory("AccountingVaultTransferRejector");
      const rejector = await Rejector.deploy(await vault.getAddress());
      await rejector.waitForDeployment();

      const amount = ethers.parseEther("0.75");
      await expect(
        rejector.depositAndWithdraw(amount, { value: amount })
      ).to.be.revertedWithCustomError(vault, "TransferFailed");

      expect(await vault.totalCredit()).to.equal(0n);
      expect(await vault.nativeBalance()).to.equal(0n);
    });

    it("partial withdraw keeps solvency", async function () {
      const { vault, alice } = await networkHelpers.loadFixture(deployFixture);
      await vault.connect(alice).deposit({ value: ethers.parseEther("2") });
      await vault.connect(alice).withdraw(ethers.parseEther("0.5"));
      expect(await vault.totalCredit()).to.equal(ethers.parseEther("1.5"));
      expect(await vault.nativeBalance()).to.equal(ethers.parseEther("1.5"));
    });
  });
});
