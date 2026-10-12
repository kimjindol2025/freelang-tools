# FreeLang Tools 경계 기준선

기준 커밋: `841a879`
기준일: 2026-10-12
현재 판정: `MIXED_MIGRATION_REQUIRED`

이 문서는 외부 언어를 정당화하는 문서가 아니라, FreeLang으로 흡수해야 할
자체 로직과 끝까지 남겨도 되는 최소 경계를 구분하는 마이그레이션 기준선이다.

## 1. FreeLang 본체 — 유지·확장

| 영역 | 정본 |
|---|---|
| trust/evidence/AI protocol | `native/*.fl` |
| backend contract | `native/backend-contract.fl` |
| Git read contract | `native/git-core.fl` |
| readiness report | `native/ready-report.fl` |
| native test framework | `src/test/*.fl`, `tests/native-*.test.fl` |

## 2. 마이그레이션 필요 — 자체 제품 로직

다음 파일은 현재 Bash/Node가 흐름·계약·결과 조합을 소유하므로 FreeLang
native 또는 FreeLangScript로 이전한다.

| 현재 파일/영역 | 이전 대상 | 이유 |
|---|---|---|
| `scripts/fl-tools` dispatch/help | `native/tools-cli.fl` | 명령 라우팅·허용 adapter 선택을 native가 소유하고 Bash는 AFJ shim만 남김 |
| `scripts/fl-detect` | `native/detect-core.fl` | 프로젝트 감지와 runner 선택을 native가 소유함 |
| `scripts/fl-route`, `fl-start`, `fl-status` | native project context | 감지·라우팅·상태 판정이 아직 host 수집과 혼재함 |
| `scripts/fl-check`, `fl-test`, `fl-review` | native gate orchestration | PASS/FAIL 조합을 Bash가 소유함 |
| `scripts/fl-check`, `fl-test`의 파일 선택 | `native/check-plan.fl`, `native/test-plan.fl` | 소스·테스트 선택 정책을 native로 이전하고 Bash는 실행 감독만 담당 |
| `scripts/fl-review`의 generated/contract 분류 | `native/review-policy.fl` | Git 원시 상태는 host adapter, 정책 분류는 native 소유 |
| `scripts/fl-start` 출력 조합 | `native/start-report.fl` | project context 출력 계약은 native 소유 |
| `scripts/fl-ready` readiness 판정 | `native/ready-core.fl` | Git·runner·상태 사유 판정은 native 소유 |
| `scripts/fl-trust` decision-input 생성 | `native/trust-input.fl` | trust gate 입력 JSON 생성은 native 소유 |
| `scripts/fl-handoff` 생성·verify 정책 | `native/handoff-core.fl` | handoff 산출물·schema·stale commit 판정은 native 소유 |
| `scripts/fl-evidence` PASS/FAIL 해석 | `native/evidence-report.fl` | raw gate 결과 해석과 evidence 성공 정책은 native 소유 |
| `scripts/fl-test` 테스트 결과 해석 | `native/test-result.fl` | runner 출력의 성공/실패 판정은 native 소유 |
| `scripts/fl-contract-check` 계약 필드 판정 | `native/operation-contract.fl` | operation contract schema/approval/risk 판정은 native 소유 |
| `scripts/fl-server` status JSON/상태 판정 | `native/server-status.fl` | 설치 상태와 다음 명령 계약은 native 소유 |
| `scripts/fl-cli` final marker/protocol 해석 | `native/cli-protocol.fl` | marker 개수·payload 추출·완료 계약은 native 소유 |
| `scripts/fl-workflow-test` package 계획/entry/report | `native/workflow-plan.fl`, `native/workflow-entry.fl`, `native/workflow-report.fl` | 외부 테스트 계획·결과 schema·workflow report 조합은 native 소유 |
| `package.json` script 조회 | `native/package-script.fl` | lint/build/deploy/list script 조회는 native 소유 |
| `scripts/fl-trust` blocked/limitations 정책 | `native/trust-blocked.fl`, `native/trust-limitations.fl` | trust 응답과 limitations 배열 생성은 native 소유 |
| `scripts/fl-inspect` native-core 입력 생성 | `native/inspect-input.fl` | inspect context JSON 생성은 native 소유 |
| `scripts/fl-report` 상태/리뷰 해석·Markdown 조합 | `native/report-core.fl` | report 정책과 출력 조합은 native 소유 |
| `scripts/fl-doctor` project health 판정 | `native/doctor-core.fl` | doctor 출력과 blocked/pass 정책은 native 소유 |
| `scripts/fl-safe-push` preflight/승인 정책 | `native/safe-push-core.fl` | clean/remote/push 승인 판정은 native, 실제 git push는 host 소유 |
| `scripts/fl-deploy` 배포 결과/artifact report | `native/deploy-report.fl` | deploy/smoke/hash/rollback 결과 조합은 native, 외부 실행은 host 소유 |
| `scripts/fl-workflow-test` dependency-blocked report | `native/workflow-blocked.fl` | node_modules 미설치 blocked 계약은 native 소유 |
| AFJ runner self-host smoke | `native/selfhost-core.fl`, `native/selfhost-probe.fl` | native 코드 check/run은 FreeLang process 경계에서 검증 |
| `scripts/fl-evidence`, `fl-trust`, `fl-handoff` | native report/orchestration | 결과 조합·저장·handoff가 혼재함 |
| `scripts/fl-workflow-test` | native workflow planner + 최소 process host | 계획·계약 생성이 Node/Bash에 있음 |
| `scripts/fl-cli`, `fl-server`, `fl-contract-check` | native process/contract modules | 실행·권한·계약 판정이 외부 언어에 있음 |
| `scripts/*.js` helper | native comparator/manifest/protocol | 자체 JSON·프로토콜 로직이 Node에 남음 |

## 3. 최소 host 경계 — 남길 수 있으나 기능을 소유하지 않음

- AFJ/FX 런타임 bootstrap 호출
- OS가 제공하는 실제 프로세스·파일·소켓·Git syscall adapter
- stdout/stderr, signal, timeout, process-group cleanup 감독
- 외부 프로젝트의 npm/Jest/Vitest 실행 adapter

host adapter는 입력을 argv/계약으로 전달하고 원시 결과를 반환할 뿐, 정책·
판정·JSON schema·결과 조합을 구현하지 않는다.

## 4. 테스트 fixture — 제품 본체로 세지 않음

`tests/**/*.sh`, `tests/**/*.js`, deploy fixture의 계약 스크립트는 외부
프로세스·signal·호스트 실패를 재현하기 위한 fixture다. 본체 이전 대상과
혼동하지 않지만, native contract가 실제로 이를 검증하는 회귀를 유지한다.

## 5. 승격 기준

다음 조건을 모두 만족하기 전에는 `NATIVE_FREELANG` 또는 전체 완성으로
승격하지 않는다.

1. 자체 `scripts/*.sh`가 명령 의미를 소유하지 않는다.
2. 자체 `scripts/*.js`가 JSON/protocol/판정 의미를 소유하지 않는다.
3. native CLI kernel이 실제 argv에서 명령을 라우팅한다.
4. host boundary 목록과 각 capability가 manifest에 등록된다.
5. 실제 실행·회귀·결정성·권한 검증이 `fl-tools ai run --deep`에 포함된다.

현재 감지기 승격 근거: `native/detect-core.fl` check와
`tests/detect-contract.sh`의 실제 subprocess/find 회귀가 PASS했다.
