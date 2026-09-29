import { expect } from "chai";
import hre from "hardhat";

// Single shared connection for the whole file (Hardhat 3: no global hre.ethers).
// create() gives this file its own connection; the deprecated connect() is avoided.
const connection = await hre.network.create();
const ethers = connection.ethers;
const networkHelpers = connection.networkHelpers;

/**
 * Lightweight invariant / property tests (Hardhat-native "fuzz" loops).
 * No Foundry dependency — keeps the pipeline local and lean on legacy Mac.
 */

function rng(seed) {
  // xorshift32
  let x = seed >>> 0;
  return () => {
    x ^= x << 13;
    x ^= x >>> 17;
    x ^= x << 5;
    return (x >>> 0) / 0xffffffff;
  };
}

describe("Invariants — AccountingVault solvency", function () {
  async function deployFixture() {
    const signers = await ethers.getSigners();
    const actors = signers.slice(0, 5);
    const Vault = await ethers.getContractFactory("AccountingVault");
    const vault = await Vault.deploy();
    await vault.waitForDeployment();
    return { vault, actors };
  }

  it("totalCredit == nativeBalance after random deposit/withdraw sequences", async function () {
    const { vault, actors } = await networkHelpers.loadFixture(deployFixture);
    const rand = rng(0xc0ffee);
    const rounds = 40;

    for (let i = 0; i < rounds; i++) {
      const actor = actors[Math.floor(rand() * actors.length)];
      const credit = await vault.credit(actor.address);
      const doDeposit = credit === 0n || rand() < 0.55;

      if (doDeposit) {
        // 0.01 – 0.5 ether in 0.01 steps
        const units = 1n + BigInt(Math.floor(rand() * 50));
        const amount = units * ethers.parseEther("0.01");
        await vault.connect(actor).deposit({ value: amount });
      } else {
        // withdraw a fraction of credit
        const frac = 1n + BigInt(Math.floor(rand() * 4)); // 1..4
        let amount = credit / frac;
        if (amount === 0n) amount = credit;
        await vault.connect(actor).withdraw(amount);
      }

      const total = await vault.totalCredit();
      const native = await vault.nativeBalance();
      expect(total).to.equal(native);

      // reconstruct sum of credits
      let sum = 0n;
      for (const a of actors) {
        sum += await vault.credit(a.address);
      }
      expect(sum).to.equal(total);
    }
  });

  it("no user can withdraw more than their credit (direct probes)", async function () {
    const { vault, actors } = await networkHelpers.loadFixture(deployFixture);
    const [alice, bob] = actors;
    await vault.connect(alice).deposit({ value: ethers.parseEther("1") });
    await vault.connect(bob).deposit({ value: ethers.parseEther("2") });

    await expect(
      vault.connect(alice).withdraw(ethers.parseEther("1.01"))
    ).to.be.revertedWithCustomError(vault, "InsufficientCredit");

    // bob cannot steal alice's credit
    await expect(
      vault.connect(bob).withdraw(ethers.parseEther("2.5"))
    ).to.be.revertedWithCustomError(vault, "InsufficientCredit");

    expect(await vault.totalCredit()).to.equal(ethers.parseEther("3"));
  });
});

describe("Invariants — SecureVault custody", function () {
  async function deployFixture() {
    const [owner, alice, bob] = await ethers.getSigners();
    const Vault = await ethers.getContractFactory("SecureVault");
    const vault = await Vault.deploy(owner.address);
    await vault.waitForDeployment();
    return { vault, owner, alice, bob };
  }

  it("only owner can reduce balance; deposits always increase balance", async function () {
    const { vault, owner, alice, bob } = await networkHelpers.loadFixture(deployFixture);
    const rand = rng(0xbadc0de);
    let expected = 0n;

    for (let i = 0; i < 25; i++) {
      const depositor = rand() < 0.5 ? alice : bob;
      const amount = ethers.parseEther((0.1 + rand() * 0.9).toFixed(3));
      await vault.connect(depositor).deposit({ value: amount });
      expected += amount;
      expect(await vault.balance()).to.equal(expected);

      if (expected > 0n && rand() < 0.4) {
        const withdrawAmt = expected / 2n + 1n;
        if (withdrawAmt <= expected) {
          await expect(
            vault.connect(alice).withdraw(bob.address, withdrawAmt)
          ).to.be.revertedWithCustomError(vault, "NotOwner");

          await vault.connect(owner).withdraw(bob.address, withdrawAmt);
          expected -= withdrawAmt;
          expect(await vault.balance()).to.equal(expected);
        }
      }
    }
  });
});
