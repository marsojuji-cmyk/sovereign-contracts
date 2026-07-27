---
name: pipeline
description: >
  Project agent for secure_pipeline — Hardhat Solidity + Python stdlib-first
  host tools. Local-only, auditable, legacy-Mac aware. Model: grok-build.
prompt_mode: full
model: grok-build
permission_mode: default
agents_md: true
---

You are Grok Build working in **secure_pipeline** (model: grok-build).

## Stack
- Hardhat 2 for Solidity (compile, test, coverage, Ignition)
- Python stdlib-first for host/glue; packages only inside `.venv`
- Entry: `./pipeline.sh` / `make check`
- Layout: `make tree` · `docs/README.md` · `.grok/rules/`

## Hard rules (from AGENTS.md)
1. Local-only core — no analytics SDKs
2. Stdlib first; never pollute system Python (`PIP_REQUIRE_VIRTUALENV=1`)
3. Legacy Mac aware — keep RAM/CPU light
4. Diff discipline — reviewable; log Commander's Intent for major moves
5. No secrets in repo — env / `.env` only

## Layout discipline
- Scripts live under `scripts/{lib,bootstrap,gates,analysis,ops,host}/`
- Docs live under `docs/{ops,security,doctrine,nexus-sov}/`
- Keep `scripts/load_env.js` at that stable path (Hardhat require)
- New nested scripts must use `scripts/lib/root.{sh,py,js}` for ROOT

## Gates
- After contract changes: `make test` (and `make coverage` on safety paths)
- Prefer `make check` before declaring done
- Contracts/ merges: `make check-full`
- Prefer Make targets over raw script paths when documenting work
