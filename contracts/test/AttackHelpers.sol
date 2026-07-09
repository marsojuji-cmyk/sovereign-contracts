// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {SecureVault} from "../SecureVault.sol";
import {AccountingVault} from "../AccountingVault.sol";

/**
 * @dev Test-only helpers. Not for deployment on public networks.
 */

/// @notice Rejects all ETH — forces TransferFailed on vault withdraw.
contract RejectEther {
    receive() external payable {
        revert("RejectEther");
    }

    fallback() external payable {
        revert("RejectEther");
    }
}

/// @notice Owner-shaped attacker: re-enters SecureVault.withdraw from receive().
contract SecureVaultReentrancyAttacker {
    SecureVault public immutable vault;
    uint256 public attackAmount;
    bool public attacking;

    constructor(SecureVault vault_) {
        vault = vault_;
    }

    /// @notice Fund the vault then attempt a reentrant withdraw to this contract.
    function attack(uint256 amount) external {
        attackAmount = amount;
        attacking = true;
        vault.withdraw(payable(address(this)), amount);
        attacking = false;
    }

    receive() external payable {
        if (attacking) {
            // Balance may already be reduced mid-call; still attempt reentry.
            vault.withdraw(payable(address(this)), attackAmount);
        }
    }
}

/// @notice Re-enters AccountingVault.withdraw during receive after a pull.
contract AccountingVaultReentrancyAttacker {
    AccountingVault public immutable vault;
    uint256 public attackAmount;
    bool public attacking;

    constructor(AccountingVault vault_) {
        vault = vault_;
    }

    function seedAndAttack(uint256 amount) external payable {
        require(msg.value == amount, "fund mismatch");
        vault.deposit{value: amount}();
        attackAmount = amount;
        attacking = true;
        vault.withdraw(amount);
        attacking = false;
    }

    receive() external payable {
        if (attacking) {
            // Credit already reduced (CEI); still force reentry so nonReentrant trips.
            vault.withdraw(attackAmount);
        }
    }
}

/// @notice Deposits then withdraws while rejecting ETH — hits TransferFailed.
contract AccountingVaultTransferRejector {
    AccountingVault public immutable vault;

    constructor(AccountingVault vault_) {
        vault = vault_;
    }

    function depositAndWithdraw(uint256 amount) external payable {
        require(msg.value == amount, "fund mismatch");
        vault.deposit{value: amount}();
        vault.withdraw(amount);
    }

    receive() external payable {
        revert("AccountingVaultTransferRejector");
    }
}

