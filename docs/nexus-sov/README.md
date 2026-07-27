# Nexus.sov — hygiene & pointers

**Purpose:** Keep sovereign / identity material **out of git** while canonical build docs live in this repo.

## Canonical copies (in repo)

| Material | Path |
|----------|------|
| Grok Build Instructions v1 | `docs/doctrine/GROK_BUILD_INSTRUCTIONS.md` |
| LIBRARIAN Protocol | `docs/doctrine/LIBRARIAN_PROTOCOL.md` |
| Applied build frame | `docs/doctrine/BUILD_FRAME_NEXUS_PIPELINE.md` |
| On-chain manifest anchor | `contracts/BuildManifestAnchor.sol` |

## Upstream folder (local only)

Default location on this host:

`~/Downloads/perplexity/commet/Comet/Nexus.sov/`

| File | Handling |
|------|----------|
| `Grok Build instructions v.1/grok-build-instructions.md` | **Superseded** by `docs/doctrine/GROK_BUILD_INSTRUCTIONS.md` — keep upstream as archive or delete after backup |
| `secrets/proton-recovery-phrase.pdf` | **Never** commit, upload, or paste into chat. Host layout: `Nexus.sov/secrets/` (chmod 700). |

## Suggested layout (Downloads)

```
Nexus.sov/
  README.md              ← hygiene index (written by pipeline hygiene pass)
  Grok Build instructions v.1/   ← optional archive
  secrets/               ← optional: recovery PDF only, chmod 700, not in cloud sync
```

## Relocation (optional)

To move Nexus out of Downloads:

```bash
mkdir -p ~/Documents/Nexus.sov/secrets
# Move only what you intend; keep recovery PDF out of git/cloud repos
mv ~/Downloads/perplexity/commet/Comet/Nexus.sov/* ~/Documents/Nexus.sov/
```

Update this README if your canonical path changes.