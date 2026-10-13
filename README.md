# FreeLang Tools

FreeLang 프로젝트에서 공통으로 사용하는 개발자 CLI와 테스트 러너.

## 다른 서버에 설치

저장소가 공개되어 있으면 다른 서버에서 다음 한 줄로 설치할 수 있다.

```bash
curl -fsSL https://raw.githubusercontent.com/kimjindol2025/freelang-tools/main/install.sh | sh
```

설치기는 `sudo`를 사용하지 않고 다음 위치에만 설치한다.

```text
$HOME/.local/share/freelang-tools
$HOME/.local/bin/fl-tools
$HOME/.local/bin/fl-test
```

`$HOME/.local/bin`이 PATH에 없으면 설치기가 추가할 명령을 출력한다.
비공개 저장소에서는 먼저 인증된 `git clone` 또는 `gh repo clone`을 수행한 뒤
저장소 안에서 `./install.sh`를 실행하거나, `GITHUB_TOKEN`/`GH_TOKEN`을
안전한 환경 변수로 전달해야 한다. 토큰을 URL이나 저장소 설정에 기록하지 않는다.

## 웹 사용 설명서

브라우저에서 명령어를 검색하고 설명·사용법·주의사항을 확인할 수 있는 정적
매뉴얼이 `docs/`에 있다. GitHub Pages workflow가 `main`의 변경을 자동으로
게시한다.

```text
docs/index.html
docs/style.css
docs/app.js
```

GitHub 저장소의 **Settings → Pages → GitHub Actions**를 Pages 소스로 선택하면
다음 주소 형식으로 볼 수 있다.

```text
https://kimjindol2025.github.io/freelang-tools/
```

## 명령

```bash
fl-tools init .
fl-tools start .
fl-tools ready .
fl-tools ai ready
fl-tools ai verify
fl-tools ai verify --deep
fl-tools ai run
fl-tools ai run --deep
fl-tools server install
fl-tools server status
fl-tools inspect .
fl-tools review .
fl-tools report .
fl-tools pipeline .
fl-tools handoff .
fl-tools evidence --json .
fl-tools capabilities .
fl-tools native-core --input evidence.json
fl-tools backend-contract --input backend.json
fl-tools git-native .
fl-tools system-json write /tmp/root /tmp/root/value.json '{"ok":true}'
fl-tools adapter list .
fl-tools airc . status
fl-tools deploy .
fl-tools test
fl-tools check
fl-tools detect .
fl-tools status .
fl-tools route .
fl-tools doctor .
fl-tools session status
fl-tools journal show
fl-tools release-check
fl-tools safe-push --help
fl-tools safety show
fl-test
```

## 전체 도구 목록

Native FreeLang 테스트 프레임워크의 구현 기획은
[`docs/NATIVE-TEST-FRAMEWORK-PLAN.md`](docs/NATIVE-TEST-FRAMEWORK-PLAN.md)에 있다.

현재 작업을 이어받을 때는 [`docs/CODEX-HANDOFF.md`](docs/CODEX-HANDOFF.md)를
먼저 읽고, 일반 사용법은 [`docs/TOOL-USAGE.md`](docs/TOOL-USAGE.md)를 본다.

`fl-tools`는 아래 명령을 하나의 공통 진입점으로 제공한다. 괄호 안의 파일은
각 명령이 실제로 호출하는 내부 도구다.

### 작업 시작·탐색

| 명령 | 역할 |
| --- | --- |
| `fl-tools init [경로]` | `.freelang/worklog.md` 작업 기록 공간 초기화 (`fl-init`) |
| `fl-tools start [경로]` | 프로젝트, 방언, runner, entrypoint, Git, 준비 상태 출력 (`fl-start`) |
| `fl-tools ready [경로]` | AI 실행 전 의존성·runner·Git 준비 상태를 JSON으로 출력 (`fl-ready`) |
| `fl-tools ai ready` | Codex용 자동 프로젝트 탐색·준비 JSON (`freelang.ai/v1`) |
| `fl-tools ai verify` | 경량 native trust 검증과 다음 행동 JSON |
| `fl-tools ai verify --deep` | 전체 테스트·review·workflow까지 포함한 검증 |
| `fl-tools ai run` | 준비 확인 후 경량 검증까지 한 번에 실행 |
| `fl-tools ai run --deep` | 준비 확인 후 전체 신뢰 관문 실행 |
| `fl-tools ai release` | 릴리즈 전 전체 검증과 승인 대기 판정 |
| `fl-tools server install` | 서버 공용 경로에 도구 설치·연결 |
| `fl-tools server status` | 서버 설치·PATH 상태 확인 |
| `fl-tools detect [경로]` | AFJ, FX, AIA, AIRC, Script, Front 자동 감지 (`fl-detect`) |
| `fl-tools route [경로]` | 프로젝트별 실행·검사·테스트 경로 요약 (`fl-route`) |
| `fl-tools inspect [경로]` | detect, route, doctor, status 통합 실행 (`fl-inspect`) |
| `fl-tools adapter list [경로]` | 방언별 runner/adapter 연결 상태 확인 (`fl-adapter`) |
| `fl-tools doctor [경로]` | runner, Git, tests, manifest 기본 건강검진 (`fl-doctor`) |
| `fl-tools status [경로]` | 방언, Git, release, test, selfhost 상태 출력 (`fl-status`) |

