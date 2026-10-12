#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
STATUS_OUTPUT="$($ROOT/scripts/fl-tools status "$ROOT")"
grep -Fxq 'GIT=dirty' <<<"$STATUS_OUTPUT"
grep -Fxq 'TEST=PASS' <<<"$STATUS_OUTPUT"

UNKNOWN_OUTPUT=""
if UNKNOWN_OUTPUT="$($ROOT/scripts/fl-tools not-a-command 2>&1)"; then
  echo 'unknown command unexpectedly passed' >&2
  exit 1
fi
grep -Fq 'freelang.tools-cli/v1' <<<"$UNKNOWN_OUTPUT"
grep -Fq '"status":"BLOCKED"' <<<"$UNKNOWN_OUTPUT"

echo 'cli-dispatch-native=PASS'
