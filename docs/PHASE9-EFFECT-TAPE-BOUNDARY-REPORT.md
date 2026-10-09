# Phase 9 — Effect Tape Runtime Boundary Report

기준 HEAD: `e4bbc8f` (`main`, Phase 9 probe 시작 시 clean)

고정 runtime:

```text
runtime: /root/freelang-surface-v0-clean-ek3qo2/v11/bootstrap.js
runtime commit: e73c58378a1bb1afb776b7abc4b43eb859006530
```

## 구현 범위

- `src/test/effect-runtime.fl`
  - public Effect Tape capability를 확인
  - capability가 `BLOCKED`면 body를 실행하지 않음
  - capability diagnostic을 보존
- `tests/native-effect-runtime.test.fl`
  - Tape 미지원 → `BLOCKED`
  - body 미실행
  - `trace_effects` 진단 보존
- `tests/capability/effect-tape-probe.fl`
  - 고정 runtime에 `trace_effects` 직접 호출
  - probe body가 실행되기 전에 공개 API 지원 여부를 확인
- `scripts/fl-effect-capability` / `tests/capability/effect-tape-probe.sh`
  - check/run stdout·stderr와 실제 종료코드 보존
  - 성공적인 실행만 지원 증거로 인정하며, 실패를 PASS로 변환하지 않음

## 판정

canonical runtime 내부 effect enforcement는 존재하지만 FreeLang 사용자 영역의
공개 `trace_effects`/Tape API는 확인되지 않았다. 따라서 실제 effect entry를
생성하거나 Tape가 있다고 가정하지 않았다. 현재 `fl-effect` runtime 연결은
`BLOCKED`다.

직접 probe 결과도 동일하다. `check`는 `0`이지만 `run`은 `1`이며,
runtime은 `trace_effects`를 찾지 못해 종료한다. `ls-fns trace`에서 확인되는
공개 함수는 `trace_expr` 하나뿐이고, 이것을 Effect Tape로 간주하지 않는다.
probe body 출력이 없으므로 미지원 상태에서 실행을 진행하지 않은 것도 확인된다.

## 검증

```text
effect-runtime.fl check: exit 0
native-effect-runtime.test.fl: 3/3 passed, exit 0
test:effect-capability: exit 0 (probe itself is BLOCKED by contract)
npm test: FREELANG_TEST=PASS, exit 0
```

판정은 `BLOCKED`다. Effect Tape가 추가되기 전까지 이 boundary를 PASS로
완화하지 않고 CI 결과에도 `BLOCKED`로 전파해야 한다. 다음 단계는 Phase 10
release gate이며, 실제 Tape 구현은 별도 runtime 변경 없이는 완료로 주장하지 않는다.
