# Phase 7 — CLI Fixture Expansion Report

상태: `IMPLEMENTED`

## 추가 fixture

- `duplicate.fl`: 최종 결과 marker 중복
- `incomplete.fl`: 최종 JSON은 있으나 완료/exit marker 누락

기존 PASS·FAIL·ERROR·BLOCKED·NOT_RUN·깨진 JSON·프로세스 오류·timeout·signal
fixture와 함께 CLI의 정상·실패·불완전 결과 경계를 실제 shell exit code로
검증한다.
