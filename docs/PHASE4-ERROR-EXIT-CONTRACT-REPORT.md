# Phase 4 — Error and Exit Contract Report

상태: `IMPLEMENTED`

## 변경

- 최종 report의 `diagnostic` 필드를 protocol validator의 필수 문자열 필드로
  고정했다.
- `tests/cli/contract-test.sh`를 추가해 정상·assertion 실패·runtime 오류·Tape
  차단·NOT_RUN·깨진 JSON·프로세스 오류·PASS와 프로세스 오류 충돌·대상 누락을
  실제 shell exit code로 검증한다.
- host validator는 FreeLang 상태를 재판정하지 않고 schema·필드·종료계약만
  검증한다.

## 금지된 PASS 경로

최종 결과가 `PASS`여도 check/run 프로세스가 비정상 종료하면 CLI는 `ERROR`
경로(exit 2)로 종료한다. 원래 process 원인은 `process.meta`와
`evidence-manifest.json`에 보존한다.
