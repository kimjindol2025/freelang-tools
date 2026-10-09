# Phase 5 — Timeout and Signal Isolation Report

상태: `IMPLEMENTED`

## 변경

- check/run 프로세스를 별도 session/process group에서 실행한다.
- timeout·signal·비정상 종료 시 해당 process group에 TERM을 보내고 잔여
  프로세스가 있으면 KILL을 보낸다.
- process group ID, cleanup 정책, 잔여 여부를 `process.meta`와
  `evidence-manifest.json`에 기록한다.
- 원래 종료코드와 원인은 기존 계약대로 보존한다.
- timeout fixture는 shell exit 2와 `CAUSE=TIMEOUT`을, signal fixture는 shell
  exit 2와 `CAUSE=SIGNAL:15`를 실제로 검증한다.

## 제한

프로세스 group cleanup은 host 감독 책임이며 FreeLang 판정을 변경하지 않는다.
정상 완료는 cleanup을 시도하지 않고, timeout·signal은 `BLOCKED` 또는
`ERROR` 계약으로 PASS를 허용하지 않는다.
