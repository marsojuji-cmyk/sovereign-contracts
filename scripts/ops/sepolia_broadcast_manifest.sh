#!/usr/bin/env bash
# After burner is funded: deploy BuildManifestAnchor on Sepolia + anchor doc bundle.
set -euo pipefail
# shellcheck source=../lib/root.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/root.sh"
cd "$ROOT"
export SECURE_PIPELINE_CONFIRM_SEPOLIA_BROADCAST=1
exec bash "$ROOT/scripts/ops/sepolia_dry_run.sh"