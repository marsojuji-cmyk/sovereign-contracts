# Kabbalian build laws (engineering companion)

**Status:** v1 — maps classical Kabbalistic structure to `secure_pipeline` gates.  
**Pairs with:** Grok Build Instructions v1 (internal; not included in this repo), `docs/doctrine/BUILD_FRAME_NEXUS_PIPELINE.md`, `AGENTS.md`.  
**Not a substitute for:** tests, Slither, or `make check` / `make check-full`.

---

## 1. Scope & classification

| Field | Value |
|-------|--------|
| Audience | Builder, auditors, Grok Build sessions |
| In scope | Mindset + laws linking Four Worlds, Gevurah/Malkhut, Sephirot checklist to repo commands |
| Out of scope | Theological claims; replacing empirical validation; Nexus `secrets/` material |
| Related artifacts | `docs/doctrine/LIBRARIAN_PROTOCOL.md`, `docs/security/THREAT_MODELS.md`, `Makefile` |
| Nexus.sov | No dedicated “Kabalian” source file found (see §3) |

---

## 2. Intent

### Prime Objective (document)

**Canonize a Kabbalian coding grammar** so sophisticated pipelines are governed by explicit restriction (Tzimtzum), vessel boundaries, and manifest proof (Malkhut)—aligned with Nexus “construction over consumption” and Phase 5 gates.

### Five Lenses

| Lens | Answer |
|------|--------|
| **WHO** | Sovereign builder; future auditors and deploy operators |
| **WHAT** | This doc + `AGENTS.md` pointer; no contract changes |
| **WHEN** | Active now for every non-trivial session; revise when Phase 6+ adds deploy gates |
| **WHERE** | `secure_pipeline` repo; optional mirror in `~/.grok/docs/` if you copy manually |
| **WHY** | Philosophy without Malkhut is klippah; shared vocabulary speeds Commander's Intent |

### Commander's Intent

- **Purpose:** Execute user next-actions 1–4 (active build frame, Four Worlds map, in-repo canon, Nexus source check).
- **End State:** One LIBRARIAN doc; `AGENTS.md` lists it; gates named under Gevurah/Malkhut.
- **Key Constraints:** Local-only core; no secrets; contracts untouched.
- **Implied Tasks:** Write §5 active build; mark world-skips; record Nexus search in §3.

---

## 3. Source ledger

| Source | Role | Note |
|--------|------|------|
| Grok Build v1 (internal; not included in this repo) | Primary for Five Lenses, validate-against-reality | Nexus.sov import |
| `docs/doctrine/BUILD_FRAME_NEXUS_PIPELINE.md` | Primary for pipeline ↔ Nexus bridge | Applied frame |
| `AGENTS.md` | Primary for gate commands | Phase 5 table |
| Classical Kabbalah (Four Worlds, Tzimtzum, Tikkun, PaRDeS) | **Secondary** — cross-domain synthesis | Engineering mapping, not dogma |
| `~/Downloads/.../Nexus.sov/` | Searched for *kabal* / Kabbalah terms | **No matches**; see §5.4 |

**Frontier:** A future Nexus.sov “Kabalian” or “Project star sheild” spec (folder exists but is empty in listing) would become primary for terminology alignment.

---

## 4. Reasoning trace

1. Sophisticated systems fail when **flow exceeds vessel capacity** (Shevirah) or **husks** hide coupling (Klippah).
2. `secure_pipeline` already encodes **Tikkun** (mutation smoke, safety tests, Slither) and **Gevurah** (secret scan, local-only preflight).
3. Missing piece was **named Atzilut intent** and **Four Worlds gap visibility** per session.
4. Therefore: one doc ties mystical structure to **Makefile targets** so Malkhut is always a command, not a feeling.

---

## 5. Analysis

### 5.1 Active build (Atzilut + Gevurah + Malkhut)

**Active build:** *Post–Phase 5 hardened merge path* — any evolution of production vaults, safety tests, or deploy-readiness claims must leave **auditable proof** in git and green gates, without expanding scope into an undefined “Nexus product.”

#### Atzilut — Prime Objective (one paragraph)

Construct and maintain a **local-first EVM vault pipeline** whose custody and accounting models remain **threat-bounded** (`SecureVault` vs `AccountingVault`), whose host layer stays **stdlib-first and telemetry-free**, and whose merge bar treats **reality validation as ritual**: every contracts touch proves compile + test + static analysis, safety paths prove coverage and mutation failure modes, and any network-facing step proves offline env shape before keys touch RPC. Success is not feature count but **reducible uncertainty** for a skeptical auditor: manifests, docs, and commands that agree.

#### Gevurah — forbidden (severity)

| Rule | Meaning |
|------|---------|
| No secrets in repo | No private keys, recovery material, or `0x`+64-hex in tracked `contracts/`, `scripts/`, `src/` |
| No system Python pollution | No global `pip install`; optional stack only in `.venv` |
| No cloud telemetry in core loop | Preflight and gate scripts stay offline-capable |
| No merge on contracts without static pass | Do not ship `contracts/` / safety-test diffs without `make check-full` |
| No deploy / Sepolia without env gate | Do not run network deploy paths without `make env-check` (and documented ops) |
| No oracle merges | No “LGTM” without cited gate output for touched layers |
| No scope wall breach | Do not ingest Nexus `secrets/` or recovery PDF into repo or AI context |
| No vessel overfill | No unguarded external calls on value paths; no skipping threat split between vaults |

#### Malkhut — gates (commands that must pass)

