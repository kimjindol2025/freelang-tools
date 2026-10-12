#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"

PASS="$($ROOT/scripts/fl-process-native printf '["safe value"]')"
OUTPUT="$PASS" node -e 'const v=JSON.parse(process.env.OUTPUT); if (!v.ok || v.code !== 0 || v.argv[0] !== "safe value") process.exit(1); console.log("process-pass=PASS");'

FAIL="$($ROOT/scripts/fl-process-native definitely-not-a-command '[]')"
OUTPUT="$FAIL" node -e 'const v=JSON.parse(process.env.OUTPUT); if (v.ok || v.status !== "FAIL" || v.code === 0) process.exit(1); console.log("process-fail=PASS");'

MARKER="/tmp/freelang-process-injection-$$"
rm -f "$MARKER"
INJECTION="$($ROOT/scripts/fl-process-native printf "[\"\$(touch $MARKER)\"]" 2>/dev/null || true)"
if [[ -e "$MARKER" ]]; then
  echo "argv injection detected" >&2
  exit 1
fi
rm -f "$MARKER"
echo "argv-safe=PASS"
