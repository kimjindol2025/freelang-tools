# FreeLang Native Test Framework 기획서

상태: `PROPOSED`

대상 저장소: `kimjindol2025/freelang-tools`

목표: 외부 Jest 패키지나 GitHub 서비스에 의존하지 않고, FreeLang 자체 문법·런타임·Effect Tape 위에서 동작하는 3종 테스트 도구를 만든다.

## 1. 문제 정의

현재 `fl-test`는 `*.test.fl`을 발견하여 FreeLang 런타임의 `check → run`을 수행한다. 이것은 기본 실행기는 제공하지만 다음 기능은 아직 전용 계약으로 분리되어 있지 않다.

- Jest처럼 suite·case·matcher를 선언하는 FreeLang-native 테스트 DSL
- 테스트 실행 중 발생한 Effect Tape의 기록·검증
- 여러 검증 결과를 하나의 결정론적 로컬 CI gate와 evidence로 묶는 흐름

이번 프로젝트는 기존 실행기를 감싸는 Bash/Node adapter를 만드는 것이 아니라, 핵심 테스트 모델과 API를 FreeLang 소스로 구현하는 것을 목표로 한다.

## 2. 설계 원칙

### 2.1 FreeLang-native

- 테스트 DSL, assertion, suite 수집, 결과 집계, Effect Tape 처리를 FreeLang으로 작성한다.
- Bash/Node는 런타임을 호출하는 최소 bootstrap 경계로만 허용한다.
- Jest는 동작 복제가 아니라 DX 참고 모델로만 사용한다.

### 2.2 Zero external dependency

- npm Jest, 외부 matcher, 외부 CI SDK를 추가하지 않는다.
- 표준 FreeLang 런타임과 저장소 내부 도구만 사용한다.

### 2.3 Deterministic first

- suite/case 수집 순서와 실행 순서를 고정한다.
- 같은 소스·같은 런타임 입력은 같은 결과와 같은 진단을 내야 한다.
- 병렬 실행은 MVP에서 금지한다.

### 2.4 실패를 숨기지 않음

- 테스트 실패, Effect 위반, parser/runtime 오류, 도구 자체 오류를 구분한다.
- native Effect Tape API가 확인되지 않은 상태에서는 성공으로 추정하지 않는다.

## 3. 3종 도구

### 3.1 `fl-jest` — FreeLang Unit/BDD Tester

Jest의 suite/case/matcher 경험을 FreeLang 문법으로 제공한다.

책임:

- suite와 test case 선언 수집
- `before_each` 실행
- matcher 실행과 구조화된 assertion 결과 생성
- text/JSON 결과 출력
- 선택 필터와 고정 실행 순서

예정 표면 DSL:

```lisp
(describe "Math"
  (before_each (fn [] (reset-state)))
  (test "adds numbers"
    (fn []
      (expect (add 2 3) (to_be 5))))
  (test "contains item"
    (fn []
      (expect ["a" "b"] (to_contain "b")))))
```

위 표기는 설계 초안이다. 실제 구현 전 canonical FreeLang parser가 지원하는 익명 함수·맵·예외 문법으로 정규화한다.

초기 matcher:

- `to_be`: 원시값·동일성 비교
- `to_equal`: Struct/List 깊은 비교
- `to_contain`: 문자열/List 포함
- `to_throw`: 함수 실행 오류 검증

### 3.2 `fl-effect` — Effect Tape Tester

Mock 객체 대신 실제 FreeLang 실행에서 관찰된 부작용을 검증한다.

책임:

- 테스트 case 전후 Effect Tape 경계 생성
- 파일·네트워크·상태 변경 effect 기록
- effect tag·대상·인자·순서 검증
- 허용·금지·기대 effect 정책 적용
- 관찰 불가 effect를 `unknown`/`error`로 보고

예정 표면 API:

```lisp
(let [tape (trace_effects
             (fn [] (write_file "out.txt" "hello")))]
  (expect tape
    (to_have_effect "FILE_WRITE" "out.txt")))
```

`trace_effects`의 실제 연결 방식은 canonical runtime의 Effect Tape API를 Phase 0에서 확인한다.

### 3.3 `fl-ci` — FreeLang Local CI Tester

GitHub Actions에 의존하지 않고, 로컬 FreeLang tools에서 반복 가능한 검증 gate를 제공한다.

책임:

- FreeLang source check
- `fl-jest` 실행
- `fl-effect` 실행
- 결과 집계와 evidence 생성
- 고정 종료 코드 반환
- 변경 없음·결정론성·회귀 조건 검사

예정 종료 코드:

```text
0 = 전체 검증 성공
1 = 테스트 실패 또는 Effect 위반
2 = parser/runtime/runner/tool 환경 오류
```

