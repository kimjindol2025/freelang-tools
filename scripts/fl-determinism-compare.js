#!/usr/bin/env node
const fs = require("fs");

const [leftPath, rightPath] = process.argv.slice(2);
if (!leftPath || !rightPath) process.exit(2);

const ignoredKeys = new Set([
  "duration", "duration_ms", "pid", "process_id", "timestamp",
  "started_at", "finished_at", "evidence_dir"
]);

function canonical(value) {
  if (Array.isArray(value)) return value.map(canonical);
  if (value && typeof value === "object") {
    return Object.keys(value)
      .filter((key) => !ignoredKeys.has(key))
      .sort()
      .reduce((result, key) => {
        result[key] = canonical(value[key]);
        return result;
      }, {});
  }
  return value;
}

function read(file) {
  return JSON.parse(fs.readFileSync(file, "utf8"));
}

const left = canonical(read(leftPath));
const right = canonical(read(rightPath));
if (JSON.stringify(left) !== JSON.stringify(right)) {
  process.stderr.write("DETERMINISM_MISMATCH=final-result\n");
  process.exit(1);
}
process.stdout.write("DETERMINISM_MATCH=final-result\n");
