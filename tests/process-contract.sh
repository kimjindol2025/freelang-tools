#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"

PASS="$($ROOT/scripts/fl-process-native printf '["safe value"]')"
source "$ROOT/tests/native-json-check.sh"
assert_native_json process-pass "$PASS"
echo "process-pass=PASS"

FAIL="$($ROOT/scripts/fl-process-native definitely-not-a-command '[]' || true)"
assert_native_json process-fail "$FAIL"
echo "process-fail=PASS"

MARKER="/tmp/freelang-process-injection-$$"
rm -f "$MARKER"
INJECTION="$($ROOT/scripts/fl-process-native printf "[\"\$(touch $MARKER)\"]" 2>/dev/null || true)"
if [[ -e "$MARKER" ]]; then
  echo "argv injection detected" >&2
  exit 1
fi
rm -f "$MARKER"
echo "argv-safe=PASS"
