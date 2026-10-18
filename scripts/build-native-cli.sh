#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CGC="${ROOT}/scripts/cgc-native"
V11_RUNTIME="${FREELANG_V11_RUNTIME:-$HOME/work/fl-8/freelang-v11/runtime}"
C_FILE="$(mktemp /tmp/fl-tools-native.XXXXXX.c)"
trap 'rm -f "$C_FILE"' EXIT

(cd "$ROOT/native" && "$CGC" tools-cli.fl "$C_FILE")
gcc -I "$V11_RUNTIME" -o "$ROOT/scripts/fl-native-cli" "$C_FILE" \
  "$V11_RUNTIME/core.c" "$V11_RUNTIME/collection.c" "$V11_RUNTIME/io.c" \
  "$V11_RUNTIME/math.c" "$V11_RUNTIME/error.c" "$V11_RUNTIME/process.c" \
  "$V11_RUNTIME/json.c" "$V11_RUNTIME/cgc-bridge.c" -lm
cp "$ROOT/scripts/fl-native-cli" "$ROOT/scripts/fl-tools"
chmod +x "$ROOT/scripts/fl-native-cli" "$ROOT/scripts/fl-tools"
echo "FL_TOOLS_NATIVE_BUILD=PASS"
