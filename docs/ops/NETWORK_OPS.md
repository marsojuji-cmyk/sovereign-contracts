# Network ops (Phase 3) — docs only, no live funds required

**Commander's Intent**

| | |
|---|---|
| **Purpose** | Document how this repo would talk to Sepolia / Etherscan **when you choose to**, without baking secrets or forcing online steps into the default loop. |
| **End State** | You can configure env, dry-run verify syntax, and deploy *commands* safely; `make check` still never needs a network. |
| **Constraints** | Local-first core · no keys in git · no mandatory RPC · testnet only in examples · never mainnet in this doc |

This phase **does not expand contracts**. It only documents optional network ops.

---

## Doctrine

| Layer | Default | Optional (you opt in) |
|-------|---------|------------------------|
| Compile / test / coverage | In-process Hardhat | — |
| Deploy | `make deploy-local` (ephemeral) | Sepolia via Ignition **when env set** |
| Verify | Inert | `hardhat verify` **when API key set** |
| Secrets | None | `.env` (gitignored) or exported shell vars |

**Hard rule:** never commit `.env`, private keys, or funded seed phrases.  
**Hard rule:** default CI / `make check` must work offline.

---

## What you need (only if leaving localhost)

| Variable | Required for | Notes |
|----------|--------------|--------|
| `SEPOLIA_RPC_URL` | Deploy / read Sepolia | HTTPS JSON-RPC from a provider you trust, or your own node |
| `DEPLOYER_PRIVATE_KEY` | Sign deploys | **0x-prefixed** hex; use a **burner** key with **testnet-only** ETH |
| `ETHERSCAN_API_KEY` | Source verify | Etherscan (or compatible) API key |

Template: [`.env.example`](../.env.example) → copy to `.env` locally:

```bash
cd /path/to/sovereign-contracts   # your clone
cp .env.example .env
chmod 600 .env
# edit .env in a local editor — do not paste keys into chat logs
```

Or export in the shell (nothing written to disk):

```bash
export SEPOLIA_RPC_URL='https://…'
export DEPLOYER_PRIVATE_KEY='0x…'   # burner only
export ETHERSCAN_API_KEY='…'
```

Validate shape **without** calling the network:

```bash
./scripts/gates/check_env.sh
# or: make env-check
```

---

## Networks in `hardhat.config.js`

| Name | chainId | When present |
|------|--------:|--------------|
| `hardhat` | 31337 | Always (default) |
| `localhost` | 31337 | Always (`npx hardhat node`) |
| `sepolia` | 11155111 | Only if `SEPOLIA_RPC_URL` is set |

If `SEPOLIA_RPC_URL` is unset, the Sepolia network entry is **omitted** — no accidental remote use.

Accounts for Sepolia are loaded only when `DEPLOYER_PRIVATE_KEY` is set. Empty accounts ⇒ deploy will fail closed (good).

---

## Local path (always preferred first)

```bash
make check                 # preflight + compile + test — no RPC
make deploy-local          # SecureVault on in-process Hardhat
make deploy-accounting     # AccountingVault on in-process Hardhat
```

Ignition on the default network is **ephemeral**: addresses exist only for that process.

Optional persistent local chain:

```bash
# terminal A
npx hardhat node

# terminal B
npx hardhat ignition deploy ./ignition/modules/SecureVault.js --network localhost
```

---

## Sepolia path (opt-in — testnet ETH only)

### 0. Preconditions

1. `make check` green locally.  
2. Burner wallet; **never** a mainnet cold wallet.  
3. Sepolia ETH from a public faucet (you obtain this yourself).  
4. `.env` filled or exports set; `./scripts/gates/check_env.sh` OK.

### 1. Dry-run mental checklist (no broadcast)

