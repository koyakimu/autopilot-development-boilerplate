# サイクルトリガー — プロンプト

## 使い方

すべての変更はサイクルとして開始します。このプロンプトで、トリガー種別に応じたサイクル定義を作成し、  
適切なフェーズに進みます。

---

## プロンプト: サイクル開始

````
あなたはAPD（Autopilot Development）フレームワークにおけるリーダーエージェントです。

## タスク

新しい変更サイクルを開始します。以下の情報に基づき、サイクル定義を作成し、適切なフェーズに誘導してください。

## インプット

変更の概要:
{{変更内容を自由記述で記入}}

## サイクル定義の作成手順

### 1. トリガー種別の判定

入力内容から、以下のいずれかに分類してください:

| トリガー | 判定基準 | 通過フェーズ |
|---------|---------|------------|
| `new_product` | 新プロダクト or Design文書の枠を超える方向転換 | Phase 0 → 1 → 2 → 3 |
| `feature_addition` | 既存Design内の新機能追加 | Phase 1 → 2 → 3 |
| `bug_fix` | バグ修正 or 小さな改善 | Phase 1(Amendment) → 3 |
| `tech_change` | リファクタ・依存更新・技術的改善 | Phase 2(Amendment) → 3 |

### 2. サイクルIDの採番

既存の docs/apd/cycles/ ディレクトリを確認し、次の連番を付与。

### 3. サイクル定義の生成

以下のYAMLフォーマットで出力:

```yaml
cycle_id: C-{NNN}
trigger: "{トリガー種別}"
title: "{変更のタイトル}"
design_ref: "docs/apd/design/product-design.yaml"
started_at: "YYYY-MM-DDTHH:MM:SSZ"

# 以下はトリガー種別に応じて記入
spec_changes:
  - type: "new_spec / amendment"
    id: "{SPEC_ID}"              # new_spec の場合
    target: "{既存SPEC_ID}"      # amendment の場合
    amendment_id: "A-{NNN}"      # amendment の場合
    context: "{コンテキスト名}"

contract_changes:
  - type: "new / amendment"
    amendment_id: "C-{NNN}"      # amendment の場合
    change: "{変更概要}"

decisions: []  # サイクル進行中に追加される
```

### 4. 次のアクション

トリガー種別に応じて、適切なフェーズのプロンプトに進むよう案内:

- `new_product` → "Phase 0: Design のプロンプトを使用してください"
- `feature_addition` → "Phase 1: Spec のプロンプト（機能追加）を使用してください"
- `bug_fix` → "Phase 1: Spec のプロンプト（バグ修正）を使用してください"
- `tech_change` → "Phase 2: Contract のプロンプトでAmendmentを作成してください"

## 出力

1. サイクル定義 YAML
2. トリガー種別の判定理由
3. 次のアクションの案内
````

---

## クイックリファレンス: サイクルフロー図

````
人間: "こういう変更がしたい"
         │
         ▼
   ┌─────────────┐
   │ トリガー判定  │
   └──────┬──────┘
          │
    ┌─────┼─────────┬──────────────┐
    ▼     ▼         ▼              ▼
 new_   feature_   bug_fix      tech_change
product addition
    │     │         │              │
    ▼     │         │              │
 Phase 0  │         │              │
 Design   │         │              │
    │     │         │              │
    ▼     ▼         ▼              │
 Phase 1  Phase 1   Phase 1        │
 Spec     Spec      Amendment      │
    │     │         │              │
    ▼     ▼         │              ▼
 Phase 2  Phase 2   │          Phase 2
 Contract Contract  │          Amendment
    │     差分      │              │
    ▼     ▼         ▼              ▼
 Phase 3  Phase 3   Phase 3    Phase 3
 Execute  Execute   Execute    Execute
    │     │         │              │
    ▼     ▼         ▼              ▼
  完了    完了      完了          完了
````
