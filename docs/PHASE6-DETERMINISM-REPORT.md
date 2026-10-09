# Phase 6 — Deterministic Comparison Report

상태: `IMPLEMENTED`

## 변경

- `scripts/fl-determinism`을 추가했다.
- 같은 FreeLang 입력을 두 개의 독립 evidence directory에서 각각 한 번씩
  실행한다.
- 두 실행의 shell exit code와 최종 JSON을 비교한다.
- 비교기는 duration·PID·timestamp 등 실행 메타데이터만 제거한다.
- status·카운트·diagnostic·assertion/effect 값과 배열 순서는 보존·비교한다.

`fl-determinism` 자체는 결정론 검증 도구이며, 각 내부 `fl-ci` invocation은
테스트를 한 번만 실행한다. 비교 실패는 exit 2이며 두 evidence 경로를
출력한다.
