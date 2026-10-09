#!/usr/bin/env node
if (process.argv[2] === "check") process.exit(0);
process.kill(process.pid, "SIGTERM");