### 검사·테스트·증거

| 명령 | 역할 |
| --- | --- |
| `fl-tools check [경로]` | 소스 문법·타입·기본 검사 실행 (`fl-check`) |
| `fl-tools test [경로]` | 프로젝트 방언에 맞는 테스트 runner 실행 (`fl-test`) |
| `fl-test` | `tests/**/*.test.fl` 자동 발견 후 FreeLang 테스트 실행 |
| `fl-tools review [경로]` | check, test, lint, build, diff, 생성물, 계약 drift 검사 (`fl-review`) |
| `fl-tools report [경로]` | status와 review를 완료 보고서로 출력 (`fl-report`) |
| `fl-tools evidence --json [경로]` | 검증 결과와 원시 출력을 JSON으로 보존 (`fl-evidence`) |
| `fl-tools trust [경로]` | check/test/review/evidence/diff/capability를 실제 실행하고 AI용 신뢰 판정 JSON 출력 (`fl-trust`) |
| `fl-tools tester-audit --run` | 선언된 FreeLang native tester를 직접 실행하고 결과를 registry에 제출 |
| `fl-tools tester-audit --run --output 파일` | 실행별 시간·exit code·보고 집계를 포함한 `freelang.tester-evidence/v1` 증거를 보존 |
| `fl-tools tester-audit --input 파일` | 이미 생성된 tester 증거의 누락·재현성·상태를 FreeLang native registry로 판정 (`tester-registry.fl`) |
| `fl-tools ai trust [경로]` | AI 전용 단일 진입점. 최종 판정은 FreeLang native `trust-core.fl`이 계산 |
| `fl-tools ai start/work/verify/release [경로]` | AI 표준 작업 protocol `freelang.ai/v1` |
| `fl-tools workflow-test [--workflows] [--all-tests] [경로]` | 기본 빠른 테스트 프로필 또는 명시한 전체 npm/Jest/Vitest/CI 테스트 실행·증거화 |
| `fl-tools native-workflow --input 파일` | 외부 테스트 결과를 `freelang.workflow/v1` FreeLang 계약으로 검증 |
| 계약 기준 문서 | [`docs/PROTOCOLS.md`](docs/PROTOCOLS.md) |

`fl-tools ai run`은 빠른 프로젝트 trust만 실행하며 `toolAudit=NOT_RUN`이다.
`fl-tools ai run --deep`와 `fl-tools ai release`는 프로젝트 trust와 별도로
31개 FreeLang native tester audit를 실행한다. audit가 `PASS`가 아니면 AI
protocol은 `BLOCKED`와 `next=rerun-native-tester-audit`를 반환한다.
| `fl-tools native-trust --input 파일` | FreeLang native 신뢰 판정 core 직접 실행 (`fl-native-trust`) |
| `fl-tools capabilities [경로]` | FreeLang native capability와 adapter 부족분을 JSON으로 출력 (`fl-capabilities`) |
| `fl-tools native-core --input 파일` | adapter 입력을 FreeLang native route/ready/verdict로 판정 (`fl-native-core`) |
| `fl-tools backend-contract --input 파일` | 시스템/JSON/HTTP/프로세스/권한/Git/실행기 결과를 `freelang.backend-contract/v1`로 통합 (`backend-contract.fl`) |
| `fl-tools git-native [경로]` | argv-safe native Git 읽기 표준 API (`git-core.fl`) |
| `fl-tools system-json <작업> <root> <path> [payload]` | allow-root 파일/JSON 표준 API (`system-json.fl`) |
| `fl-tools handoff [경로]` | 다음 작업자를 위한 `.freelang/handoff.md`와 `handoff.json` 생성 (`fl-handoff`) |
| `fl-tools handoff --verify [경로]` | handoff schema와 현재 Git commit의 stale 여부 검증 |

### 실행·배포·릴리즈

