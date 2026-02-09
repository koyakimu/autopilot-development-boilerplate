---
name: apd-cycle
description: >
  This skill should be used when the user asks to "start a new cycle",
  "begin a change", "add a feature", "fix a bug", "start development",
  "新しいサイクルを開始", "変更を始めたい", or wants to classify and
  initiate a new APD development cycle.
tools: ["Read", "Write", "Glob", "Grep", "Bash"]
---

# APD Cycle — サイクル開始

APDフレームワークにおけるリーダーエージェントとして、新しい変更サイクルを開始する。
ユーザーの変更内容からトリガー種別を判定し、サイクル定義YAMLを生成して適切なフェーズへ誘導する。

## 手順

### 1. 変更内容の確認

ユーザーに変更内容を確認する。まだ伝えられていない場合は「どのような変更を行いたいですか？」と質問する。

### 2. 既存状態の確認

以下をGlob/Readで確認する:

- `docs/apd/cycles/*.yaml` — 既存サイクル一覧（次のサイクルIDを採番するため）
- `docs/apd/design/product-design.yaml` — Design文書の有無
- `docs/apd/specs/*.yaml` — 既存Specの有無
- `docs/apd/contract/*.yaml` — 既存Contractの有無

### 3. トリガー種別の判定

ユーザーの入力内容と既存成果物の状態から、以下のいずれかに分類する:

| トリガー | 判定基準 | 通過フェーズ |
|---------|---------|------------|
| `new_product` | 新プロダクト or Design文書の枠を超える方向転換 | Phase 0 → 1 → 2 → 3 |
| `feature_addition` | 既存Design内の新機能追加 | Phase 1 → 2 → 3 |
| `bug_fix` | バグ修正 or 小さな改善 | Phase 1(Amendment) → 3 |
| `tech_change` | リファクタ・依存更新・技術的改善 | Phase 2(Amendment) → 3 |

### 4. サイクルIDの採番

`docs/apd/cycles/` ディレクトリの既存ファイルを確認し、次の連番 `C-{NNN}` を付与する。
ファイルが存在しない場合は `C-001` から開始。

### 5. サイクル定義の生成

以下の形式で `docs/apd/cycles/C-{NNN}.yaml` を生成する:

```yaml
cycle_id: C-{NNN}
trigger: "{トリガー種別}"
title: "{変更のタイトル}"
design_ref: "docs/apd/design/product-design.yaml"
started_at: "YYYY-MM-DDTHH:MM:SSZ"

spec_changes:
  - type: "new_spec / amendment"
    id: "{SPEC_ID}"
    target: "{既存SPEC_ID}"      # amendment の場合
    amendment_id: "A-{NNN}"      # amendment の場合
    context: "{コンテキスト名}"

contract_changes:
  - type: "new / amendment"
    amendment_id: "C-{NNN}"      # amendment の場合
    change: "{変更概要}"

decisions: []
```

### 6. 出力

1. **サイクル定義YAML** を `docs/apd/cycles/C-{NNN}.yaml` に書き出す
2. **トリガー種別の判定理由** を説明する
3. **次のアクション** を案内する:

| トリガー | 次のアクション |
|---------|-------------|
| `new_product` | `/apd-design` を実行してDesign文書を作成 |
| `feature_addition` | `/apd-spec add` を実行してSpecを生成 |
| `bug_fix` | `/apd-spec bugfix` を実行してSpec Amendmentを作成 |
| `tech_change` | `/apd-contract` を実行してContract Amendmentを作成 |
