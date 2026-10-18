#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
TEMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/freelang-http.XXXXXX")"
PORT_FILE="$TEMP_ROOT/port"
SERVER_PID=""
cleanup() { [[ -n "$SERVER_PID" ]] && kill "$SERVER_PID" 2>/dev/null || true; rm -rf "$TEMP_ROOT"; }
trap cleanup EXIT INT TERM

python3 -c 'import http.server, json, pathlib, sys
class Handler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        body = json.dumps({"ok": True, "route": self.path}, separators=(",", ":")).encode()
        self.send_response(200)
        self.send_header("content-type", "application/json")
        self.send_header("x-freelang", "native")
        self.send_header("content-length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)
    def log_message(self, *_args): pass
server = http.server.HTTPServer(("127.0.0.1", 0), Handler)
pathlib.Path(sys.argv[1]).write_text(str(server.server_port))
server.serve_forever()' "$PORT_FILE" >"$TEMP_ROOT/server.log" 2>&1 &
SERVER_PID=$!
for _ in 1 2 3 4 5 6 7 8 9 10; do
  [[ -s "$PORT_FILE" ]] && break
  kill -0 "$SERVER_PID" 2>/dev/null || { cat "$TEMP_ROOT/server.log" >&2; exit 1; }
  sleep 0.1
done
[[ -s "$PORT_FILE" ]] || { cat "$TEMP_ROOT/server.log" >&2; exit 1; }
PORT="$(<"$PORT_FILE")"
curl -fsS "http://127.0.0.1:$PORT/health" >/dev/null

OUTPUT="$($ROOT/scripts/fl-http-native "http://127.0.0.1:$PORT/health")"
source "$ROOT/tests/native-json-check.sh"
assert_native_json http "$OUTPUT"
echo "http-loopback=PASS"
