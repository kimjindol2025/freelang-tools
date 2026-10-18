#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_PATH="$(readlink -f -- "${BASH_SOURCE[0]}")"
ROOT="$(cd -- "$(dirname -- "$SCRIPT_PATH")/../.." && pwd -P)"
export FL_TOOLS_DISPATCH_ROOT="$ROOT"
SELF_JSON="$(mktemp)"
cleanup() { rm -f "$SELF_JSON"; }
trap cleanup EXIT INT TERM
source "$ROOT/tests/native-json-check.sh"

"$ROOT/scripts/fl-tools" trust "$ROOT" > "$SELF_JSON"
assert_native_json trust "$(<"$SELF_JSON")"
echo 'TRUST_CONTRACT=PASS'

AI_JSON="$("$ROOT/scripts/fl-tools" ai ready "$ROOT")"
assert_native_json ai-ready "$AI_JSON"
echo 'AI_PROTOCOL=PASS'
