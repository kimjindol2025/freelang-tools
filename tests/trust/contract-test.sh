#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_PATH="$(readlink -f -- "${BASH_SOURCE[0]}")"
ROOT="$(cd -- "$(dirname -- "$SCRIPT_PATH")/../.." && pwd -P)"
SELF_JSON="$(mktemp)"
cleanup() { rm -f "$SELF_JSON"; }
trap cleanup EXIT INT TERM

"$ROOT/scripts/fl-tools" trust "$ROOT" > "$SELF_JSON"
node - "$SELF_JSON" <<'NODE'
const fs = require('fs');
const value = JSON.parse(fs.readFileSync(process.argv[2], 'utf8'));
if (value.schemaVersion !== 'freelang.trust/v1' || value.verdict !== 'TRUSTED') process.exit(1);
for (const gate of ['check', 'test', 'review', 'evidence', 'diffCheck', 'capabilityCoverage']) {
  if (!(gate in value.gates)) process.exit(1);
}
if (!Array.isArray(value.evidence.commands) || !Array.isArray(value.limitations) ||
    value.decision?.source !== 'freelang-native' || value.decision?.command !== 'trust-core') process.exit(1);
console.log('TRUST_CONTRACT=PASS');
NODE
