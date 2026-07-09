# AGENTS.md — Secure Pipeline

## Mission
Build a **local-first**, **auditable** smart-contract and ops pipeline.
Hardhat owns Solidity; Python owns host checks, glue scripts, and optional analysis — never cloud telemetry in the core loop.

## Hard rules (ethos)
1. **Local-only core** — no analytics SDKs; optional tools must degrade offline.
2. **Stdlib first** — scripts run with bare `python3` when possible; third-party deps are optional and venv-scoped.
3. **Never pollute system Python** — install packages only inside `.venv`.
4. **Legacy Mac aware** — Intel / Monterey / 16 GB class; keep RAM/CPU light.
5. **Diff discipline** — reviewable changes; log Commander's Intent for major moves.
6. **ANSI / plain output** — no hard dependency on Rich/Textual for critical paths.
7. **No secrets in repo** — keys only via env / `.env` (gitignored).

## Runtime doctrine

| Layer | Tool | Notes |
|-------|------|--------|
| Contracts | Hardhat 2 + toolbox | compile, test, coverage |
| Deploy | Hardhat Ignition | declarative modules under `ignition/` |
| Verify | hardhat-verify | needs `ETHERSCAN_API_KEY` (optional) |
| Host / glue | Python 3.14+ stdlib | preflight; future scripts |
| Isolation | `python3 -m venv .venv` | preferred interpreter when present |
| Gate | `make check` | preflight + compile + test |
| Static (optional) | Slither in `.venv` | `make slither` / `make check-full` |

## Project map

| Path | Role |
|------|------|
| `pipeline.sh` / `Makefile` | Unified entrypoints |
| `hardhat.config.js` | Networks, solc 0.8.28, plugins |
| `contracts/SecureVault.sol` | Owner-custody vault scaffold |
| `contracts/AccountingVault.sol` | Pull/credit vault (different threat model) |
| `contracts/test/AttackHelpers.sol` | Test-only reentrancy / reject helpers |
| `test/*.js` | Unit + safety + invariant suites |
| `ignition/modules/` | SecureVault + AccountingVault modules |
| `docs/THREAT_MODELS.md` | Threat model notes |
| `docs/NETWORK_OPS.md` | Sepolia / verify ops (opt-in; docs-first) |
| `docs/STATIC_ANALYSIS.md` | Slither install / gate / accepted findings |
| `requirements-slither.txt` | Pinned Slither stack (cbor2 5.6.5 + analyzer) |
| `slither.config.json` | Filter paths + fail policy |
| `scripts/setup_python.sh` | One-shot venv bootstrap |
| `scripts/run_slither.sh` | Static analysis runner |
| `scripts/check_env.sh` | Offline env shape check |
| `scripts/load_env.js` | Minimal .env loader (no dotenv dep) |
| `src/preflight.py` | HW + Python + privacy checks |
| `data/` | Local lineage (chmod 700; do not commit secrets) |

## When editing this project
- Multi-step work: open with **Commander's Intent** (Purpose / End State / Constraints / Implied Tasks).
- Prefer tables for schema/mapping; Threat/Opportunity for architecture choices.
- End with **Immediate Next Actions**.
- Prefer project `.venv/bin/python` over system site-packages.
- After contract changes: `make test` (and `make coverage` when touching safety paths).

## Phase roadmap

- [x] Phase 0 — Python ethos foundation (venv, preflight, shell guard)
- [x] Phase 1 — Hardhat 2 scaffold (SecureVault, tests, Ignition, coverage)
- [x] Phase 2 — AccountingVault + reentrancy/safety extras + invariant loops
- [x] Phase 3 — Documented Sepolia path (env keys only); verify dry-run docs
- [x] Phase 4 — Optional Slither (venv; cbor2 pin for Python 3.14)

## Grok Build activation (paste)
```
Plan: Work inside /Users/admin/agents/secure_pipeline using AGENTS.md ethos.
Stack: Hardhat 2 for Solidity; Python stdlib-first + optional .venv.
Hardware: 2015-class Intel MBP / Monterey — lightweight, no global pip installs.
Privacy: local-only core; no telemetry; no secrets in git.
Success: make check green; auditable diffs; contracts tested before deploy modules change.
```
