# Phase 0 Capability Report

상태: `PARTIAL_PASS`

## 고정 실행기

```text
dialect: FreeLang v11 canonical
runtime: /root/freelang-surface-v0-clean-ek3qo2/v11/bootstrap.js
commit: e73c58378a1bb1afb776b7abc4b43eb859006530
fixture: tests/capability/runtime-capability.fl
```

## 실행 명령

```bash
node /root/freelang-surface-v0-clean-ek3qo2/v11/bootstrap.js \
  check /root/kilo-freelang/projects/freelang-tools/tests/capability/runtime-capability.fl

cd /root/kilo-freelang/projects/freelang-tools/tests/capability
node /root/freelang-surface-v0-clean-ek3qo2/v11/bootstrap.js run runtime-capability.fl
```

## 실제 결과

```text
CHECK_EXIT=0
✓ runtime-capability.fl 문법 이상 없음

RUN_EXIT=0
CAP_FUNCTION=5
CAP_MODULE=PASS
CAP_EXCEPTION=PASS
CAP_EFFECT_TAPE=BLOCKED
```

## 판정

| Capability | 판정 | 근거 |
|---|---|---|
| 함수 등록·호출 | PASS | `phase0_add 2 3` → `5` |
| 모듈 로딩 | PASS | `(load "module.fl")` 후 함수 호출 성공 |
| 예외 포착 | PASS | `throw`를 `try/catch`로 포착 |
| Effect Tape 사용자 API | BLOCKED | `trace_effects`/Tape 호출 API를 canonical FreeLang 사용자 영역에서 확인하지 못함 |
| Effect Enforcement 내부 계층 | OBSERVED, NOT USER API | runtime 내부 TypeScript effect enforcement 소스는 존재하지만 FreeLang 테스트가 직접 Tape를 조회할 수 있다는 증거는 없음 |

## 다음 조치

Effect Tape는 임의의 mock API로 구현하지 않는다. Phase 0에서 canonical runtime의
공식 노출 경계가 추가로 확인될 때까지 `fl-effect` native 구현은 `BLOCKED` 계약을
유지한다. 다음 구현 가능한 순서는 공통 결과 schema와 `fl-jest`의 순수 assertion
core다.
