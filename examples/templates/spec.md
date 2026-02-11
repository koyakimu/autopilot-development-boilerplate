<!-- Specテンプレート: YAML frontmatter + Markdown -->
<!-- CLAUDE.mdのデフォルトスペックフォーマットに準拠 -->

---
spec_id: "{CONTEXT_ID}-{NNN}"   # 例: OM-001
context: "{コンテキスト名}"       # 例: order-management
version: 1
cycle_ref: "C-{NNN}"
created_at: "YYYY-MM-DDTHH:MM:SSZ"
title: "{機能タイトル}"
decision_refs: []
# - D-001
# - D-002
---

## User Story

**As a** {誰が}
**I want** {何を}
**So that** {なぜ}

## Acceptance Criteria

### AC-001
- **Given**: {前提条件}
- **When**: {トリガーとなる操作}
- **Then**: {期待される結果}

### AC-002
- **Given**: {前提条件}
- **When**: {トリガーとなる操作}
- **Then**: {期待される結果}

### AC-003 (Error Case)
- **Given**: {エラーが起きる前提条件}
- **When**: {操作}
- **Then**: {エラー時の期待動作}

## UI Description

{画面の構成、主要要素、インタラクションの説明}
{モックツールへの指示がある場合はここに記載}

## Context Boundary

### Inputs
- **From**: {入力元コンテキスト or 外部} — {データの説明}

### Outputs
- **To**: {出力先コンテキスト or 外部} — {データの説明}

### Dependencies
- **{依存するコンテキスト}**: {依存理由}

## Notes

{追加の考慮事項、制約、前提など}
