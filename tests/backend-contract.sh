#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
OUTPUT="$($ROOT/scripts/fl-backend-contract "$ROOT/tests/backend-contract-input.json")"
printf '%s\n' "$OUTPUT"
OUTPUT_JSON="$OUTPUT" node -e '
const value = JSON.parse(process.env.OUTPUT_JSON.split("\n")[0]);
if (value.schemaVersion !== "freelang.backend-contract/v1" || value.status !== "PASS") process.exit(1);
if (value.passCount !== 7 || value.blockedCount !== 0) process.exit(1);
if (value.categories.length !== 7) process.exit(1);
for (const category of value.categories) {
  if (!category.result || category.result.ok !== true || !category.result.status) process.exit(1);
}
console.log("BACKEND_CONTRACT_TEST=PASS");
'
