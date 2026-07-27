# Scripts

Role-nested host tooling. Prefer **`make <target>`** over calling these directly.

| Directory | Purpose | Examples |
|-----------|---------|----------|
| `lib/` | Shared root resolvers | `root.sh`, `root.py`, `root.js` |
| `bootstrap/` | Environment setup | `setup_python.sh` |
| `gates/` | Offline quality / safety gates | `check_env.sh`, `coverage_floor.py`, `mutation_smoke.sh`, `env_probe.py` |
| `analysis/` | Static analysis runners | `run_slither.sh` |
| `ops/` | Network / manifest / wallet helpers | `sepolia_dry_run.sh`, `manifest_bundle_hash.py` |
| `host/` | Machine maintenance | `mac_clean.sh` |
| `load_env.js` | **Stable path** for Hardhat (do not move) | required by `hardhat.config.js` |

## Adding a script

1. Pick the role directory above.
2. Resolve repo root with `lib/root.*` (markers: `hardhat.config.js` + `AGENTS.md`).
3. Wire a Make target if it is part of the public surface.
4. Document in `docs/README.md` / `AGENTS.md` project map when user-facing.

```bash
# bash
# shellcheck source=../lib/root.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/root.sh"
cd "$ROOT"

# python
from root import project_root  # after sys.path insert of scripts/lib
ROOT = project_root(Path(__file__))

# node
const { projectRoot } = require("../lib/root");
```
