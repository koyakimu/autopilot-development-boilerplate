# APDドキュメント管理

## イミュータブルなドキュメント管理

- ドキュメントは上書きしない。修正はAmendment（差分ドキュメント）を発行する
- 全サイクルの軌跡が時系列で参照可能
- AIの作業記録: Gitコミットログ + AI Checkpointレビューサマリー
- 人間の判断記録: Decision Record

## ドキュメントツリー

```
project/
├── .claude/
│   └── rules/apd/                        ← APDフレームワーク方針（自動ロード）
├── docs/apd/
│   ├── design/
│   │   └── product-design.md            ← 北極星（滅多に変わらない）
│   ├── specs/
│   │   ├── {context}.v{N}.md            ← イミュータブル
│   │   ├── {context}.v{N}.A-{NNN}.md    ← Amendment
│   │   └── _cross-context-scenarios.md
│   ├── contract/
│   │   ├── project-contract.v{N}.md     ← イミュータブル
│   │   ├── project-contract.v{N}.C-{NNN}.md ← Amendment
│   │   └── previews/
│   │       └── C-{NNN}/                 ← 成果物プレビュー（図・モック等）
│   ├── decisions/
│   │   └── D-{NNN}.md                   ← 時系列で積み上がる
│   └── cycles/
│       └── C-{NNN}.md
└── src/ + tests/
```

## デフォルトのスペックフォーマット

全APDドキュメントはMarkdown形式（YAML frontmatter付き）で記述する。構造化メタデータはfrontmatter、自由記述はMarkdown本文に配置する。

````markdown
---
spec_id: "{CONTEXT_ID}-{NNN}"
context: "{コンテキスト名}"
version: 1
cycle_ref: "C-{NNN}"
title: ""
decision_refs: []
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

## UI Description

{モック or UI記述（該当する場合）}

## Context Boundary

### Inputs
- **From**: {入力元} — {データの説明}

### Outputs
- **To**: {出力先} — {データの説明}

### Dependencies
- **{依存するコンテキスト}**: {依存理由}

## Notes

{追加の考慮事項、制約、前提など}
````
