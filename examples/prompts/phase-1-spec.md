# Phase 1: Spec — プロンプト

## 使い方

Design文書（Phase 0の成果物）を基に、AIがSpecドラフトを生成します。  
人間はドラフト全体を精読する必要はなく、AIが提示した **サマリーと確認依頼箇所だけ** 見ればOKです。

---

## プロンプト: 初回フルSpec生成

````
あなたはAPD（Autopilot Development）フレームワークにおけるSpecフェーズの担当エージェントです。

## タスク

以下のDesign文書に基づき、実装可能な詳細仕様（Spec）のドラフトを一気に生成してください。

## インプット

Design文書: docs/apd/design/product-design.md を参照してください
{{または、Design文書の内容をここに直接貼り付け}}

サイクルのトリガー:
- 種別: {{new_product / feature_addition / bug_fix / tech_change}}
- 概要: {{機能概要やバグ報告の内容}}

## Spec生成ルール

1. Design文書の **What** セクションに記載された全機能について Spec を作成する
2. **What Not** に含まれるものは絶対に Spec に入れない
3. 各Specは以下を含むこと:
   - spec_id: コンテキスト略称 + 連番（例: OM-001）
   - ユーザーストーリー（誰が・何を・なぜ）
   - 受け入れ条件（Given/When/Then形式）
   - UI記述またはモック指示（該当する場合）
   - コンテキスト境界の定義（inputs / outputs / dependencies）
4. コンテキスト間のデータフローを特定し、_cross-context-scenarios.md としてまとめる
5. 判断が必要だった箇所はDecision Recordのドラフトを作成する

## 出力形式

### 1. Specファイル群
docs/apd/specs/ ディレクトリに配置可能な Markdown 形式（YAML frontmatter付き）で出力。
フォーマットはCLAUDE.mdのデフォルトスペックフォーマットに従う。

### 2. Exit Criteriaチェックリスト（必須）
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

### 3. 確認依頼リスト（必須）
推論で埋めた箇所、自信がない箇所を明示する:

```
## 確認が必要な箇所
1. [spec_id] [箇所]: [推論内容] ← 確認してください
2. ...
```

### 4. Decision Recordドラフト（判断が発生した場合）
docs/apd/decisions/ ディレクトリに配置可能な Markdown 形式（YAML frontmatter付き）で出力。
AIが選択肢を提示し、人間が選ぶ形にする。
````

---

## プロンプト: 機能追加Spec（差分サイクル）

````
あなたはAPD（Autopilot Development）フレームワークにおけるSpecフェーズの担当エージェントです。

## タスク

既存Specへの差分として、新機能のSpecドラフトを生成してください。

## インプット

Design文書: docs/apd/design/product-design.md
既存Spec: docs/apd/specs/ ディレクトリの全ファイルを参照
サイクル定義: docs/apd/cycles/C-{{NNN}}.md

追加機能の概要:
{{機能の概要を記述}}

## ルール

1. 既存Specとの整合性を確認し、矛盾があれば報告する
2. 新規Specは新ファイルとして作成する（既存ファイルは上書きしない）
3. 既存Specの修正が必要な場合はAmendmentとして作成する
4. コンテキスト間データフローに影響がある場合、_cross-context-scenarios.md のAmendmentも作成する

## 出力形式

初回フルSpec生成と同じ3点セット（Spec + Exit Criteriaチェック + 確認依頼リスト）に加え:
- 既存Specへの影響分析
- Amendment が必要な既存Specのリスト
````

---

## プロンプト: バグ修正Spec Amendment

````
あなたはAPD（Autopilot Development）フレームワークにおけるSpecフェーズの担当エージェントです。

## タスク

バグ報告に基づき、Spec Amendment を作成してください。

## インプット

バグ報告:
{{バグの内容、再現手順、期待動作}}

関連Spec: docs/apd/specs/{{対象spec}}.md

## トリアージ

まず原因を判定してください:
- **Spec起因**（仕様漏れ・曖昧さ）→ Spec Amendment を作成
- **Execute起因**（実装がSpecと合っていない）→ 「Execute起因です。実装修正のみで対応可能です」と報告

## Spec起因の場合の出力

1. Amendment（docs/apd/specs/{context}.v{N}.A-{NNN}.md）
2. 影響を受ける他のSpecの分析
3. Decision Recordドラフト（仕様判断が必要な場合）
````

---

## Human Checkpoint 1

Specが完成したら、以下を確認します:

- [ ] Exit Criteriaチェックリストが全て ✅ になっているか
- [ ] 確認依頼リストの各項目について判断を返したか
- [ ] Decision Recordの各判断について decision と reason を記入したか
- [ ] What Not に含まれるものがSpecに紛れ込んでいないか

✅ 承認 → Phase 2 へ（ここから先、人間は基本介入しない）  
🔄 修正 → フィードバックを返してドラフトを更新
