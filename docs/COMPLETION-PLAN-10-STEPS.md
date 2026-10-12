# FreeLang Tools 완성 계획 — 10단계

목표는 `fl-tools`의 제품·업무·판정 로직을 FreeLang으로 운영하고, 외부
언어는 런타임이 OS를 호출하는 최소 host 경계와 테스트 fixture로만 남기는
것이다. 각 단계는 실제 실행 검증을 통과해야 다음 단계로 진행한다.

## 완료 판정 규칙

- `MIXED_MIGRATION_REQUIRED`가 남아 있으면 전체 완성이 아니다.
- 문서·카탈로그만으로 PASS를 만들지 않는다.
- 단계마다 native check, 실제 실행, 회귀, `git diff --check`를 수행한다.
- 마지막 단계에서 `fl-tools ai run --deep`가 `TRUSTED`이고 외부 자체 로직이
  남지 않아야 완성으로 판정한다.

## 단계

| 단계 | 목표 | 핵심 산출물 | 완료 조건 |
|---:|---|---|---|
| 1 | 외부 경계 기준선 확정 | boundary manifest, native 진입점 설계 | JS/Bash를 본체·host·fixture로 분류하고 실행 기준선 기록 |
| 2 | FreeLang CLI kernel | `native/tools-cli.fl`, argv/command/result contract | `help`, `status`, `route`, `ready`가 native 경로로 실제 실행 |
| 3 | 시스템·파일·JSON 표준화 | native fs/json 모듈과 오류 계약 | read/write/exists/list/parse/stringify가 동일 계약으로 PASS |
| 4 | 프로세스·권한 표준화 | argv 실행기, allowed-root 권한 모듈 | shell 문자열 실행을 제거하고 deny/timeout/cleanup 실제 검증 |
| 5 | HTTP 표준화 | HTTP client/response contract | status/headers/body/data/error 계약과 loopback 실제 요청 PASS |
| 6 | Git 표준 모듈 | `git-status`, `git-head`, `git-diff`, `git-branch` | argv-safe native Git 호출과 dirty/clean 회귀 PASS |
| 7 | fl-tools 오케스트레이션 이전 | check/test/review/evidence/trust native orchestration | Bash는 최소 shim, 판정·조합·저장은 FreeLang 소유 |
| 8 | Node 자체 로직 제거 | native JSON/schema/protocol/handoff/report | 자체 JS helper가 host adapter/fixture 외에 0개 |
| 9 | 실행기·self-host 경계 축소 | AFJ/FX bootstrap 계약, native runner smoke | bootstrap/host 경계 문서화 및 native self-host smoke PASS |
| 10 | 최종 완성 게이트 | release manifest, migration report | 전체 회귀·결정성·실행·권한·loopback·deep gate PASS 후 commit/push |

## 현재 상태

- 기준 커밋: `841a879`
- 현재 판정: `MIXED_MIGRATION_REQUIRED`
- 이미 완료된 기반: native trust/evidence/ready report, backend contract,
  native Git read contract
