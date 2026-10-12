# FreeLang Tools 순차 검수 보고서

기준 HEAD: `8ac2c4e7d8ca3372b8faa741c5ab15bfb828a768`, 시작 시 clean.

판정: **PARTIAL — FreeLang 최종 JSON 판정을 연결·강화; 외부 adapter는 별도 계약, Effect Tape BLOCKED**.

2026-10-11 수정보안: native aggregation은 0 executed를 NOT_RUN으로 유지한다. 호스트
validator는 실제 PASS가 1개 이상이고, executed/status 합계와 expected/actual/missing/excess
집계가 일치해야 PASS를 허용한다. FreeLang fallback `fl-test`는 로그 정규식 대신 `fl-ci`
한 번의 최종 JSON 경로를 사용한다.

## 실제 검사

- `npm run test:cli-contract`: 11개 PASS, exit=0.
- `npm run test:cli-isolation`: timeout/error 모두 exit=2, 잔여 process 0,
  검사 exit=0.
- `npm run test:effect-capability`: checker exit=0. 실제 API는 UNAVAILABLE,
  probe는 BLOCKED이며 본문이 실행되지 않는 계약을 확인했다. Effect 기능 PASS가 아니다.

기존 기준 실행은 현재 v11 경로, 시작 당시 HEAD e5ae0ad1의 수정된 번들이었다. 수정 후에는
AGENTS 고정 commit `e73c58378a1bb1afb776b7abc4b43eb859006530`의 committed `bootstrap.js`를
임시 파일로 추출해 공식 검증했다. 실제 고정 commit 확인 후 11 CLI cases, timeout/signal
격리, effect capability probe, native aggregation/reporter syntax를 실행했다.

## 재현된 문제

`scripts/fl-test`는 실행 로그의 `Test Results: n/n passed` 정규식으로 성공을
판정한다. assertion 없이 `Test Results: 0/0 passed`만 출력하는 임시 `.test.fl`을
실행하자 `FREELANG_TEST=PASS`, exit=0이었다. 이는 테스트 0개를 PASS로
처리하지 않는 AGENTS 계약과 다르다.

`scripts/fl-protocol-check.js`는 actual_count=0, executed_count=1,
pass_count=0인 합계 불일치 PASS fixture도 허용했다. 테스트 실행 개수와
상태별 집계의 교차 검증이 필요하다.

## 보안과 범위

CLI의 process group 격리와 프로토콜 중복·깨진 JSON·runtime 오류 차단은 기존
검사에서 확인했다. 임의 테스트·프로젝트 계약을 실행하는 CLI는 sandbox 자체가
아니므로 분석 권한이 있는 fixture만 실행해야 한다. 배포·설치·pipeline·실제
외부 프로젝트 계약은 실행하지 않았다. 실제 Effect API는 BLOCKED다.

수정 후 검증: 새 protocol fixture 5개 PASS, CLI contract 11개 PASS, isolation의 timeout/
signal exit=2 및 잔여 process 0, Effect Tape probe BLOCKED(expected), `fl-test` smoke는
정상 결과 exit=0·0/0 결과 exit=3(NOT_RUN)이었다. native `result.fl`/`report.fl`와 host
스크립트 구문 검사를 통과했다. pinned commit blob을 `/tmp`에만 추출했고 runtime 저장소를
수정하지 않았다.

외부 dialect와 custom test-contract adapter는 해당 runner 자체의 exit=0 계약을 유지한다.
그 adapter들은 최종 JSON으로 정규화하지 않았으며 문서대로 실행 권한·경로를 별도 검토해야
한다. 실제 외부 프로젝트 및 deploy는 실행하지 않았다. 커밋·푸시·배포는 하지 않았다.
