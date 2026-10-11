# Changelog

## v0.2.0 — AI-native FreeLang tools gate

### TECHNICAL_BASELINE

- FreeLang capability probe and native CLI decision core added.
- Handoff and evidence outputs expose machine-readable contracts.
- Review includes native inspect and deploy contracts remain dirty-worktree safe.

### RELEASE_COMMIT

- Set by the release commit that contains this changelog entry.

### KNOWN_LIMITS

- Git API, directory walk, JSON Schema execution, and process timeout remain explicit adapter/runtime boundaries.
- The current checkout may be dirty during development; deployment requires a clean fixed commit.

### REGRESSION_RESULT

- AFJ FreeLang tests: PASS
- `fl-tools review`: PASS
- deploy fixture: requires clean worktree or explicit fixture override

### ARTIFACT_HASH

- Produced by the project deploy contract at release time.
