# Gate rules (secure_pipeline)

Prefer **Make targets** over raw script paths in instructions and automation.

## Daily / PR gates

| Intent | Command |
|--------|---------|
| Fast local green | `make check` |
| Contracts or safety-test diffs | `make check-full` |
| Claim 100% coverage | `make coverage && make coverage-gate` |
| Before any network command | `make env-check` |
| Detect env tier (no RPC) | `make env-probe` |
| Prove tests catch guard removal | `make mutation-smoke` |

## Bootstrap

| Intent | Command |
|--------|---------|
| Create `.venv` | `make setup-python` |
| `.venv` + Slither | `make setup-slither` |

## Deploy (local only by default)

| Intent | Command |
|--------|---------|
| SecureVault hardhat | `make deploy-local` |
| AccountingVault hardhat | `make deploy-accounting` |
| BuildManifestAnchor hardhat | `make deploy-manifest` |
| Doc bundle hash | `make manifest-hash` |
| Anchor bundle locally | `make anchor-manifest-local` |
| Sepolia dry-run | `make sepolia-dry-run` |

## After edits
- Solidity / safety tests → `make test` (coverage when touching reentrancy paths).
- Host scripts → `make preflight` and/or `make env-check`.
- Never commit `.env`, keys, or `data/` secrets.
- Success bar: `make check` green; contracts merge also needs `make check-full`.
