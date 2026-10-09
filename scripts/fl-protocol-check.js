#!/usr/bin/env node
const fs = require("fs");

const [resultPath, exitMarker, processExit] = process.argv.slice(2);
const allowed = new Set(["PASS", "FAIL", "ERROR", "BLOCKED", "NOT_RUN"]);
const required = [
  "schema", "complete", "status", "exit_code", "expected_count", "actual_count",
  "missing_count", "excess_count", "invalid_count", "executed_count", "pass_count",
  "fail_count", "error_count", "blocked_count", "skipped_count", "diagnostic"
];

function fail(message) {
  process.stderr.write(`PROTOCOL_ERROR=${message}\n`);
  process.exit(2);
}

let value;
try {
  value = JSON.parse(fs.readFileSync(resultPath, "utf8"));
} catch (error) {
  fail(`invalid-json:${error.message}`);
}

if (!value || typeof value !== "object" || Array.isArray(value)) fail("result-not-object");
for (const key of required) if (!Object.prototype.hasOwnProperty.call(value, key)) fail(`missing-field:${key}`);
if (value.schema !== "freelang-tools/report/v1") fail("schema-mismatch");
if (value.complete !== true) fail("incomplete-result");
if (!allowed.has(value.status)) fail("unknown-status");
if (typeof value.diagnostic !== "string") fail("invalid-diagnostic");

const countKeys = [
  "expected_count", "actual_count", "missing_count", "excess_count", "invalid_count",
  "executed_count", "pass_count", "fail_count", "error_count", "blocked_count", "skipped_count"
];
for (const key of countKeys) {
  if (!Number.isInteger(value[key]) || value[key] < 0) fail(`invalid-count:${key}`);
}

const expectedExit = value.status === "PASS" ? 0 : value.status === "FAIL" ? 1 : value.status === "NOT_RUN" ? 3 : 2;
if (value.exit_code !== expectedExit || Number(exitMarker) !== expectedExit) fail("exit-code-mismatch");
if (value.actual_count !== value.pass_count + value.fail_count + value.error_count + value.blocked_count + value.skipped_count + value.invalid_count) fail("count-total-mismatch");
if (value.missing_count > 0 && value.excess_count > 0) fail("missing-and-excess");
if (value.status === "PASS" && (value.executed_count < 1 || value.fail_count || value.error_count || value.blocked_count || value.invalid_count || value.missing_count || value.excess_count)) fail("invalid-pass");
if (value.status === "FAIL" && (!value.fail_count || value.error_count || value.blocked_count || value.invalid_count || value.missing_count || value.excess_count)) fail("invalid-fail");
if (value.status === "NOT_RUN" && value.executed_count !== 0) fail("invalid-not-run");

process.stdout.write(`PROTO_STATUS=${value.status}\nPROTO_EXIT_CODE=${expectedExit}\nPROCESS_EXIT=${processExit}\n`);
