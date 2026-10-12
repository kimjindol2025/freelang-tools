#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
OUTPUT="$($ROOT/scripts/fl-git-native "$ROOT")"
OUTPUT_JSON="${OUTPUT%%$'\n'*}"
EXPECTED_HEAD="$(git -C "$ROOT" rev-parse HEAD)" OUTPUT="$OUTPUT_JSON" node -e '
const value=JSON.parse(process.env.OUTPUT);
if (value.schemaVersion !== "freelang.git/v1" || value.source !== "freelang-native" || value.readOnly !== true) process.exit(1);
for (const key of ["status","head","branch","diff"]) if (!value[key] || value[key].ok !== true) process.exit(1);
if (value.head.value !== process.env.EXPECTED_HEAD && process.env.EXPECTED_HEAD) process.exit(1);
console.log("git-status-head-branch-diff=PASS");
'
