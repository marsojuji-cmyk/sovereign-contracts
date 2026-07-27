# Contracts

| Contract | Threat model | Role |
|----------|--------------|------|
| `SecureVault.sol` | **Owner custody** — one owner can drain the pot | Ownable ETH vault: push withdraw, pause, two-step ownership, `withdrawAll` |
| `AccountingVault.sol` | **Per-user credit / pull** — no shared owner drain | Ledger + self-service withdraw |
| `BuildManifestAnchor.sol` | **Event-only** — no fund custody | LIBRARIAN / doctrine content-hash anchors |
| `test/AttackHelpers.sol` | Test-only | Reentrancy + reject-ETH probes |

## Contrast (why both)

| | SecureVault | AccountingVault |
|--|-------------|-----------------|
| Who withdraws? | Owner only | Each user their own credit |
| Main risk class | Privileged key / owner malware | Insolvent ledger / over-credit |
| Invariant | Only owner reduces balance | `totalCredit == nativeBalance` |
| Withdraw style | Push to arbitrary `to` | Pull to `msg.sender` |

**Not production-audited.** Patterns only: custom errors, reentrancy guard, CEI, events.

Ignition modules: `ignition/modules/SecureVault.js`, `AccountingVault.js`, `BuildManifestAnchor.js`.

Threat notes: `docs/security/THREAT_MODELS.md`.
