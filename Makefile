# Secure Pipeline — unified automation
# Local-first · Hardhat + Python preflight

ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
.DEFAULT_GOAL := help

.PHONY: help preflight setup-python setup-slither compile test coverage coverage-gate \
	check check-full env-check env-probe mutation-smoke slither deploy-local \
	deploy-accounting deploy-manifest manifest-hash anchor-manifest-local \
	sepolia-dry-run clean all tree

help:
	@echo "Secure Pipeline"
	@echo ""
	@echo "  make preflight           Host / Python / privacy checks (+ data/health.json)"
	@echo "  make setup-python        Create .venv (stdlib)"
	@echo "  make setup-slither       .venv + Slither (Phase 4+)"
	@echo "  make compile             solc via Hardhat"
	@echo "  make test                Unit + safety + invariant tests"
	@echo "  make coverage            Hardhat 3 built-in coverage (lcov + HTML)"
	@echo "  make coverage-gate       Require 100% stmt on production vaults (needs report)"
	@echo "  make check               preflight + compile + test (fast dev gate)"
	@echo "  make slither             Static analysis (requires setup-slither)"
	@echo "  make check-full          check + slither (required for contracts/ diffs)"
	@echo "  make env-check           Offline .env shape + secret-pattern scan"
	@echo "  make env-probe           Detect PIPELINE_ENV=local|local-node|testnet"
	@echo "  make mutation-smoke      Strip nonReentrant; expect fail; restore"
	@echo "  make deploy-local        Ignition → SecureVault (hardhat)"
	@echo "  make deploy-accounting   Ignition → AccountingVault (hardhat)"
	@echo "  make deploy-manifest     Ignition → BuildManifestAnchor (hardhat)"
	@echo "  make manifest-hash       SHA-256 of canonical Grok Build doc bundle"
	@echo "  make anchor-manifest-local  Deploy + anchor bundle on current network"
	@echo "  make sepolia-dry-run     Offline env + local Ignition; optional RPC probe"
	@echo "  make tree                Print engineered layout (Grok map)"
	@echo "  make clean               cache / artifacts / coverage / reports"
	@echo "  make all                 alias for check"
	@echo ""
	@echo "Sepolia / verify: docs/ops/NETWORK_OPS.md"
	@echo "Slither:          docs/security/STATIC_ANALYSIS.md"
	@echo "Layout:           docs/README.md · AGENTS.md"
	@echo ""

preflight:
	@bash $(ROOT)pipeline.sh preflight

setup-python:
	@bash $(ROOT)scripts/bootstrap/setup_python.sh

setup-slither:
	@bash $(ROOT)scripts/bootstrap/setup_python.sh --with-slither

compile:
	@npx hardhat build

test:
	@npx hardhat test

coverage:
	@npx hardhat test --coverage

# Uses existing report; does not re-run coverage (keeps gate intentional).
coverage-gate:
	@python3 $(ROOT)scripts/gates/coverage_floor.py

check: preflight compile test
	@echo ""
	@echo "✓ check passed (preflight + compile + test)"

slither:
	@bash $(ROOT)scripts/analysis/run_slither.sh

# Merge / contracts/ gate: full suite + static analysis.
# Coverage floor is separate (make coverage && make coverage-gate) — slow on Intel.
check-full: check slither
	@echo ""
	@echo "✓ check-full passed (check + slither)"
	@echo "  Optional: make coverage && make coverage-gate"

env-check:
	@bash $(ROOT)scripts/gates/check_env.sh

env-probe:
	@python3 $(ROOT)scripts/gates/env_probe.py

mutation-smoke:
	@bash $(ROOT)scripts/gates/mutation_smoke.sh

deploy-local:
	@npx hardhat ignition deploy ./ignition/modules/SecureVault.js

deploy-accounting:
	@npx hardhat ignition deploy ./ignition/modules/AccountingVault.js

deploy-manifest:
	@npx hardhat ignition deploy ./ignition/modules/BuildManifestAnchor.js

manifest-hash:
	@python3 $(ROOT)scripts/ops/manifest_bundle_hash.py

anchor-manifest-local:
	@npx hardhat run $(ROOT)scripts/ops/publish_local_manifest_anchor.js

sepolia-dry-run:
	@bash $(ROOT)scripts/ops/sepolia_dry_run.sh

tree:
	@echo "secure_pipeline/ (engineered layout)"
	@echo "├── AGENTS.md · README.md · Makefile · pipeline.sh"
	@echo "├── hardhat.config.js · package.json · slither.config.json"
	@echo "├── contracts/                       # Solidity sources"
	@echo "├── test/                            # Hardhat tests"
	@echo "├── ignition/modules/                # Deploy modules"
	@echo "├── src/preflight.py                 # Host preflight (PYTHONPATH)"
	@echo "├── scripts/"
	@echo "│   ├── lib/           root helpers (sh/py/js)"
	@echo "│   ├── bootstrap/     setup_python"
	@echo "│   ├── gates/         check_env · coverage · env_probe · mutation"
	@echo "│   ├── analysis/      run_slither"
	@echo "│   ├── ops/           sepolia · manifest · wallet"
	@echo "│   ├── host/          mac_clean"
	@echo "│   └── load_env.js    Hardhat .env loader (stable path)"
	@echo "├── docs/"
	@echo "│   ├── ops/ · security/ · doctrine/ · nexus-sov/"
	@echo "│   └── README.md      doc index"
	@echo "└── data/ logs/ reports/             # local runtime (gitignored)"

clean:
	@rm -rf cache artifacts coverage coverage.json gasReporterOutput.json reports
	@echo "cleaned Hardhat build artifacts and reports"

all: check
