# Phase 8 — Native GitHub CI Report

상태: `IMPLEMENTED`

## 변경

- `.github/workflows/native-ci.yml`을 추가했다.
- GitHub Actions는 `freelang-tools`를 checkout하고 고정된 FreeLang runtime
  commit을 별도 checkout한다.
- Node.js 22 환경에서 runtime을 build한 뒤 `fl-ci`, CLI contract,
  timeout/signal isolation, determinism, native regression만 실행한다.
- Jest workflow나 로그 정규식 기반 판정은 호출하지 않는다.
- native evidence artifact를 항상 업로드한다.

## Runtime 고정

- repository: `kimjindol2025/freelang-v11`
- ref: `3eba7f1def12000e5327265677f3d9a786330fae`
- runtime 지원을 증명하지 못하면 workflow는 PASS로 완화하지 않고 실패한다.

## 제한

현재 workflow runtime ref는 GitHub에서 checkout 가능한 검증 커밋이다.
local canonical runtime SHA `e73c583...`가 GitHub 원격에 게시되면 다음
단계에서 ref를 그 전체 SHA로 교체한다. 실제 Effect Tape 지원은 이 workflow가
대신 증명하지 않으며, runtime 미지원 상태는 계속 `BLOCKED`다.
