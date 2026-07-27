# Structure rules (secure_pipeline)

Grok: respect the engineered layout. Do not flatten scripts or docs.

## Keep at repo root
- `AGENTS.md`, `README.md`, `Makefile`, `pipeline.sh`
- `hardhat.config.js`, `package.json`, `slither.config.json`, `.solcover.js`
- `requirements.txt`, `requirements-slither.txt`, `.env.example`
- Hardhat trees: `contracts/`, `test/`, `ignition/`

## Nested by role

| Area | Path | Put here |
|------|------|----------|
| Shared resolvers | `scripts/lib/` | `root.sh`, `root.py`, `root.js` |
| Bootstrap | `scripts/bootstrap/` | venv / setup |
| Gates | `scripts/gates/` | env-check, coverage floor, mutation, env-probe |
| Analysis | `scripts/analysis/` | Slither runner |
| Ops | `scripts/ops/` | Sepolia, manifest, wallet, solana helpers |
| Host | `scripts/host/` | Mac clean / machine maintenance |
| Hardhat env | `scripts/load_env.js` | **Stable path** — required by `hardhat.config.js` |
| Host Python | `src/` | `preflight.py` (PYTHONPATH) |
| Ops docs | `docs/ops/` | network + mutation |
| Security docs | `docs/security/` | threat models + static analysis |
| Doctrine docs | `docs/doctrine/` | Grok Build / LIBRARIAN / frames |
| Runtime | `data/`, `logs/`, `reports/` | gitignored local state |

## Adding files
1. Choose the role directory above — never drop new tools in a flat `scripts/` root (except `load_env.js`).
2. Resolve repo root with `scripts/lib/root.*` (walk-up markers: `hardhat.config.js` + `AGENTS.md`).
3. Wire a `make` target when the script is part of the public surface.
4. Link new docs from `docs/README.md` and the project map in `AGENTS.md`.

## Layout check
```bash
make tree
```
