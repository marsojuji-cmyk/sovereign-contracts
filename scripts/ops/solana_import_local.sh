#!/usr/bin/env bash
# Import a Solana base58 private key into a local keypair file only.
# Never logs the key. Never reads from argv (paste at hidden prompt).
set -euo pipefail

OUT="${1:-${HOME}/.config/solana/id.json}"
DIR="$(dirname "$OUT")"

mkdir -p "$DIR"
chmod 700 "$DIR"

if [[ -f "$OUT" ]]; then
  echo "Refusing to overwrite existing keypair: $OUT"
  echo "Pass a different path as first argument if you intend a new file."
  exit 1
fi

printf 'Paste base58 secret (input hidden; stays on this machine): ' >&2
read -rs B58
echo >&2

if [[ -z "${B58}" ]]; then
  echo "Empty input — aborted." >&2
  exit 1
fi

printf '%s' "$B58" | python3 -c '
import json, sys

ALPHABET = b"123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"


def b58decode(s: str) -> bytes:
    num = 0
    for ch in s.encode("ascii"):
        num *= 58
        try:
            num += ALPHABET.index(ch)
        except ValueError:
            raise SystemExit("invalid base58 character")
    pad = 0
    for ch in s:
        if ch == "1":
            pad += 1
        else:
            break
    full = num.to_bytes((num.bit_length() + 7) // 8, "big") if num else b""
    return b"\x00" * pad + full


out_path = sys.argv[1]
raw = b58decode(sys.stdin.read().strip())
if len(raw) not in (32, 64):
    raise SystemExit(f"unexpected decoded length {len(raw)} (want 32 or 64 bytes)")
if len(raw) == 32:
    raise SystemExit("got 32-byte seed only — export full secret key from wallet app")
with open(out_path, "w", encoding="utf-8") as f:
    json.dump(list(raw), f)
' "$OUT"
unset B58

chmod 600 "$OUT"
echo "Wrote keypair: $OUT"

if command -v solana >/dev/null 2>&1; then
  solana address -k "$OUT"
  solana config set --keypair "$OUT" >/dev/null 2>&1 || true
  echo "Default keypair set (solana config)."
else
  echo "solana CLI not installed — keypair file is ready; install CLI to use it."
fi