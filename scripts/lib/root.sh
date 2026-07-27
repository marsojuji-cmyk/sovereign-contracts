# shellcheck shell=bash
# Resolve secure_pipeline repo root from any nested scripts/* path.
# Usage (from a script under scripts/<role>/):
#   # shellcheck source=../lib/root.sh
#   source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/root.sh"
#   cd "$ROOT"
#
# Marker files: hardhat.config.js + AGENTS.md (must both exist).

if [[ -n "${SECURE_PIPELINE_ROOT:-}" && -f "${SECURE_PIPELINE_ROOT}/hardhat.config.js" ]]; then
  ROOT="$SECURE_PIPELINE_ROOT"
else
  _sp_start="$(cd "$(dirname "${BASH_SOURCE[1]:-${BASH_SOURCE[0]}}")" && pwd)"
  _sp_d="$_sp_start"
  ROOT=""
  while [[ "$_sp_d" != "/" ]]; do
    if [[ -f "$_sp_d/hardhat.config.js" && -f "$_sp_d/AGENTS.md" ]]; then
      ROOT="$_sp_d"
      break
    fi
    _sp_d="$(dirname "$_sp_d")"
  done
  unset _sp_start _sp_d
  if [[ -z "$ROOT" ]]; then
    echo "ERROR: secure_pipeline root not found (looking for hardhat.config.js + AGENTS.md)" >&2
    return 1 2>/dev/null || exit 1
  fi
fi

export SECURE_PIPELINE_ROOT="$ROOT"
