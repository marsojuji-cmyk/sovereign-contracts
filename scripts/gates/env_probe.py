#!/usr/bin/env python3
"""
Detect active pipeline environment tier (stdlib only, no RPC).

Prints human summary and export-friendly PIPELINE_ENV=...

  local       — default in-process Hardhat (safe)
  local-node  — HARDHAT_NETWORK=localhost or explicit local node intent
  testnet     — SEPOLIA_RPC_URL set (still offline probe; no calls)

Mainnet is never a valid tier in this doctrine.
"""
from __future__ import annotations

import os
import sys
from pathlib import Path

_LIB = Path(__file__).resolve().parent.parent / "lib"
if str(_LIB) not in sys.path:
    sys.path.insert(0, str(_LIB))
from root import project_root  # noqa: E402

ROOT = project_root(Path(__file__))


def detect() -> str:
    rpc = (os.environ.get("SEPOLIA_RPC_URL") or "").strip()
    hh = (os.environ.get("HARDHAT_NETWORK") or "").strip().lower()
    if rpc:
        if "mainnet" in rpc.lower() and "sepolia" not in rpc.lower():
            return "invalid-mainnet-shaped"
        return "testnet"
    if hh in ("localhost", "local", "node"):
        return "local-node"
    if os.environ.get("SECURE_PIPELINE_LOCAL_NODE", "").lower() in ("1", "true", "yes"):
        return "local-node"
    return "local"


def main() -> int:
    # Optional: load .env keys without printing values (shape only)
    env_path = ROOT / ".env"
    if env_path.is_file() and "SEPOLIA_RPC_URL" not in os.environ:
        try:
            for line in env_path.read_text(encoding="utf-8").splitlines():
                line = line.split("#", 1)[0].strip()
                if not line or "=" not in line:
                    continue
                k, v = line.split("=", 1)
                k, v = k.strip(), v.strip().strip('"').strip("'")
                if k and k not in os.environ:
                    os.environ[k] = v
        except OSError:
            pass

    tier = detect()
    print("SECURE PIPELINE — ENV PROBE (offline)")
    print("=====================================")
    print(f"PIPELINE_ENV={tier}")
    print()
    print("Meaning:")
    print("  local       in-process Hardhat — default, zero funds")
    print("  local-node  persistent local node (set HARDHAT_NETWORK=localhost)")
    print("  testnet     SEPOLIA_RPC_URL present — opt-in Sepolia only")
    print()
    if tier == "invalid-mainnet-shaped":
        print("✗ RPC URL looks like mainnet — out of doctrine. Unset and use Sepolia.")
        return 1
    if tier == "testnet":
        key_set = bool((os.environ.get("DEPLOYER_PRIVATE_KEY") or "").strip())
        print(f"  DEPLOYER_PRIVATE_KEY: {'set' if key_set else 'unset (cannot sign)'}")
        print("  Docs: docs/ops/NETWORK_OPS.md — never print secrets")
    else:
        print("  Safe default for make check / local deploy modules")
    print()
    # Machine-friendly single line for eval (optional)
    print(f"export PIPELINE_ENV={tier}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
