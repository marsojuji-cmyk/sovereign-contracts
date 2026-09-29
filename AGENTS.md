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
| Contracts | Hardhat 3 + toolbox-mocha-ethers | compile, test, coverage |
| Deploy | Hardhat Ignition | declarative modules under `ignition/` |
| Verify | hardhat-verify | needs `ETHERSCAN_API_KEY` (optional) |
| Host / glue | Python 3.14+ stdlib | preflight; future scripts |
| Isolation | `python3 -m venv .venv` | preferred interpreter when present |
| Gate | `make check` | preflight + compile + test |
| Static (optional) | Slither in `.venv` | `make slither` / `make check-full` |

## Directory doctrine (where things live)

Hardhat conventions stay at the repo root. Host tooling and docs are **role-nested** so Grok and humans can navigate without hunting a flat dump.

```
secure_pipeline/
├── AGENTS.md                 # THIS FILE — primary Grok rules
├── README.md                 # Human quickstart
├── Makefile / pipeline.sh    # Unified entrypoints (prefer make *)
├── hardhat.config.js         # solc 0.8.28 · networks · plugins
├── package.json              # npm scripts mirror make targets
├── .env.example              # Shape only — never commit .env
├── .grok/
│   ├── agents/pipeline.md    # Project agent profile (grok-build)
│   └── rules/                # Auto-loaded Grok rules (structure + gates)
├── contracts/                # Production + test Solidity
├── test/                     # Hardhat JS suites
├── ignition/modules/         # Declarative deploys
├── src/preflight.py          # Host preflight (PYTHONPATH=src)
├── scripts/
│   ├── lib/                  # Shared root resolvers (sh / py / js)
│   ├── bootstrap/            # setup_python.sh
│   ├── gates/                # check_env · coverage_floor · env_probe · mutation
│   ├── analysis/             # run_slither.sh
│   ├── ops/                  # sepolia · manifest · wallet · solana
│   ├── host/                 # mac_clean.sh
│   └── load_env.js           # Stable path for hardhat.config.js
├── docs/
│   ├── README.md             # Doc index
│   ├── ops/                  # NETWORK_OPS · MUTATION_SMOKE
│   ├── security/             # THREAT_MODELS · STATIC_ANALYSIS
│   ├── doctrine/             # Grok Build · LIBRARIAN · frames
│   └── nexus-sov/            # Hygiene notes (no recovery material)
├── data/ · logs/ · reports/  # Local runtime only (gitignored)
└── artifacts/ · cache/       # Hardhat build outputs (gitignored)
```

Print this map anytime: `make tree`.

## Project map (paths)

| Path | Role |
|------|------|
| `pipeline.sh` / `Makefile` | Unified entrypoints |
| `hardhat.config.js` | Networks, solc 0.8.28, plugins |
| `.grok/agents/pipeline.md` | Project agent (model: grok-build) |
| `.grok/rules/` | Auto-loaded structure + gate rules for Grok |
| `contracts/SecureVault.sol` | Owner-custody vault scaffold |
| `contracts/AccountingVault.sol` | Pull/credit vault (different threat model) |
| `contracts/BuildManifestAnchor.sol` | Event-only LIBRARIAN / build manifest anchors |
| `contracts/test/AttackHelpers.sol` | Test-only reentrancy / reject helpers |
| `test/*.js` | Unit + safety + invariant suites |
| `ignition/modules/` | SecureVault + AccountingVault + BuildManifestAnchor |
| `docs/README.md` | Documentation index |
| `docs/security/THREAT_MODELS.md` | Threat model notes |
| `docs/ops/NETWORK_OPS.md` | Sepolia / verify ops (opt-in; docs-first) |
| `docs/security/STATIC_ANALYSIS.md` | Slither install / gate / accepted findings |
| `docs/doctrine/GROK_BUILD_INSTRUCTIONS.md` | Grok Build v1; construction-over-consumption |
| `docs/doctrine/LIBRARIAN_PROTOCOL.md` | Report/doc skeleton (companion to Build §6) |
| `docs/doctrine/BUILD_FRAME_NEXUS_PIPELINE.md` | Five Lenses + Prime Objective applied |
| `docs/doctrine/KABBALIAN_BUILD_LAWS.md` | Four Worlds, Gevurah/Malkhut ↔ Makefile gates |
| `docs/nexus-sov/README.md` | Nexus.sov hygiene; recovery material out of git |
| `requirements-slither.txt` | Pinned Slither stack (cbor2 5.6.5 + analyzer) |
| `slither.config.json` | Filter paths + fail policy |
| `scripts/lib/` | Root resolvers — use when adding nested scripts |
| `scripts/bootstrap/setup_python.sh` | One-shot venv bootstrap |
| `scripts/analysis/run_slither.sh` | Static analysis runner |
| `scripts/gates/check_env.sh` | Offline env shape + secret-pattern scan |
| `scripts/gates/coverage_floor.py` | 100% stmt floor on production vaults |
| `scripts/gates/env_probe.py` | `PIPELINE_ENV` detection (no RPC) |
| `scripts/gates/mutation_smoke.sh` | Deliberate nonReentrant strip → expect fail → restore |
| `scripts/ops/` | Sepolia dry-run, manifest hash/anchor, wallet helpers |
| `scripts/load_env.js` | Minimal .env loader (no dotenv dep; Hardhat stable path) |
| `src/preflight.py` | HW + Python + privacy + `data/health.json` |
| `data/` | Local lineage (chmod 700; do not commit secrets) |

