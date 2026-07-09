// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title AccountingVault
 * @notice Per-user credit ledger with pull withdrawals — contrasting SecureVault's owner custody.
 * @dev Threat model differences vs SecureVault:
 *      - Users withdraw *their own* credit (not a privileged owner draining a shared pot).
 *      - Solvency invariant: sum(credits) == address(this).balance (when no forced ETH gifts).
 *      - Still uses CEI + nonReentrant on the external call path.
 *      Not production-audited.
 */
contract AccountingVault {
    mapping(address => uint256) public credit;
    uint256 public totalCredit;
    bool private _locked;

    event Deposited(address indexed account, uint256 amount);
    event Withdrawn(address indexed account, uint256 amount);

    error ZeroAddress();
    error ZeroAmount();
    error InsufficientCredit();
    error TransferFailed();
    error Reentrancy();

    modifier nonReentrant() {
        if (_locked) revert Reentrancy();
        _locked = true;
        _;
        _locked = false;
    }

    receive() external payable {
        _deposit(msg.sender, msg.value);
    }

    /// @notice Credit `msg.value` to the caller.
    function deposit() external payable {
        _deposit(msg.sender, msg.value);
    }

    /// @notice Credit `msg.value` to `account` (payer may fund someone else).
    function depositTo(address account) external payable {
        if (account == address(0)) revert ZeroAddress();
        _deposit(account, msg.value);
    }

    /// @notice Pull `amount` of the caller's credit back to the caller.
    function withdraw(uint256 amount) external nonReentrant {
        if (amount == 0) revert ZeroAmount();
        uint256 bal = credit[msg.sender];
        if (bal < amount) revert InsufficientCredit();

        // Effects before interaction
        unchecked {
            credit[msg.sender] = bal - amount;
            totalCredit -= amount;
        }

        emit Withdrawn(msg.sender, amount);

        (bool ok, ) = payable(msg.sender).call{value: amount}("");
        if (!ok) revert TransferFailed();
    }

    function balanceOf(address account) external view returns (uint256) {
        return credit[account];
    }

    /// @notice ETH held by the contract (should match totalCredit under normal use).
    function nativeBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function _deposit(address account, uint256 amount) private {
        if (amount == 0) revert ZeroAmount();
        if (account == address(0)) revert ZeroAddress();

        credit[account] += amount;
        totalCredit += amount;
        emit Deposited(account, amount);
    }
}

