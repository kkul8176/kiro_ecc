# Kiro ECC (Everything Claude Code) 설정

이 워크스페이스에는 [Everything Claude Code](https://github.com/anthropics/courses/tree/master/everything-claude-code) 프로젝트에서 포팅된 Kiro 전용 에이전트, 스킬, steering, hook 설정이 포함되어 있습니다.

## 구조 개요

```
.kiro/
├── agents/        # 16개 전문 에이전트 (JSON + MD)
├── skills/        # 18개 워크플로우 스킬
├── steering/      # 16개 규칙/가이드라인
├── hooks/         # 10개 자동화 훅
├── scripts/       # 2개 유틸리티 스크립트
└── settings/      # MCP 서버 설정 예시
```

---

## 에이전트 (agents/)

전문 분야별 AI 어시스턴트입니다. Kiro가 작업 유형에 따라 자동으로 선택하거나, `invokeSubAgent`로 명시적 호출이 가능합니다.

| 에이전트 | 역할 | 언제 사용 |
|---|---|---|
| `planner` | 구현 계획 수립 | 복잡한 기능, 리팩터링 |
| `architect` | 시스템 설계, 확장성 | 아키텍처 결정 |
| `code-reviewer` | 코드 품질, 보안 리뷰 | 코드 작성/수정 후 |
| `security-reviewer` | 취약점 탐지, OWASP Top 10 | 인증, API, 민감 데이터 |
| `tdd-guide` | 테스트 주도 개발 | 새 기능, 버그 수정 |
| `build-error-resolver` | 빌드/타입 에러 해결 | 빌드 실패 시 |
| `e2e-runner` | E2E 테스트 (Playwright) | 사용자 플로우 테스트 |
| `database-reviewer` | DB 스키마, 쿼리 최적화 | 데이터베이스 작업 |
| `doc-updater` | 문서 업데이트 | README, 코드맵 갱신 |
| `refactor-cleaner` | 데드 코드 정리 | 코드 유지보수 |
| `go-reviewer` | Go 코드 리뷰 | Go 프로젝트 |
| `go-build-resolver` | Go 빌드 에러 | Go 빌드 실패 |
| `python-reviewer` | Python 코드 리뷰 | Python 프로젝트 |
| `harness-optimizer` | 테스트 하네스 최적화 | 테스트 성능 개선 |
| `loop-operator` | 검증 루프 실행 | 종합 체크 반복 |
| `chief-of-staff` | 프로젝트 관리, 커뮤니케이션 | 멀티채널 관리 |

각 에이전트는 `.json`(CLI용)과 `.md`(IDE용) 두 가지 포맷으로 제공됩니다.

---

## 스킬 (skills/)

채팅에서 `/` 메뉴를 통해 호출할 수 있는 워크플로우입니다.

| 스킬 | 설명 | 언제 사용 |
|---|---|---|
| `tdd-workflow` | TDD 워크플로우 (80%+ 커버리지) | 새 기능, 버그 수정 |
| `coding-standards` | 코딩 표준, 네이밍, 가독성 | 프로젝트 시작, 리뷰 |
| `security-review` | 보안 체크리스트 (OWASP) | 인증, API, 시크릿 처리 |
| `verification-loop` | 빌드→타입체크→린트→테스트→보안 종합 검증 | PR 생성 전 |
| `api-design` | REST API 설계 패턴 | API 설계/리팩터링 |
| `frontend-patterns` | React, Next.js 프론트엔드 패턴 | UI 컴포넌트 개발 |
| `backend-patterns` | Node.js, Express 백엔드 패턴 | API, 서비스 개발 |
| `e2e-testing` | Playwright E2E 테스트 | E2E 테스트 추가 |
| `golang-patterns` | Go 관용구, 동시성 패턴 | Go 프로젝트 |
| `golang-testing` | Go 테이블 기반 테스트, 벤치마크 | Go 테스트 작성 |
| `python-patterns` | Python 관용구, 타입 힌트 | Python 프로젝트 |
| `python-testing` | pytest, 커버리지 | Python 테스트 작성 |
| `database-migrations` | DB 스키마 마이그레이션 | 스키마 변경 |
| `postgres-patterns` | PostgreSQL 최적화 | PostgreSQL 작업 |
| `docker-patterns` | Docker, 컨테이너화 | Dockerfile 작성 |
| `deployment-patterns` | 배포 전략, CI/CD | 배포 설정 |
| `search-first` | 기존 솔루션 탐색 우선 | 새 기능 시작 |
| `agentic-engineering` | AI 에이전트 워크플로우 | 에이전트 시스템 구축 |

---

## Steering (steering/)

Kiro가 대화 중 자동으로 참조하는 규칙과 가이드라인입니다.

### 자동 로드 (auto) — 모든 대화에 적용

| 파일 | 내용 |
|---|---|
| `coding-style.md` | 불변성, 파일 구조, 에러 처리, 코드 품질 체크리스트 |
| `security.md` | 커밋 전 보안 체크, 시크릿 관리, 보안 대응 프로토콜 |
| `testing.md` | 80% 커버리지, TDD 워크플로우, 테스트 유형 |
| `development-workflow.md` | 계획→TDD→코드리뷰→커밋 파이프라인 |
| `git-workflow.md` | Conventional Commits, PR 워크플로우 |
| `patterns.md` | Repository 패턴, API 응답 포맷, 스켈레톤 프로젝트 |
| `performance.md` | 모델 선택 전략, 컨텍스트 윈도우 관리 |
| `lessons-learned.md` | 프로젝트별 패턴, 교훈 (직접 편집 가능) |

### 파일 매칭 (fileMatch) — 해당 파일 편집 시 자동 로드

| 파일 | 트리거 |
|---|---|
| `typescript-patterns.md` | `*.ts`, `*.tsx` |
| `typescript-security.md` | `*.ts`, `*.tsx`, `*.js`, `*.jsx` |
| `python-patterns.md` | `*.py` |
| `golang-patterns.md` | `*.go` |
| `swift-patterns.md` | `*.swift` |

### 수동 호출 (manual) — `#키워드`로 활성화

| 파일 | 호출 방법 | 용도 |
|---|---|---|
| `dev-mode.md` | `#dev-mode` | 구현 집중 모드 |
| `review-mode.md` | `#review-mode` | 코드 리뷰 모드 |
| `research-mode.md` | `#research-mode` | 기술 조사 모드 |

---

## Hook (hooks/)

IDE 이벤트에 반응하여 자동 실행되는 자동화입니다. Agent Hooks 패널에서 개별 토글 가능합니다.

| 훅 | 트리거 | 동작 |
|---|---|---|
| `quality-gate` | 수동 클릭 | 빌드+타입체크+린트+테스트 실행 |
| `typecheck-on-edit` | TS 파일 저장 | 타입 에러 체크 |
| `console-log-check` | JS/TS 파일 저장 | console.log 감지 |
| `auto-format` | JS/TS 파일 저장 | 포맷팅 이슈 수정 |
| `tdd-reminder` | TS 파일 생성 | 테스트 먼저 작성 리마인더 |
| `git-push-review` | shell 명령 실행 전 | git push 전 리뷰 |
| `doc-file-warning` | 파일 쓰기 전 | 불필요한 문서 생성 방지 |
| `code-review-on-write` | 파일 쓰기 후 | 자동 코드 리뷰 |
| `extract-patterns` | 에이전트 종료 시 | lessons-learned.md 패턴 추출 제안 |
| `session-summary` | 에이전트 종료 시 | 세션 요약 생성 |

> ⚠️ `doc-file-warning`과 `git-push-review`는 모든 write/shell 작업을 가로채므로, 대량 파일 작업 시 일시 비활성화를 권장합니다.

---

## 스크립트 (scripts/)

| 스크립트 | 용도 |
|---|---|
| `quality-gate.sh` | 패키지 매니저 자동 감지 후 빌드/타입체크/린트/테스트 실행 |
| `format.sh` | Biome 또는 Prettier 자동 감지 후 파일 포맷팅 |

---

## 글로벌 설정 (~/.kiro/steering/)

아래 steering 파일들은 `~/.kiro/steering/`에도 설치되어 모든 Kiro 프로젝트에 적용됩니다:

- auto (7개): coding-style, security, testing, development-workflow, git-workflow, patterns, performance
- fileMatch (5개): typescript-patterns, typescript-security, python-patterns, golang-patterns, swift-patterns
- `lessons-learned`, `dev-mode`, `review-mode`, `research-mode`는 프로젝트별로 다르므로 로컬에만 존재

---

## 권장 워크플로우

1. 기능 계획 → `planner` 에이전트 또는 Kiro Spec 사용
2. 테스트 먼저 → `tdd-workflow` 스킬 호출
3. 구현 후 리뷰 → `code-reviewer` 에이전트 자동 실행
4. 보안 체크 → `security-reviewer` 에이전트
5. 종합 검증 → `verification-loop` 스킬 또는 `quality-gate` 훅 클릭
6. 커밋 → Conventional Commits 형식

---

## 출처

[Everything Claude Code (ECC)](https://github.com/anthropics/courses/tree/master/everything-claude-code) v1.10.0에서 포팅.
Kiro 포팅 기여: [@ihimanss](https://github.com/ihimanss), [@aws-hsungmin](https://github.com/aws-hsungmin)
