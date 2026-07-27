#!/usr/bin/env bash
# mac_clean.sh — local-only Mac maintenance (stdlib ethos: no deps, ANSI-safe)
# Safe defaults; skips project node_modules/.venv unless MAC_CLEAN_DEEP=1
set -euo pipefail

echo "== Mac clean suite =="
df -h / | awk 'NR==1 || $NF=="/"'

reclaimed=0
note() { echo "  -> $*"; }

# User caches (safe)
for target in \
  "$HOME/Library/Caches/com.anthropic.claudefordesktop.ShipIt" \
  "$HOME/Library/Caches/hardhat-nodejs" \
  "$HOME/Library/Caches/pip" \
  "$HOME/Library/Caches/Homebrew" \
  ; do
  if [[ -d "$target" ]]; then
    size=$(du -sk "$target" 2>/dev/null | awk '{print $1}')
    rm -rf "$target"
    reclaimed=$((reclaimed + size))
    note "removed $(basename "$target") (~$((size/1024))M)"
  fi
done

# npm
if command -v npm >/dev/null 2>&1; then
  npm cache clean --force 2>/dev/null || true
  note "npm cache cleaned"
fi

# pip (user + venv if present)
if command -v pip3 >/dev/null 2>&1; then
  pip3 cache purge 2>/dev/null || true
fi
if [[ -x "$(dirname "$0")/../.venv/bin/pip" ]]; then
  "$(dirname "$0")/../.venv/bin/pip" cache purge 2>/dev/null || true
fi
note "pip cache purged"

# Homebrew
if command -v brew >/dev/null 2>&1; then
  brew cleanup -s 2>/dev/null || true
  brew autoremove -y 2>/dev/null || true
  note "brew cleanup + autoremove"
fi

# Old logs (>30 days in user Library/Logs)
if [[ -d "$HOME/Library/Logs" ]]; then
  find "$HOME/Library/Logs" -type f -mtime +30 -delete 2>/dev/null || true
  note "pruned logs older than 30 days"
fi

# Trash (optional — confirm via env; bounded wait so Finder cannot hang the suite)
if [[ "${MAC_CLEAN_EMPTY_TRASH:-}" == "1" ]]; then
  ( osascript -e 'tell application "Finder" to empty trash' 2>/dev/null ) &
  apid=$!
  for _ in $(seq 1 15); do
    kill -0 "$apid" 2>/dev/null || break
    sleep 1
  done
  kill "$apid" 2>/dev/null || true
  wait "$apid" 2>/dev/null || true
  note "emptied Trash (or timed out after 15s — retry from Finder)"
fi

# Comet/browser cache — opt-in (resets app state)
if [[ "${MAC_CLEAN_COMET_CACHE:-}" == "1" ]] && [[ -d "$HOME/Library/Caches/Comet/Default" ]]; then
  rm -rf "$HOME/Library/Caches/Comet/Default"
  note "Comet cache cleared (MAC_CLEAN_COMET_CACHE=1)"
fi

# Docker — opt-in
if [[ "${MAC_CLEAN_DOCKER:-}" == "1" ]] && command -v docker >/dev/null 2>&1; then
  docker system prune -f 2>/dev/null || true
  note "docker system prune"
fi

# Deep: project artifacts (reinstall required)
# shellcheck source=../lib/root.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/root.sh"
if [[ "${MAC_CLEAN_DEEP:-}" == "1" ]]; then
  rm -rf "$ROOT/cache" "$ROOT/artifacts" "$ROOT/coverage" 2>/dev/null || true
  note "Hardhat cache/artifacts/coverage cleared (rebuild with make check)"
fi

echo ""
echo "Approx reclaimed from tracked cache dirs: ~$((reclaimed/1024))M"
df -h / | awk 'NR==1 || $NF=="/"'
echo "Done. Optional: MAC_CLEAN_EMPTY_TRASH=1 MAC_CLEAN_COMET_CACHE=1 ./scripts/host/mac_clean.sh"