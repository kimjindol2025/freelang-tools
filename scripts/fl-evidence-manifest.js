#!/usr/bin/env node
const fs = require("fs");
const path = require("path");

const [evidenceDir, processExit = "2"] = process.argv.slice(2);
if (!evidenceDir) process.exit(2);

function readJson(file) {
  try {
    return JSON.parse(fs.readFileSync(path.join(evidenceDir, file), "utf8"));
  } catch {
    return null;
  }
}

function readMeta() {
  const result = {};
  try {
    for (const line of fs.readFileSync(path.join(evidenceDir, "process.meta"), "utf8").split(/\r?\n/)) {
      const split = line.indexOf("=");
      if (split > 0) result[line.slice(0, split)] = line.slice(split + 1);
    }
  } catch {
    result.META_READ_ERROR = true;
  }
  return result;
}

const files = fs.existsSync(evidenceDir)
  ? fs.readdirSync(evidenceDir).filter((name) => fs.statSync(path.join(evidenceDir, name)).isFile()).sort()
  : [];
const finalResult = readJson("final-result.json");
const meta = readMeta();
const manifest = {
  schema: "freelang-tools/evidence-manifest/v1",
  complete: true,
  evidence_dir: evidenceDir,
  process_exit: Number(processExit),
  final_status: finalResult?.status ?? null,
  final_exit_code: finalResult?.exit_code ?? null,
  result_file: files.includes("final-result.json") ? "final-result.json" : null,
  raw_stdout: files.includes("stdout.log") ? "stdout.log" : null,
  raw_stderr: files.includes("stderr.log") ? "stderr.log" : null,
  metadata_file: files.includes("process.meta") ? "process.meta" : null,
  files,
  tool_head: meta.TOOL_HEAD ?? null,
  runtime: meta.RUNTIME ?? null,
  runtime_commit: meta.RUNTIME_COMMIT ?? null,
  target: meta.TARGET ?? null,
  check_exit: meta.CHECK_EXIT === undefined ? null : Number(meta.CHECK_EXIT),
  run_exit: meta.RUN_EXIT === undefined ? null : Number(meta.RUN_EXIT),
  cause: meta.CAUSE ?? null,
};

fs.writeFileSync(path.join(evidenceDir, "evidence-manifest.json"), `${JSON.stringify(manifest)}\n`);
