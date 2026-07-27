# Threat models — Phase 2

Local-first teaching notes for the two production scaffolds.

## SecureVault — owner custody

```
Depositors ──ETH──► [ shared balance ] ──withdraw / withdrawAll──► owner-chosen recipient
                         ▲
                         └── pause freezes deposit + withdraw
```

| Threat | Mitigation in scaffold |
|--------|------------------------|
| Non-owner drain | `onlyOwner` |
| Reentrancy on withdraw | `nonReentrant` + CEI order |
| Transfer to rejecting contract | `TransferFailed` |
| Zero-address owner / recipient | `ZeroAddress` |
| Accidental one-tx ownership handoff | Two-step: `transferOwnership` → `acceptOwnership` (+ cancel) |
| Emergency ops freeze | `pause` / `unpause` (deposits + withdrawals) |

**Residual risk:** compromised owner (or accepted pending owner) drains everything. Not multi-sig / timelock.

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

## BuildManifestAnchor — manifest publisher (no custody)

```
Owner ──anchor(hash, label, version)──► event log (no stored state beyond owner)
```

| Threat | Mitigation in scaffold |
|--------|------------------------|
| Forged manifest attribution | `onlyOwner` on `anchor` |
| Zero / garbage hash | `ZeroHash` |
| Owner takeover | `transferOwnership` with `ZeroAddress` guard |

**Residual risk:** Owner can emit arbitrary labels; off-chain readers must verify `contentHash` against real files. Events are not replay-protected across chains — treat chain + address + log index as context.
