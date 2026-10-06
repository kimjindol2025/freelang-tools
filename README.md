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
fl-tools inspect .
fl-tools review .
fl-tools report .
fl-tools pipeline .
fl-tools handoff .
fl-tools evidence --json .
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
fl-test
```

## 전체 도구 목록

`fl-tools`는 아래 명령을 하나의 공통 진입점으로 제공한다. 괄호 안의 파일은
각 명령이 실제로 호출하는 내부 도구다.

### 작업 시작·탐색

| 명령 | 역할 |
| --- | --- |
| `fl-tools init [경로]` | `.freelang/worklog.md` 작업 기록 공간 초기화 (`fl-init`) |
| `fl-tools start [경로]` | 프로젝트, 방언, runner, entrypoint, Git, 준비 상태 출력 (`fl-start`) |
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
| `fl-tools handoff [경로]` | 다음 작업자를 위한 `.freelang/handoff.md` 생성 (`fl-handoff`) |

### 실행·배포·릴리즈

| 명령 | 역할 |
| --- | --- |
| `fl-tools pipeline [경로]` | init → inspect → review → report → handoff 자동 실행 (`fl-pipeline`) |
| `fl-tools pipeline [경로] --deploy` | 검증 통과 후 프로젝트 배포 계약까지 실행 |
| `fl-tools deploy [경로]` | review, dirty worktree, deploy, smoke, artifact hash 확인 (`fl-deploy`) |
| `fl-tools deploy --internal [경로]` | 고정 Git 커밋을 서버 내부 release/current 경로에 반영하고 smoke 실행 (`fl-internal-deploy`) |
| `fl-tools airc [경로] <명령>` | AIRC의 `airc.fl` CLI를 v11 runner로 실행 (`fl-airc`) |
| `fl-tools release-check` | CHANGELOG, tag, worktree, artifact hash 릴리즈 준비 검사 (`fl-release-check`) |
| `fl-tools safe-push` | push 전 원격·worktree 안전성 검사 (`fl-safe-push`) |

### 세션·운영 기록

| 명령 | 역할 |
| --- | --- |
| `fl-tools session <명령>` | PM2, 포트, 로그 등 개발 세션 상태 조회 (`fl-session`) |
| `fl-tools journal <명령>` | 작업 시작·결과를 `.freelang/worklog.md`에 기록 (`fl-journal`) |
| `fl-tools help` | 전체 명령 사용법 출력 (`fl-tools`) |

### npm 스크립트 대응

저장소 안에서는 같은 기능을 npm 명령으로도 호출할 수 있다.

```bash
npm run start
npm run init
npm run inspect
npm run review
npm run report
npm run pipeline
npm run handoff
npm run evidence
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

`init`은 프로젝트의 `.freelang/worklog.md` 작업 기록 공간을 만든다.
`inspect`는 감지·라우팅·건강검진·상태를 한 번에 출력하고, `report`는 테스트와
리뷰 결과를 완료 보고서 형식으로 출력한다. `handoff`는 다음 작업자를 위한
`.freelang/handoff.md`를 만들고, `evidence --json`은 검증 결과를 JSON으로
보존한다. `adapter list`는 현재 프로젝트에서 사용할 수 있는 런너를 보여준다.
`pipeline`은 init부터 inspect, review, report, handoff까지 자동 실행한다.
외부·상용 계약 배포가 필요하면 `fl-tools pipeline . --deploy`를 사용하며, push는 실행하지 않는다.
이 서버에서 코딩용 내부 배포만 할 때는 `fl-tools deploy --internal .`을 사용한다.
내부 배포는 SSH, 공용 포트, PM2를 사용하지 않고 프로젝트의
`.freelang/internal-deploy.sh` 계약만 실행한다. 계약은 고정 커밋을
`releases/<commit>`에 복사하고 `current` 심볼릭 링크를 원자적으로 교체하며,
프로젝트별 DB는 내부 배포 루트의 `shared/db`에 둔다.
`--deploy`도 dirty worktree 보호를 유지하므로, 작업 기록 파일을 먼저 commit하거나
명시적으로 `FREELANG_ALLOW_DIRTY_DEPLOY=1`을 설정해야 한다.

`fl-test`는 현재 프로젝트의 `tests/**/*.test.fl`을 자동 발견하고, AFJ
런타임의 `check → run`과 `deftest`/`is`/`is=`/`run-tests` 결과를 검사한다.

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
