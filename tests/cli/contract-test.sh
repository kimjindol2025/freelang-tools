#!/usr/bin/env bash
set -u

TOOLS_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd -P)"
CLI="$TOOLS_ROOT/scripts/fl-ci"
passed=0
failed=0

run_case() {
  local name="$1"
  local target="$2"
  local expected="$3"
  local actual

  if "$CLI" "$TOOLS_ROOT/$target" >/tmp/freelang-cli-contract-out.$$ 2>/tmp/freelang-cli-contract-err.$$; then
    actual=0
  else
    actual=$?
  fi

  if [[ "$actual" -eq "$expected" ]]; then
    echo "PASS $name exit=$actual"
    passed=$((passed + 1))
  else
    echo "FAIL $name expected=$expected actual=$actual" >&2
    failed=$((failed + 1))
  fi
}

trap 'rm -f /tmp/freelang-cli-contract-out.$$ /tmp/freelang-cli-contract-err.$$' EXIT

run_case "pass" tests/cli/pass.fl 0
run_case "assertion-fail" tests/cli/fail.fl 1
run_case "runtime-error" tests/cli/error.fl 2
run_case "effect-blocked" tests/cli/blocked.fl 2
run_case "not-run" tests/cli/not-run.fl 3
run_case "broken-final-json" tests/cli/broken.fl 2
run_case "duplicate-final-result" tests/cli/duplicate.fl 2
run_case "incomplete-final-protocol" tests/cli/incomplete.fl 2
run_case "process-error" tests/cli/process-error.fl 2
run_case "pass-process-error" tests/cli/pass-process-error.fl 2
run_case "missing-target" tests/cli/missing.fl 2

echo "CLI_CONTRACT passed=$passed failed=$failed"
[[ "$failed" -eq 0 ]]
