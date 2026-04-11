---
inclusion: auto
description: Development workflow guidelines for planning, TDD, code review, and commit pipeline
---

# Development Workflow

> This rule extends the git workflow rule with the full feature development process that happens before git operations.
> **참고**: 이 워크플로우는 전체 기능 구현 시의 권장 순서이다. 개별 요청에 대한 에이전트 라우팅은 `agent-routing.md`를 따른다.

The Feature Implementation Workflow describes the development pipeline: planning, TDD, code review, and then committing to git.

## Feature Implementation Workflow

1. **Plan First**
   - **새 프로젝트 요청인 경우**: 요건 분석, 설계 문서, 코드 등 어떤 파일이든 생성하기 전에 반드시 `<project-name>/` 폴더를 먼저 만들고, 모든 산출물(문서 포함)을 그 안에 배치한다. 워크스페이스 루트에 직접 파일을 생성하지 않는다.
   - Use **planner** agent to create implementation plan
   - Identify dependencies and risks
   - Break down into phases

2. **TDD Approach**
   - Use **tdd-guide** agent
   - Write tests first (RED)
   - Implement to pass tests (GREEN)
   - Refactor (IMPROVE)
   - Verify 80%+ coverage

3. **Code Review**
   - Use **code-reviewer** agent immediately after writing code
   - Address CRITICAL and HIGH issues
   - Fix MEDIUM issues when possible

4. **Commit & Push**
   - Detailed commit messages
   - Follow conventional commits format
   - See the git workflow rule for commit message format and PR process
