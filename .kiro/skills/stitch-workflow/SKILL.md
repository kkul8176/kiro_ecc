---
name: stitch-workflow
description: >
  Stitch MCP를 활용한 디자인 시스템 구성 및 페이지 디자인 워크플로우.
  Stitch로 디자인 작업을 수행할 때 활성화한다.
metadata:
  origin: ECC
---

# Stitch 디자인 워크플로우

Stitch MCP 도구를 사용하여 디자인 시스템을 구성하고 페이지를 디자인하는 워크플로우이다.

## 언제 사용하나

- 사용자가 Stitch를 사용한 디자인을 요청한 경우
- 브랜딩 사이트를 참고한 디자인 시스템 구성이 필요한 경우
- 다수 페이지의 일관된 디자인이 필요한 경우

## Stitch 디자인 시스템 구성

### 1. 프로젝트 생성
```
mcp_stitch_create_project(title: "프로젝트명")
```

### 2. 디자인 시스템 생성
참고 웹사이트의 색상, 폰트, 스타일을 분석하여 디자인 시스템을 구성한다.
```
mcp_stitch_create_design_system(
  projectId: "...",
  designSystem: {
    displayName: "디자인 시스템명",
    theme: {
      colorMode: "LIGHT" | "DARK",
      headlineFont: "INTER" | "MANROPE" | ...,
      bodyFont: "INTER" | "MANROPE" | ...,
      roundness: "ROUND_EIGHT",
      customColor: "#hex색상"
    }
  }
)
```

### 3. 디자인 시스템 적용
```
mcp_stitch_update_design_system(...)
```

## 페이지 디자인 생성

### 텍스트 프롬프트로 스크린 생성
```
mcp_stitch_generate_screen_from_text(
  projectId: "...",
  prompt: "페이지 설명",
  deviceType: "DESKTOP" | "MOBILE" | "TABLET"
)
```

### 기존 스크린 수정
```
mcp_stitch_edit_screens(
  projectId: "...",
  selectedScreenIds: ["스크린ID"],
  prompt: "수정 내용"
)
```

### 변형 생성
```
mcp_stitch_generate_variants(
  projectId: "...",
  selectedScreenIds: ["스크린ID"],
  prompt: "변형 설명",
  variantOptions: {
    variantCount: 3,
    creativeRange: "EXPLORE",
    aspects: ["LAYOUT", "COLOR_SCHEME"]
  }
)
```

## 로컬 파일 저장 (필수)

Stitch에서 스크린을 생성한 것만으로는 산출물이 완성된 것이 아니다. **반드시 로컬 파일로 저장해야 한다.**

### 저장 절차
1. `mcp_stitch_get_screen`으로 각 스크린의 HTML 코드를 가져온다.
2. `design/{페이지명}.html` 파일로 저장한다.
3. 파일 명명 규칙: `{페이지명}.html` (예: `HomePage.html`, `SearchPage.html`)
4. **저장 후 `listDirectory`로 design/ 폴더를 확인하여 파일이 실제로 존재하는지 자체 검증한다.**
5. design/ 폴더에 HTML 파일이 0개이면 저장이 실패한 것이므로 재시도한다.

> Stitch 프로젝트에 스크린이 존재하는 것과 로컬 design/ 폴더에 파일이 존재하는 것은 다르다.

## 디자인 수정 (Stitch 기반)

기존 Stitch 디자인을 수정할 때:
1. `mcp_stitch_list_projects`, `mcp_stitch_list_design_systems`로 현재 설정을 확인한다.
2. 디자인 시스템의 색상, 폰트, 컴포넌트 스타일을 유지하면서 수정한다.
3. `mcp_stitch_edit_screens`로 변경한다.
4. 변경된 결과물을 HTML로 다시 다운로드하여 `design/` 폴더를 업데이트한다.

## 주요 MCP 도구 목록

| 도구 | 용도 |
|------|------|
| `mcp_stitch_create_project` | 프로젝트 생성 |
| `mcp_stitch_list_projects` | 프로젝트 목록 조회 |
| `mcp_stitch_get_project` | 프로젝트 상세 조회 |
| `mcp_stitch_create_design_system` | 디자인 시스템 생성 |
| `mcp_stitch_update_design_system` | 디자인 시스템 수정 |
| `mcp_stitch_list_design_systems` | 디자인 시스템 목록 |
| `mcp_stitch_generate_screen_from_text` | 텍스트로 스크린 생성 |
| `mcp_stitch_edit_screens` | 스크린 수정 |
| `mcp_stitch_generate_variants` | 변형 생성 |
| `mcp_stitch_get_screen` | 스크린 상세 (HTML 코드) |
| `mcp_stitch_list_screens` | 스크린 목록 |
| `mcp_stitch_apply_design_system` | 디자인 시스템 적용 |
