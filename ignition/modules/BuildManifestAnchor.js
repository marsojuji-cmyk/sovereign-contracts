import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

/**
 * Deploy BuildManifestAnchor — publisher for off-chain LIBRARIAN / Grok Build manifests.
 */
const BuildManifestAnchorModule = buildModule("BuildManifestAnchorModule", (m) => {
  const initialOwner = m.getParameter("initialOwner", m.getAccount(0));
  const anchor = m.contract("BuildManifestAnchor", [initialOwner]);
  return { anchor };
});

export default BuildManifestAnchorModule;