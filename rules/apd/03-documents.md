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
│   ├── previews/
│   │   └── C-{NNN}/                     ← 成果物プレビュー（図・モック等）
│   ├── decisions/
│   │   └── D-{NNN}.md                   ← 時系列で積み上がる
│   └── cycles/
│       ├── C-{NNN}.md                   ← サイクル定義（handoff/evidenceなしの場合）
│       └── C-{NNN}/                     ← サイクル定義 + handoff/evidenceがある場合のディレクトリ形式
│           ├── cycle.md
│           ├── handoffs/
│           │   └── H-{NNN}.md           ← コンテキストリセット時の引き継ぎ（追記のみ）
│           └── evidence/
│               └── {review-id}/{axis-id}/   ← 動作検証の証跡（スクショ・ログ等）
└── src/ + tests/
```

サイクルが handoff や evidence を持つ場合は、`C-{NNN}.md` を `C-{NNN}/cycle.md` に置き換えてディレクトリ化する。持たないサイクルは従来どおり単一ファイルでよい。

ディレクトリ化への移行はサイクル開始時にリーダーが先回りで行う必要はない。最初は単一ファイルで開始し、handoff または evidence が初めて発生する時点でリーダーがディレクトリ形式に変換する（既存 `C-{NNN}.md` を `C-{NNN}/cycle.md` にリネームし、空の `handoffs/` `evidence/` を作成）。

## デフォルトのSpecフォーマット

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

## Evaluation Rubric

Build Phaseの評価ループが反復で参照する**品質軸**の集合。**ACの再掲ではなく、ACで表現しきれない品質軸**（パフォーマンス、エラーハンドリング、UI完成度、アクセシビリティ、AI出力品質など、テスト化が困難な軸）を書く。

> 三層の役割分担:
> - **Acceptance Criteria（AC）**: 機能要件の Given/When/Then。「何が動けば合格か」
> - **Test Strategy**: ACをテストでどうカバーするか。「テスト全パス = AC全充足」を保証する
> - **Evaluation Rubric**: ACを超えた品質軸。「テスト全パスの上で、さらに何をもって良しとするか」を保証する。動作検証（実成果物を動かす）で確認する

### R-001: {評価軸の名前}
- **criteria**: {何を満たせば合格か}
- **verification**:
  - **method**: {どう検証するか — 例: Playwright MCPで実ブラウザ操作 / curl でAPI叩く / pytest 実行}
  - **evidence_required**: [{保存すべき証跡 — 例: screenshot, operation_log, test_output}]
  - **note**: {自動検証不可な場合の代替手段や前提条件}

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

## handoff documentのフォーマット

Build Phaseで長時間化したサイクルがコンテキストリセットを行う場合、リーダーエージェントが書き出す。追記のみ（H-001, H-002 と積み上がる）。新セッションは最新の handoff から再開する。

**揮発する情報のみを書く**。サイクル目的・Spec/Designへの参照・Decision Records一覧などはサイクル定義（`cycle.md`）から辿れるので handoff には書かない。

````markdown
---
handoff_id: "H-{NNN}"
cycle_id: "C-{NNN}"
created_at: "YYYY-MM-DD"
reason: "{なぜリセットしたか}"
boundary: "{どの作業単位の完了境界で切ったか}"
prev_handoff: "{H-{NNN-1} があれば。なければ null}"
---

## Completed Work Units

- [x] {完了済みの作業単位}

## Remaining Tasks

- [ ] {次セッションが取り組むタスク}

## Open Questions

{未解決の問い、エスカレーション候補、リーダーが保留にした判断}

## Test Status

- 通過: {状況}
- 失敗中: {あれば具体的に}
````

新セッションの起動手順:

1. `.claude/rules/apd/` 自動ロード
2. CLAUDE.md 自動ロード
3. 最新の handoff を読む
4. `cycle_id` から サイクル定義（`cycle.md`）を読み、Spec / Design / Decision Records にたどる

## evidence の保存

Build Phaseの動作検証で残す証跡。配置先は `docs/apd/cycles/C-{NNN}/evidence/{review-id}/{axis-id}/`。ファイル名は内容を表す自由記述でよい（例: `screenshot-login.png`、`api-response.json`）。レビューサマリーから「軸ID → evidenceパス」を引けるようにする。
