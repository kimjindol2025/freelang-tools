# FreeLang Tools

> **상태: v11 완료 (v11.1.0-node-free)**
>
> [v11 완료 기록](docs/V11_COMPLETE.md)

FreeLang 프로젝트의 네이티브 개발 CLI, 시험 러너, 감사 도구입니다.

- `fl-tools start <project>` — 방언, runner, Git, 준비 상태 확인
- `fl-tools route <project>` — 프로젝트 실행·검사·시험 경로 확인
- `fl-tools check <project>` — FreeLang 소스 검사
- `fl-tools test <project>` — 프로젝트 시험 실행
- `fl-tools review <project>` — 변경 및 품질 관문 검토
- `fl-tools tester-audit --run` — native tester 감사 실행

v11 cgc-native 고정점은 `e0eb4960665102ae806a243cbfe2c169b0794ecfb2a9a97aae514564e58b8010`이며, 전체 시험 41/41·감사 44/44입니다.

FreeLang native runner가 기본 경로입니다. 일부 Node 프로젝트에 대한 npm 연결은 선택 경로로만 유지됩니다. 옛 Node/bootstrap 방식은 `legacy/`를 참고하세요.
