# Sovereign Contracts

**Runs an auditable compile, test, coverage and deploy path for Solidity locally, gated by Python checks. No cloud accounts.**

[![CI](https://github.com/marsojuji-cmyk/sovereign-contracts/actions/workflows/ci.yml/badge.svg)](https://github.com/marsojuji-cmyk/sovereign-contracts/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Node 22](https://img.shields.io/badge/node-22-339933.svg)](.github/workflows/ci.yml)

A local-first **Hardhat 3 + Python** workspace. The contracts are **teaching scaffolds, not audited products**.

```
Purpose     → auditable compile / test / cover / deploy path
End state   → make check green on a laptop without cloud accounts
Constraints → local-first · stdlib Python core · venv-scoped optional deps · legacy Mac light
```

## What it guarantees

What the test suite enforces on every CI run:

- **Solvency invariant (AccountingVault).** `totalCredit` equals the contract's native balance after randomized deposit/withdraw sequences, and no user can withdraw more than their credit (`test/invariants.js`).
- **Custody invariant (SecureVault).** Only the owner can reduce the balance, and deposits always increase it.
- **Reentrancy is rejected.** Reentrant withdraws from a malicious contract revert (`test/SecureVault.safety.js`, `test/AccountingVault.js`).
- **Guarded ownership.** SecureVault uses two-step ownership: propose, then accept, with cancel. Accepting from a non-pending address and proposing the zero address are both rejected.
- **Pause blocks money movement.** Paused SecureVault rejects deposits and withdrawals. Double pause/unpause and non-owner pause are rejected.
- **Failed transfers revert.** A recipient that rejects ETH causes `TransferFailed`; the vault never silently loses it.
- **No funds at risk by default.** The default network is in-process Hardhat. Etherscan verify stays inert until `ETHERSCAN_API_KEY` is set, and no live deploy runs as part of `make check`.

## Quickstart

```bash
git clone https://github.com/marsojuji-cmyk/sovereign-contracts && cd sovereign-contracts
npm ci                    # Node 22 (CI version)
npx hardhat test          # 40 tests: unit, safety and invariants
make setup-python         # one-time Python venv
make check                # preflight + compile + test
```

| Command | Effect |
|---------|--------|
| `make preflight` | Hardware + Python + privacy |
| `make compile` | Solidity → artifacts |
| `make test` | Full suite (unit + safety + invariants) |
| `make coverage` | Hardhat 3 built-in coverage (lcov + HTML) |
| `make deploy-local` | Ignition → SecureVault (hardhat net) |
| `make deploy-accounting` | Ignition → AccountingVault |
| `make check` | preflight + compile + test (fast) |
| `make check-full` | **contracts/ gate** — check + slither |
| `make coverage-gate` | 100% stmt floor on production vaults (after `make coverage`) |
| `make env-check` | Offline env shape + secret-pattern scan |
| `make env-probe` | `PIPELINE_ENV=local\|local-node\|testnet` |
| `make slither` | Static analysis (needs setup-slither) |
| `make tree` | Print directory map |
| `./pipeline.sh hardhat …` | raw Hardhat proxy |

**Sepolia / verify:** [`docs/ops/NETWORK_OPS.md`](docs/ops/NETWORK_OPS.md) (no `make deploy-sepolia`).  
**Slither:** [`docs/security/STATIC_ANALYSIS.md`](docs/security/STATIC_ANALYSIS.md) — `make setup-slither && make slither`.  
**Docs index:** [`docs/README.md`](docs/README.md).  
**Agent rules:** [`AGENTS.md`](AGENTS.md).

npm mirrors:

```bash
npm test
npm run compile
npm run coverage
npm run check
```

**Sepolia / verify:** [`docs/ops/NETWORK_OPS.md`](docs/ops/NETWORK_OPS.md) (there is no `make deploy-sepolia`).
**Slither:** [`docs/security/STATIC_ANALYSIS.md`](docs/security/STATIC_ANALYSIS.md). Run `make setup-slither && make slither`.
**Docs index:** [`docs/README.md`](docs/README.md). **Agent rules:** [`AGENTS.md`](AGENTS.md).

npm mirrors: `npm test`, `npm run compile`, `npm run coverage`, `npm run check`.

## How it fails

| Condition | Behaviour |
|---|---|
| Any test fails | `npx hardhat test` exits non-zero. CI goes red and `make check` stops |
| Statement coverage on any of the three production contracts drops below 100% (after `make coverage`) | `make coverage-gate` fails (`scripts/gates/coverage_floor.py`) |
| A private-key-shaped token appears under `contracts/`, `scripts/` or `src/` | `make env-check` fails without printing the match (`scripts/gates/check_env.sh`) |
| Non-owner withdraw, over-withdraw, zero amount, zero recipient | The contract reverts with a custom error |
| Sepolia RPC or Etherscan key unset | The network and verify paths stay inert. Nothing deploys |

## Evidence

- **CI** (`ci.yml`, run 37684903181 on `24dde12`): compiled 4 Solidity files with solc 0.8.28, **40 passing**.
- **Local, 2026-10-07, Node 22.23.3:** `npx hardhat test` gave 40 passing. `npx hardhat test --coverage` gave **100.00% lines / 100.00% statements** on AccountingVault, BuildManifestAnchor and SecureVault.
- Slither and mutation smoke (`make slither`, `scripts/gates/mutation_smoke.sh`) are local-only and not part of CI.

## Stack

| Side | Role |
|------|------|
| **Hardhat 3** | Compile, test, Ignition deploy, verify (when keyed), coverage |
| **Python 3** | Host preflight, gates, glue (stdlib-first) |
| **SecureVault** | Owner-custody ETH vault scaffold |
| **AccountingVault** | Pull/credit ledger (different threat model) |
| **BuildManifestAnchor** | Event-only doctrine / LIBRARIAN anchors |

## Layout

```
sovereign-contracts/
├── AGENTS.md · README.md · Makefile · pipeline.sh
├── hardhat.config.js · package.json · slither.config.json
├── contracts/                 # SecureVault · AccountingVault · BuildManifestAnchor
│   └── test/AttackHelpers.sol
├── test/                      # unit + safety + invariants
├── ignition/modules/
├── src/preflight.py           # host preflight → data/health.json
├── scripts/
│   ├── lib/                   # root resolvers (sh/py/js)
│   ├── bootstrap/             # setup_python
│   ├── gates/                 # env-check · coverage · mutation · probe
│   ├── analysis/              # slither
│   ├── ops/                   # sepolia · manifest · wallet
│   ├── host/                  # mac_clean
│   └── load_env.js            # Hardhat .env loader (stable path)
├── docs/
│   ├── README.md              # index
│   ├── ops/ · security/ · doctrine/ · nexus-sov/
├── data/ · logs/ · reports/   # local runtime (gitignored)
└── artifacts/ · cache/        # Hardhat outputs (gitignored)
```

## Python doctrine

1. Stdlib runs without pip.
2. Packages only inside `.venv`.
3. Optional `rich` via `make setup-python` then `./scripts/bootstrap/setup_python.sh --with-optional`.
4. Shell guard: `PIP_REQUIRE_VIRTUALENV=1` (in `~/.zshrc`).

## Security notes

- **No private keys in git.** Use `.env` locally; see `.env.example`.
- Default network is **in-process Hardhat** — no RPC, no funds at risk.
- Contracts are **teaching scaffolds**, not audited products. See `docs/security/THREAT_MODELS.md`.
- Etherscan verify stays inert until `ETHERSCAN_API_KEY` is set.

## Status

| Gate | Status |
|------|--------|
| Python preflight | Ready |
| Compile (0.8.28) | Ready |
| Tests | unit + safety + invariants |
| Coverage | 100% lines and statements on all three contracts (local run, 2026-10-07) |
| Ignition local deploy | SecureVault + AccountingVault + BuildManifestAnchor |
| Network ops docs | `docs/ops/NETWORK_OPS.md` (Phase 3) |
| Sepolia in Hardhat | Only if `SEPOLIA_RPC_URL` set |
| Live deploy / verify | Opt-in; not part of `make check` |
| Phase 2–5b | Done (gates + engineered layout + BuildManifestAnchor) |
| Phase 6 | **Done — Assurance** (coverage · mutation · env · ops dry path; see `AGENTS.md`) |

## License

MIT. See [LICENSE](LICENSE). Doctrine: see `AGENTS.md`. Stay local, prefer `.venv`, and ship diffs you can defend.
