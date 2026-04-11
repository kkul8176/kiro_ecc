---
inclusion: auto
description: Project-specific patterns, preferences, and lessons learned over time (user-editable)
---

# Lessons Learned

This file captures project-specific patterns, coding preferences, common pitfalls, and architectural decisions that emerge during development. It serves as a workaround for continuous learning by allowing you to document patterns manually.

**How to use this file:**
1. The `extract-patterns` hook will suggest patterns after agent sessions
2. Review suggestions and add genuinely useful patterns below
3. Edit this file directly to capture team conventions
4. Keep it focused on project-specific insights, not general best practices

---

## Project-Specific Patterns

*Document patterns unique to this project that the team should follow.*

### Example: API Error Handling
```typescript
// Always use our custom ApiError class for consistent error responses
throw new ApiError(404, 'Resource not found', { resourceId });
```

---

## Code Style Preferences

*Document team preferences that go beyond standard linting rules.*

### Example: Import Organization
```typescript
// Group imports: external, internal, types
import { useState } from 'react';
import { Button } from '@/components/ui';
import type { User } from '@/types';
```

---

## Kiro Hooks

### `install.sh` is additive-only — it won't update existing installations
The installer skips any file that already exists in the target (`if [ ! -f ... ]`). Running it against a folder that already has `.kiro/` will not overwrite or update hooks, agents, or steering files. To push updates to an existing project, manually copy the changed files or remove the target files first before re-running the installer.

### README.md mirrors hook configurations — keep them in sync
The hooks table and Example 5 in README.md document the action type (`runCommand` vs `askAgent`) and behavior of each hook. When changing a hook's `then.type` or behavior, update both the hook file and the corresponding README entries to avoid misleading documentation.

### Prefer `askAgent` over `runCommand` for file-event hooks
`runCommand` hooks on `fileEdited` or `fileCreated` events spawn a new terminal session every time they fire, creating friction. Use `askAgent` instead so the agent handles the task inline. Reserve `runCommand` for `userTriggered` hooks where a manual, isolated terminal run is intentional (e.g., `quality-gate`).

### 대량 파일 작업 시 `doc-file-warning`과 `git-push-review` hook 비활성화 권장
`doc-file-warning`(preToolUse/write)과 `git-push-review`(preToolUse/shell)는 거의 모든 write/shell 작업을 가로채므로, ECC 설치·스캐폴딩·대량 리팩터링 같은 작업에서 심각한 오버헤드가 발생한다. 이런 작업 전에 Agent Hooks 패널에서 두 hook을 일시 비활성화하고, 작업 완료 후 다시 켜는 것을 권장한다.

---

## Common Pitfalls

*Document mistakes that have been made and how to avoid them.*

### Example: Database Transactions
- Always wrap multiple database operations in a transaction
- Remember to handle rollback on errors
- Don't forget to close connections in finally blocks

### Kiro `executeBash`에서 멀티라인 스크립트와 CRLF 주의
이 워크스페이스의 터미널(zsh)에서 `executeBash`로 멀티라인 스크립트나 세미콜론 체인 명령을 실행하면 `dquote` 오류가 발생한다. CRLF 줄바꿈이 포함된 외부 스크립트도 실행 불가. 대안:
- 복잡한 스크립트는 `fsWrite`로 파일을 먼저 생성한 후 `/bin/bash`로 실행
- 단일 명령을 개별 호출로 분리
- 출력이 깨져 보여도 실제로는 실행되는 경우가 많으므로 `listDirectory`로 결과를 반드시 확인

---

## Architecture Decisions

*Document key architectural decisions and their rationale.*

### Example: State Management
- **Decision**: Use Zustand for global state, React Context for component trees
- **Rationale**: Zustand provides better performance and simpler API than Redux
- **Trade-offs**: Less ecosystem tooling than Redux, but sufficient for our needs

