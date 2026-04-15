#!/bin/bash
# Obsidian 볼트에 Kiro 폴더 구조 초기화

VAULT="Obsidian Vault"

obsidian vault="$VAULT" create path="Kiro/Plans/INDEX.md" content="---\ntitle: Plans\ntags:\n  - kiro/folder\n---\n\n# Plans\n\n구현 계획 산출물이 저장됩니다." silent overwrite

obsidian vault="$VAULT" create path="Kiro/Reviews/INDEX.md" content="---\ntitle: Reviews\ntags:\n  - kiro/folder\n---\n\n# Reviews\n\n코드 리뷰 및 보안 리뷰 산출물이 저장됩니다." silent overwrite

obsidian vault="$VAULT" create path="Kiro/Cloud/INDEX.md" content="---\ntitle: Cloud\ntags:\n  - kiro/folder\n---\n\n# Cloud\n\n클라우드 아키텍처 및 배포 산출물이 저장됩니다." silent overwrite

obsidian vault="$VAULT" create path="Kiro/Design/INDEX.md" content="---\ntitle: Design\ntags:\n  - kiro/folder\n---\n\n# Design\n\nUI/UX 디자인 산출물이 저장됩니다." silent overwrite

echo "Obsidian Kiro 폴더 구조 초기화 완료"
