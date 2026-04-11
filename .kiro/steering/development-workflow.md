---
inclusion: auto
description: Development workflow guidelines for planning, TDD, code review, and commit pipeline
---

# Development Workflow

> This rule extends the git workflow rule with the full feature development process that happens before git operations.
> **참고**: 이 워크플로우는 전체 기능 구현 시의 권장 순서이다. 개별 요청에 대한 에이전트 라우팅은 `agent-routing.md`를 따른다.

The Feature Implementation Workflow describes the development pipeline: planning, TDD, code review, and then committing to git.

## Feature Implementation Workflow

> 아래 워크플로우에서 에이전트를 순차적으로 invoke하는 경우, `agent-routing.md`의 릴레이 파이프라인 규칙(루프 제한, 에스컬레이션 조건)을 준수한다.

1. **Plan First**
   - **새 프로젝트 요청인 경우**: 요건 분석, 설계 문서, 코드 등 어떤 파일이든 생성하기 전에 반드시 `<project-name>/` 폴더를 먼저 만들고, 모든 산출물(문서 포함)을 그 안에 배치한다. 워크스페이스 루트에 직접 파일을 생성하지 않는다.
   - Use **planner** agent to create implementation plan
   - planner 또는 architect는 프로젝트 초기에 `docs/artifact-manifest.md`를 생성한다 (`artifact-protocol.md` 참조)
   - Identify dependencies and risks
   - Break down into phases

2. **TDD Approach**
   - Use **tdd-guide** agent
   - Write tests first (RED)
   - Implement to pass tests (GREEN)
   - Refactor (IMPROVE)
   - Verify 80%+ coverage

3. **Code Review (리뷰 루프)**
   - **code-reviewer invoke 전 자기 점검 (필수)**: 코드를 작성한 후, code-reviewer에게 넘기기 전에 스스로 다음을 점검한다:
     - 보안 취약점 (하드코딩된 시크릿, 인젝션, XSS)
     - 에러 핸들링 (모든 예외 상황 처리)
     - 성능 (불필요한 연산, 메모리 누수, N+1 쿼리)
     - 코딩 표준 (네이밍, 중복 코드, 복잡도)
     - 사용자 요구사항 완전 반영 여부
   - code-reviewer에게 지적받을 여지를 최소화하는 것이 목표다.
   - Use **code-reviewer** agent immediately after self-check
   - Kiro가 심판 역할: CRITICAL/HIGH는 반영, MEDIUM은 판단, LOW는 유지 가능
   - 수정 → 재리뷰 루프는 **최대 3라운드** (agent-routing.md 릴레이 규칙 참조)
   - 3라운드 후 미해결 시 사용자에게 에스컬레이션

4. **Commit & Push**
   - Detailed commit messages
   - Follow conventional commits format
   - See the git workflow rule for commit message format and PR process
