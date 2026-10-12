#!/usr/bin/env bash
set -Eeuo pipefail
SCRIPT_PATH="$(readlink -f -- "${BASH_SOURCE[0]}")"
ROOT="$(cd -- "$(dirname -- "$SCRIPT_PATH")/.." && pwd -P)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT INT TERM
mkdir -p "$TMP_DIR/.freelang"
cp "$ROOT/tests/operation-contract-input.json" "$TMP_DIR/.freelang/contract.json"

OUTPUT="$($ROOT/scripts/fl-contract-check "$TMP_DIR" deploy)"
[[ "$OUTPUT" == *"CONTRACT=VALID"* ]]
[[ "$OUTPUT" == *"APPROVAL_REQUIRED=YES"* ]]
[[ "$OUTPUT" == *"RISK=high"* ]]
if "$ROOT/scripts/fl-contract-check" "$TMP_DIR" rollback >/dev/null 2>&1; then
  echo "unexpected action match"
  exit 1
fi
echo "OPERATION_CONTRACT=PASS"
