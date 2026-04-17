#!/bin/bash
# Obsidian 볼트에 Kiro LLM Wiki 폴더 구조 초기화

VAULT="Obsidian Vault"
DATE=$(date +%Y-%m-%d)

echo "=== Kiro LLM Wiki 폴더 구조 초기화 ==="

# 산출물 폴더 (기존)
obsidian vault="$VAULT" create path="Kiro/Projects/README.md" content="---\ntitle: Kiro 프로젝트 인덱스\ntags:\n  - kiro/artifact\n  - kiro/index\n---\n\n# Kiro 프로젝트 인덱스\n\n에이전트 산출물이 프로젝트별로 정리됩니다.\n\n## 프로젝트 목록\n\n- 새 프로젝트가 생성되면 여기에 자동으로 링크됩니다." silent overwrite
echo "✅ Projects/"

obsidian vault="$VAULT" create path="Kiro/Architecture/INDEX.md" content="---\ntitle: Architecture\ntags:\n  - kiro/folder\n---\n\n# Architecture\n\n아키텍처 설계 산출물이 저장됩니다." silent overwrite
echo "✅ Architecture/"

obsidian vault="$VAULT" create path="Kiro/Plans/INDEX.md" content="---\ntitle: Plans\ntags:\n  - kiro/folder\n---\n\n# Plans\n\n구현 계획 산출물이 저장됩니다." silent overwrite
echo "✅ Plans/"

obsidian vault="$VAULT" create path="Kiro/Reviews/INDEX.md" content="---\ntitle: Reviews\ntags:\n  - kiro/folder\n---\n\n# Reviews\n\n코드 리뷰 및 보안 리뷰 산출물이 저장됩니다." silent overwrite
echo "✅ Reviews/"

obsidian vault="$VAULT" create path="Kiro/Cloud/INDEX.md" content="---\ntitle: Cloud\ntags:\n  - kiro/folder\n---\n\n# Cloud\n\n클라우드 아키텍처 및 배포 산출물이 저장됩니다." silent overwrite
echo "✅ Cloud/"

obsidian vault="$VAULT" create path="Kiro/Design/INDEX.md" content="---\ntitle: Design\ntags:\n  - kiro/folder\n---\n\n# Design\n\nUI/UX 디자인 산출물이 저장됩니다." silent overwrite
echo "✅ Design/"

# LLM Wiki 폴더 (신규)
obsidian vault="$VAULT" create path="Kiro/Sources/Articles/README.md" content="---\ntitle: Articles\ntags:\n  - kiro/sources\n---\n\n# Articles\n\n외부 기사, 블로그 포스트 등 원본 소스가 저장됩니다.\n\n> 이 폴더의 파일은 불변입니다. LLM은 읽기만 하고 수정하지 않습니다." silent overwrite
echo "✅ Sources/Articles/"

obsidian vault="$VAULT" create path="Kiro/Sources/MeetingNotes/README.md" content="---\ntitle: Meeting Notes\ntags:\n  - kiro/sources\n---\n\n# Meeting Notes\n\n회의록, ARM 결과 등 원본 소스가 저장됩니다.\n\n> 이 폴더의 파일은 불변입니다. LLM은 읽기만 하고 수정하지 않습니다." silent overwrite
echo "✅ Sources/MeetingNotes/"

obsidian vault="$VAULT" create path="Kiro/Sources/Reports/README.md" content="---\ntitle: Reports\ntags:\n  - kiro/sources\n---\n\n# Reports\n\n보고서, 분석 자료 등 원본 소스가 저장됩니다.\n\n> 이 폴더의 파일은 불변입니다. LLM은 읽기만 하고 수정하지 않습니다." silent overwrite
echo "✅ Sources/Reports/"

obsidian vault="$VAULT" create path="Kiro/Wiki/Entities/README.md" content="---\ntitle: Entities\ntags:\n  - kiro/wiki\n---\n\n# Entities\n\n사람, 서비스, 시스템 등 엔티티 페이지가 저장됩니다." silent overwrite
echo "✅ Wiki/Entities/"

obsidian vault="$VAULT" create path="Kiro/Wiki/Concepts/README.md" content="---\ntitle: Concepts\ntags:\n  - kiro/wiki\n---\n\n# Concepts\n\n개념, 패턴, 원칙 등 개념 페이지가 저장됩니다." silent overwrite
echo "✅ Wiki/Concepts/"

obsidian vault="$VAULT" create path="Kiro/Wiki/Comparisons/README.md" content="---\ntitle: Comparisons\ntags:\n  - kiro/wiki\n---\n\n# Comparisons\n\n비교 분석 페이지가 저장됩니다." silent overwrite
echo "✅ Wiki/Comparisons/"

# INDEX.md (위키 전체 카탈로그)
obsidian vault="$VAULT" create path="Kiro/INDEX.md" content="---\ntitle: Kiro Wiki Index\ntags:\n  - kiro/index\ndate: $DATE\n---\n\n# Wiki Index\n\n## 프로젝트 산출물\n| 페이지 | 에이전트 | 날짜 | 요약 |\n|--------|---------|------|------|\n\n## 지식 위키\n| 페이지 | 카테고리 | 소스 수 | 최종 수정 |\n|--------|---------|--------|----------|\n\n## 소스 목록\n| 소스 | 카테고리 | Ingest 날짜 | 관련 위키 페이지 |\n|------|---------|------------|----------------|" silent overwrite
echo "✅ INDEX.md"

# LOG.md (시간순 변경 이력)
obsidian vault="$VAULT" create path="Kiro/LOG.md" content="---\ntitle: Kiro Wiki Log\ntags:\n  - kiro/log\n---\n\n# Wiki Log\n\n## [$DATE] init | LLM Wiki 초기화\n- 작업: Kiro LLM Wiki 폴더 구조 초기화\n- 생성된 폴더: Sources/, Wiki/, Projects/, Architecture/, Plans/, Reviews/, Cloud/, Design/\n- 생성된 파일: INDEX.md, LOG.md" silent overwrite
echo "✅ LOG.md"

echo ""
echo "=== 초기화 완료 ==="
echo "Obsidian에서 Kiro/ 폴더를 확인하세요."
