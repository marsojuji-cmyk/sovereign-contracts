# Secure Pipeline — unified automation
# Local-first · Hardhat + Python preflight

ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
.DEFAULT_GOAL := help

.PHONY: help preflight setup-python compile test coverage check deploy-local clean all

help:
	@echo "Secure Pipeline"
	@echo ""
	@echo "  make preflight      Host / Python / privacy checks"
	@echo "  make setup-python   Create .venv (stdlib)"
	@echo "  make compile        solc via Hardhat"
	@echo "  make test           Unit tests"
	@echo "  make coverage       solidity-coverage report"
	@echo "  make check          preflight + compile + test (CI gate)"
	@echo "  make deploy-local   Ignition → SecureVault on hardhat network"
	@echo "  make clean          cache / artifacts / coverage"
	@echo "  make all            alias for check"
	@echo ""

preflight:
	@bash $(ROOT)pipeline.sh preflight

setup-python:
	@bash $(ROOT)scripts/setup_python.sh

compile:
	@npx hardhat compile

test:
	@npx hardhat test

coverage:
	@npx hardhat coverage

check: preflight compile test
	@echo ""
	@echo "✓ check passed (preflight + compile + test)"

deploy-local:
	@npx hardhat ignition deploy ./ignition/modules/SecureVault.js

clean:
	@rm -rf cache artifacts coverage coverage.json gasReporterOutput.json
	@echo "cleaned Hardhat build artifacts"

all: check
