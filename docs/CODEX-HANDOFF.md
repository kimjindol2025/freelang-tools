# FreeLang Tools — 다음 Codex 전달사항

기준일: 2026-10-14

## 저장소 상태

- 저장소: `freelang-tools`
- 기본 브랜치: `main`
- 마지막 원격 커밋: `5d0f4f1 feat(tools): preserve tester audit evidence`
- 현재 로컬은 원격보다 2커밋 앞서 있다.
- 이번 정리 변경은 다음 커밋으로 묶을 예정이다.
- 이번 작업에서는 commit, push, deploy, PM2 변경을 하지 않는다.

## 지금까지 확정된 방향

1. 테스트의 권위는 npm/Jest/Node가 아니라 FreeLang native runner다.
2. host Bash/Node는 프로세스 감독·입력 라우팅·증거 보존만 담당한다.
3. 31개 tester를 `native/tester-registry.fl`에 선언하고
   `native/tester-runner.fl`이 실행 증거를 수집한다.
4. `tester-registry.fl`은 누락, 깨진 schema, 0개 실행, SKIPPED, FAIL,
   BLOCKED, 종료코드 오류를 PASS로 인정하지 않는다.
5. `ai run --deep`와 `ai release`는 프로젝트 trust와 별도로 native tester
   audit를 요구한다. audit가 PASS가 아니면 `canProceed=false`다.

## 현재 구현 변경

다음 파일은 이전 작업에서 수정되었으며, 모두 같은 기능 묶음이다.

- `scripts/fl-ai`: deep/release 시 native tester audit 실행 및 영구 증거 경로
- `scripts/fl-ai-protocol`: `toolAudit` 상태를 native protocol로 전달
- `native/ai-protocol.fl`: tool audit를 별도 gate로 판정하고 BLOCKED/next 생성
- `scripts/fl-evidence`: 긴 raw 출력은 환경변수가 아닌 임시 파일로 전달
- `native/evidence-report.fl`: raw evidence 파일 채널을 읽어 ARG_MAX 초과 방지
- `schemas/ai-protocol.schema.json`: `run`, `quick/deep`, `toolAudit` 계약 반영
- `docs/PROTOCOLS.md`: AI tool audit 계약 설명
- `docs/TOOL-USAGE.md`: 현재 운영 사용법

## 검증된 것

- `bash -n scripts/fl-ai scripts/fl-ai-protocol` 통과
- `native/ai-protocol.fl` canonical AFJ check/type-check 통과
- `jq empty schemas/ai-protocol.schema.json` 통과
- `git diff --check` 통과
- 저장된 `/tmp/freelang-tools-evidence.json` 재판정은 31/31 PASS
- 승인된 실행 환경에서 새 native tester audit는 31/31 PASS
- 승인된 실행 환경에서 `fl-tools ai run --deep .`는 `TRUSTED`,
  `toolAudit.status=PASS`, `canProceed=true`
- protocol synthetic contract:
  - `toolAudit=PASS` → tool gate 허용
  - `toolAudit=BLOCKED` → `status=BLOCKED`, `next=rerun-native-tester-audit`, exit 2
  - quick → `toolAudit=NOT_RUN`, `required=false`

## 환경별 주의사항

일부 Codex 샌드박스에서는 자식 프로세스 생성이 `EPERM`으로 차단되어
감사가 `BLOCKED`가 될 수 있다. 이는 실행 환경의 한계이며 PASS로 우회하면
안 된다. 자식 프로세스가 허용된 운영 환경에서는 다음 결과가 확인됐다.

```bash
./scripts/fl-tools tester-audit --run --output .freelang/evidence/tester-audit-latest.json
./scripts/fl-tools tester-audit --input .freelang/evidence/tester-audit-latest.json
./scripts/fl-tools ai run --deep .
```

결과: 31/31 native tester PASS, project trust TRUSTED,
`toolAudit.status=PASS`, `canProceed=true`.

## 다음 Codex 작업 규칙

- 시작 시 이 문서와 `AGENTS.md`, `docs/TOOL-USAGE.md`를 읽는다.
- 먼저 `./scripts/fl-tools ai run .`을 실행한다.
- `canProceed=false`면 코드 수정부터 하지 말고 `next`와 `limitations`를 해결한다.
- FreeLang 기능은 `native/*.fl`에 추가한다. JS/Bash에 본체 로직을 우회 구현하지 않는다.
- 변경 후 canonical check, 관련 native test, live 실행, `git diff --check`를 한다.
- 실제 출력이 없는 항목은 PASS로 보고하지 않는다.
- commit/push는 사용자가 명시적으로 요청한 뒤 fresh verification 후에만 한다.

## 종료 기준 — 충족됨

이 저장소를 다시 열 때는 다음 상태를 모두 확인해야 한다.

- 31개 native tester 실시간 PASS
- `fl-tools ai run --deep .`의 `toolAudit.status=PASS`
- 프로젝트 trust의 check/test/review/evidence/diff gate 확인
- schema와 handoff 증거의 commit stale 여부 확인
- 변경사항 검토 후 사용자 승인에 따른 commit/push