| 명령 | 역할 |
| --- | --- |
| `fl-tools pipeline [경로]` | init → inspect → review → report → handoff 자동 실행 (`fl-pipeline`) |
| `fl-tools pipeline [경로] --deploy` | 검증 통과 후 프로젝트 배포 계약까지 실행 |
| `fl-tools deploy --approve [경로]` | 사용자 승인 후 review, dirty worktree, deploy, smoke, artifact hash 확인 (`fl-deploy`) |
| `fl-tools deploy --internal [경로]` | 고정 Git 커밋을 서버 내부 release/current 경로에 반영하고 smoke 실행 (`fl-internal-deploy`) |
| `fl-tools airc [경로] <명령>` | AIRC의 `airc.fl` CLI를 v11 runner로 실행 (`fl-airc`) |
| `fl-tools release-check` | CHANGELOG, tag, worktree, artifact hash 릴리즈 준비 검사 (`fl-release-check`) |
| `fl-tools safe-push` | push 전 원격·worktree 안전성 검사 (`fl-safe-push`) |
| `fl-tools safety [show|set]` | Skill Atlas 안전정책 모드 조회·변경 (`fl-safety`) |

### 세션·운영 기록

| 명령 | 역할 |
| --- | --- |
| `fl-tools session <명령>` | PM2, 포트, 로그 등 개발 세션 상태 조회 (`fl-session`) |
| `fl-tools journal <명령>` | 작업 시작·결과를 `.freelang/worklog.md`에 기록 (`fl-journal`) |
| `fl-tools help` | 전체 명령 사용법 출력 (`fl-tools`) |

### npm 스크립트 대응

저장소 안에서는 기존 npm 명령 구조를 그대로 사용할 수 있다. 다만 npm script의
실제 진입점은 `fl-tools`이며, npm은 FreeLang 명령을 호출하는 호환 계층이다.

```bash
npm run start
npm run init
npm run inspect
npm run review
npm run report
npm run pipeline
npm run handoff
npm run evidence
npm run trust
npm run adapter
npm run airc
npm run deploy
npm test
npm run check
npm run detect
npm run status
npm run route
npm run doctor
npm run release-check
npm run test:deploy-fixture
```

예를 들어 `npm run review`는 `./scripts/fl-tools review .`로 해석되고,
`npm test`는 `./scripts/fl-tools test .`로 해석된다. 따라서 Codex가 기억하는
npm 명령을 그대로 사용해도 실행 경로는 FreeLang 도구 체계를 따른다.

`init`은 프로젝트의 `.freelang/worklog.md` 작업 기록 공간을 만든다.
`ready`는 설치·빌드·테스트를 실행하지 않는 읽기 전용 사전 점검이다. 통과하면
출력된 `next` 명령으로 AI 검증을 이어갈 수 있으며, `READY_WITH_CHANGES`는
dirty worktree가 있다는 뜻이지 trust 통과를 의미하지 않는다.
`inspect`는 감지·라우팅·건강검진·상태를 한 번에 출력하고, `report`는 테스트와
리뷰 결과를 완료 보고서 형식으로 출력한다. `handoff`는 다음 작업자를 위한
`.freelang/handoff.md`와 기계 검증용 `.freelang/handoff.json`을 만들고,
`handoff --verify`는 기록된 commit이 현재 HEAD와 같은지 확인한다.
`evidence --json`은 검증 결과를 JSON으로 보존한다. `adapter list`는 현재
프로젝트에서 사용할 수 있는 런너를 보여준다.
`pipeline`은 init부터 inspect, review, report, handoff까지 자동 실행한다.
검증만 수행하고 대상 프로젝트에 작업 기록 파일을 만들지 않으려면
`fl-tools pipeline . --read-only`를 사용한다. 이 모드에서는 init/handoff를
건너뛴다.
외부·상용 계약 배포가 필요하면 `fl-tools pipeline . --deploy`를 사용하며, push는 실행하지 않는다.
배포·rollback·push 같은 위험 계약은 계약 검증만으로 실행되지 않으며, 반드시
`--approve`를 명시해야 한다. 승인이 없으면 `APPROVAL=WAITING`과 함께 차단된다.
이 서버에서 코딩용 내부 배포만 할 때는 `fl-tools deploy --internal .`을 사용한다.
내부 배포는 SSH, 공용 포트, PM2를 사용하지 않고 프로젝트의
`.freelang/internal-deploy.sh` 계약만 실행한다. 계약은 고정 커밋을
`releases/<commit>`에 복사하고 `current` 심볼릭 링크를 원자적으로 교체하며,
프로젝트별 DB는 내부 배포 루트의 `shared/db`에 둔다.
`--deploy`도 dirty worktree 보호를 유지하므로, 작업 기록 파일을 먼저 commit하거나
명시적으로 `FREELANG_ALLOW_DIRTY_DEPLOY=1`을 설정해야 한다.

