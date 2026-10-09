# Phase 10 — Release Gate Preparation Report

기준 변경: Phase 9 `2b11e92`

## 이번 단계의 범위

- Effect Tape capability probe를 GitHub Native CI에 연결
- runtime checkout이 workflow의 전체 SHA와 일치하는지 검증
- API 미지원과 일반 runtime 오류를 분리
- Effect Tape 자체는 runtime 미지원이므로 계속 `BLOCKED`

## 오류 분류 계약

`fn-doc trace_effects`의 결과를 구조화된 JSON으로 확인한다.

| 조건 | 판정 |
|---|---|
| 문법 검사 실패 | `ERROR` |
| `fn-doc` 명령 자체 오류 또는 깨진 JSON | `ERROR` |
| API 문서 `found:false` + probe 실행 실패 + body 미실행 | `BLOCKED` |
| API 문서 `found:true` + probe 실행 실패 | `ERROR` |
| API 문서 `found:true` + 실행 성공 + body 실행 | `SUPPORTED` |
| API 미존재인데 실행 성공 | `ERROR` |

문자열로 runtime 오류 종류를 추측하지 않는다. `fn-doc`의 구조화된
`found` 필드와 실제 실행 종료코드를 함께 사용한다.

## Runtime 환경

GitHub Actions는 `kimjindol2025/freelang-v11`의 checkout 가능한
`3eba7f1def12000e5327265677f3d9a786330fae`를 사용하고, checkout 직후
`git rev-parse HEAD`가 환경 변수와 같은지 검증한다.

로컬 canonical runtime `e73c58378a1bb1afb776b7abc4b43eb859006530`은 현재
GitHub runtime 저장소에 게시되어 있지 않다. 따라서 두 SHA가 같다고
주장하지 않고, CI는 실제 checkout SHA를 증거로 남긴다. canonical runtime을
GitHub에 게시한 뒤에만 동일 SHA로 통일할 수 있다.

## 로컬 검증

```text
bash -n scripts/fl-effect-capability tests/capability/effect-tape-probe.sh: PASS
npm run test:effect-capability: PASS
CHECK_EXIT=0
API_DOC_EXIT=1 (found:false의 공식 미존재 반환)
RUN_EXIT=1
API_DOC_STATUS=UNAVAILABLE
EFFECT_TAPE_PROBE=BLOCKED
probe body: 미실행
```

## 현재 판정

Phase 10 release gate는 아직 `READY`가 아니다. Effect Tape가 `BLOCKED`이고,
로컬 canonical SHA와 GitHub checkout SHA도 아직 동일하지 않다. 이번 단계는
잘못된 `BLOCKED`/`ERROR` 혼동을 제거하고 CI 환경의 실제 SHA를 검증하는
준비 단계다.
