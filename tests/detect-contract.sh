#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
OUTPUT="$("$ROOT/scripts/fl-detect" "$ROOT")"

grep -Fxq 'DIALECT=AFJ' <<<"$OUTPUT"
grep -Fxq 'FAMILY=AFJ' <<<"$OUTPUT"
grep -Fxq 'RUNNER=none' <<<"$OUTPUT"
grep -Fxq 'EXTENSIONS=.fl' <<<"$OUTPUT"
grep -Fq "$ROOT/tests/native-assert.test.fl" <<<"$OUTPUT"

echo 'detect-native=PASS'