### 멀티 에이전트 오케스트레이션: 명시적 진입점 패턴 권장
`.kiro/agents/`에 에이전트를 정의하는 것만으로는 자동 호출되지 않는다. steering이나 hook 없이는 Kiro 메인 에이전트가 모든 작업을 직접 처리하며, 서브 에이전트는 `invokeSubAgent`가 명시적으로 호출될 때만 실행된다. ("Invoke agent" 문구가 채팅에 표시되어야 실제 서브 에이전트가 동작한 것)

오케스트레이터 패턴을 적용하려면:
- **방법 1**: steering에 "구현/설계 요청은 반드시 `invokeSubAgent`로 architect를 먼저 호출하라"는 강제 규칙 추가
- **방법 2**: `promptSubmit` hook으로 "이 요청을 architect 서브 에이전트에게 위임하세요"를 자동 주입
- 단, 단순 질문/설명 요청까지 architect를 거치면 오버헤드이므로, "구현/설계 요청"에만 적용하는 것이 적절하다.
- **주의**: `development-workflow.md` 같은 steering에 "planner agent 사용"이라고 적어도 이는 가이드라인일 뿐 강제 실행이 아니다. 확실한 호출을 원하면 hook 또는 steering의 명령형 규칙("반드시 ~하라")을 사용할 것.

### 활용도 낮은 에이전트 식별 및 라우팅 제외
`.kiro/agents/`에 등록된 에이전트 중 `harness-optimizer`(Claude Code/Cursor 등 크로스 플랫폼 하네스 최적화), `loop-operator`(자율 에이전트 루프 운영), `chief-of-staff`(멀티채널 커뮤니케이션 관리)는 현재 프로젝트 환경(Kiro + NestJS)에서 직접 활용도가 낮다. `agent-routing.md`의 라우팅 테이블에서 이들을 제외하거나, 명시적으로 "이 프로젝트에서는 사용하지 않음"으로 표기하여 불필요한 라우팅 판단 오버헤드를 줄일 것.

### 새 애플리케이션은 반드시 전용 폴더에 생성
워크스페이스 루트에 직접 프로젝트 파일(package.json, tsconfig.json 등)을 생성하면 다른 프로젝트와 섞인다. 새 애플리케이션을 만들 때는 항상 `<app-name>/` 하위 폴더를 먼저 만들고 그 안에 모든 파일을 구성할 것. 관련 문서(docs/architecture 등)도 해당 앱 폴더 내에 배치한다.

### `agent-routing.md` 적용 시 서브 에이전트 결과의 후처리 패턴
`agent-routing.md`에 의해 서브 에이전트(예: architect)가 invoke되면, 서브 에이전트의 출력은 요약된 형태로 반환된다. 메인 에이전트는 이 결과를 사용자에게 그대로 전달하지 말고, 핵심 내용을 정리하고 다음 단계 선택지를 제시하는 "후처리" 역할을 해야 한다. 서브 에이전트의 raw output은 상세하지만 구조화되지 않을 수 있으므로, 메인 에이전트가 표/다이어그램/코드블록으로 재구성하여 가독성을 높이는 것이 효과적이다.

### steering auto inclusion 과다 시 컨텍스트 윈도우 압박
steering 파일이 `inclusion: auto`로 설정되면 매 대화마다 컨텍스트에 로드된다. 파일이 14개 이상 누적되면 컨텍스트 윈도우를 상당히 소비하여 실제 작업에 쓸 수 있는 공간이 줄어든다. 특정 도메인에만 관련된 steering(예: cloud-cost-awareness, cloud-security-baseline, iac-governance)은 `inclusion: fileMatch` + `fileMatchPattern: "*.tf"` 같은 조건부 포함으로 전환하여, 해당 파일을 다룰 때만 로드되게 하는 것이 효과적이다. 새 steering 추가 시 "이 규칙이 모든 대화에 필요한가?"를 먼저 판단할 것.

---

## Notes

- Keep entries concise and actionable
- Remove patterns that are no longer relevant
- Update patterns as the project evolves
- Focus on what's unique to this project
