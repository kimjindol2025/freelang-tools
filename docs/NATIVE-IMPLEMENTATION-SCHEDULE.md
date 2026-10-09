# Native Tester Implementation Schedule

승인된 최종 구현 순서. 각 단계는 검증 후 독립 커밋·푸시한다.

| 단계 | 목표 | 완료 산출물 |
|---|---|---|
| 1 | `fl-ci` 실행 계약 | schema·상태·exit code 계약 문서와 검증 기준 |
| 2 | 단일 실행 orchestration | `fl-test → fl-effect → fl-ci` 1회 실행 경로 |
| 3 | 최종 JSON/evidence | final JSON 1개와 stdout/stderr/metadata 보존 |
| 4 | 오류·종료 계약 | 깨진 JSON·누락·중복·프로세스 오류 판정 |
| 5 | timeout·signal 격리 | 강제 종료·잔여 프로세스 정리·증거 보존 |
| 6 | 결정론 비교 | 반복 결과에서 assertion/effect 값 보존 검증 |
| 7 | CLI fixture 확대 | timeout·signal·누락·중복·side-effect fixture |
| 8 | native CI 연결 | Jest 없이 `fl-ci`만 호출하는 CI 경계 |
| 9 | Effect Tape capability | 실제 runtime 지원 확인, 미지원은 `BLOCKED` |
| 10 | v0.1 릴리스 | README·schema·release note·tag |

## 공통 금지사항

- 외부 Jest를 핵심 엔진으로 도입하지 않는다.
- 가짜 Effect Tape를 만들지 않는다.
- 핵심 판정을 Bash/Node 정규식으로 이전하지 않는다.
- 테스트 삭제·skip·기대값 완화를 하지 않는다.
- 실행하지 않은 검사를 `PASS`로 기록하지 않는다.

## 단계 완료 규칙

각 단계는 고정 canonical runtime으로 syntax check, focused native test,
실제 실행, 실패 입력 검증, 반복 비교를 수행한다. 변경 파일·명령·실제
exit code·stdout/stderr·증거 경로·미완료/차단 원인을 기록한 뒤 다음 단계로
진행한다.
