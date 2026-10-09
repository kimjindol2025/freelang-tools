# FreeLang Native CI Contract

상태: `PHASE_1_CONTRACT_LOCKED`

이 문서는 `fl-test`, `fl-effect`, `fl-ci`가 공유하는 최종 실행 계약이다.
핵심 판정은 FreeLang이 소유하고, host CLI는 프로세스 감독과 결과 전달만
담당한다.

## 실행 경계

```text
test source
  -> FreeLang collection/execution
  -> result.fl aggregation
  -> effect.fl decision
  -> ci.fl final report
  -> host CLI protocol validation
  -> shell exit code
```

동일 invocation의 테스트는 한 번만 실행한다. reporter, evidence, CI summary
생성을 위해 테스트를 재실행하지 않는다.

## Final result schema

최종 결과는 `freelang-tools/ci-report/v1` 또는 그 하위 report schema를
사용하며 다음 필드를 반드시 포함한다.

- `schema`
- `complete: true`
- `status`
- `exit_code`
- `expected_count`, `actual_count`
- `missing_count`, `excess_count`, `invalid_count`
- `executed_count`
- `pass_count`, `fail_count`, `error_count`, `blocked_count`, `skipped_count`
- `diagnostic`

`actual_count`가 `expected_count`와 다르거나, 필드·타입·schema·상태가
유효하지 않으면 `ERROR`로 판정한다.

## Status and process exit

| FreeLang status | shell exit |
|---|---:|
| `PASS` | 0 |
| `FAIL` | 1 |
| `ERROR` | 2 |
| `BLOCKED` | 2 |
| `NOT_RUN` | 3 |

테스트 0개, 전부 `SKIPPED`, 결과 누락, 깨진 JSON, timeout, signal,
프로세스 오류는 `PASS`가 될 수 없다. 프로그램 예외와 함수 미등록·모듈
로딩·테스터 오류를 공식 API로 구분할 수 없으면 `BLOCKED` 또는 `ERROR`를
진단과 함께 보존한다.

## Evidence

host CLI는 다음을 동일 evidence directory에 보존한다.

- 최종 JSON 1개
- raw stdout/stderr
- syntax check stdout/stderr
- process metadata와 원래 종료 원인
- protocol validation 출력

`duration`, PID 등 실행 메타데이터만 반복 비교에서 제외할 수 있다. assertion
값과 effect 대상·인자·순서는 정규화하거나 삭제하지 않는다.

## Current limitation

canonical runtime에 공개 Effect Tape API가 없으므로 Tape 검사는 현재
`BLOCKED`다. 가짜 Tape나 로그 추측으로 `PASS`를 만들지 않는다.
