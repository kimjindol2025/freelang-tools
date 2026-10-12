#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AFJ_ROOT="${FREELANG_AFJ_ROOT:-/home/kim/kim/platform/freelang-afj}"
C_FILE="$(mktemp /tmp/fl-tools-native.XXXXXX.c)"
trap 'rm -f "$C_FILE"' EXIT

"$AFJ_ROOT/bin/cgc-bin" "$ROOT/native/tools-cli.fl" "$C_FILE"
bash "$AFJ_ROOT/scripts/build-general-program.sh" "$C_FILE" "$ROOT/scripts/fl-native-cli"
cp "$ROOT/scripts/fl-native-cli" "$ROOT/scripts/fl-tools"
chmod +x "$ROOT/scripts/fl-native-cli" "$ROOT/scripts/fl-tools"
echo "FL_TOOLS_NATIVE_BUILD=PASS"