## When editing this project
- Non-trivial builds: apply **Five Lenses** + Prime Objective (`docs/doctrine/GROK_BUILD_INSTRUCTIONS.md`); reports use **LIBRARIAN** (`docs/doctrine/LIBRARIAN_PROTOCOL.md`); optional Kabbalian frame (`docs/doctrine/KABBALIAN_BUILD_LAWS.md`) for Atzilut/Gevurah/Malkhut + Four Worlds.
- Multi-step work: open with **Commander's Intent** (Purpose / End State / Constraints / Implied Tasks).
- Prefer tables for schema/mapping; Threat/Opportunity for architecture choices.
- End with **Immediate Next Actions**.
- Prefer project `.venv/bin/python` over system site-packages.
- After contract changes: `make test` (and `make coverage` when touching safety paths).
- **New scripts:** place under `scripts/{bootstrap,gates,analysis,ops,host}/` and resolve root via `scripts/lib/root.{sh,py,js}` — do not hardcode `../..` alone without the walk-up helper.
- **New docs:** place under `docs/{ops,security,doctrine}/` and link from `docs/README.md`.
- Prefer `make <target>` over raw script paths in user-facing instructions (stable surface).

## Phase roadmap

- [x] Phase 0 — Python ethos foundation (venv, preflight, shell guard)
- [x] Phase 1 — Hardhat 2 scaffold (SecureVault, tests, Ignition, coverage)
- [x] Phase 2 — AccountingVault + reentrancy/safety extras + invariant loops
- [x] Phase 3 — Documented Sepolia path (env keys only); verify dry-run docs
- [x] Phase 4 — Optional Slither (venv; cbor2 pin for Python 3.14)
- [x] Phase 5 — Self-assessing gates: health.json, coverage floor, secret scan, env probe
- [x] Phase 5b — Engineered layout (role-nested scripts/docs + Grok rules)
- [x] **Phase 6 — Assurance** — coverage floor habit, mutation bite, env discipline, ops dry-path trust; **no new contracts / no live network spend**

### Phase 6 WBS (assurance) — complete

| ID | Focus | Done when | Evidence |
|----|--------|-----------|----------|
| M0 | Baseline freeze | Roadmap stub + inventory after 5b | AGENTS + README Phase 6 |
| M1 | Coverage floor | `make coverage && make coverage-gate` green | 100% stmts on production vaults |
| M2 | Mutation bite | `make mutation-smoke` green | nonReentrant strip → test fails → restore |
| M3 | Env / secrets | `make env-check` + `make env-probe` green | offline shape OK; `PIPELINE_ENV=testnet` |
| M4 | Ops dry path | `make sepolia-dry-run` + `make manifest-hash` | local Ignition + chainId probe; **no broadcast** |
| M5 | Ship package | Gates re-proven; reviewable docs; dossier 100% | this closeout |

**Out of scope (Phase 6, held):** mainnet, live Sepolia deploy, multi-sig, new vault Solidity, system pip, secrets in Calendar/Notes.

## Gates (Phase 5+)

| Gate | Command | When |
|------|---------|------|
| Fast dev | `make check` | every local edit loop |
| **Contracts merge** | `make check-full` | any diff under `contracts/` (or `test/` safety paths) |
| Coverage floor | `make coverage && make coverage-gate` | before claiming 100% / portfolio evidence |
| Env / secrets | `make env-check` | before any network or deploy command |
| Env tier | `make env-probe` | detect `PIPELINE_ENV` without RPC |
| Mutation bite | `make mutation-smoke` | suite must fail under guard removal |

- Preflight writes **`data/health.json`** (gitignored under `data/`) — env shape, privacy, coverage snapshot if present.
- Secret scan in `scripts/gates/check_env.sh` fails on `0x`+64-hex patterns under `contracts/`, `scripts/`, `src/`.
- Hardhat already caches compiles via `cache/solidity-files-cache.json` — do not reimplement.

## Grok Build activation (paste)
```
Plan: Work inside secure_pipeline using AGENTS.md ethos.
Path: /Users/admin/agents/secure_pipeline (or local clone).
Stack: Hardhat 3 for Solidity; Python stdlib-first + optional .venv.
Layout: make tree · docs/README.md · .grok/rules/
Hardware: 2015-class Intel MBP — lightweight, no global pip installs.
Privacy: local-only core; no telemetry; no secrets in git.
Success: make check green; contracts/ diffs also make check-full; auditable diffs.
```
