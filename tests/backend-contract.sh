#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
OUTPUT="$($ROOT/scripts/fl-backend-contract "$ROOT/tests/backend-contract-input.json")"
printf '%s\n' "$OUTPUT"
source "$ROOT/tests/native-json-check.sh"
assert_native_json backend "${OUTPUT%%$'\n'*}"
echo "BACKEND_CONTRACT_TEST=PASS"
