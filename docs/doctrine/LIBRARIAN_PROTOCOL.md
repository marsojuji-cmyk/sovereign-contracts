# LIBRARIAN Protocol (v1 companion)

**Status:** Defined here because Grok Build Instructions v1.0 references this structure but does not ship a separate spec.  
**Pairs with:** Grok Build Instructions v1 (Build Protocol §6; internal, not included in this repo) and project `AGENTS.md` (Commander's Intent).  
**Use when:** Any document or report is a *deliverable* (threat model, network ops, design memo, portfolio evidence).

---

## Purpose

Turn reports into **catalogued, falsifiable knowledge** — not narrative fluff. Each section has a job; skip a section only when the build is explicitly trivial.

---

## Document skeleton (required sections)

| # | Section | Mnemonic | Content contract |
|---|---------|----------|------------------|
| 1 | **Scope & classification** | **L**ocate | Audience, sensitivity, in/out of scope, related artifacts (paths, versions). |
| 2 | **Intent** | **I**ntent | Prime Objective + Five Lenses table (WHO/WHAT/WHEN/WHERE/WHY). Commander's Intent if engineering. |
| 3 | **Source ledger** | **B**ibliography | Primary sources only for facts; secondary labeled; "unknown / frontier" explicit. |
| 4 | **Reasoning trace** | **R**easoning | Premises → steps → conclusion; no orphan claims. |
| 5 | **Analysis body** | **A**nalysis | Tables for mappings, options, threat/opportunity; prose for narrative glue only. |
| 6 | **Review pass** | **R**eview | Weakest link, untested assumptions, adversarial notes (what would break this?). |
| 7 | **Inventory** | **I**nventory | Files created/changed, commands run, gate results (`make check`, etc.). |
| 8 | **Assurance** | **A**ssurance | Validation: tests, scans, manual checks; settled fact vs hypothesis. |
| 9 | **Navigation** | **N**avigation | Changelog snippet, current state, numbered next milestones + dependencies. |

**Mnemonic:** *Locate → Intent → Bibliography → Reasoning → Analysis → Review → Inventory → Assurance → Navigation* → **LIBRARIAN**.

---

## Five Lenses table (paste into §2)

```markdown
| Lens | Answer |
|------|--------|
| WHO | |
| WHAT | |
| WHEN | |
| WHERE | |
| WHY | |
```

---

## Commander's Intent (engineering overlay)

When the artifact is code or ops, add under §2:

- **Purpose** — one sentence  
- **End State** — measurable  
- **Key Constraints / Acceptable Risk** — bullets  
- **Implied Tasks** — bullets  

(Aligned with `~/.grok/skills/grok-ethos/SKILL.md`.)

---

## Threat & Opportunity (architecture overlay)

For design decisions, add a subsection under §5:

| Threats | Opportunities |
|---------|----------------|
| … | … |

**Risk:** Low / Med / High — one-line justification.

---

## Quality gates before "done"

- [ ] Every factual claim in §3 or tied to a primary source, or marked *frontier*.  
- [ ] §4 could be audited by a skeptical reader without hidden steps.  
- [ ] §7 lists real paths (no invented files).  
- [ ] §8 cites empirical results where the build touched code (`make check` minimum).  
- [ ] §9 has at least one executable next action.

---

## Minimal template (copy)

```markdown
# [Title]

## 1. Scope & classification
…

## 2. Intent
### Prime Objective
…

### Five Lenses
| Lens | Answer |
|------|--------|
| WHO | … |
| WHAT | … |
| WHEN | … |
| WHERE | … |
| WHY | … |

## 3. Source ledger
…

## 4. Reasoning trace
…

## 5. Analysis
…

## 6. Review pass
- Weakest link: …
- Untested assumptions: …

## 7. Inventory
…

## 8. Assurance
…

## 9. Navigation
### Changelog
…

### Next milestones
1. …
```

---

## SO WHAT

LIBRARIAN is the **anti-entropy layer** for written builds: the same discipline as tests for code. Grok Build v1 tells you *to* structure reports; this file tells you *how*.