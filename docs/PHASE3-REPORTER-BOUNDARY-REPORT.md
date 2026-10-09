# Phase 3 — Native Reporter Boundary Report

상태: `PASS`

## 구현 범위

- `src/test/report.fl`
  - `report-summary`: 공통 aggregate에서 안정적인 report schema 생성
  - `report-json`: JSON CI artifact 직렬화
  - `report-text`: 사람이 읽는 단일 요약 문자열 생성
- `tests/native-report.test.fl`
  - PASS 결과의 상태·카운트 보존
  - BLOCKED 결과의 상태 보존
  - JSON 직렬화·역직렬화 왕복
  - 텍스트 보고서의 카운트·상태 노출

## 보고서 계약

reporter는 결과를 PASS로 재해석하지 않는다. `FAIL`, `ERROR`, `BLOCKED`,
`NOT_RUN`은 aggregate에서 받은 상태 그대로 JSON과 텍스트에 반영한다.
프로세스 종료코드 결정은 아직 host bootstrap 경계의 책임으로 남겨둔다.

## 실행기

```text
dialect: FreeLang v11 canonical
runtime: /root/freelang-surface-v0-clean-ek3qo2/v11/bootstrap.js
commit: e73c58378a1bb1afb776b7abc4b43eb859006530
```

## 검증 결과

```text
report.fl: 문법·타입 검사 통과
native-report.test.fl: 5/5 passed
npm test: FREELANG_TEST=PASS
```

검증 중 fixture의 비표준 `def` 사용이 발견되어 canonical 지원 문법인
`define`으로 수정했다. 수정 후 reporter 5/5 및 전체 회귀가 통과했다.

## 판정

결과 schema를 소비하는 FreeLang 네이티브 텍스트·JSON reporter를 확보했다.
아직 Effect Tape capability, AST 수집, 단일 실행 artifact, CI 종료코드
bootstrap은 구현하지 않았다.
