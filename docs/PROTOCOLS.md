# FreeLang Tools 계약 기준

이 문서는 `freelang-tools`가 프로젝트와 AI 에이전트 사이에서 사용하는
기계 판독 계약의 정본 목록이다. 실행 의미와 최종 판정은 FreeLang native
core가 소유하고, Bash/Node는 탐색·프로세스 감독·증거 보존 어댑터로만 동작한다.

## 계약 흐름

```text
ready(preflight) → ai(v1) → 작업 → trust(v1) → workflow(v1) → handoff(v1)
```

| 계약 | 정본 스키마 | 생산자 | 소비자 | 핵심 판정 |
|---|---|---|---|---|
| `freelang.ready/v1` | `schemas/ready.schema.json` | `fl-ready` | `fl-ai ready/work` | 프로젝트를 시작할 수 있는가 |
| `freelang.ai/v1` | `schemas/ai-protocol.schema.json` | `fl-ai` | Codex/AI | `canProceed`와 `next` |
| `freelang.trust/v1` | `schemas/trust.schema.json` | `trust-core.fl` | `fl-ai verify/release` | `TRUSTED` 여부 |
| `freelang.workflow/v1` | `schemas/workflow.schema.json` | `fl-workflow-test` | `native/workflow-core.fl` | 외부 테스트 결과 유효성 |
| `freelang.handoff/v1` | `schemas/handoff.schema.json` | `fl-ai`/`fl-handoff` | 다음 에이전트 | stale commit 여부 |
| `freelang.operation-contract/v1` | `schemas/operation-contract.schema.json` | 프로젝트 | deploy/push/rollback | 사용자 승인 필요 여부 |
| `freelang.backend-contract/v1` | `schemas/backend-contract.schema.json` | `backend-contract.fl` | FreeLang backend/AI | 시스템·JSON·HTTP·프로세스·권한·Git·실행기 결과 통합 |

## 상태와 종료코드

### AI 진입 계약

`freelang.ai/v1`의 `status`는 세 값만 사용한다.

- `READY`: AI 작업을 계속할 수 있음
- `NOT_READY`: trust 결과가 `UNTRUSTED`이거나 승인이 필요한 상태
- `BLOCKED`: 실행 불가 또는 계약 위반

`verdict`는 `TRUSTED`, `TRUSTED_WITH_APPROVAL`, `UNTRUSTED`, `BLOCKED` 중 하나다.
`canProceed`가 최종 작업 허용 플래그이며, `false`이면 `next`를 따르고 멈춘다.

`fl-tools ai run --deep`와 `fl-tools ai release`는 프로젝트 trust와 별도로
`toolAudit`를 요구한다. `toolAudit.status`가 `PASS`가 아니면 최종
`canProceed=false`, `status=BLOCKED`, `next=rerun-native-tester-audit`로
판정한다. 빠른 `ai run`/`ai verify` 경로에서는 `required=false`와
`status=NOT_RUN`이며, 릴리즈 전에는 deep 경로를 반드시 실행해야 한다.

### Preflight 계약

`freelang.ready/v1`의 `READY_WITH_CHANGES`는 dirty worktree를 뜻한다.
이는 AI protocol의 `READY`와 다르며, 작업 시작은 가능하지만 배포·릴리즈는
별도 review와 사용자 승인을 통과해야 한다.

### 테스트 계약

FreeLang native 테스트의 정본 상태와 종료코드는 다음과 같다.

| 상태 | 종료코드 |
|---|---:|
| `PASS` | 0 |
| `FAIL` | 1 |
| `ERROR` | 2 |
| `BLOCKED` | 2 |
| `NOT_RUN` | 3 |

외부 `npm`, Jest, Vitest는 실행 어댑터다. 결과는 반드시
`freelang.workflow/v1`로 변환한 뒤 `native/workflow-core.fl`이 검증한다.
기본 workflow는 프로젝트의 `test:fast` 프로필을 우선 실행한다. 전체 테스트
스크립트는 `fl-tools workflow-test --all-tests`를 명시했을 때만 실행한다.
wall-clock·CPU·명령 수 제한 초과는 테스트 실패가 아니라 `BLOCKED`로 보존한다.
프로젝트가 기본 제한을 조정해야 하면 루트의 `freelang-tools.json`에
`workflow` 계약을 선언한다. 정본 형식은 `schemas/workflow-config.schema.json`이며,
환경변수는 CI·진단용 명시적 override로만 사용한다.

## 승인 경계

`deploy`, `rollback`, `push`, `pull`, `commit`, `delete`는
`freelang.operation-contract/v1`에서 `approvalRequired: true`를 요구한다.
계약이 있어도 사용자 승인 없이는 실행하지 않는다.

## Backend 표준 경계

모든 backend 효과는 `{ok, status, error}` 공통 결과를 사용한다. HTTP는
`status`, `headers`, `body`, `data`, `error`, 프로세스는 `code`, `argv`,
`stdout`, `stderr`를 추가한다. 권한은 명시된 allowed root 아래 경로만
허용한다. Git 표준 API는 읽기 전용 `status`, `head`, `branch`, `diff`를
argv 분리 방식으로 실행한다. OS 효과와 프로세스 감독은 host adapter가
담당하고, 결과 계약과 PASS/BLOCKED 판정은 FreeLang native가 소유한다.

## 표준 사용 순서

```bash
fl-tools ai ready
fl-tools ai work
fl-tools ai verify
fl-tools ai verify --deep
fl-tools ai release
```

기존 `start`, `inspect`, `review`, `trust`는 호환용이며 AI 기본 경로가 아니다.
