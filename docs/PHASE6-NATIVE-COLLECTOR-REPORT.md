# Phase 6 — Native Collector Plan Report

기준 HEAD: `e212740` (`main`, 작업 시작 시 clean)

고정 runtime:

```text
runtime: /root/freelang-surface-v0-clean-ek3qo2/v11/bootstrap.js
runtime commit: e73c58378a1bb1afb776b7abc4b43eb859006530
```

## 구현 범위

- `src/test/collector.fl`
  - FreeLang collector-case schema
  - declaration 필드·타입·범위 검증
  - 고정 `order` 정렬
  - suite/name filter
  - duplicate·invalid declaration 판정
  - 선택 0건 `NOT_RUN`
- `tests/native-collector.test.fl`
  - 순서 결정성
  - filter 선택 수
  - suite/name key
  - 빈 선택
  - duplicate·invalid 입력

## 중요한 경계

canonical runtime의 `deftest`는 등록 후 대기하는 collector가 아니라 선언 시
즉시 body를 실행한다. 따라서 이번 단계에서 `deftest`를 가로채거나 기존
`run-tests`를 복제하지 않았다. `collector.fl`은 body function을 자료구조로
보존하는 수집 계획만 만들며 body를 실행하지 않는다.

```text
collector plan → 다음 단계의 executor
```

실행 격리, before_each, 단일 실행 artifact, 종료코드 연결은 이미 구현된 CLI
경계와 다음 executor 단계의 책임이며 이번 단계에서 완료로 주장하지 않는다.

## 검증

```text
collector.fl check: exit 0
native-collector.test.fl: 6/6 passed, exit 0
npm test: FREELANG_TEST=PASS, exit 0
```

canonical runtime metadata warning은 기존 정책대로 숨기지 않았다.

## 판정

FreeLang-native 수집 계획의 입력 검증과 결정론적 선택은 완료했다. 실제 source
AST discovery와 test body 실행은 아직 구현하지 않았으며, collector body를
실행하지 않은 것이 의도된 범위다.
