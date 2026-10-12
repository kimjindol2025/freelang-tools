#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
TEMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/freelang-http.XXXXXX")"
PORT_FILE="$TEMP_ROOT/port"
SERVER_PID=""
cleanup() { [[ -n "$SERVER_PID" ]] && kill "$SERVER_PID" 2>/dev/null || true; rm -rf "$TEMP_ROOT"; }
trap cleanup EXIT INT TERM

node -e 'const fs=require("fs"),http=require("http"); const server=http.createServer((req,res)=>{res.writeHead(200,{"content-type":"application/json","x-freelang":"native"}); res.end(JSON.stringify({ok:true,route:req.url}));}); server.listen(0,"127.0.0.1",()=>fs.writeFileSync(process.argv[1],String(server.address().port)));' "$PORT_FILE" >"$TEMP_ROOT/server.log" 2>&1 &
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
OUTPUT="$OUTPUT" node -e '
const value=JSON.parse(process.env.OUTPUT);
if (value.schemaVersion !== "freelang.http/v1" || value.ok !== true || value.status !== 200 || !value.data || value.data.ok !== true) process.exit(1);
console.log("http-loopback=PASS");
'
