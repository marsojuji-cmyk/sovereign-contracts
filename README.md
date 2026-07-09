# Secure Pipeline

Local-first **Hardhat 2 + Python** workspace for sovereign contract work.

```
Purpose  → auditable compile / test / cover / deploy path
End State → make check green on this Mac without cloud accounts
Constraints → local-first · stdlib Python core · venv-scoped optional deps · legacy Mac light
```

## Stack

| Side | Role |
|------|------|
| **Hardhat 2** | Compile, test, Ignition deploy, verify (when keyed), coverage |
| **Python 3** | Host preflight, future glue (stdlib-first) |
| **SecureVault** | Owner-custody ETH vault scaffold |
| **AccountingVault** | Pull/credit ledger (different threat model) |

## Quickstart

```bash
cd /Users/admin/agents/secure_pipeline

# one-time Python venv (if missing)
./scripts/setup_python.sh

# full local gate
make check
# or: ./pipeline.sh check
```

| Command | Effect |
|---------|--------|
| `make preflight` | Hardware + Python + privacy |
| `make compile` | Solidity → artifacts |
| `make test` | Full suite (unit + safety + invariants) |
| `make coverage` | solidity-coverage report |
| `make deploy-local` | Ignition → SecureVault (hardhat net) |
| `make deploy-accounting` | Ignition → AccountingVault |
| `make check` | preflight + compile + test |
| `./pipeline.sh hardhat …` | raw Hardhat proxy |

npm mirrors:

```bash
npm test
npm run compile
npm run coverage
npm run check
```

## Layout

```
secure_pipeline/
├── pipeline.sh / Makefile
├── hardhat.config.js
├── contracts/
│   ├── SecureVault.sol        # owner custody
│   ├── AccountingVault.sol    # pull/credit ledger
│   └── test/AttackHelpers.sol # reentrancy probes
├── test/                      # unit + safety + invariants
├── ignition/modules/
├── docs/THREAT_MODELS.md
├── scripts/setup_python.sh
├── src/preflight.py
└── AGENTS.md
```

## Python doctrine

Same as `grok-terminal-ethos` / ClearBlock:

1. Stdlib runs without pip.
2. Packages only inside `.venv`.
3. Optional `rich` via `./scripts/setup_python.sh --with-optional`.
4. Shell guard: `PIP_REQUIRE_VIRTUALENV=1` (in `~/.zshrc`).

## Security notes

- **No private keys in git.** Use `.env` locally; see `.env.example`.
- Default network is **in-process Hardhat** — no RPC, no funds at risk.
- Contracts are **teaching scaffolds**, not audited products. See `docs/THREAT_MODELS.md`.
- Etherscan verify stays inert until `ETHERSCAN_API_KEY` is set.

## Current status

| Gate | Status |
|------|--------|
| Python preflight | Ready |
| Compile (0.8.28) | Ready |
| Tests | 25 passing (unit + safety + invariants) |
| Coverage | ~100% stmts/lines on production contracts |
| Ignition local deploy | SecureVault + AccountingVault |
| Live network / verify | Configured, keys optional |
| Phase 2 safety | Done |

## Doctrine

See `AGENTS.md`. Stay local. Prefer `.venv`. Ship diffs you can defend.
