#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
TEMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/freelang-system-json.XXXXXX")"
trap 'rm -rf "$TEMP_ROOT"' EXIT INT TERM

source "$ROOT/tests/native-json-check.sh"
check_pass() { local output="$1" operation="$2"; OPERATION="$operation" assert_native_json system-json "$output"; echo "$operation=PASS"; }

check_pass "$($ROOT/scripts/fl-system-json write "$TEMP_ROOT" "$TEMP_ROOT/value.json" '{"ok":true}')" write
check_pass "$($ROOT/scripts/fl-system-json exists "$TEMP_ROOT" "$TEMP_ROOT/value.json")" exists
check_pass "$($ROOT/scripts/fl-system-json read "$TEMP_ROOT" "$TEMP_ROOT/value.json")" read
check_pass "$($ROOT/scripts/fl-system-json list "$TEMP_ROOT" "$TEMP_ROOT")" list
check_pass "$($ROOT/scripts/fl-system-json parse "$TEMP_ROOT" "$TEMP_ROOT/value.json" '{"n":1}')" parse
check_pass "$($ROOT/scripts/fl-system-json stringify "$TEMP_ROOT" "$TEMP_ROOT/value.json" '[1,2,3]')" stringify
DENIED="$($ROOT/scripts/fl-system-json read "$TEMP_ROOT" /etc/passwd)"
assert_native_json system-json-denied "$DENIED"
echo "permission-deny=PASS"
