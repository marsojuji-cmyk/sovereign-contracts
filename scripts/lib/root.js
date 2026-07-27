/**
 * Resolve secure_pipeline repo root from any nested scripts/* path.
 * Marker: hardhat.config.js + AGENTS.md
 */
const fs = require("fs");
const path = require("path");

function projectRoot(startDir) {
  const env = process.env.SECURE_PIPELINE_ROOT;
  if (env) {
    const p = path.resolve(env);
    if (
      fs.existsSync(path.join(p, "hardhat.config.js")) &&
      fs.existsSync(path.join(p, "AGENTS.md"))
    ) {
      return p;
    }
  }

  let d = path.resolve(startDir || __dirname);
  for (let i = 0; i < 8; i++) {
    if (
      fs.existsSync(path.join(d, "hardhat.config.js")) &&
      fs.existsSync(path.join(d, "AGENTS.md"))
    ) {
      return d;
    }
    const parent = path.dirname(d);
    if (parent === d) break;
    d = parent;
  }
  throw new Error(
    "secure_pipeline root not found (looking for hardhat.config.js + AGENTS.md)"
  );
}

module.exports = { projectRoot };