## 4. 내부 아키텍처

```text
FreeLang test source
        │
        ▼
FreeLang Parser / AST
        │
        ├─ Test Collector
        ├─ Assertion & Matcher
        ├─ Effect Tape Boundary
        └─ Isolation Context
                │
                ▼
        Structured Test Result
                │
        ├─ fl-jest reporter
        ├─ fl-effect reporter
        └─ fl-ci evidence gate
```

권장 FreeLang 소스 경계:

```text
src/test/ast.fl          AST 선언·source span 모델
src/test/assert.fl       assertion·matcher
src/test/runner.fl       suite/case 실행·격리
src/test/effect.fl       Effect Tape adapter·정책
src/test/result.fl       결과·진단·집계 모델
src/tools/fl-jest.fl     Jest형 CLI 계획·출력
src/tools/fl-effect.fl   Effect CLI 계획·출력
src/tools/fl-ci.fl       CI gate 계획·출력
```

실행 파일 `scripts/fl-tools`와 설치기는 위 FreeLang 모듈을 호출하는 최소 진입점으로만 수정한다.

## 5. 공통 결과 계약

```text
schema: freelang-tools/test-result/v1
runner: fl-jest | fl-effect | fl-ci
status: passed | failed | skipped | blocked | error
suite: string?
name: string?
source: file/line/column?
assertions: integer
effects: tape entries?
diagnostic: structured error?
```

결과 의미:

- `passed`: 요구 조건을 실제 실행으로 충족
- `failed`: 테스트 또는 effect 기대값 불일치
- `blocked`: 필요한 runtime capability·runner가 없음
- `error`: parser·runner·도구 내부 오류
- `skipped`: 명시적으로 제외된 case

## 6. 본구현 착수 전 판정·실행 계약 게이트

검수 결과에 따라 기능 구현보다 먼저 다음 다섯 계약을 통과해야 한다. 이 게이트를 통과하지 못하면 구현 상태를 `BLOCKED`로 두고 PASS로 승격하지 않는다.

### 6.1 첫 실행기 고정

첫 구현 대상은 반드시 다음을 기록한다.

```text
dialect: <FreeLang dialect>
runtime: <runner path or identifier>
commit: <runtime commit>
```

고정된 실행기로 다음 최소 fixture를 실제 실행한다.

- 함수 등록과 호출
- 예외 포착과 expected throw
- 모듈 로딩
- Effect Tape capability 조회

fixture와 원시 stdout/stderr가 없으면 해당 capability를 지원한다고 판정하지 않는다.

### 6.2 PASS 조건과 상태 전이 통일

개별 테스트 상태와 전체 실행 상태를 분리하되, 전체 상태는 아래 우선순위로 계산한다.

| 개별 상태 | 의미 | 전체 집계에 미치는 영향 |
|---|---|---|
| `PASS` | 테스트가 실행되고 모든 assertion 통과 | 실패·오류가 없으면 성공 후보 |
| `FAIL` | assertion 또는 기대 effect 불일치 | 전체 `FAIL` 후보 |
| `ERROR` | 테스트 내부가 아닌 parser·module·tester 오류 | 전체 `ERROR` |
| `SKIPPED` | 명시적으로 실행 제외 | 전부 skipped면 `NOT_RUN` |

전체 실행 상태와 종료 코드는 다음으로 고정한다.

```text
PASS       = 실행된 테스트가 하나 이상이고 FAIL/ERROR/BLOCKED가 없음 → exit 0
FAIL       = 하나 이상의 FAIL이 있고 ERROR/BLOCKED가 없음 → exit 1
ERROR      = FAIL과 ERROR가 함께 있거나 결과 누락·깨진 schema/JSON 발생 → exit 2
BLOCKED    = runner·capability·timeout·도구 경계 문제로 판정 불가 → exit 2
NOT_RUN    = 선택 테스트 0개이거나 전부 SKIPPED → exit 3
```

기본 PASS 금지 조건:

- 테스트 0개
- 전부 skipped
- 결과 레코드 누락
- 깨진 JSON 또는 schema 불일치
- 실행되지 않은 runner
- Effect 기록 불가

`fl-status`, `fl-review`, `fl-evidence`, 세 native tester는 이 상태와 종료 코드를 공유한다. 기존 `NO_TESTS`/`NOT_RUN`과 review PASS의 충돌은 본 구현 전에 제거한다.

결과 집계기는 개별 결과 수, 실행된 case 수, 누락된 결과 수를 함께 보존한다. 결과 레코드가 예상 개수보다 적으면 테스트가 성공했더라도 `ERROR`로 판정한다.

### 6.3 단일 실행·결과 공유

