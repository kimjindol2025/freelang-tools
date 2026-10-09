#!/usr/bin/env bash
set -u

TOOLS_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd -P)"
CLI="$TOOLS_ROOT/scripts/fl-ci"
timeout_dir="$(mktemp -d "${TMPDIR:-/tmp}/freelang-cli-timeout.XXXXXX")"
signal_dir="$(mktemp -d "${TMPDIR:-/tmp}/freelang-cli-signal.XXXXXX")"

set +e
FREELANG_CLI_EVIDENCE_DIR="$timeout_dir" "$CLI" "$TOOLS_ROOT/tests/cli/timeout.fl" 1 >/dev/null 2>&1
timeout_exit=$?
FREELANG_CLI_EVIDENCE_DIR="$signal_dir" FREELANG_AFJ_RUNNER="$TOOLS_ROOT/tests/cli/signal-runner.js" \
  "$CLI" "$TOOLS_ROOT/tests/cli/pass.fl" >/dev/null 2>&1
signal_exit=$?
set -e

[[ "$timeout_exit" -eq 2 ]]
[[ "$signal_exit" -eq 2 ]]
grep -F 'CAUSE=TIMEOUT' "$timeout_dir/process.meta" >/dev/null
grep -F 'RUN_CLEANUP=TERM_THEN_KILL' "$timeout_dir/process.meta" >/dev/null
grep -F 'RUN_RESIDUAL=0' "$timeout_dir/process.meta" >/dev/null
grep -F 'CAUSE=SIGNAL:15' "$signal_dir/process.meta" >/dev/null
grep -F 'RUN_CLEANUP=TERM_THEN_KILL' "$signal_dir/process.meta" >/dev/null
grep -F 'RUN_RESIDUAL=0' "$signal_dir/process.meta" >/dev/null

echo "CLI_ISOLATION timeout_exit=$timeout_exit signal_exit=$signal_exit residual=0"
