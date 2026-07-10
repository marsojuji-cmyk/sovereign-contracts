# Mutation smoke

**Commander's Intent**

| | |
|---|---|
| **Purpose** | Prove unit/safety tests have real bite — not only coverage %. |
| **End State** | Deliberate `nonReentrant` removal fails the suite; restore leaves `make check` green. |
| **Constraints** | Local-only · never commit mutation · always `git checkout` restore |

## Findings (why early attempts were weak)

1. **Full-balance withdraw** — reentering for the entire remaining balance hits `InsufficientBalance` without needing `nonReentrant`.
2. **Infinite reentry in the attacker** — `receive()` always called `withdraw` again until balance was 0, so the **innermost** call reverted and the whole chain looked like `TransferFailed` even with the guard stripped.

**Fixes:**

- Safety test deposits **2 ETH**, reenters with **1 ETH**.
- `SecureVaultReentrancyAttacker.receive` reenters **once** (`attacking = false` before the nested withdraw).

With those, stripping `nonReentrant` lets the attacker pull 2×1 ETH successfully → suite **fails**. With the guard, nested call reverts → outer `TransferFailed` → suite **passes**.

AccountingVault still relies on **CEI on credits** for reentrancy safety; `nonReentrant` is defense in depth there.

## Run

```bash
export PATH="$HOME/.local/bin:$PATH"
cd /path/to/secure_pipeline
./scripts/mutation_smoke.sh
```

## Mutation used

| File | Change |
|------|--------|
| `contracts/SecureVault.sol` | `withdraw` loses `nonReentrant` |

Expected under mutation: `blocks reentrant withdraw when owner is a malicious contract` **fails**.

## Relation to gates

| Gate | Mutation smoke |
|------|----------------|
| `make check` | Must stay green **after** smoke (restore) |
| `make coverage-gate` | Coverage alone is not enough — this catches weak tests |
| `make check-full` | Unchanged; still required for contracts/ merges |
