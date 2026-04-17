---
inclusion: auto
description: Obsidian LLM Wiki 구조 및 운영 규칙 - 카파시 LLM Wiki 패턴 기반. 위키 검색, Ingest, 산출물 동기화 시 참조.
---

# Obsidian LLM Wiki 규칙

> 이 규칙은 Obsidian 볼트와 상호작용하는 모든 작업에 적용된다.
> 볼트 이름: `Obsidian Vault`
> CLI 명령 접두사: `obsidian vault="Obsidian Vault"`

## 볼트 구조

```
Kiro/
├── INDEX.md              ← 위키 전체 카탈로그 (검색 시 여기부터)
├── Logs/                 ← 월별 변경 이력
│   ├── INDEX.md          ← 월별 로그 목록
│   └── LOG-YYYY-MM.md    ← 월별 로그 (append-only)
├── Sources/              ← 원본 소스 (불변, 수정 금지)
│   ├── Articles/
│   ├── MeetingNotes/
│   └── Reports/
├── Wiki/                 ← LLM이 관리하는 지식 위키
│   ├── Entities/         ← 사람, 서비스, 시스템
│   ├── Concepts/         ← 개념, 패턴, 원칙
│   └── Comparisons/      ← 비교 분석
├── Projects/             ← 프로젝트별 인덱스
├── Architecture/         ← 아키텍처 산출물
├── Plans/                ← 구현 계획
├── Reviews/              ← 코드/보안 리뷰
├── Cloud/                ← 클라우드/배포
└── Design/               ← UI/UX 디자인
```

## 3레이어 원칙

| 레이어 | 위치 | 소유자 | 규칙 |
|--------|------|--------|------|
| Raw Sources | `Kiro/Sources/` | 사용자 | 불변 — LLM은 읽기만, 수정 금지 |
| Wiki | `Kiro/Wiki/` + 산출물 폴더 | LLM | LLM이 생성/수정/관리 |
| Schema | 이 steering 파일 | 사용자 + LLM | 위키 운영 규칙 |

## 검색 (Query)

위키에서 정보를 찾을 때:

1. **INDEX.md 먼저 읽기** — `obsidian read file="INDEX"` → 관련 페이지 목록 파악
2. **키워드 검색** — `obsidian search query="키워드"` → 전문 검색
3. **페이지 읽기** — `obsidian read file="페이지명"` → 상세 내용 확인
4. **LOG.md 확인** (최근 변경 질문 시) — `obsidian read file="LOG"` → 최근 활동

## Ingest (소스 통합)

외부 소스를 위키에 통합할 때:

1. **소스 저장** — `Kiro/Sources/{카테고리}/` 에 원본 저장 (불변)
2. **요약 작성** — 소스를 읽고 핵심 내용 요약
3. **엔티티 추출** — 사람, 서비스, 시스템, 개념 등 식별
4. **위키 페이지 업데이트** — 기존 페이지에 새 정보 통합, 없으면 새 페이지 생성
5. **크로스레퍼런스** — 관련 페이지 간 `[[위키링크]]` 추가
6. **모순 확인** — 새 정보가 기존 내용과 충돌하면 명시적으로 기록
7. **INDEX.md 업데이트** — 새/수정된 페이지를 카탈로그에 반영
8. **월별 LOG에 기록** — `Kiro/Logs/LOG-YYYY-MM.md`에 Ingest 이력 append

## 산출물 동기화 (Artifact Sync)

에이전트 산출물이 `docs/`에 생성되면 (`obsidian-sync` hook이 처리):

1. type에 따라 적절한 폴더에 Obsidian 노트 생성
2. INDEX.md에 항목 추가
3. 월별 LOG에 기록 append (`Kiro/Logs/LOG-YYYY-MM.md`)
4. 프로젝트 인덱스 노트 업데이트

## INDEX.md 형식

```markdown
---
title: Kiro Wiki Index
tags: [kiro/index]
---

# Wiki Index

## 프로젝트 산출물
| 페이지 | 에이전트 | 날짜 | 요약 |
|--------|---------|------|------|

## 지식 위키
| 페이지 | 카테고리 | 소스 수 | 최종 수정 |
|--------|---------|--------|----------|

## 소스 목록
| 소스 | 카테고리 | Ingest 날짜 | 관련 위키 페이지 |
|------|---------|------------|----------------|
```

## 월별 LOG 형식

로그는 `Kiro/Logs/LOG-YYYY-MM.md` 형식으로 월별 분리하여 관리한다.

파일 구조:
```
Kiro/Logs/
├── INDEX.md           ← 월별 로그 목록
├── LOG-2026-04.md     ← 4월 로그
├── LOG-2026-05.md     ← 5월 로그
└── ...
```

각 월별 LOG 파일 형식:
```markdown
---
title: Kiro Log - YYYY-MM
tags: [kiro/log]
---

# Kiro Log - YYYY-MM

## [YYYY-MM-DD] {type} | {제목}
- 소스/에이전트: {출처}
- 업데이트된 페이지: [[페이지1]], [[페이지2]]
- 새로 생성된 페이지: [[페이지3]]
```

LOG append 시 규칙:
- 현재 월에 해당하는 `LOG-YYYY-MM.md` 파일에 append
- 해당 월 파일이 없으면 새로 생성
- `obsidian vault="Obsidian Vault" append path="Kiro/Logs/LOG-YYYY-MM.md" content="..."`

type: `ingest` | `artifact` | `query` | `lint` | `update` | `eval`

## Wiki Lint (건강 검진)

주기적으로 확인할 항목:
- 고립된 페이지 (인바운드 링크 없음)
- 오래된 정보 (최종 수정이 오래된 페이지)
- 누락된 크로스레퍼런스
- 언급되었지만 페이지가 없는 개념
- 소스 간 모순
