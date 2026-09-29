import { expect } from "chai";
import hre from "hardhat";

// Single shared connection for the whole file (Hardhat 3: no global hre.ethers).
// create() gives this file its own connection; the deprecated connect() is avoided.
const connection = await hre.network.create();
const ethers = connection.ethers;
const networkHelpers = connection.networkHelpers;

describe("BuildManifestAnchor", function () {
  async function deployFixture() {
    const [owner, alice] = await ethers.getSigners();
    const Factory = await ethers.getContractFactory("BuildManifestAnchor");
    const anchor = await Factory.deploy(owner.address);
    await anchor.waitForDeployment();
    return { anchor, owner, alice };
  }

  describe("deployment", function () {
    it("sets owner", async function () {
      const { anchor, owner } = await networkHelpers.loadFixture(deployFixture);
      expect(await anchor.owner()).to.equal(owner.address);
    });

    it("rejects zero-address owner", async function () {
      const Factory = await ethers.getContractFactory("BuildManifestAnchor");
      await expect(Factory.deploy(ethers.ZeroAddress)).to.be.revertedWithCustomError(
        Factory,
        "ZeroAddress"
      );
    });
  });

  describe("anchor", function () {
    it("emits ManifestAnchored for owner", async function () {
      const { anchor, owner } = await networkHelpers.loadFixture(deployFixture);
      const hash = ethers.keccak256(ethers.toUtf8Bytes("LIBRARIAN:v1:BUILD_FRAME"));
      await expect(anchor.anchor(hash, "BUILD_FRAME_NEXUS", "2026-07-10"))
        .to.emit(anchor, "ManifestAnchored")
        .withArgs(owner.address, hash, "BUILD_FRAME_NEXUS", "2026-07-10");
    });

    it("reverts zero hash", async function () {
      const { anchor } = await networkHelpers.loadFixture(deployFixture);
      await expect(anchor.anchor(ethers.ZeroHash, "x", "1")).to.be.revertedWithCustomError(
        anchor,
        "ZeroHash"
      );
    });

    it("reverts when non-owner anchors", async function () {
      const { anchor, alice } = await networkHelpers.loadFixture(deployFixture);
      const hash = ethers.keccak256(ethers.toUtf8Bytes("nope"));
      await expect(anchor.connect(alice).anchor(hash, "x", "1")).to.be.revertedWithCustomError(
        anchor,
        "NotOwner"
      );
    });
  });

  describe("ownership", function () {
    it("transfers ownership", async function () {
      const { anchor, owner, alice } = await networkHelpers.loadFixture(deployFixture);
      await expect(anchor.transferOwnership(alice.address))
        .to.emit(anchor, "OwnershipTransferred")
        .withArgs(owner.address, alice.address);
      expect(await anchor.owner()).to.equal(alice.address);
    });

    it("rejects zero-address transfer", async function () {
      const { anchor } = await networkHelpers.loadFixture(deployFixture);
      await expect(anchor.transferOwnership(ethers.ZeroAddress)).to.be.revertedWithCustomError(
        anchor,
        "ZeroAddress"
      );
    });
  });
});