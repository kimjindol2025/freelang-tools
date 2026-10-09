# Phase 2 — Single Execution Orchestration Report

상태: `IMPLEMENTED`

## 변경

- `scripts/fl-ci`를 공식 native CI 진입점으로 추가했다.
- `fl-ci`는 자체 실행 로직을 갖지 않고 `fl-cli`를 정확히 한 번 `exec`한다.
- `fl-cli`가 syntax check, 단일 target run, final protocol validation,
  evidence 보존, shell exit code 전달을 소유한다.
- `package.json`에 `npm run ci`를 추가했다.

## 단일 실행 계약

```text
fl-ci target
  -> fl-cli target (one process boundary)
     -> check target
     -> run target once
     -> validate one final result
     -> return final exit code
```

reporter나 evidence 생성 때문에 target을 재실행하지 않는다. `check`는
syntax capability 검사이며 테스트 body를 실행하지 않는다.

## 다음 단계

최종 JSON과 raw stdout/stderr 보존을 별도 Phase 3에서 확장한다. Effect Tape
지원 여부는 이 단계에서 변경하지 않는다.
