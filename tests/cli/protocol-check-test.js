#!/usr/bin/env node
const assert = require("node:assert/strict");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const { spawnSync } = require("node:child_process");

const root = path.resolve(__dirname, "../..");
const checker = path.join(root, "scripts/fl-protocol-check.js");
const scratch = fs.mkdtempSync(path.join(os.tmpdir(), "fl-protocol-"));
const base = {
  schema: "freelang-tools/report/v1", complete: true, status: "PASS", exit_code: 0,
  expected_count: 1, actual_count: 1, missing_count: 0, excess_count: 0, invalid_count: 0,
  executed_count: 1, pass_count: 1, fail_count: 0, error_count: 0, blocked_count: 0,
  skipped_count: 0, diagnostic: ""
};

function check(name, patch, expectedExit) {
  const resultPath = path.join(scratch, `${name}.json`);
  fs.writeFileSync(resultPath, JSON.stringify({ ...base, ...patch }));
  const child = spawnSync(process.execPath, [checker, resultPath, "0", "0"], { encoding: "utf8" });
  assert.equal(child.status, expectedExit, `${name}: ${child.stderr}`);
}

try {
  check("valid-pass", {}, 0);
  check("empty-forged-pass", {
    expected_count: 0, actual_count: 0, executed_count: 1, pass_count: 0
  }, 2);
  check("count-mismatch", { executed_count: 1, pass_count: 0 }, 2);
  check("unaccounted-expected", { expected_count: 2 }, 2);
  check("all-skipped-pass", {
    actual_count: 1, executed_count: 0, pass_count: 0, skipped_count: 1
  }, 2);
  process.stdout.write("PROTOCOL_CHECK_CASES=5 PASS\n");
} finally {
  fs.rmSync(scratch, { recursive: true, force: true });
}