| When | Commands | Kingdom (what they manifest) |
|------|----------|------------------------------|
| Every local edit loop | `make check` | Host health + compile + 32 tests |
| Any `contracts/` or safety-path `test/` diff | `make check-full` | Above + Slither |
| Touching safety / claiming full stmt evidence | `make coverage && make coverage-gate` | 100% stmt floor on production vaults |
| Before network / deploy / Sepolia | `make env-check` | `.env` shape + secret-pattern scan |
| Before choosing deploy tier | `make env-probe` | `PIPELINE_ENV` without RPC |
| Proving guards are load-bearing | `make mutation-smoke` | Suite fails if `nonReentrant` stripped |
| Optional portfolio / anchor evidence | `make manifest-hash`, `make anchor-manifest-local` | Build bundle lineage on-chain (local net) |

**Session minimum for this active build:** `make check` green (verified at doc authoring).

---

### 5.2 Four Worlds — pipeline map & skips

| World | Pipeline stage | Where it lives in repo | Status |
|-------|----------------|------------------------|--------|
| **Atzilut** | Prime Objective, WHO/WHY, threat split | Grok Build Instructions v1 (internal; not included), `BUILD_FRAME_NEXUS_PIPELINE.md`, `THREAT_MODELS.md`, session Commander's Intent | **Partial skip:** small edits often omit explicit Atzilut paragraph |
| **Beriah** | Blueprints, modules, LIBRARIAN reports | `ignition/`, design docs, `LIBRARIAN_PROTOCOL.md` | **Partial skip:** host-only script tweaks without doc/threat note |
| **Yetzirah** | Code + tests as formed vessels | `contracts/`, `test/`, `scripts/` | **Strong** — default builder focus |
| **Assiah** | Manifest proof | `make check`, `check-full`, `data/health.json`, deploy targets | **Partial skip:** `make test` without preflight; `check-full` without coverage when claiming 100%; deploy without `env-check` |

**Skipped-world summary**

| Skip pattern | Risk | Mitigation |
|--------------|------|------------|
| Atzilut omitted | Scope creep, wrong vault model | One Prime Objective line in PR/session notes |
| Beriah omitted | Hidden coupling | LIBRARIAN §2 for non-trivial docs; update `THREAT_MODELS.md` on boundary change |
| Assiah omitted | False confidence | Use table §5.1 Malkhut by diff type |

**Law:** *No Assiah without Yetzirah; no Yetzirah without Beriah for boundary changes; no Beriah without Atzilut for non-trivial work.*

---

### 5.3 Sephirot checklist (quick architecture pass)

Before merge, walk **Gevurah → Yesod → Malkhut**: what is forbidden, what is the stable interface, what commands prove the kingdom. Full Sephirot table lives in session teaching; see `BUILD_FRAME` cross-domain map for Grok Build ↔ gates.

---

### 5.4 Nexus.sov — “Kabalian” source search

| Location | Result |
|----------|--------|
| `secure_pipeline` (ripgrep `kabal*`) | No matches |
| `~/Downloads/perplexity/commet/Comet/Nexus.sov` (ripgrep) | No matches |
| Nexus tree | `Grok Build instructions v.1/`, empty `Project star sheild/`, `Warp 1 (TBD)/`, `secrets/` (out of band) |

**Conclusion:** “Kabalian” in this repo is **generic Kabbalah-inspired engineering law** until a Nexus document is added. If you add a spec under Nexus.sov, update §3 source ledger and reconcile terms here.

### Threat & Opportunity

| Threats | Opportunities |
|---------|----------------|
| Checklist without running gates | Shared language for ethos + Nexus sessions |
| Mystical vocabulary alienates auditors | PaRDeS maps to Peshat (API) → Sod (threats) |
| Empty `Project star sheild` becomes orphan lore | Future shield spec slots into Beriah with gates |

**Risk:** Low for doc-only; **Med** if deploy gates are skipped while citing this doc.

---

## 6. Review pass

- **Weakest link:** Atzilut still voluntary for tiny diffs—acceptable if Malkhut table is followed for `contracts/`.
- **Untested assumptions:** `make check-full` not re-run in this session (Slither slower); `make check` passed.
- **Adversarial:** Reader could treat Sephirot as decoration—mitigation: every Gevurah row ties to `AGENTS.md` or script behavior.

---

## 7. Inventory

| Artifact | Action |
|----------|--------|
| `docs/doctrine/KABBALIAN_BUILD_LAWS.md` | Created (this file) |
| `AGENTS.md` | Pointer in project map + when editing |
| Commands run | `make check` → 32 passing |

---

## 8. Assurance

- **Empirical:** `make check` green at authoring time.
- **Logical:** Malkhut commands match `Makefile` and `AGENTS.md` Gates table.
- **Settled:** Nexus has no kabal* text in indexed paths. **Frontier:** Phase 6 deploy automation as mandatory Assiah.

---

## 9. Navigation

**Changelog:** v1 — initial canon from Grok session next-actions.

**Next milestones**

1. Choose Phase 6 path (`BUILD_FRAME`: Sepolia dry-run vs new vault vs ops doc) and add **Atzilut paragraph** to that effort.
2. On next `contracts/` diff, run `make check-full` and record in PR notes (Malkhut).
3. If Nexus “star shield” or Warp material arrives, import provenance to §3 and align Gevurah rules.
4. Optional: copy summary to `~/.grok/docs/kabbalian-build-laws.md` for global Grok sessions.

---

## Appendix — PaRDeS in this repo

| Level | Example paths |
|-------|----------------|
| Peshat | Solidity natspec, revert strings, `Makefile` targets |
| Remez | Module layout, `pipeline.sh` entrypoints |
| Derash | `THREAT_MODELS.md`, `BUILD_FRAME_NEXUS_PIPELINE.md` |
| Sod | `.env`, recovery material — **never in git**; `env-check` enforces shape |