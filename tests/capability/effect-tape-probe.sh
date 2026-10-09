#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd -P)"
OUTPUT="$(mktemp)"
trap 'rm -f -- "$OUTPUT"' EXIT INT TERM

set +e
"$ROOT/scripts/fl-effect-capability" >"$OUTPUT" 2>&1
CODE=$?
set -e

cat "$OUTPUT"
grep -q '^CHECK_EXIT=0$' "$OUTPUT"
grep -q '^API_DOC_EXIT=1$' "$OUTPUT"
grep -q '^API_DOC_STATUS=UNAVAILABLE$' "$OUTPUT"
grep -q '^EFFECT_TAPE_PROBE=BLOCKED$' "$OUTPUT"
grep -q '^CAUSE=runtime-did-not-expose-a-public-effect-tape-api$' "$OUTPUT"
test "$CODE" -eq 0
if grep -q '^EFFECT_TAPE_PROBE_BODY_EXECUTED$' "$OUTPUT"; then
  echo "probe body unexpectedly executed" >&2
  exit 1
fi

echo "effect-tape capability probe: PASS (blocked is the expected contract)"
