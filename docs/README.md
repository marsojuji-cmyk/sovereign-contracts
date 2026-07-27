# Documentation index

Local-first docs for **secure_pipeline**. Prefer this map over hunting filenames.

## Ops

| Doc | When to read |
|-----|----------------|
| [ops/NETWORK_OPS.md](ops/NETWORK_OPS.md) | Sepolia env shape, dry-run, verify (opt-in) |
| [ops/MUTATION_SMOKE.md](ops/MUTATION_SMOKE.md) | How mutation-smoke proves tests bite |

## Security

| Doc | When to read |
|-----|----------------|
| [security/THREAT_MODELS.md](security/THREAT_MODELS.md) | Vault threat boundaries (owner-custody vs pull/credit) |
| [security/STATIC_ANALYSIS.md](security/STATIC_ANALYSIS.md) | Slither install, gate, accepted findings |

## Doctrine (Grok Build / build law)

| Doc | When to read |
|-----|----------------|
| [doctrine/GROK_BUILD_INSTRUCTIONS.md](doctrine/GROK_BUILD_INSTRUCTIONS.md) | Five Lenses + Prime Objective (v1) |
| [doctrine/LIBRARIAN_PROTOCOL.md](doctrine/LIBRARIAN_PROTOCOL.md) | Report / doc skeleton |
| [doctrine/BUILD_FRAME_NEXUS_PIPELINE.md](doctrine/BUILD_FRAME_NEXUS_PIPELINE.md) | Applied frame: Nexus ↔ this pipeline |
| [doctrine/KABBALIAN_BUILD_LAWS.md](doctrine/KABBALIAN_BUILD_LAWS.md) | Four Worlds ↔ Makefile gates |

## Adjacent

| Doc | When to read |
|-----|----------------|
| [nexus-sov/README.md](nexus-sov/README.md) | Nexus.sov hygiene — recovery material stays out of git |
| [../AGENTS.md](../AGENTS.md) | Project rules Grok loads automatically |
| [../README.md](../README.md) | Human quickstart |

## Scripts map (stable entry via Make)

| Make target | Script |
|-------------|--------|
| `make setup-python` | `scripts/bootstrap/setup_python.sh` |
| `make env-check` | `scripts/gates/check_env.sh` |
| `make env-probe` | `scripts/gates/env_probe.py` |
| `make coverage-gate` | `scripts/gates/coverage_floor.py` |
| `make mutation-smoke` | `scripts/gates/mutation_smoke.sh` |
| `make slither` | `scripts/analysis/run_slither.sh` |
| `make sepolia-dry-run` | `scripts/ops/sepolia_dry_run.sh` |
| `make manifest-hash` | `scripts/ops/manifest_bundle_hash.py` |
| `make tree` | prints engineered layout |

Shared root helpers (for new nested scripts): `scripts/lib/root.{sh,py,js}`.
