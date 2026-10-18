#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
OUTPUT="$("$ROOT/scripts/fl-detect" "$ROOT")"

grep -Fxq 'DIALECT=TOOLS' <<<"$OUTPUT"
grep -Fxq 'FAMILY=FREELANG_TOOLS' <<<"$OUTPUT"
grep -Fxq "RUNNER=$ROOT/scripts/fl-tools" <<<"$OUTPUT"
grep -Fxq 'EXTENSIONS=.fl' <<<"$OUTPUT"
grep -Fq "$ROOT/tests/native-assert.test.fl" <<<"$OUTPUT"

echo 'detect-native=PASS'
