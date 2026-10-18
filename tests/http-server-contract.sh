#!/usr/bin/env bash
set -Eeuo pipefail
SCRIPT_PATH="$(readlink -f -- "${BASH_SOURCE[0]}")"
TOOLS_ROOT="$(cd -- "$(dirname -- "$SCRIPT_PATH")/.." && pwd -P)"
TEST_FILE="$TOOLS_ROOT/tests/native-http-server.test.fl"
TEMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/fl-http-native.XXXXXX")"
SERVER_LOG="$TEMP_ROOT/server.log"
BODY_FILE="$TEMP_ROOT/body"
SERVER_PID=""
cleanup() {
  if [[ -n "$SERVER_PID" ]] && kill -0 "$SERVER_PID" 2>/dev/null; then
    kill "$SERVER_PID" 2>/dev/null || true
  fi
  if [[ -n "$SERVER_PID" ]]; then wait "$SERVER_PID" 2>/dev/null || true; fi
  for file in "$SERVER_LOG" "$BODY_FILE"; do
    [[ ! -e "$file" ]] || unlink "$file"
  done
  rmdir -- "$TEMP_ROOT" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

FREELANG_V11_RUNTIME="${FREELANG_V11_RUNTIME:-$HOME/work/fl-8/freelang-v11/runtime}" \
FL_HTTP_SERVER_MODE=YES FL_HTTP_PORT=0 FL_HTTP_MAX_REQUESTS=6 \
  "$TOOLS_ROOT/scripts/fl-cgc-run" "$TEST_FILE" >"$SERVER_LOG" 2>&1 &
SERVER_PID=$!
PORT=""
for _ in {1..100}; do
  if [[ -s "$SERVER_LOG" ]]; then
    PORT="$(sed -n 's/^HTTP_LISTENING=127\.0\.0\.1:\([0-9][0-9]*\)$/\1/p' "$SERVER_LOG" | head -1)"
    [[ -n "$PORT" ]] && break
  fi
  if ! kill -0 "$SERVER_PID" 2>/dev/null; then
    echo 'HTTP_SERVER_TEST=FAIL'
    exit 1
  fi
  sleep 0.05
done
if [[ -z "$PORT" ]]; then
  echo 'HTTP_SERVER_TEST=FAIL'
  exit 1
fi

check_response() {
  local expected_status="$1" expected_body="$2" method="$3" path="$4"
  shift 4
  local actual_status
  actual_status="$(curl --silent --show-error --connect-timeout 2 --max-time 3 \
    --output "$BODY_FILE" --write-out '%{http_code}' --request "$method" "$@" \
    "http://127.0.0.1:$PORT$path")"
  local actual_body
  actual_body="$(<"$BODY_FILE")"
  [[ "$actual_status" == "$expected_status" && "$actual_body" == "$expected_body" ]]
}

check_response 200 '{"ok":true}' GET /health
check_response 200 '{"echo":{"message":"hello"}}' POST /echo \
  --header 'Content-Type: application/json' --data-binary '{"message":"hello"}'
check_response 404 '{"error":"not found"}' GET /missing
check_response 413 '{"error":"payload too large"}' POST /echo \
  --header 'Content-Type: application/json' --data-binary '0123456789012345678901234567890123456789'
check_response 400 '{"error":"invalid JSON"}' POST /echo \
  --header 'Content-Type: application/json' --data-binary '{'
check_response 429 '{"error":"rate limit exceeded"}' GET /health

if ! wait "$SERVER_PID"; then
  echo 'HTTP_SERVER_TEST=FAIL'
  exit 1
fi
SERVER_PID=""
if [[ -n "$(ps -p "$!" -o pid= 2>/dev/null || true)" ]]; then
  echo 'HTTP_SERVER_PROCESSES=1'
  echo 'HTTP_SERVER_TEST=FAIL'
  exit 1
fi
echo 'HTTP_SERVER_TEST=6/6'
echo 'HTTP_SERVER_PROCESSES=0'
echo 'HTTP_SERVER_TEST=PASS'
