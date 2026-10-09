# 판정 계약 보완 보고서

기준 HEAD: `a250ef7ff03df24f4411226e90cf448ef880c009`

기준 브랜치: `main` (`origin/main`과 동기화, 작업 시작 시 dirty 없음)

고정 실행기:

```text
dialect: FreeLang v11 canonical
runtime: /root/freelang-surface-v0-clean-ek3qo2/v11/bootstrap.js
runtime commit: e73c58378a1bb1afb776b7abc4b43eb859006530
```

## 수정 내용

- `src/test/result.fl`
  - schema, 필수 필드, 허용 상태, 문자열·정수·범위 검증 추가
  - unknown status, 깨진 record, schema 불일치, 결과 누락·초과를 `ERROR` 처리
  - `NOT_RUN`은 0개 또는 전부 `SKIPPED`일 때만 유지
  - `diagnostic`, `invalid_count`, `excess_count` 보존
- `src/test/assert.fl`
  - `to_throw`의 `try-call` 오류를 문자열로 추측하지 않음
  - canonical `try-call`의 `_tag`, `code`, `category`, `message` 진단 보존
  - expected exception과 runner/runtime 오류를 구분할 API가 없으므로 `BLOCKED`
- `src/test/report.fl`
  - JSON과 text에 전체 상태·카운트·diagnostic 보존
- native tests
  - `native-result`: 14/14
  - `native-assert`: 8/8
  - `native-report`: 7/7

## Phase와 10단계 대응표

| Phase | 기획안 단계 | 상태 | 범위 |
|---|---:|---|---|
| 0 | 3. Effect Tape capability 조사 | PARTIAL / BLOCKED | canonical runtime capability 조사, 가짜 Tape 금지 |
| 1 | 4. 공통 결과·진단 모델 | PASS | 결과 schema·집계·상태 계약 |
| 2 | 5. `fl-jest` native core 일부 | PASS | matcher 자료구조와 기본 matcher |
| 3 | 6. reporter·CLI 경계 일부 | PARTIAL | FreeLang JSON/text reporter, CLI 종료코드는 미구현 |
| 4 | 7. `fl-effect` native core 경계 | PARTIAL / BLOCKED | effect 정책 모델, 실제 Tape 연결은 미지원 |
| 4 보완 | 4·6·7 계약 보완 | PARTIAL | 입력 검증·진단 보존·`to_throw` 분류 차단 |

아직 구현하지 않은 범위는 테스트 수집, case 격리, 단일 실행 artifact 공유,
CLI bootstrap 종료코드, 실제 Effect Tape 연결이다. 이번 변경은 matcher·reporter를
그 범위까지 확대하지 않는다.

## 실제 검증

```text
result.fl check: exit 0
assert.fl check: exit 0
report.fl check: exit 0
native-result.test.fl: 14/14 passed, exit 0
native-assert.test.fl: 8/8 passed, exit 0
native-report.test.fl: 7/7 passed, exit 0
npm test: FREELANG_TEST=PASS, exit 0
repeated native-report stdout: COMPARE_EXIT=0
```

의도적 assertion 불일치 fixture는 다음을 출력했다.

```text
Test Results: 0/1 passed (1 FAILED)
```

그러나 canonical bootstrap 프로세스 종료코드는 `0`이었다. 따라서 내부 FAIL
자료구조 판정은 검증됐지만 CLI 종료코드 계약은 아직 구현되지 않은 것으로
기록한다. 이 실행 결과를 근거로 CLI 완료를 주장하지 않는다.

## 미완료·차단 원인

- canonical `try-call`은 모든 호출 오류를 `E_TRY_CALL`/`runtime-error`로
  반환하므로 expected exception, 함수 미등록, tester 오류의 공식 구분이 불가하다.
  현재 `to_throw`는 `BLOCKED`와 원본 diagnostic을 반환한다.
- canonical runtime에 user-level `trace_effects`/Effect Tape API가 없어 실제
  effect 기록·tag·target·인자·순서 검증은 `BLOCKED`다.
- 프로세스 종료코드 전달을 담당할 CLI/bootstrap이 아직 구현되지 않았다.
