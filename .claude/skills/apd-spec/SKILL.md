---
name: apd-spec
description: >
  This skill should be used when the user asks to "generate specs",
  "start Phase 1", "create specifications", "add a feature spec",
  "fix a bug spec", "Specを生成", "仕様書を作成", "機能追加のSpec",
  "バグ修正のAmendment", or wants to generate Spec documents from
  the Design document. Supports three modes: full generation,
  feature addition, and bugfix amendment.
tools: ["Read", "Write", "Glob", "Grep"]
---

# APD Phase 1: Spec — 仕様書の生成

APDフレームワークにおけるSpecフェーズの担当エージェントとして、Design文書からSpec（詳細仕様書）を生成する。

Phase 1は「人間の時間」であり、AIがドラフトを生成し、人間がサマリーと確認依頼箇所だけレビューする。

## 事前準備

以下のファイルを読み込む:

1. **CLAUDE.md** — プロジェクト設定（デフォルトスペックフォーマット、エスカレーションポリシー等）を確認
2. **`docs/apd/design/product-design.yaml`** — Design文書を読み込む
3. **`docs/apd/specs/*.yaml`** — 既存Specがあれば読み込む
4. **`docs/apd/decisions/*.yaml`** — 既存Decision Recordsがあれば読み込む
5. **アクティブサイクル** — `docs/apd/cycles/` の最新ファイルを読み込み、トリガー種別を確認

## モード判定

ユーザーの指示またはサイクル定義のトリガー種別から、実行モードを判定する:

- **full** — 初回フルSpec生成（`new_product` トリガー時）
- **add** — 機能追加Spec（`feature_addition` トリガー時）
- **bugfix** — バグ修正Amendment（`bug_fix` トリガー時）

不明な場合はユーザーに確認する。

---

## モード: full（初回フルSpec生成）

### 生成ルール

1. Design文書の **What** セクションに記載された全機能について Spec を作成する
2. **What Not** に含まれるものは絶対に Spec に入れない
3. 各Specは以下を含む:
   - `spec_id`: コンテキスト略称 + 連番（例: OM-001）
   - ユーザーストーリー（誰が・何を・なぜ）
   - 受け入れ条件（Given/When/Then形式）
   - UI記述またはモック指示（該当する場合）
   - コンテキスト境界の定義（inputs / outputs / dependencies）
4. コンテキスト間のデータフローを特定し、`docs/apd/specs/_cross-context-scenarios.yaml` としてまとめる
5. 判断が必要だった箇所は Decision Record のドラフトを作成する

### 出力

1. **Specファイル群** — `docs/apd/specs/` ディレクトリにYAML形式で書き出す
2. **Exit Criteriaチェックリスト**（下記参照）
3. **確認依頼リスト**（下記参照）
4. **Decision Recordドラフト** — 判断が発生した場合、`docs/apd/decisions/D-{NNN}.yaml` に書き出す

---

## モード: add（機能追加Spec）

### 追加ルール

1. 既存Specとの整合性を確認し、矛盾があれば報告する
2. 新規Specは新ファイルとして作成する（既存ファイルは上書きしない — Immutable原則）
3. 既存Specの修正が必要な場合は **Amendment** として作成する（`docs/apd/specs/{context}.v{N}.A-{NNN}.yaml`）
4. コンテキスト間データフローに影響がある場合、`_cross-context-scenarios.yaml` のAmendmentも作成する

### 出力

fullモードの出力に加え:
- 既存Specへの影響分析
- Amendment が必要な既存Specのリスト

---

## モード: bugfix（バグ修正Amendment）

### トリアージ

まず原因を判定する:

- **Spec起因**（仕様漏れ・曖昧さ）→ Spec Amendment を作成
- **Execute起因**（実装がSpecと合っていない）→ 「Execute起因です。実装修正のみで対応可能です。`/apd-execute` で修正してください」と報告

### Spec起因の場合の出力

1. **Amendment YAML** — `docs/apd/specs/{context}.v{N}.A-{NNN}.yaml`
2. 影響を受ける他のSpecの分析
3. Decision Recordドラフト（仕様判断が必要な場合）

---

## 共通出力: Exit Criteriaチェックリスト

以下の充足状況を表形式でサマリーする:

| Exit Criteria | 状態 | 備考 |
|---|---|---|
| 全機能にスペックが存在する | ✅/⚠️/❌ | |
| 各スペックにユーザーストーリーがある | ✅/⚠️/❌ | |
| 各スペックに受け入れ条件がある | ✅/⚠️/❌ | |
| 各スペックにUI記述がある（該当時） | ✅/⚠️/❌ | |
| コンテキスト境界が定義されている | ✅/⚠️/❌ | |
| コンテキスト間データフローが特定されている | ✅/⚠️/❌ | |
| Decision Recordが作成されている（判断発生時） | ✅/⚠️/❌ | |

## 共通出力: 確認依頼リスト

推論で埋めた箇所、自信がない箇所を明示する:

```
## 確認が必要な箇所
1. [spec_id] [箇所]: [推論内容] ← 確認してください
2. ...
```

## Human Checkpoint 1

Specが完成したら、以下のチェックリストを提示する:

- [ ] Exit Criteriaチェックリストが全て ✅ になっているか
- [ ] 確認依頼リストの各項目について判断を返したか
- [ ] Decision Recordの各判断について decision と reason を記入したか
- [ ] What Not に含まれるものがSpecに紛れ込んでいないか

承認されたら「`/apd-contract` を実行してPhase 2に進んでください（ここから先、人間は基本介入しません）」と案内する。
修正が必要な場合はフィードバックを受けてドラフトを更新する。
