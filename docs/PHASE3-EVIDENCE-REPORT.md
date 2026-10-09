# Phase 3 — Final JSON and Evidence Report

상태: `IMPLEMENTED`

## 변경

- `scripts/fl-evidence-manifest.js`를 추가했다.
- 모든 `fl-cli` 종료 경로에서 `evidence-manifest.json`을 생성한다.
- manifest는 최종 상태·종료코드·원래 process exit·check/run exit·timeout/signal
  원인과 보존된 evidence 파일 목록을 기록한다.
- manifest는 host evidence 메타데이터이며 FreeLang 판정을 대체하지 않는다.

## 보존 계약

- `final-result.json`: FreeLang 최종 JSON
- `stdout.log`, `stderr.log`: raw 실행 출력
- `check.stdout.log`, `check.stderr.log`: syntax check 출력
- `process.meta`: runtime·SHA·명령·종료 원인
- `protocol.stdout.log`, `protocol.stderr.log`: schema 검증 결과
- `evidence-manifest.json`: 위 파일과 최종 상태의 인덱스

정상 완료와 실패·프로세스 오류 모두 evidence manifest를 남긴다. manifest
생성 실패는 원래 테스트 판정을 PASS로 바꾸지 않는다.
