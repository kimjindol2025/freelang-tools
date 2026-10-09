# Phase 8 — Execution Isolation Contract Report

기준 HEAD: `60a5906` (`main`, 작업 시작 시 clean)

고정 runtime:

```text
runtime: /root/freelang-surface-v0-clean-ek3qo2/v11/bootstrap.js
runtime commit: e73c58378a1bb1afb776b7abc4b43eb859006530
```

## 구현 범위

- `src/test/isolation.fl`
  - case별 명시적 initial/current state context
  - reset 필요 표시와 reset count
  - state leak·invalid context 검출
  - empty selection `NOT_RUN`
- `tests/native-isolation.test.fl`
  - case별 초기 상태 보존
  - READY 상태
  - reset 후 state 복원
  - state leak·invalid 입력 `ERROR`
  - empty selection `NOT_RUN`

## runtime 보정

canonical runtime에서 함수 매개변수 `contexts`가 호출 파일의 전역 변수명과
충돌해 전달된 목록 대신 전역 목록을 참조하는 현상이 확인됐다. 매개변수를
`context_list`로 변경해 실제 입력을 검증하도록 했다.

또한 runtime snapshot/restore capability를 확인하지 못했으므로, `state_leaked`
표시는 명시적 context 계약의 상태이며 자동 runtime snapshot을 가장하지 않는다.

## 검증

```text
isolation.fl check: exit 0
native-isolation.test.fl: 6/6 passed, exit 0
npm test: FREELANG_TEST=PASS, exit 0
```

## 범위 제한

이번 단계는 isolation context 계약과 누수 판정만 완료했다. 실제 전역 runtime
state snapshot/restore, before_each 실행, Effect Tape boundary, 병렬 격리는
아직 구현하지 않았다.