- 1단계 기준선: 완료 (`docs/FREELANG-BOUNDARY-MANIFEST.md`)
- 2단계 진행: `native/tools-cli.fl`와 `scripts/fl-native-cli` 추가, `fl-tools help/status/route/ready` 실제 native report 경로 확인
- 2단계 잔여: check/test/review의 명령 의미를 native kernel로 이전
- 3단계 진행: `native/system-json.fl`와 allow-root read/write/list/parse/stringify 실제 검증 추가
- 4단계 진행: `native/process-core.fl` argv-safe 실행 및 실패/injection 회귀 PASS
- 5단계 진행: `native/http-core.fl` loopback 실제 요청/응답 정규화 PASS
- 6단계 진행: `native/git-core.fl` status/head/branch/diff 읽기 계약 추가
- 감지 경로 진행: `native/detect-core.fl`와 `scripts/fl-native-detect`로 프로젝트 감지·runner 선택을 native로 이전하고 `test:detect-contract` PASS
- 실행 계획 진행: `native/check-plan.fl`, `native/test-plan.fl`이 소스·테스트 선택 정책을 소유하고 `fl-check`/`fl-test`는 runner 감독만 수행
- CLI dispatch 진행: `scripts/fl-tools`를 native CLI kernel wrapper로 축소하고, native가 명령을 허용된 host adapter에 argv-safe로 dispatch
- CLI dispatch 회귀: `test:cli-dispatch`에서 native status와 unknown-command BLOCKED 계약 PASS
- 릴리스 정책 진행: `native/release-core.fl`이 릴리스 필드·계약·clean worktree 정책을 소유하고, Bash는 Git/파일 관찰만 담당
- 테스트 결과 정책 진행: `native/test-result.fl`이 runner 출력의 성공/실패 판정을 소유하고 Bash는 프로세스 감독만 담당
- operation contract 정책 진행: `native/operation-contract.fl`이 schema/action/approval/risk 판정을 소유하고 회귀 테스트 PASS
- server status 정책 진행: `native/server-status.fl`이 설치 상태 JSON과 READY 판정을 소유
- CLI final protocol 진행: `native/cli-protocol.fl`이 stdout marker 검증과 final-result 추출을 소유
- workflow orchestration 진행: package plan·result entry·report 조합을 native 모듈로 이전하고 `freelang-mcp` 실제 실행 `WORKFLOW_TEST=PASS` 확인
- package script 경계 진행: lint/build/deploy/list 조회를 `native/package-script.fl`로 통합하고 route/start/review/deploy에서 Node 조회 제거
- GitHub workflow 계획 진행: `workflow-plan.fl`이 `.github/workflows`의 관련 `run:` 명령, unsafe/변수 skip, `--all-tests` 실행 정책을 native로 판정
- inspect/report 진행: `inspect-input.fl`이 native-core 입력을 만들고 `report-core.fl`이 TEST/REVIEW 해석 및 Markdown 보고서 조합을 소유
- doctor/pipeline 진행: `doctor-core.fl`이 health 판정을, `pipeline-core.fl`이 단계 exit/배포 skip/최종 PASS 정책을 소유
- safe-push 진행: `safe-push-core.fl`이 clean/remote/push authorization 사전 판정을 소유하고 실제 `git push`는 명시적 host 경계로 유지
- deploy report 진행: `deploy-report.fl`이 deploy/smoke/hash/rollback 결과 조합을 소유하고 실제 외부 계약 실행은 host 경계로 유지
- self-host gate 진행: AFJ deep trust에 `selfHost` gate를 추가하고 native runner check/run smoke를 실제 `PASS`로 확인
- review 정책 진행: `native/review-policy.fl`이 generated/contract drift 분류를 소유하고 `fl-review`는 gate 실행 감독만 담당
- start 컨텍스트 진행: `native/start-report.fl`이 start 출력 계약을 소유하고 Bash는 탐색·doctor/Git host 관찰만 담당
- readiness 진행: `native/ready-core.fl`이 Git·runner·READY/BLOCKED 판정을 소유하고 `fl-ready`는 감지·경로 host adapter만 담당
- trust input 진행: `native/trust-input.fl`이 trust decision JSON 계약을 소유하고 `fl-trust`의 Node JSON 생성 로직 제거
- handoff 진행: `native/handoff-core.fl`이 handoff JSON/Markdown 생성과 stale commit 검증을 소유
- evidence 진행: `native/evidence-report.fl`이 raw status/review 해석과 최종 PASS 정책을 소유하고 Bash는 관문 실행·exit 감독만 담당
- 최신 검증: `npm run check`, `npm test`, `./scripts/fl-review .`, `npm run selfhost-smoke`, `./scripts/fl-tools ai run --deep` 모두 실제 실행 PASS
- 결정성 검증: `./scripts/fl-tools determinism tests/cli/pass.fl 8` 실제 실행 PASS
- 릴리스 정책 검증: native 성공 경로 PASS, 현재 dirty worktree에서는 `RELEASE_READY=NO`를 정확히 반환
- 전체 완성 보류: `fl-check`/`fl-test` 실행 감독, `fl-cli`의 timeout/evidence host 경계, `fl-tools` 자체 dispatch가 아직 완전 native 소유가 아님
- 외부 자체 로직을 남긴 채 완성으로 보고하지 않는다.
