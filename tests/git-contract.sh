#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
OUTPUT="$($ROOT/scripts/fl-git-native "$ROOT")"
OUTPUT_JSON="${OUTPUT%%$'\n'*}"
source "$ROOT/tests/native-json-check.sh"
assert_native_json git "$OUTPUT_JSON" "$(git -C "$ROOT" rev-parse HEAD)"
echo "git-status-head-branch-diff=PASS"
