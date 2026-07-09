# Threat models — Phase 2

Local-first teaching notes for the two production scaffolds.

## SecureVault — owner custody

```
Depositors ──ETH──► [ shared balance ] ──withdraw──► owner-chosen recipient
```

| Threat | Mitigation in scaffold |
|--------|------------------------|
| Non-owner drain | `onlyOwner` |
| Reentrancy on withdraw | `nonReentrant` + CEI order |
| Transfer to rejecting contract | `TransferFailed` |
| Zero-address owner / recipient | `ZeroAddress` |

**Residual risk:** compromised owner key drains everything. Not multi-sig / timelock.

## AccountingVault — pull ledger

```
Payers ──ETH──► credit[account] ──withdraw──► same account (pull)
```

| Threat | Mitigation in scaffold |
|--------|------------------------|
| Steal another user’s credit | withdraw only `msg.sender` credit |
| Over-withdraw | `InsufficientCredit` |
| Reentrancy on pull | `nonReentrant` + CEI |
| Ledger insolvency | invariant tests: `totalCredit == balance` |

**Residual risk:** forced ETH via `selfdestruct` can desync balance vs ledger (documented limitation).

## Safety extras (tests)

| Suite | What it proves |
|-------|----------------|
| `test/SecureVault.safety.js` | Malicious owner contract cannot reenter-drain; reject-ETH path |
| `test/AccountingVault.js` | Reentrancy / TransferFailed / solvency unit cases |
| `test/invariants.js` | Random multi-actor loops preserve solvency & custody rules |

Reentrancy via `receive()` often surfaces as **`TransferFailed`** on the outer call (inner guard reverts the ETH transfer). Funds still stay put.
