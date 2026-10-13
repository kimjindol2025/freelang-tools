# FreeLang Tools 현재 사용법

이 문서는 현재 저장소를 닫는 시점의 실제 사용 순서다. 외부 Jest/npm 결과는
보조 어댑터이며, 최종 테스트 의미·집계·판정은 FreeLang native가 소유한다.

## AI 작업 순서

```bash
./scripts/fl-tools ai run .
# canProceed=true일 때만 수정

./scripts/fl-tools ai run .
# 수정 후 빠른 재검증

./scripts/fl-tools ai run --deep .
# 릴리즈 전 전체 trust + 31개 native tester audit

./scripts/fl-tools ai release .
# 릴리즈 판정만 확인; 배포·push는 실행하지 않음
```

`ai run`은 빠른 경로라 `toolAudit.status=NOT_RUN`이다. `--deep`와 `release`는
`toolAudit.status=PASS`가 아니면 진행을 허용하지 않는다.

## Native tester audit

```bash
./scripts/fl-tools tester-audit --run
./scripts/fl-tools tester-audit --run --output .freelang/evidence/tester-audit-latest.json
./scripts/fl-tools tester-audit --input .freelang/evidence/tester-audit-latest.json
```

정상 기준은 `expectedCount=31`, `resultCount=31`, `invalidCount=0`,
`failedCount=0`, `blockedCount=0`, `notRunCount=0`, `verdict=PASS`다.
실행 결과는 `freelang.tester-evidence/v1`으로 보존한다.

## 기본 검수

```bash
./scripts/fl-check .
./scripts/fl-tools tester-audit --input /path/to/evidence.json
git diff --check
```

FreeLang 소스 문법은 canonical AFJ runner로 확인한다.

```bash
node /home/kim/kim/platform/freelang-afj/bootstrap-native.js check native/ai-protocol.fl
```

## 증거와 handoff

AI protocol이 persist되는 경로는 대상 프로젝트의 다음 파일이다.

```text
.freelang/evidence/latest.json
.freelang/evidence/tester-audit-latest.json
.freelang/last-result.json
.freelang/handoff.json
.freelang/handoff.md
```

이 파일들은 다음 작업자가 실제 실행 결과와 `next`를 확인하는 용도다.
파일이 없거나 실행하지 않은 결과는 PASS로 해석하지 않는다.

## 현재 환경 주의사항

현재 Codex 샌드박스에서는 자식 프로세스 생성이 `EPERM`으로 차단될 수 있다.
이 경우 AFJ의 `process_spawn`은 `E_PROCESS_SPAWN`을 안전하게 `BLOCKED`로
보존하며, native audit 31개 전체가 PASS가 될 수 없다. 저장된 과거 증거의
재판정 PASS와 현재 환경에서 새로 실행한 PASS는 서로 다른 증거다.

실시간 31개 audit와 deep gate를 닫기 전에 자식 프로세스 실행이 허용된
운영 서버에서 다시 실행한다.