`fl-test`는 먼저 명시적 테스트 계약(`FREELANG_TEST_CONTRACT`,
`.freelang/test.sh`, `scripts/verify.sh`, `scripts/test`)을 찾고 실행한다.
계약이 없으면 현재 프로젝트의 `tests/**/*.test.fl`을 자동 발견하고, AFJ
런타임의 `check → run`과 `deftest`/`is`/`is=`/`run-tests` 결과를 검사한다.
테스트가 없으면 `FREELANG_TEST=NOT_RUN`, 종료코드 3을 반환하며
review/report/deploy를 통과시키지 않는다.

`*-live.test.fl`은 기본 테스트 목록에서 제외한다. 네트워크·외부 서버가 실제로
준비된 경우에만 `FL_TOOLS_HTTP_TEST_URL` 또는
`FL_TOOLS_INCLUDE_LIVE_TESTS=YES`를 명시해 실행한다. `SKIPPED`, `FAIL`,
`BLOCKED` 결과는 PASS로 승격하지 않으며, 최종 FreeLang 보고서의 `complete`,
`status`, 집계 필드가 함께 PASS여야 통과한다.

AIRC 프로젝트는 다음처럼 기존 `airc.fl` CLI를 공통 도구에서 호출할 수 있다.

```bash
fl-tools detect /path/to/airc-project
fl-tools check /path/to/airc-project
fl-tools airc /path/to/airc-project status
```

실행기는 프로젝트의 `bootstrap.js`, `FREELANG_AIRC_RUNNER`,
`FREELANG_V11_RUNNER`, 서버의 v11 runner 순서로 찾는다. 오래된 절대 경로를
참조하거나 runner 의존성이 없으면 실행을 PASS로 위장하지 않고 실제 오류를
그대로 보고한다.

AFJ 런너 위치는 기본적으로 다음을 사용한다.

```text
/home/kim/kim/platform/freelang-afj/bootstrap.js
```

다른 환경에서는 다음처럼 지정한다.

```bash
FREELANG_AFJ_RUNNER=/path/to/bootstrap.js fl-test
```

프로젝트에 설치하지 않고도 PATH에 연결해 사용할 수 있다.

```bash
ln -s "$PWD/scripts/fl-tools" "$HOME/.local/bin/fl-tools"
ln -s "$PWD/scripts/fl-test" "$HOME/.local/bin/fl-test"
```

## 테스트 파일 규약

```freelang
(deftest "산술" (is= 3 (+ 1 2)))
(run-tests)
```

테스트 파일은 `tests/*.test.fl` 또는 하위 디렉터리의 `*.test.fl` 이름을 사용한다.

`fl-tools`는 계열을 강제로 통합하지 않는다. AFJ, FX, AIA, AIRC, Script, Front를
판별하고 현재 연결된 어댑터가 없으면 `BLOCKED` 또는 `UNRESOLVED`로 보고한다.

Node/MCP 프로젝트는 `NODE/MCP` 프로파일로 감지한다. workflow 테스트는 기본적으로
`test:fast` 프로필을 우선 실행하고, 전체 테스트는 `--all-tests`를 명시해야 한다.
명령당 45초 wall-clock, 30초 CPU, 전체 180초, 최대 6개 명령으로 제한되며 제한
초과는 테스트 실패가 아닌 `BLOCKED`로 기록된다.
프로젝트별로 더 긴 제한이 필요하면 루트 `freelang-tools.json`의 `workflow`
계약에서 양의 정수 초/명령 수를 선언할 수 있다.
배포·릴리스·push 명령은 자동 실행하지 않는다.

## 운영 명령

표준 작업 흐름은 다음 세 명령이다.

```text
START → CODING → REVIEW → DEPLOY
```

- `start`: 프로젝트·방언·runtime·entrypoint·테스트·Git 상태를 확인한다.
- `review`: check, test, build/lint, diff, 계약·생성물 검사를 묶는다.
- `deploy`: review PASS 이후 프로젝트가 제공한 배포·smoke 계약만 실행한다.
  배포 계약이 없으면 서버 구조를 추측하지 않고 `DEPLOY=BLOCKED`로 끝난다.

배포 경로 자체는 실제 서버에 연결하지 않는 fixture로 검증한다.

```bash
npm run test:deploy-fixture
```

- `route`: 프로젝트 방언·runner·개발/테스트 명령을 요약한다.
- `doctor`: runner, Git, 테스트, 기본 manifest를 점검한다.
- `session`: PM2와 포트·로그를 조회한다. 알 수 없는 서비스를 임의로 재시작하지 않는다.
- `journal`: `.freelang/worklog.md`에 작업 시작·결과를 기록한다.
- `release-check`: CHANGELOG, tag, worktree, artifact hash 준비 상태를 검사한다.
- `safe-push`: `--push`를 명시하기 전에는 원격 상태만 검사한다.
