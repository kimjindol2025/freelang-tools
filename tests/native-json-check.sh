#!/usr/bin/env bash

assert_native_json() {
  local mode="$1" json="$2" expected_head="${3:-}" output code
  output="$(mktemp)"
  if CONTRACT_MODE="$mode" CONTRACT_JSON="$json" EXPECTED_HEAD="$expected_head" \
      CONTRACT_OPERATION="${OPERATION:-}" \
      "$ROOT/scripts/fl-cgc-run" "$ROOT/tests/contract-json-check.fl" >"$output" 2>&1; then
    if "$ROOT/scripts/fl-native-test-result" "$output"; then
      code=0
    else
      code=$?
      cat "$output" >&2
    fi
  else
    code=$?
    cat "$output" >&2
  fi
  rm -f "$output"
  return "$code"
}
