# FreeLang Tools 수정 및 보안 지시서

## P1 공식 성공 판정 통일

FreeLang fallback의 `scripts/fl-test`와 `fl-cli/fl-ci`가 같은 FreeLang 최종 JSON을
사용하도록 연결한다. 로그 정규식만으로 PASS를 판정하지 않는다. 0/0 출력만 있는 테스트,
전부 skipped, 잘못된 집계, 단순 PASS 문구 위조를 실패 또는 NOT_RUN으로
보존한다. 실제 테스트는 동일 invocation에서 한 번만 실행한다.

## P1 최종 JSON 집계 불변식

actual_count=0, executed_count=1, pass_count=0 fixture가 현재 검사기에
통과한다. PASS에는 실제 실행·통과한 테스트가 필요하다. expected/actual 및
missing/excess, executed와 상태별 합계를 교차 확인한다. native reporter와
호스트 validator에 같은 계약을 적용하고 경계값·음수·중복·전부 skipped를
회귀 테스트로 검증한다.

## P2 Runtime 계약과 실행 권한

AGENTS는 e73c5837 고정을 요구하지만 기본 CLI는 현재 v11 경로를 사용한다.
실제 runtime 커밋과 번들 hash를 증적에 기록하고 고정 조건 불일치를 명시적으로
처리한다. 문서와 구현을 어떤 조건으로 정렬할지 확정한 뒤 정식 검증한다.

외부 프로젝트가 제공한 test/deploy 계약은 실행 권한과 경로를 먼저 확인한다.
symbolic link의 realpath, timeout·signal cleanup, 환경변수의 비밀정보 증적
제외를 유지한다. deploy는 검수 자동 실행에 포함하지 않는다.

## 완료 조건

0/0 위조와 집계 불일치가 더 이상 PASS가 아니어야 한다. 기존 CLI 11개와
isolation/capability 검사를 유지하고, 고정 runtime에서 공식 native tests를
실행한다. Effect Tape 미지원은 BLOCKED로 남긴다.

2026-10-11 수정: native aggregation, host protocol checker, FreeLang `fl-test`
fallback을 연결했고 회귀를 추가했다. `fl-test`의 외부 dialect/custom test-contract
adapter는 자체 runner의 exit code 계약을 그대로 따르므로 최종 JSON으로 자동 정규화하지
않는다. 해당 실행기를 신뢰하는 계약의 범위로 기록하고, 임의 프로젝트 코드는 계속 실행
권한·경로를 확인한 뒤 돌린다.