| Step | Question | Abort if |
|------|----------|----------|
| Network | Am I targeting `sepolia` (11155111)? | Any other chain |
| Key | Is this a burner? | Key ever used on mainnet with real funds |
| Value | Am I sending only testnet ETH? | Mainnet RPC URL by mistake |
| Module | Which Ignition module? | Deploying `contracts/test/*` helpers |
| Verify | Do I need source upload? | Key missing → skip verify |

### 2. Deploy (real broadcast — only when you intend to)

```bash
# SecureVault — set initial owner explicitly (recommended)
npx hardhat ignition deploy ./ignition/modules/SecureVault.js \
  --network sepolia \
  --parameters '{"SecureVaultModule":{"initialOwner":"0xYourBurnerAddress"}}'

# AccountingVault — no constructor args
npx hardhat ignition deploy ./ignition/modules/AccountingVault.js \
  --network sepolia
```

Ignition writes under `ignition/deployments/` (gitignored). Keep that tree local or back it up offline if you care about redeploy continuity.

### 3. Verify (optional, after deploy)

Replace placeholders with the address Ignition printed:

```bash
# SecureVault(address initialOwner)
npx hardhat verify --network sepolia \
  0xDeployedVaultAddress \
  0xInitialOwnerAddress

# AccountingVault() — no constructor args
npx hardhat verify --network sepolia \
  0xDeployedAccountingVaultAddress
```

**Dry-run note:** Hardhat verify always hits the explorer API when invoked. There is no fully offline “fake verify.”  
**Safe practice:** only run verify after a successful testnet deploy you own; omit the command entirely if you do not want explorer interaction.

If verify fails with “already verified,” treat as success. If constructor args mismatch, re-check the Ignition parameters you used.

---

## Command cheat sheet

| Intent | Command | Network I/O |
|--------|---------|-------------|
| Local gate | `make check` | None |
| Env shape | `make env-check` | None |
| Sepolia dry-run | `make sepolia-dry-run` | None by default; read-only `chainId` if RPC set |
| Local deploy | `make deploy-local` | None (in-process) |
| Manifest anchor (local) | `make deploy-manifest` | None (in-process) |
| List networks | `npx hardhat` (see config) | None |
| Sepolia deploy | `npx hardhat ignition deploy … --network sepolia` | Yes — broadcast |
| Verify | `npx hardhat verify --network sepolia …` | Yes — explorer API |

This repo intentionally has **no** `make deploy-sepolia` target. Network deploys stay explicit so a tired `make` habit cannot spend gas.

---

## Threat & opportunity (ops)

| Threat | Mitigation |
|--------|------------|
| Key in git / chat | `.env` gitignored; `chmod 600`; never commit; rotate if leaked |
| Mainnet mis-target | Only `sepolia` documented; config omits other public nets |
| RPC provider logging | Prefer self-hosted or least-trust HTTPS; no secrets in URL query if avoidable |
| Explorer doxxing | Verify is optional; address still public once deployed |
| Clipboard malware | Type deployer address checks; confirm chainId in wallet if using one |

| Opportunity | Why |
|-------------|-----|
| Same Ignition modules local + Sepolia | No contract surface growth for Phase 3 |
| Env-gated network | Offline default preserved |
| Docs-only success criterion | Phase 3 complete without spending testnet ETH |

---

## Out of scope (Phase 3)

- Mainnet  
- Multi-sig / hardware wallet wiring  
- Tenderly / third-party dashboards  
- Expanding or changing vault Solidity  
- Automated faucet scripts  

---

## Success criteria (this phase)

- [x] Network ops documented (`docs/ops/NETWORK_OPS.md`)  
- [x] `.env.example` lists only needed keys  
- [x] Hardhat config can attach Sepolia **only** from env  
- [x] `make check` still requires zero RPC  
- [x] Env shape checker runs offline  
- [ ] (Optional, human) You later run a real Sepolia deploy on a burner — not required for Phase 3 closeout  

Related: [THREAT_MODELS.md](./THREAT_MODELS.md) · [AGENTS.md](../AGENTS.md)
