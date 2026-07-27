# Static analysis — Phase 4 (Slither)

**Commander's Intent**

| | |
|---|---|
| **Purpose** | Optional local static analysis on production contracts without cloud services. |
| **End State** | `make slither` runs in project `.venv`, filters test helpers, fails on medium/high. |
| **Constraints** | Optional · venv-only · no system pip · works offline once installed · legacy-Mac light |

---

## Install (once)

```bash
cd /Volumes/Agent_Tenet10/Users/admin/agents/secure_pipeline   # or your clone
export PATH="$HOME/.local/bin:$PATH"   # Node for Hardhat if needed
./scripts/bootstrap/setup_python.sh --with-slither --force
# equivalent: .venv/bin/pip install -r requirements-slither.txt
```

| Package | Pin | Why |
|---------|-----|-----|
| `cbor2` | `5.6.5` | wheel-friendly / avoids Rust builds on odd Pythons |
| `slither-analyzer` | `0.11.3` if Python **&lt; 3.10**; `0.11.5` if **≥ 3.10** | 0.11.5 needs 3.10+; Sonoma CLT is often 3.9 |

**Dual-boot note:** A `.venv` built on Monterey (e.g. Framework Python 3.14) will break on Sonoma if that interpreter is missing. `setup_python.sh` now recreates broken venvs. Prefer re-running setup on the boot you use for `make check-full`.

Never: `pip install slither-analyzer` into system/Frameworks Python.

---

## Run

```bash
make slither
# or
./scripts/analysis/run_slither.sh
# or
./pipeline.sh slither
```

Outputs (gitignored under `reports/` except when you choose to commit a snapshot):

| File | Content |
|------|---------|
| `reports/slither-checklist.md` | Markdown checklist |
| `reports/slither.json` | Machine-readable findings |

Config: `slither.config.json`  
Filter: `contracts/test/` (attack helpers) and `node_modules/`.

**Gate policy**

| Impact | Gate |
|--------|------|
| High / Medium | **Fail** (`--fail-medium`) |
| Low / Informational | Report only (do not fail) |

`make check` stays **without** Slither so the core gate remains lean on cold machines.  
`make check-full` = `check` + `slither` — **required for any `contracts/` (or safety-path) diff** before merge/portfolio claim.

---

## Accepted findings (production)

After filtering test helpers, Slither reports intentional patterns:

| Detector | Where | Disposition |
|----------|-------|-------------|
| `low-level-calls` | `SecureVault.withdraw` / `withdrawAll`, `AccountingVault.withdraw` | **Accepted** — deliberate `call{value:}` with success check, CEI, `nonReentrant` |

These are **informational**. They document the ETH transfer primitive; they are not untreated reentrancy.

Test-only contracts (`contracts/test/AttackHelpers.sol`) intentionally look “bad” (lock ether, reentrancy probes). They are **filtered** from the gate.

---

## What Slither is not

- Not a substitute for unit / invariant tests  
- Not formal verification  
- Not a license to skip human review  
- Not run by default in `make check` (optional weight)

---

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `slither not found` | `./scripts/bootstrap/setup_python.sh --with-slither` |
| `cbor2` build / Rust error | Pin `cbor2==5.6.5` (see `requirements-slither.txt`) |
| Compile framework errors | `npx hardhat compile` then re-run; script uses `--hardhat-ignore-compile` when artifacts exist |
| Too many findings in tests | Ensure `--filter-paths` includes `contracts/test/` |

---

## Success criteria (Phase 4)

- [x] Optional venv install path documented and scripted  
- [x] `cbor2` pin for Python 3.14 on this Mac  
- [x] `make slither` / `pipeline.sh slither`  
- [x] Test helpers filtered; medium/high fail gate  
- [x] Accepted informational findings recorded here  
- [x] Core `make check` remains Slither-free  

Related: [THREAT_MODELS.md](./THREAT_MODELS.md) · [NETWORK_OPS.md](./NETWORK_OPS.md)
