# Phase 2 — Native Assertion Core Report

상태: `PASS`

## 구현 범위

- `src/test/assert.fl`
  - `to_be`: 값 동일성 판정
  - `to_equal`: 구조 값 비교
  - `to_contain`: 리스트·문자열 포함 판정
  - `to_throw`: `try-call` 기반 예외 발생 판정
  - 모든 matcher는 실행 결과를 직접 출력하지 않고 assertion 자료구조를 반환
- `tests/native-assert.test.fl`
  - 성공·실패 matcher 결과
  - 중첩 구조 비교
  - 포함·미포함 판정
  - 예외 발생·정상 반환 구분

## 공통 Assertion 계약

각 matcher는 다음 구조를 반환한다.

```text
{
  "schema": "freelang-tools/assertion/v1",
  "status": "PASS | FAIL",
  "matcher": "to_be | to_equal | to_contain | to_throw",
  "actual": ...,
  "expected": ...,
  "message": "..."
}
```

판정은 FreeLang 값으로 보존되며, 결과 집계·리포터가 이를 소비한다. 실제 값과
기대 값은 결정론 비교를 위해 정규화하거나 삭제하지 않는다.

## 실행기

```text
dialect: FreeLang v11 canonical
runtime: /root/freelang-surface-v0-clean-ek3qo2/v11/bootstrap.js
commit: e73c58378a1bb1afb776b7abc4b43eb859006530
```

## 검증 명령

```bash
node /root/freelang-surface-v0-clean-ek3qo2/v11/bootstrap.js check src/test/assert.fl
node /root/freelang-surface-v0-clean-ek3qo2/v11/bootstrap.js check tests/native-assert.test.fl
node /root/freelang-surface-v0-clean-ek3qo2/v11/bootstrap.js run tests/native-assert.test.fl
npm test
```

## 실제 결과

```text
assert.fl: 문법·타입 검사 통과
native-assert.test.fl: 문법 검사 통과
Test Results: 7/7 passed
npm test: FREELANG_TEST=PASS
```

canonical runtime의 metadata 경고는 기존 단계와 동일하게 표시되며, 오류로
숨기지 않았다. metadata 계약은 reporter boundary 단계의 후속 항목이다.

## 판정

FreeLang 함수와 표준 `try-call`만으로 핵심 matcher를 구현하고 검증했다. 아직
AST 기반 테스트 수집, 단일 실행 artifact, Effect Tape, CLI 종료 코드·리포터는
구현하지 않았다.
