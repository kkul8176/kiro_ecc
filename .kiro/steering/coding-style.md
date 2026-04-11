---
inclusion: auto
description: Core coding style rules including immutability, file organization, error handling, and code quality standards.
---

# Coding Style

## Immutability (CRITICAL)

ALWAYS create new objects, NEVER mutate existing ones:

```
// Pseudocode
WRONG:  modify(original, field, value) → changes original in-place
CORRECT: update(original, field, value) → returns new copy with change
```

Rationale: Immutable data prevents hidden side effects, makes debugging easier, and enables safe concurrency.

## File Organization

MANY SMALL FILES > FEW LARGE FILES:
- High cohesion, low coupling
- 200-400 lines typical, 800 max
- Extract utilities from large modules
- Organize by feature/domain, not by type

## Error Handling

ALWAYS handle errors comprehensively:
- Handle errors explicitly at every level
- Provide user-friendly error messages in UI-facing code
- Log detailed error context on the server side
- Never silently swallow errors

## Input Validation

ALWAYS validate at system boundaries:
- Validate all user input before processing
- Use schema-based validation where available
- Fail fast with clear error messages
- Never trust external data (API responses, user input, file content)

## Code Quality Checklist

Before marking work complete:
- [ ] Code is readable and well-named
- [ ] Functions are small (<50 lines)
- [ ] Files are focused (<800 lines)
- [ ] No deep nesting (>4 levels)
- [ ] Proper error handling
- [ ] No hardcoded values (use constants or config)
- [ ] No mutation (immutable patterns used)

## Cloud-Ready Coding (배포 대비)

로컬에서 클라우드로 전환할 때 깨지지 않도록, 개발 시점부터 다음을 지킨다:

- **환경 변수 외부 주입**: DB 연결 문자열, API URL, 시크릿 등은 반드시 환경 변수(`process.env`, `os.environ` 등)로 읽는다. `.env` 파일에 기본값을 두되, 코드에 하드코딩하지 않는다.
- **헬스체크 엔드포인트**: HTTP 서버가 있는 앱은 `GET /health` (또는 `GET /`) 엔드포인트를 만든다. 200 응답만 반환하면 된다. 로드밸런서/컨테이너 오케스트레이터가 이걸로 앱 상태를 확인한다.
- **포트 설정 유연화**: 서버 포트를 `PORT` 환경 변수로 설정 가능하게 한다. 기본값은 두되 (`const port = process.env.PORT || 3000`), 고정하지 않는다.
- **로컬 파일 시스템 비의존**: 업로드 파일, 임시 파일 등을 로컬 디스크에 영구 저장하지 않는다. 클라우드에서는 컨테이너가 재시작되면 파일이 사라진다. 파일 저장이 필요하면 외부 스토리지(S3 등) 연동을 고려한다.
- **CORS 설정 유연화**: 허용 도메인을 환경 변수로 설정 가능하게 한다. `localhost`만 하드코딩하지 않는다.
- **Graceful Shutdown**: `SIGTERM` 시그널을 받으면 진행 중인 요청을 마무리하고 종료하는 로직을 넣는다. 컨테이너 환경에서 필수.
