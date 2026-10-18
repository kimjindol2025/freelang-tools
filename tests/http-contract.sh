#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
bash "$ROOT/tests/http-server-contract.sh"
echo "http-loopback=PASS"
