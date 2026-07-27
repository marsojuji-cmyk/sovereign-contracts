// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title BuildManifestAnchor
 * @notice Owner-published anchors for off-chain build manifests (LIBRARIAN / Grok Build).
 * @dev No ETH custody. Emits auditable events; does not store strings on-chain (gas-light).
 *      Hash off-chain files (e.g. SHA-256) and pass as bytes32 (truncate or use keccak of content).
 */
contract BuildManifestAnchor {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event ManifestAnchored(
        address indexed publisher,
        bytes32 indexed contentHash,
        string label,
        string version
    );

    error NotOwner();
    error ZeroAddress();
    error ZeroHash();

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    constructor(address initialOwner) {
        if (initialOwner == address(0)) revert ZeroAddress();
        owner = initialOwner;
        emit OwnershipTransferred(address(0), initialOwner);
    }

    /// @notice Publish an anchor for an off-chain manifest (docs bundle, report, gate log).
    function anchor(bytes32 contentHash, string calldata label, string calldata version) external onlyOwner {
        if (contentHash == bytes32(0)) revert ZeroHash();
        emit ManifestAnchored(msg.sender, contentHash, label, version);
    }

    function transferOwnership(address newOwner) external onlyOwner {
        if (newOwner == address(0)) revert ZeroAddress();
        address previous = owner;
        owner = newOwner;
        emit OwnershipTransferred(previous, newOwner);
    }
}