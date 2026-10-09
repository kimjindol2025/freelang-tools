# Phase 7 — Native Executor Report

기준 HEAD: `60a5906` (`main`, 작업 시작 시 clean)

고정 runtime:

```text
runtime: /root/freelang-surface-v0-clean-ek3qo2/v11/bootstrap.js
runtime commit: e73c58378a1bb1afb776b7abc4b43eb859006530
```

## 구현 범위

- `src/test/executor.fl`
  - collector plan의 selected body를 한 번씩 호출
  - assertion map의 `PASS`/`FAIL`/`BLOCKED` 보존
  - 호출 오류는 문자열 추측 없이 `ERROR`와 원본 Result diagnostic으로 보존
  - invalid declaration과 empty filter를 기존 aggregate에 연결
- `tests/native-executor.test.fl`
  - pass assertion
  - fail assertion actual/expected 보존
  - blocked matcher 보존
  - body runtime error → ERROR
  - selected cases aggregate
  - empty selection → NOT_RUN
  - invalid declaration → ERROR

## canonical runtime 보정

`map execute-case selected` 형태는 이 runtime에서 함수 인자를 안정적으로
호출하지 않아 body 결과가 기본 PASS처럼 보일 수 있었다. 이 경로는 명시적
`(fn [entry] (execute-case entry))` lambda로 고정했으며, 수정 후 fail case가
실제 `FAIL` aggregate로 집계되는 것을 확인했다.

## 검증

```text
executor.fl check: exit 0
native-executor.test.fl: 7/7 passed, exit 0
npm test: FREELANG_TEST=PASS, exit 0
```

## 범위 제한

이번 단계는 selected body의 단일 호출과 결과 변환만 완료했다. state isolation,
before_each, timeout의 executor 내부 전달, Effect Tape boundary, immutable
artifact 공유는 다음 단계로 남긴다. 실제 Tape 지원도 여전히 `BLOCKED`다.
