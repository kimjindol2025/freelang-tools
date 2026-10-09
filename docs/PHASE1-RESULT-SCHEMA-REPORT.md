# Phase 1 — Native Result Schema Report

상태: `PASS`

## 구현 범위

- `src/test/result.fl`
  - `test-result`: 개별 결과 생성
  - `result-count`: 상태별 집계
  - `result-aggregate`: 전체 실행 상태·카운트 계산
- `tests/native-result.test.fl`
  - PASS
  - FAIL
  - ERROR 우선
  - BLOCKED
  - 빈 실행 NOT_RUN
  - 전부 SKIPPED NOT_RUN
  - 결과 누락 ERROR

## 실행기

```text
dialect: FreeLang v11 canonical
runtime: /root/freelang-surface-v0-clean-ek3qo2/v11/bootstrap.js
commit: e73c58378a1bb1afb776b7abc4b43eb859006530
```

## 검증 명령

```bash
node /root/freelang-surface-v0-clean-ek3qo2/v11/bootstrap.js \
  check src/test/result.fl

cd tests
node /root/freelang-surface-v0-clean-ek3qo2/v11/bootstrap.js \
  check native-result.test.fl
node /root/freelang-surface-v0-clean-ek3qo2/v11/bootstrap.js \
  run native-result.test.fl
```

## 실제 결과

```text
result.fl: 문법 이상 없음
native-result.test.fl: 문법 이상 없음
Test Results: 7/7 passed
```

canonical runtime의 meta-check가 함수 metadata 부재 경고를 출력하지만 type-check는
통과했다. 이 단계에서는 metadata 계약을 아직 구현하지 않았으므로 경고를 PASS로
숨기지 않고 다음 assertion 단계의 보완 항목으로 남긴다.

## 판정

결과 schema의 상태 집계는 구현·실행·검증되었다. 아직 assertion matcher, AST 수집,
Effect Tape, CLI 종료 코드, 단일 실행 artifact는 구현하지 않았다.
