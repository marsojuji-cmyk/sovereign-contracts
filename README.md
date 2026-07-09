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
| **SecureVault** | Ownable ETH vault scaffold (not production-audited) |

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
| `make test` | 11 unit tests |
| `make coverage` | solidity-coverage report |
| `make deploy-local` | Ignition → in-process Hardhat Network |
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
├── pipeline.sh / Makefile     # unified entrypoints
├── hardhat.config.js          # local networks; verify key via env only
├── contracts/SecureVault.sol  # scaffold contract
├── test/SecureVault.js        # unit tests
├── ignition/modules/          # declarative deploy
├── scripts/setup_python.sh
├── src/preflight.py           # stdlib host checks
├── AGENTS.md                  # ethos rules for agents
└── .env.example               # optional remote keys (never commit .env)
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
- `SecureVault` is a **teaching scaffold**, not an audited product.
- Etherscan verify stays inert until `ETHERSCAN_API_KEY` is set.

## Current status

| Gate | Status |
|------|--------|
| Python preflight | Ready |
| Compile (0.8.28) | Ready |
| Unit tests | 11 passing |
| Coverage | ~100% stmts/lines (branches ~81%) |
| Ignition local deploy | Ready |
| Live network / verify | Configured, keys optional |

## Doctrine

See `AGENTS.md`. Stay local. Prefer `.venv`. Ship diffs you can defend.
