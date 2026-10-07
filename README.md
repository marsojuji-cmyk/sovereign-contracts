# Sovereign Contracts

**An auditable compile/test/cover/deploy path — local-first, no cloud accounts.**

Local-first **Hardhat 3 + Python** workspace for sovereign contract work.

```
Purpose  → auditable compile / test / cover / deploy path
End State → make check green on this Mac without cloud accounts
Constraints → local-first · stdlib Python core · venv-scoped optional deps · legacy Mac light
```

## Stack

| Side | Role |
|------|------|
| **Hardhat 3** | Compile, test, Ignition deploy, verify (when keyed), coverage |
| **Python 3** | Host preflight, gates, glue (stdlib-first) |
| **SecureVault** | Owner-custody ETH vault scaffold |
| **AccountingVault** | Pull/credit ledger (different threat model) |
| **BuildManifestAnchor** | Event-only doctrine / LIBRARIAN anchors |

## Quickstart

```bash
cd /path/to/sovereign-contracts   # your clone

# one-time Python venv (if missing)
make setup-python
# or: ./scripts/bootstrap/setup_python.sh

# full local gate
make check
# or: ./pipeline.sh check

# see engineered layout
make tree
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
**Grok rules:** [`AGENTS.md`](AGENTS.md) + [`.grok/rules/`](.grok/rules/).

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
├── AGENTS.md · README.md · Makefile · pipeline.sh
├── hardhat.config.js · package.json · slither.config.json
├── .grok/
│   ├── agents/pipeline.md     # project agent (grok-build)
│   └── rules/                 # auto-loaded structure + gates
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

## Current status

| Gate | Status |
|------|--------|
| Python preflight | Ready |
| Compile (0.8.28) | Ready |
| Tests | unit + safety + invariants |
| Coverage | ~100% stmts/lines on production contracts |
| Ignition local deploy | SecureVault + AccountingVault + BuildManifestAnchor |
| Network ops docs | `docs/ops/NETWORK_OPS.md` (Phase 3) |
| Sepolia in Hardhat | Only if `SEPOLIA_RPC_URL` set |
| Live deploy / verify | Opt-in; not part of `make check` |
| Phase 2–5b | Done (gates + engineered layout + BuildManifestAnchor) |
| Phase 6 | **Done — Assurance** (coverage · mutation · env · ops dry path; see `AGENTS.md`) |

## Doctrine

See `AGENTS.md`. Stay local. Prefer `.venv`. Ship diffs you can defend.
