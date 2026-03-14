---
name: status
description: >
  This skill should be used when the user asks to "show APD status",
  "check project progress", "what phase am I in", "APDの状態を見せて",
  or wants to know the current state of an APD project.
tools: ["Read", "Glob", "Grep", "Bash"]
---

# APD Status — プロジェクト進行状況の表示

APDフレームワークのプロジェクト状態を成果物の有無から判定し、次のアクションを提案する。

## 手順

### 1. 成果物のスキャン

以下のディレクトリをGlobでスキャンし、存在するファイルを一覧化する:

- `docs/apd/cycles/*.md` — サイクル定義
- `docs/apd/design/*.md` — Design文書
- `docs/apd/specs/*.md` — Spec文書
- `docs/apd/previews/` — 成果物プレビュー
- `docs/apd/decisions/*.md` — Decision Records
- `src/` — 実装コード
- `tests/` — テストコード

### 2. フェーズ状態の判定

成果物の有無から現在のフェーズを推定する:

| 状態 | 判定基準 |
|------|---------|
| 未開始 | docs/apd/cycles/ が空、docs/apd/design/ が空 |
| Phase 0 進行中 | docs/apd/cycles/ にサイクルあり、docs/apd/design/ が空 |
| Phase 0 完了 | docs/apd/design/product-design.md が存在 |
| Phase 1 完了 | docs/apd/specs/ にファイルが存在 |
| Phase 2 完了 | src/ と tests/ にファイルが存在し、テストがパス |

### 3. アクティブサイクルの確認

`docs/apd/cycles/` の最新ファイルを読み込み、トリガー種別と対象フェーズを確認する。

### 4. 状態レポートの出力

以下の形式でレポートを出力する:

```
## APD プロジェクト状態

### アクティブサイクル
- サイクルID: C-XXX
- トリガー: feature_addition
- タイトル: ...

### 成果物インベントリ
- Design: 1ファイル
- Specs: 5ファイル
- Previews: 3ファイル
- Decisions: 2ファイル

### 現在のフェーズ
Phase 1 完了 — Spec生成済み

### 次のアクション
→ `/apd:build` を実行してPhase 2（Build）を開始してください
```

### 5. 次のアクション提案

フェーズ状態に応じて、適切なスキルを提案する:

- 未開始 → `/apd:cycle` でサイクルを開始
- Phase 0 未完了 → `/apd:design` でDesign文書を作成
- Phase 0 完了 → `/apd:spec full` でSpecを生成
- Phase 1 完了 → `/apd:build` でBuildを開始
- Phase 2 完了 → サイクル完了
