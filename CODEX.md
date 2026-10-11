# FreeLang Tools Codex 작업 규칙

이 저장소는 FreeLang 프로젝트를 공통으로 검사·리뷰·배포하기 위한 CLI와
테스트 러너다. 현재 호스트 구현은 Bash이며, FreeLang 테스트 픽스처는
`.fl` 파일로 작성한다.

## Codex 자동 호출 규칙

모든 프로젝트 작업은 아래 순서를 강제한다. 경로를 생략하면 현재 Git root를
자동 탐색한다.

```text
fl-tools ai ready → 작업 → fl-tools ai verify → next
```

1. 시작 전 `fl-tools ai ready`를 실행한다.
2. JSON의 `canProceed`가 `true`일 때만 작업을 계속한다.
3. 수정 후 `fl-tools ai verify`를 실행한다.
4. 전체 테스트나 릴리즈 전에는 `fl-tools ai verify --deep`를 사용한다.
5. `next`, `.freelang/evidence/latest.json`, `.freelang/handoff.json`을 확인한다.
6. `canProceed=false`이면 원인을 보고하고 중단한다.

Codex는 `start`, `inspect`, `review`, `trust`를 기본 조합 경로로 직접 호출하지
않는다. 이 명령들은 내부 호환용이다. 배포·push는 사용자의 명시적 승인 없이는
실행하지 않는다.

## 기본 작업 흐름

```text
init → inspect → check/test → review → report → deploy
```

- `fl-tools init <path>`: `.freelang/worklog.md` 작업 기록 공간을 만든다.
- `fl-tools detect <path>`: FreeLang/AIRC 계열과 런너를 판별한다.
- `fl-tools inspect <path>`: detect, route, doctor, status를 통합 실행한다.
- `fl-tools pipeline <path>`: init, inspect, review, report, handoff를 자동 실행한다.
- `fl-tools start <path>`: 작업 시작 컨텍스트와 준비 상태를 출력한다.
- `fl-tools ready <path>`: 설치·빌드·테스트 없이 Codex가 바로 이어갈 수 있는 준비 상태(JSON)를 확인한다.
- `fl-tools check <path>`: 소스 문법과 테스트를 검사한다.
- `fl-tools review <path>`: check, test, lint, build, diff, 생성물, 계약 drift를 검사한다.
- `fl-tools report <path>`: status와 review를 완료 보고서로 출력한다.
- `fl-tools handoff <path>`: 다음 작업자를 위한 `.freelang/handoff.md`를 생성한다.
- `fl-tools evidence --json <path>`: 검증 결과와 원시 출력을 JSON으로 보존한다.
- `fl-tools ai verify <path>`: AI가 사용하는 정식 검증 진입점이다. 최종 verdict는
  `native/trust-core.fl`이 계산하며 `decision.source=freelang-native`를 요구한다.
- `fl-tools ai ready|work|verify|release [--deep] [path]`: AI protocol `freelang.ai/v1`의 표준 작업 단계다.
- `fl-tools workflow-test <path>`: 프로젝트가 선언한 `npm test`/`test:*`와 선택된 CI 테스트 단계를 실행한다.
  Node/TypeScript/MCP 프로젝트도 `NODE` 프로필로 감지하며, 의존성이 없으면 설치하지 않고 `BLOCKED`로 남긴다.
  CPU/시간/명령 수 제한을 기본 적용해 장시간 테스트가 서버를 점유하지 않도록 한다.
- `fl-tools native-workflow --input <file>`: npm/Jest/Vitest 어댑터 결과를
  `freelang.workflow/v1`로 검증하고 FreeLang 계약 판정을 반환한다.
- `fl-tools native-trust --input <file>`: FreeLang native trust decision core를 직접 실행한다.
- `fl-tools adapter list <path>`: AFJ, FX, AIA, Script, Front 런너 상태를 출력한다.
- `fl-tools airc [path] <command>`: AIRC 프로젝트의 `airc.fl` CLI를 기존 v11 runner로 실행한다.
- `fl-tools deploy <path>`: review 통과 후 프로젝트가 제공한 외부 배포·smoke 계약만 실행한다.
- `fl-tools deploy --internal <path>`: 고정 Git 커밋을 현재 서버 내부 release/current 경로에
  반영하는 `.freelang/internal-deploy.sh` 계약을 실행한다. SSH, 공용 포트, PM2는 사용하지 않는다.

AIRC 프로젝트는 `airc.fl` 또는 `SPEC.airc`와 `.airc` 파일을 기준으로 감지한다.
기존 FreeLang v11 runner를 사용하며, 다른 환경에서는
`FREELANG_AIRC_RUNNER=/path/to/bootstrap.js` 또는
`FREELANG_V11_RUNNER=/path/to/bootstrap.js`를 지정한다.

`pipeline`은 기본적으로 배포와 push를 실행하지 않는다. 배포가 명시적으로
필요할 때만 `fl-tools pipeline <path> --deploy`를 사용한다. 이 모드도 dirty
worktree 보호를 유지하며, 우회는 `FREELANG_ALLOW_DIRTY_DEPLOY=1`을 명시해야 한다.

## 런너 설정

AFJ 런너는 다음 우선순위로 선택된다.

1. `FREELANG_AFJ_RUNNER`
2. 프로젝트의 `bootstrap.js`
3. `FREELANG_AFJ_ROOT/bootstrap.js`
4. `/root/lang/freelang-afj/bootstrap.js`
5. `/root/freelang-afj/bootstrap.js`

환경별 경로는 명시적으로 설정하는 것을 권장한다.

```bash
export FREELANG_AFJ_RUNNER=/path/to/freelang-afj/bootstrap.js
```

## 검증 명령

```bash
bash -n scripts/* install.sh uninstall.sh tests/deploy-fixture/run.sh
npm test
npm run test:deploy-fixture
npm run review -- .
```

검증 결과는 실제 명령의 출력만 근거로 `PASS`, `FAIL`, `BLOCKED`,
`NOT_APPLICABLE` 중 하나로 기록한다. AFJ 런너나 프로젝트 의존성이 없으면
성공으로 추정하지 않는다.

## 안전 규칙

- 사용자 변경과 미추적 파일을 보존한다.
- `git reset --hard`, broad delete, force-push를 사용하지 않는다.
- `fl-tools deploy`는 dirty worktree에서 기본 차단된다.
- `fl-tools safe-push`는 `--push` 없이는 원격 상태만 확인한다.
- commit, push, 실제 배포는 사용자가 명시적으로 요청한 경우에만 수행한다.
- 토큰·개인키·비밀 환경변수는 출력하거나 문서화하지 않는다.

## 새 코드 언어

저장소 루트 작업 규칙에 따라 새 자동화·검증 스크립트는 가능하면 FreeLang
Script를 우선 검토한다. 다만 이 저장소의 기존 CLI는 POSIX/Bash 실행 호환성이
핵심이므로, 런너 통합·운영체제 API·기존 CLI 유지에 필요한 최소 Bash/Node.js
수정은 허용한다.
