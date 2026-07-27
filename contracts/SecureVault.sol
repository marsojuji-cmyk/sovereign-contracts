// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title SecureVault
 * @notice Ownable ETH vault — teaching scaffold for the secure pipeline.
 * @dev Patterns: Ownable (two-step), pause, non-reentrant withdraw, CEI, events.
 *      Not production-audited. Do not use with real funds without a professional review.
 *
 * Threat model: owner custody — anyone may deposit; only owner may withdraw.
 * Residual risk: compromised owner (or pending owner who accepts) can drain funds.
 */
contract SecureVault {
    address public owner;
    address public pendingOwner;
    bool public paused;
    bool private _locked;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);
    event OwnershipTransferCancelled(address indexed owner, address indexed cancelledPending);
    event Deposited(address indexed from, uint256 amount);
    event Withdrawn(address indexed to, uint256 amount);
    event Paused(address indexed account);
    event Unpaused(address indexed account);

    error NotOwner();
    error NotPendingOwner();
    error ZeroAddress();
    error ZeroAmount();
    error InsufficientBalance();
    error TransferFailed();
    error Reentrancy();
    error EnforcedPause();
    error ExpectedPause();

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    modifier whenNotPaused() {
        if (paused) revert EnforcedPause();
        _;
    }

    modifier nonReentrant() {
        if (_locked) revert Reentrancy();
        _locked = true;
        _;
        _locked = false;
    }

    constructor(address initialOwner) {
        if (initialOwner == address(0)) revert ZeroAddress();
        owner = initialOwner;
        emit OwnershipTransferred(address(0), initialOwner);
    }

    receive() external payable whenNotPaused {
        if (msg.value == 0) revert ZeroAmount();
        emit Deposited(msg.sender, msg.value);
    }

    /// @notice Deposit ETH into the vault (explicit entrypoint; receive() also works).
    function deposit() external payable whenNotPaused {
        if (msg.value == 0) revert ZeroAmount();
        emit Deposited(msg.sender, msg.value);
    }

    /// @notice Owner withdraws `amount` wei to `to` (checks-effects-interactions + reentrancy guard).
    function withdraw(address payable to, uint256 amount) external onlyOwner nonReentrant {
        if (paused) revert EnforcedPause();
        if (to == address(0)) revert ZeroAddress();
        if (amount == 0) revert ZeroAmount();
        if (address(this).balance < amount) revert InsufficientBalance();

        emit Withdrawn(to, amount);

        (bool ok, ) = to.call{value: amount}("");
        if (!ok) revert TransferFailed();
    }

    /// @notice Owner empties the vault to `to` (same guards as withdraw).
    function withdrawAll(address payable to) external onlyOwner nonReentrant {
        if (paused) revert EnforcedPause();
        if (to == address(0)) revert ZeroAddress();
        // Use > 0 (not == 0) so Slither incorrect-equality does not flag balance checks.
        uint256 amount = address(this).balance;
        if (!(amount > 0)) revert ZeroAmount();

        emit Withdrawn(to, amount);

        (bool ok, ) = to.call{value: amount}("");
        if (!ok) revert TransferFailed();
    }

    /// @notice Begin two-step ownership transfer. New owner must call acceptOwnership().
    function transferOwnership(address newOwner) external onlyOwner {
        if (newOwner == address(0)) revert ZeroAddress();
        pendingOwner = newOwner;
        emit OwnershipTransferStarted(owner, newOwner);
    }

    /// @notice Pending owner claims ownership (completes two-step transfer).
    function acceptOwnership() external {
        if (msg.sender != pendingOwner) revert NotPendingOwner();
        address prev = owner;
        owner = msg.sender;
        pendingOwner = address(0);
        emit OwnershipTransferred(prev, msg.sender);
    }

    /// @notice Owner cancels a pending ownership transfer.
    function cancelOwnershipTransfer() external onlyOwner {
        address cancelled = pendingOwner;
        if (cancelled == address(0)) revert ZeroAddress();
        pendingOwner = address(0);
        emit OwnershipTransferCancelled(owner, cancelled);
    }

    /// @notice Freeze deposits and withdrawals (owner emergency control).
    function pause() external onlyOwner {
        if (paused) revert ExpectedPause();
        paused = true;
        emit Paused(msg.sender);
    }

    /// @notice Resume deposits and withdrawals.
    function unpause() external onlyOwner {
        if (!paused) revert ExpectedPause();
        paused = false;
        emit Unpaused(msg.sender);
    }

    function balance() external view returns (uint256) {
        return address(this).balance;
    }
}