한 invocation에서 테스트 프로그램은 한 번만 실행한다.

```text
collect
  → execute once
  → immutable result artifact
       ├─ fl-jest reporter
       ├─ fl-effect reporter
       └─ fl-ci gate
```

`fl-evidence`가 같은 AFJ 테스트를 다시 실행하지 않도록 실행 결과 artifact를 입력으로 받는다. 파일 쓰기·네트워크·상태 변경은 원 실행의 Tape와 결과를 공유하며, reporter가 프로그램을 재실행하지 않는다.

### 6.4 Effect 기록·차단·오류 분리

각 effect 정책은 실행 전 차단인지 실행 후 위반 기록인지 명시한다.

```text
DENY_BEFORE_RUN      = 실행 전 차단, effect 미발생
OBSERVE_THEN_FAIL    = 실행 후 Tape 기록, 결과는 FAIL
RECORDING_UNAVAILABLE= Tape 기록 자체 불가, PASS 금지 → BLOCKED/ERROR
```

다음 결과도 서로 구분한다.

- 기대한 예외 발생: 테스트 조건 충족 가능
- 예외 미발생: FAIL
- 함수 미등록·모듈 로딩 실패: ERROR
- 테스터 내부 오류: ERROR
- Tape 기록 불가: BLOCKED 또는 ERROR

### 6.5 FreeLang 판정기와 bootstrap 책임

“bootstrap은 호출·인자 전달만 한다”는 문구를 다음처럼 확장한다.

- FreeLang 판정기: 수집, 실행 의미, assertion, effect 정책, 상태 전이, 결과 schema를 담당한다.
- 외부 bootstrap/host: 고정 runtime 실행, 인자 전달, wall-clock timeout, child process 종료, signal 전달, 임시 경로 정리, stdout/stderr 캡처를 담당한다.
- bootstrap은 PASS/FAIL을 임의로 바꾸지 않고 FreeLang 결과와 프로세스 종료 원인을 보존한다.
- bootstrap timeout과 강제 종료는 테스트 `FAIL`이 아니라 전체 `BLOCKED` 또는 `ERROR`로 전달한다.

### 6.6 멈춤·시간·임시 경로 책임

- timeout은 테스트 실패가 아니라 `BLOCKED` 또는 `ERROR`로 기록한다.
- wall-clock `duration`, 실행 시각, PID, host 임시 디렉터리의 절대 경로는 결정론 비교 대상에서 제외한다.
- assertion의 actual/expected 값은 정규화로 삭제하거나 대체하지 않는다.
- Effect Tape의 tag, target, 인자, 발생 순서는 반드시 비교 대상에 포함한다.
- 시간·난수·임시 경로가 assertion 값이나 effect 대상에 들어가면 고정 fixture 또는 명시적 입력으로 주입한다.
- 비결정적 값을 단순히 지워서 일치시키지 않고, 필요한 경우 `NONDETERMINISTIC` effect로 표시해 정책에서 판단한다.

### 6.7 착수 순서

```text
실행기·결과 schema·상태/종료코드·격리 계약 확정
→ 수집 → 실행 → assertion → JSON → 종료코드 한 경로 완성
→ Effect Tape 연결
→ CI 연결
```

## 7. 10단계 실행 플랜

### 1단계 — 범위·용어·성공 기준 고정

목표:

- `fl-jest`, `fl-effect`, `fl-ci`의 책임을 겹치지 않게 확정한다.
- FreeLang-native 구현과 Bash/Node bootstrap의 경계를 고정한다.
- `passed`, `failed`, `blocked`, `error`, `skipped` 의미를 확정한다.

산출물: 이 문서의 결과 계약, 금지 범위, 종료 코드 초안.

검증: 세 도구가 서로의 기능을 중복 소유하지 않는지 문서 검토.

### 2단계 — canonical FreeLang 문법 조사

목표:

- canonical parser의 AST 노드와 source span 형태를 확인한다.
- 함수, 클로저, 맵, 리스트, 예외, 문자열 보간 문법을 실제로 측정한다.
- 기존 `deftest`, `is`, `is=`, `run-tests` 구현 위치와 호출 규약을 확인한다.

산출물: `docs/NATIVE-SYNTAX-NOTES.md`, 최소 parse fixture.

검증: 문서 예시가 아닌 실제 `check`와 `run` 결과를 보존.

### 3단계 — Effect Tape capability 조사

목표:

- Effect Tape가 parser·runtime·stdlib 중 어느 경계에 존재하는지 확인한다.
- effect 시작·종료·기록·조회 API와 표준 tag를 확인한다.
- 파일·네트워크·상태 변경의 격리 가능성을 판단한다.

산출물: Effect Tape adapter 계약과 capability matrix.

