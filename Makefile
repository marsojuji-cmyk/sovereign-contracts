# Secure Pipeline — unified automation
# Local-first · Hardhat + Python preflight

ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
.DEFAULT_GOAL := help

.PHONY: help preflight setup-python setup-slither compile test coverage coverage-gate \
	check check-full env-check env-probe mutation-smoke slither deploy-local \
	deploy-accounting clean all

help:
	@echo "Secure Pipeline"
	@echo ""
	@echo "  make preflight           Host / Python / privacy checks (+ data/health.json)"
	@echo "  make setup-python        Create .venv (stdlib)"
	@echo "  make setup-slither       .venv + Slither (Phase 4+)"
	@echo "  make compile             solc via Hardhat"
	@echo "  make test                Unit + safety + invariant tests"
	@echo "  make coverage            solidity-coverage report"
	@echo "  make coverage-gate       Require 100% stmt on production vaults (needs report)"
	@echo "  make check               preflight + compile + test (fast dev gate)"
	@echo "  make slither             Static analysis (requires setup-slither)"
	@echo "  make check-full          check + slither (required for contracts/ diffs)"
	@echo "  make env-check           Offline .env shape + secret-pattern scan"
	@echo "  make env-probe           Detect PIPELINE_ENV=local|local-node|testnet"
	@echo "  make mutation-smoke      Strip nonReentrant; expect fail; restore"
	@echo "  make deploy-local        Ignition → SecureVault (hardhat)"
	@echo "  make deploy-accounting   Ignition → AccountingVault (hardhat)"
	@echo "  make clean               cache / artifacts / coverage / reports"
	@echo "  make all                 alias for check"
	@echo ""
	@echo "Sepolia / verify: docs/NETWORK_OPS.md"
	@echo "Slither:          docs/STATIC_ANALYSIS.md"
	@echo "Phase 5 gates:    AGENTS.md"
	@echo ""

preflight:
	@bash $(ROOT)pipeline.sh preflight

setup-python:
	@bash $(ROOT)scripts/setup_python.sh

setup-slither:
	@bash $(ROOT)scripts/setup_python.sh --with-slither

compile:
	@npx hardhat compile

test:
	@npx hardhat test

coverage:
	@npx hardhat coverage

# Uses existing report; does not re-run coverage (keeps gate intentional).
coverage-gate:
	@python3 $(ROOT)scripts/coverage_floor.py

check: preflight compile test
	@echo ""
	@echo "✓ check passed (preflight + compile + test)"

slither:
	@bash $(ROOT)scripts/run_slither.sh

# Merge / contracts/ gate: full suite + static analysis.
# Coverage floor is separate (make coverage && make coverage-gate) — slow on Intel.
check-full: check slither
	@echo ""
	@echo "✓ check-full passed (check + slither)"
	@echo "  Optional: make coverage && make coverage-gate"

env-check:
	@bash $(ROOT)scripts/check_env.sh

env-probe:
	@python3 $(ROOT)scripts/env_probe.py

mutation-smoke:
	@bash $(ROOT)scripts/mutation_smoke.sh

deploy-local:
	@npx hardhat ignition deploy ./ignition/modules/SecureVault.js

deploy-accounting:
	@npx hardhat ignition deploy ./ignition/modules/AccountingVault.js

clean:
	@rm -rf cache artifacts coverage coverage.json gasReporterOutput.json reports
	@echo "cleaned Hardhat build artifacts and reports"

all: check
