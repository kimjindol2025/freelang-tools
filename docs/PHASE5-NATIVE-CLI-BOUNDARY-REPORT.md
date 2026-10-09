# Phase 5 — Native CLI Boundary Report

기준 HEAD: `1bc300937e2fc0443128ceb9efef909e13b926a6`

작업 후 브랜치: `main`

고정 runtime:

```text
runtime: /root/freelang-surface-v0-clean-ek3qo2/v11/bootstrap.js
runtime commit: e73c58378a1bb1afb776b7abc4b43eb859006530
```

## 구현

- `src/test/cli.fl`
  - FreeLang이 최종 JSON·종료코드·완료 marker를 한 번 생성
- `scripts/fl-cli`
  - check는 사전 검증, run은 한 번만 실행
  - raw stdout/stderr, check 로그, process metadata, final-result.json 보존
  - timeout·signal·프로세스 오류를 성공으로 숨기지 않음
  - 로그의 PASS 문구나 건수는 판정에 사용하지 않음
- `scripts/fl-protocol-check.js`
  - 결과 envelope의 JSON/schema/필수 카운트/완료 표시를 검증
  - FreeLang이 계산한 `exit_code`와 marker 일치 여부 검증
  - aggregate의 상태 의미와 집계는 FreeLang 결과가 소유
- `package.json`
  - `npm run cli -- <file>` 진입점 추가

## 실제 shell 종료코드

| Fixture | 실제 종료코드 | 결과 |
|---|---:|---|
| `tests/cli/pass.fl` | 0 | PASS |
| `tests/cli/fail.fl` | 1 | FAIL |
| `tests/cli/error.fl` | 2 | ERROR |
| `tests/cli/blocked.fl` | 2 | BLOCKED |
| `tests/cli/not-run.fl` | 3 | NOT_RUN |
| `tests/cli/broken.fl` | 2 | 깨진 JSON |
| `tests/cli/process-error.fl` | 2 | 최종 결과 누락·프로세스 오류 |
| `tests/cli/pass-process-error.fl` | 2 | PASS 결과 + process exit 1 충돌 |
| `tests/cli/timeout.fl` | 2 | timeout (`CHECK_EXIT=124`) |
| signal runner | 2 | `RUN_EXIT=143`, `CAUSE=SIGNAL:15` |

PASS 결과와 프로세스 오류가 충돌한 fixture에서는 `final-result.json`의 PASS와
원래 `RUN_EXIT=1`, `CAUSE=PROCESS_FAILURE`, stderr가 모두 보존되며 CLI는 2로
종료했다.

## 증거 경로

대표 실행 evidence:

```text
PASS: /tmp/freelang-cli.3JmQIi
FAIL: /tmp/freelang-cli.sAbvB9
ERROR: /tmp/freelang-cli.vRCPz5
BLOCKED: /tmp/freelang-cli.5GfI1d
NOT_RUN: /tmp/freelang-cli.VebGTt
PASS+process error: /tmp/freelang-cli.En1NqL
timeout: /tmp/freelang-cli.raHGAX
signal: /tmp/freelang-cli.2t7hDz
side effect: /tmp/freelang-cli.333jpB
```

각 경로에는 `stdout.log`, `stderr.log`, `final-result.json`(확보 시),
`process.meta`가 있다. 동일 `pass.fl` 반복 실행 결과는 `COMPARE_EXIT=0`으로
최종 JSON이 동일했다. side-effect fixture는 단일 invocation 후 파일 값 `1`을
확인했다.

## 회귀 검증

```text
result.fl check: exit 0
report.fl check: exit 0
cli.fl check: exit 0
native-result: 14/14
native-assert: 8/8
native-report: 10/10
native-effect: 6/6
npm test: FREELANG_TEST=PASS
npm run cli -- tests/cli/pass.fl: exit 0
```

canonical runtime의 metadata warning은 남아 있으며 숨기지 않았다.

## 판정과 범위

FreeLang final result와 실제 shell exit code의 연결은 검증 완료했다. 다만 이
작업은 로컬 CLI 경계만 완료한 것이며, 테스트 collector·격리·single-run
artifact 공유 구조, 실제 Effect Tape, AI 검수, GitHub workflow/push 자동화는
완료로 주장하지 않는다.
