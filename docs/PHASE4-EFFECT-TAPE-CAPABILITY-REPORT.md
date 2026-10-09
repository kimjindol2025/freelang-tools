# Phase 4 — Effect Tape Capability Report

상태: `PARTIAL_PASS` / Tape capability는 `BLOCKED`

## 구현 범위

- `src/test/effect.fl`
  - `effect-capability`: canonical runtime의 user-level Tape API 상태를 명시
  - `effect-decision`: 기록 불가·사전 차단·사후 관찰 판정을 분리
- `tests/native-effect.test.fl`
  - Tape API 미지원은 `BLOCKED`
  - 기록 불가는 `BLOCKED`
  - `DENY_BEFORE_RUN`은 실행 전 차단
  - 관찰된 일치 effect는 `PASS`
  - 관찰된 위반 effect는 `FAIL`

## Capability 판정

```text
status: BLOCKED
api_available: false
api: trace_effects
reason: canonical runtime exposes no user-level Effect Tape API
```

Phase 0에서 확인한 것처럼 canonical 런타임 내부에는 effect enforcement 계층이
있지만, FreeLang 사용자 코드가 Tape를 시작·조회할 수 있는 공개 API는 확인되지
않았다. 따라서 mock Tape나 가짜 effect entry를 만들지 않았다.

## 실행기

```text
dialect: FreeLang v11 canonical
runtime: /root/freelang-surface-v0-clean-ek3qo2/v11/bootstrap.js
commit: e73c58378a1bb1afb776b7abc4b43eb859006530
```

## 검증 결과

```text
effect.fl: 문법·타입 검사 통과
native-effect.test.fl: 6/6 passed
npm test: FREELANG_TEST=PASS
```

## 판정

Effect 정책 경계는 FreeLang으로 구현·검증했지만 실제 Tape 연결은 아직
`BLOCKED`다. 공개 Tape capability가 추가되면 이 모듈의 capability adapter를
실제 기록·tag·target·argument·순서 비교로 연결해야 한다.
