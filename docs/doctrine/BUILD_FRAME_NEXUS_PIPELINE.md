# Build frame: Nexus.sov ↔ secure_pipeline

**Format:** LIBRARIAN Protocol (abbreviated where sections are satisfied elsewhere).  
**Date:** 2026-07-10  
**Gate snapshot:** `make check` green (25 tests) at frame authoring time.

---

## 1. Scope & classification

| Field | Value |
|-------|--------|
| Audience | Builder (admin), future auditors, Grok Build sessions |
| In scope | Operating system for construction; EVM vault pipeline as **evidence substrate** |
| Out of scope | Contents of `Nexus.sov/proton-recovery-phrase.pdf` (never ingest to repo or chat) |
| Related artifacts | Grok Build Instructions v1 (internal; not included in this repo), `docs/doctrine/LIBRARIAN_PROTOCOL.md`, `AGENTS.md` |
| Upstream pack | `~/Downloads/.../Nexus.sov/Grok Build instructions v.1/` |

---

## 2. Intent

### Prime Objective

**Construct a durable, local-first build operating system** that links Nexus.sov intent (construction over consumption) to **auditable on-chain scaffolding** in `secure_pipeline`, so every future session produces versioned docs + runnable gates—not one-off answers.

### Five Lenses

| Lens | Answer |
|------|--------|
| **WHO** | You (sovereign builder); beneficiaries = future you + anyone auditing vault behavior; affected parties = future vault users/counterparties if contracts deploy. |
| **WHAT** | (a) Imported Grok Build v1 + LIBRARIAN spec in-repo; (b) global copy under `~/.grok/docs/`; (c) this applied frame; (d) optional Phase 6+ contract work only when Prime Objective tightens. **Boundary:** two vaults + host gates, not a full Nexus product. |
| **WHEN** | **Now:** docs + wiring (done this session). **Next:** choose one hardened path (Sepolia dry-run *or* new vault module *or* cross-chain ops doc). **Later:** multi-month roadmap with decision gates per Build Protocol §8. |
| **WHERE** | Dev: macOS Intel-class, `secure_pipeline` repo, Grok Build TUI; persistence: git + `data/health.json`; Nexus.sov materials stay in Downloads until you explicitly relocate. |
| **WHY** | Reduces uncertainty about *how* to build and *whether* artifacts are true; EVM layer proves "validate against reality" is habitual before any sovereign/finance stack grows. |

### Commander's Intent

- **Purpose:** Install Grok Build v1 as the default construction grammar for this repo and Grok global docs.  
- **End State:** Any report uses LIBRARIAN; any code change hits `make check` / `make check-full`; builder can open one frame doc and continue.  
- **Key Constraints:** Local-only core; no secrets in git; legacy Mac lightweight; diff discipline.  
- **Implied Tasks:** Import instructions; define LIBRARIAN; apply lenses; wire `AGENTS.md`; verify gates.

---

## 3. Source ledger

| Source | Role |
|--------|------|
| `grok-build-instructions.md` (Nexus.sov v1) | Primary for Build Protocol & Five Lenses |
| `AGENTS.md` | Primary for repo gates & ethos |
| `docs/security/THREAT_MODELS.md` | Primary for vault threat boundaries |
| `~/.grok/skills/grok-ethos/SKILL.md` | Primary for Commander's Intent formatting |
| No standalone LIBRARIAN file in Nexus pack | **Frontier** → defined in `docs/doctrine/LIBRARIAN_PROTOCOL.md` |

---

## 4. Reasoning trace

1. Nexus.sov ships **process** (Grok Build v1), not application code.  
2. `secure_pipeline` already implements **reality validation** (tests, mutation smoke, coverage floor).  
3. Without LIBRARIAN, document builds drift; without import, v1 is orphaned in Downloads.  
4. Therefore: **process docs in git**, **global mirror in ~/.grok**, **one applied frame** tying WHO/WHY to EVM gates.  
5. Wallet/recovery PDF is **out of band**—identity material must not become training/context surface.

---

## 5. Analysis

### Cross-domain map (Build Pattern: synthesis)

| Grok Build v1 | secure_pipeline |
|---------------|-----------------|
| Validate against reality | `make check`, `make coverage-gate`, `make env-check` |
| Adversarial testing | safety tests, `make mutation-smoke`, Slither optional |
| Archive & roadmap | `AGENTS.md` phases, `data/health.json` |
| First-principles custody | `SecureVault` vs `AccountingVault` threat split |

### Threat & Opportunity

| Threats | Opportunities |
|---------|----------------|
| Treating imported philosophy without gates → pretty docs, brittle code | Same session culture for *any* Nexus artifact |
| Accidental secret ingest from Nexus folder | Clear scope wall around recovery material |
| Scope creep into "Nexus product" before Prime Objective sharpens | Vault pipeline as portfolio-grade evidence |

**Risk:** **Low** for doc-only integration; **Med** when moving to testnet deploy (keys, ops).

---

## 6. Review pass

- **Weakest link:** Nexus.sov *product* definition still implicit—only Build Instructions exist beside recovery PDF.  
- **Untested assumptions:** That global `~/.grok/docs/` copy is enough for non–secure_pipeline sessions (may need user-guide link).  
- **Adversarial:** A reader could ignore LIBRARIAN; mitigation = `AGENTS.md` pointer + use for next doc edit.

---

## 7. Inventory

| Artifact | Path |
|----------|------|
| Grok Build v1 | internal; not included in this repo |
| LIBRARIAN spec | `docs/doctrine/LIBRARIAN_PROTOCOL.md` |
| This frame | `docs/doctrine/BUILD_FRAME_NEXUS_PIPELINE.md` |
| Grok Build v1 (global) | `~/.grok/docs/grok-build-instructions.md` |
| User-guide pointer | `~/.grok/docs/user-guide/23-grok-build.md` |

---

## 8. Assurance

- Empirical: run `make check` after `AGENTS.md` edit (required).  
- Logical: LIBRARIAN sections map 1:1 to Build Protocol §5–§8.  
- **Settled:** v1 text imported with provenance. **Frontier:** Nexus.sov roadmap beyond instructions.

---

## 9. Navigation

### Changelog (2026-07-10)

- Imported Grok Build Instructions v1 into repo + `~/.grok/docs/`.  
- Authored LIBRARIAN Protocol companion.  
- Applied Five Lenses + Prime Objective for Nexus ↔ pipeline.  
- Wired `AGENTS.md` project map.

### Decision gates (2026-07-10 — all three executed)

| Gate | Status | Artifact |
|------|--------|----------|
| **C** Nexus hygiene | Done | `docs/nexus-sov/README.md`, `Nexus.sov/README.md` (Downloads) |
| **B** New module | Done | `BuildManifestAnchor` + tests + Ignition + `make check-full` |
| **A** Sepolia dry-run | Done | `make sepolia-dry-run` (no broadcast unless `SECURE_PIPELINE_CONFIRM_SEPOLIA_BROADCAST=1`) |

### Immediate next actions

1. Optional: `make coverage && make coverage-gate` after contract add.  
2. Optional: real Sepolia anchor — burner key + `SECURE_PIPELINE_CONFIRM_SEPOLIA_BROADCAST=1`.  
3. Anchor a manifest: hash your LIBRARIAN bundle off-chain, `anchor()` on local or Sepolia deploy.