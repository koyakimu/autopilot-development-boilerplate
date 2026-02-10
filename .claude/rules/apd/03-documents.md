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
│   │   └── product-design.yaml          ← 北極星（滅多に変わらない）
│   ├── specs/
│   │   ├── {context}.v{N}.yaml          ← イミュータブル
│   │   ├── {context}.v{N}.A-{NNN}.yaml  ← Amendment
│   │   └── _cross-context-scenarios.yaml
│   ├── contract/
│   │   ├── project-contract.v{N}.yaml   ← イミュータブル
│   │   ├── project-contract.v{N}.C-{NNN}.yaml ← Amendment
│   │   └── previews/
│   │       └── C-{NNN}/                 ← 成果物プレビュー（図・モック等）
│   ├── decisions/
│   │   └── D-{NNN}.yaml                 ← 時系列で積み上がる
│   └── cycles/
│       └── C-{NNN}.yaml
└── src/ + tests/
```

## デフォルトのスペックフォーマット

```yaml
spec_id: "{CONTEXT_ID}-{NNN}"
context: "{コンテキスト名}"
version: 1
cycle_ref: "C-{NNN}"

title: ""
user_story:
  as_a: ""       # 誰が
  i_want: ""     # 何を
  so_that: ""    # なぜ

acceptance_criteria:
  - id: "AC-001"
    given: ""
    when: ""
    then: ""

ui_description: ""   # モック or UI記述（該当する場合）

context_boundary:
  inputs: []
  outputs: []
  dependencies: []

notes: ""
```
