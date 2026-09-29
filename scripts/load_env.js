/**
 * Minimal local .env loader — no dotenv dependency.
 * Does not override variables already present in process.env.
 * Never logs values.
 */
import fs from "node:fs";
import path from "node:path";

export function loadEnv(filePath) {
  const p = filePath || path.join(import.meta.dirname, "..", ".env");
  if (!fs.existsSync(p)) return false;
  const text = fs.readFileSync(p, "utf8");
  for (const raw of text.split("\n")) {
    const line = raw.trim();
    if (!line || line.startsWith("#")) continue;
    const eq = line.indexOf("=");
    if (eq <= 0) continue;
    const key = line.slice(0, eq).trim();
    let val = line.slice(eq + 1).trim();
    if (
      (val.startsWith('"') && val.endsWith('"')) ||
      (val.startsWith("'") && val.endsWith("'"))
    ) {
      val = val.slice(1, -1);
    }
    if (process.env[key] === undefined) {
      process.env[key] = val;
    }
  }
  return true;
}