검증: capability가 없으면 `BLOCKED`로 기록하며 가짜 Tape를 만들지 않는다.

### 4단계 — 공통 결과·진단 모델 구현

목표:

- FreeLang source로 결과 맵과 진단 구조를 정의한다.
- 테스트명, suite명, source 위치, assertion 수, effect 목록을 표현한다.
- text/JSON reporter가 공유할 내부 모델을 만든다.

산출물: `result`, `diagnostic`, `summary` native 모듈과 단위 fixture.

검증: 성공·실패·blocked·error 네 상태가 서로 다른 결과를 생성.

### 5단계 — `fl-jest` native core

목표:

- `describe`, `test`, `before_each`, `expect` 선언을 AST 또는 native registry로 수집한다.
- `to_be`, `to_equal`, `to_contain`, `to_throw`를 구현한다.
- case별 격리 컨텍스트와 고정 실행 순서를 구현한다.

산출물: `fl-jest` native module, 성공·실패·예외 fixture.

검증: 외부 Jest 없이 FreeLang 소스만으로 테스트 실행·실패 집계.

### 6단계 — `fl-jest` reporter·CLI 경계

목표:

- FreeLang core의 결과를 text와 JSON으로 출력한다.
- `--filter`, 입력 파일/디렉터리, 종료 코드 `0/1/2`를 정의한다.
- Bash 진입점은 native FreeLang runner 호출과 argv 전달만 담당한다.

산출물: `src/tools/fl-jest.fl` 및 최소 bootstrap.

검증: 같은 입력을 반복 실행해 결과 JSON이 결정론적으로 같은지 비교.

### 7단계 — `fl-effect` native core

목표:

- 테스트 case마다 Tape boundary를 생성한다.
- `trace_effects`와 `to_have_effect`를 native API로 구현한다.
- allow/deny/expect 정책과 effect 순서·인자 비교를 지원한다.

산출물: `effect.fl`, effect fixture, mismatch diagnostic fixture.

검증: 실제 effect 기록, 기대 일치, 기대 불일치, capability 부족을 각각 검증.

### 8단계 — `fl-ci` native orchestration

목표:

- `fl-jest`, `fl-effect`, source check를 하나의 FreeLang 계획으로 조합한다.
- 실패 전파와 `0/1/2` 종료 정책을 구현한다.
- JSON/Text evidence를 생성하고 원시 결과를 보존한다.

산출물: `src/tools/fl-ci.fl`, clean/failure/blocked CI fixture.

검증: clean은 0, 테스트 실패는 1, runner capability 오류는 2를 반환.

### 9단계 — FreeLang tools 통합·회귀

목표:

- `scripts/fl-tools`와 `install.sh`에 최소 bootstrap 명령을 연결한다.
- 기존 `fl-test`, `fl-check`, `fl-review`, `fl-evidence`와 결과 계약을 연결한다.
- 기존 명령의 출력 계약과 테스트를 깨뜨리지 않는다.

산출물: 통합 명령, catalog/adapter 등록, 회귀 fixture.

검증: 기존 저장소 테스트, native tester 테스트, install smoke를 모두 실행.

### 10단계 — 개발 경험·릴리즈 준비

목표:

- watch mode, 실패 case 재실행, Markdown report를 우선순위에 따라 추가한다.
- 병렬 실행은 Tape 충돌과 결정론성 증거가 있을 때만 검토한다.
- 문서, changelog, release gate, handoff를 정리한다.

산출물: 최종 사용자 문서, 예제 프로젝트, 릴리즈 검증 보고서.

검증: clean checkout에서 외부 Jest와 GitHub API 없이 전체 native 흐름을 재현.

## 8. 검증 계획

각 단계에서 다음 순서를 지킨다.

```text
FreeLang syntax check
→ native runtime run
→ expected failure run
→ repeated deterministic run
→ evidence comparison
```

검증하지 않은 기능은 `PASS`로 보고하지 않는다. native Tape API가 없으면 Phase 2를 `BLOCKED`로 기록하고 API를 임의로 흉내 내지 않는다.

## 9. 금지 범위

- Jest/npm 패키지 설치
- Bash/Node에 핵심 assertion·matcher·Tape 비교 로직 작성
- GitHub API를 CI 실행 경로에 포함
- native runtime이 지원하지 않는 문법을 확정 API로 문서화
- 병렬 실행을 먼저 도입하여 결정론성을 훼손

## 10. 현재 판정

```text
PLAN = PROPOSED
IMPLEMENTATION = PHASE_1_RESULT_SCHEMA
NATIVE_FREELANG_CORE = REQUIRED
GITHUB_RUNTIME_DEPENDENCY = NONE
NEXT = ASSERTION_CORE
```
