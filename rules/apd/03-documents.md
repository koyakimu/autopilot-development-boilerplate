# APD ドキュメント管理

## イミュータブルなドキュメント管理

- ドキュメントは上書きしない。修正は Spec Patch（差分ドキュメント）を発行する
- 全サイクルの軌跡が時系列で参照可能
- AI の作業記録: Git コミットログ + PR 履歴
- 人間の判断記録: Decision Record

## ドキュメントツリー（フラット）

```
project/
├── .claude/
│   └── rules/apd/                ← APD フレームワーク方針（自動ロード）
├── docs/apd/
│   ├── design.md                 ← 北極星（滅多に変わらない）
│   ├── spec-{slug-or-issue}.md   ← Spec 本体
│   ├── spec-{slug}-patch-{NNN}.md ← Spec の差分修正
│   ├── decision-{NNN}.md         ← Decision Record（時系列で積み上がる）
│   └── preview-{slug}/           ← 成果物プレビュー（図・モック等。任意）
└── src/ + tests/
```

サブディレクトリは原則作らない。ファイル名の prefix で分類する。`docs/apd/` 配下のファイル数が増えて見通しが悪くなったら、その時点で構造を見直す。

### 命名の指針

- `spec-{...}.md` の `{...}` 部分は GitHub issue 番号があれば issue 番号、なければ短い slug を使う
- Spec ID は frontmatter で別途定義する（`spec_id: "AUTH-042"` 等）
- ファイル名は人間がディレクトリ一覧で意味を把握できる形にする

## 成果物の場所と参照

| 種類 | 場所 | 備考 |
|------|------|------|
| Design | `docs/apd/design.md` | 全サイクル共通 |
| Spec | `docs/apd/spec-{slug}.md` | サイクル単位 |
| Spec Patch | `docs/apd/spec-{slug}-patch-{NNN}.md` | Spec の差分 |
| Decision Record | `docs/apd/decision-{NNN}.md` | 時系列 |
| 成果物プレビュー | `docs/apd/preview-{slug}/` | 任意 |
| Handoff（試し方） | PR 本文の「試し方」セクション | ファイル化しない |
| 進行中の todo | GitHub issue（あれば）or `docs/apd/todo.md`（フォールバック） | — |

## Spec フォーマット

Markdown 形式（YAML frontmatter付き）。

````markdown
---
spec_id: "{CONTEXT_ID}-{NNN}"
context: "{コンテキスト名}"
version: 1
issue_ref: "{GitHub issue 番号、なければ null}"
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

{モック or UI 記述（該当する場合）}

## Context Boundary

### Inputs
- **From**: {入力元} — {データの説明}

### Outputs
- **To**: {出力先} — {データの説明}

### Dependencies
- **{依存するコンテキスト}**: {依存理由}

## Test Strategy

### AC Coverage

| AC ID | Test Type | Description |
|-------|-----------|-------------|
| AC-001 | unit / integration / e2e | {テスト内容} |

## Deliverable Previews

{生成すべきプレビューの種別と説明（該当する場合）}

## Notes

{追加の考慮事項、制約、前提など}
````

## Handoff（試し方）の場所

Build が完了したら、PR 本文に「## 試し方」セクションを記載する。各 AC を人間が実機で検証できる手順として書く。

ファイル化はしない。理由:
- PR 本文は人間が次に見る場所
- レビュー時に diff と並べて確認できる
- 同じ機能の再 build 時に PR が新しく作られるので、Handoff も自然に最新になる
