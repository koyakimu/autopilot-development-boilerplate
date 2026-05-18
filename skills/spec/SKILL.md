---
name: spec
description: >
  Generates Spec drafts from the Design document. Supports three
  modes: full (initial generation), add (feature addition), and
  bugfix (Spec Patch). Use when the user asks to generate specs,
  add a feature spec, fix a bug spec, or run /apd:spec
  ("Spec を生成", "仕様書を作成", "機能追加の Spec", "バグ修正の Patch").
argument-hint: "[full|add|bugfix] [issue#?]"
---

# APD Spec — 仕様書の生成

Spec フェーズの担当として、Design 文書から Spec（詳細仕様書）を生成する。Spec フェーズは「人間の時間」だが、AI がドラフトを生成し、人間がサマリーと確認依頼箇所だけレビューする。

## 事前準備

以下を読み込む:

1. `CLAUDE.md` — プロジェクト設定（デフォルト Spec フォーマット、エスカレーションポリシー等）
2. `docs/apd/design.md` — Design 文書
3. `docs/apd/spec-*.md` — 既存 Spec（あれば）
4. `docs/apd/decision-*.md` — 既存 Decision Records（あれば）
5. 対象の GitHub issue（あれば。`gh issue view {number}` で内容を取得）

## モード判定

ユーザーの指示またはトリガー種別から、実行モードを判定する:

- **full** — 初回フル Spec 生成
- **add** — 機能追加 Spec
- **bugfix** — バグ修正 Patch

不明な場合はユーザーに確認する。

---

## モード: full（初回フル Spec 生成）

### スコーピング

Design 文書の **What** セクションに記載された全機能を確認し、ユーザーと対話して**今回のサイクルのスコープ**を決定する:

1. 全機能を一覧化し、**今回のスコープ** と **スコープ外（後続サイクルで実装）** に分類する提案を行う
2. ユーザーの判断を仰ぎ、スコープを確定する
3. **スコープ外に分類された機能は backlog に記録する**。GitHub issue が使える環境では `gh issue create` で起票し、`apd:scope-out` ラベルを付ける。使えない環境では `docs/apd/todo.md` に追記する
4. 確定したスコープ内の機能についてのみ Spec を生成する

### 生成ルール

1. スコープ内の機能について Spec を作成する
2. **What Not** に含まれるものは絶対に Spec に入れない
3. 各 Spec は以下を含む:
   - `spec_id`: コンテキスト略称 + 連番（例: AUTH-001）
   - `issue_ref`: 関連 GitHub issue 番号（あれば）
   - ユーザーストーリー（誰が・何を・なぜ）
   - 受け入れ条件（Given/When/Then 形式）
   - UI 記述またはモック指示（該当する場合）
   - コンテキスト境界の定義（inputs / outputs / dependencies）
   - **テスト戦略**（AC Coverage テーブル: 各 AC に対するテスト種別と内容）
   - **成果物プレビュー記述**（生成すべきプレビュー種別と方向性。該当する場合）
4. コンテキスト間のデータフローが複雑な場合は、`docs/apd/spec-cross-context.md` としてまとめる
5. 判断が必要だった箇所は Decision Record のドラフトを作成する

### 出力

1. **Spec ファイル群** — `docs/apd/spec-{slug}.md` として書き出す。`{slug}` は issue 番号があれば issue 番号、なければ短い slug
2. **確認チェックリスト**（下記参照）
3. **確認依頼リスト**（下記参照）
4. **Decision Record ドラフト** — 判断が発生した場合、`docs/apd/decision-{NNN}.md` に書き出す

---

## モード: add（機能追加 Spec）

### 追加ルール

1. 既存 Spec との整合性を確認し、矛盾があれば報告する
2. 新規 Spec は新ファイルとして作成する（既存ファイルは上書きしない — Immutable 原則）
3. 既存 Spec の修正が必要な場合は **Spec Patch** として作成する（`docs/apd/spec-{slug}-patch-{NNN}.md`）
4. コンテキスト間データフローに影響がある場合、`spec-cross-context.md` の Patch も作成する

### 出力

full モードの出力に加え:

- 既存 Spec への影響分析
- Patch が必要な既存 Spec のリスト

---

## モード: bugfix（バグ修正 Patch）

### トリアージ

まず原因を判定する:

- **Spec 起因**（仕様漏れ・曖昧さ）→ Spec Patch を作成
- **Build 起因**（実装が Spec と合っていない）→ 「Build 起因です。実装修正のみで対応可能です。`/apd:start` で修正を開始してください」と報告

### Spec 起因の場合の出力

1. **Spec Patch** — `docs/apd/spec-{slug}-patch-{NNN}.md`
2. 影響を受ける他の Spec の分析
3. Decision Record ドラフト（仕様判断が必要な場合）

---

## 技術選定（Decision Records）

Spec 生成と並行して、主要な技術選定について Decision Record を作成し、ユーザーの判断を仰ぐ。技術選定は Build フェーズの前提条件となるため、Spec フェーズで確定させる。

### 判断が必要な技術選定の特定

以下の領域について、CLAUDE.md で既に確定していない項目を洗い出す:

- プログラミング言語 / ランタイム
- フレームワーク / ライブラリ
- ビルドツール / バンドラー
- データベース / ストレージ
- インフラストラクチャ / デプロイ
- その他プロジェクト固有の重要な技術選択

### Decision Record の生成

未確定の技術選定ごとに `docs/apd/decision-{NNN}.md` を作成する:

1. 各 Option には以下のトレードオフを明記する:
   - メリット / デメリット
   - 学習コスト / エコシステムの成熟度
   - プロジェクト要件との適合性
   - 将来の拡張性への影響
2. AI Recommendation を付記してよいが、決定権は人間にある

### ユーザーへの提示と承認

Decision Record ドラフトを全て提示し、各項目について `decision` と `reason` の記入を求める。

**全ての Decision Record にユーザーの判断が記入されるまで、Spec の確認を完了できない。**

### CLAUDE.md で確定済みの場合

CLAUDE.md で技術スタックが明示的に指定されている場合、Decision Record の生成をスキップしてよい。ただし「他に検討すべき技術選択はありますか？」とユーザーに確認する。

---

## 共通出力: 確認チェックリスト

以下の充足状況を表形式でサマリーする:

| 確認項目 | 状態 | 備考 |
|---|---|---|
| 全機能に Spec が存在する | ✅/⚠️/❌ | |
| 各 Spec にユーザーストーリーがある | ✅/⚠️/❌ | |
| 各 Spec に受け入れ条件がある | ✅/⚠️/❌ | |
| 各 Spec に UI 記述がある（該当時） | ✅/⚠️/❌ | |
| コンテキスト境界が定義されている | ✅/⚠️/❌ | |
| コンテキスト間データフローが特定されている | ✅/⚠️/❌ | |
| 各 Spec にテスト戦略（AC Coverage）がある | ✅/⚠️/❌ | |
| 各 Spec に成果物プレビュー記述がある（該当時） | ✅/⚠️/❌ | |
| Decision Record が作成されている（判断発生時） | ✅/⚠️/❌ | |
| 技術選定 Decision Records に全てユーザー判断が記録されている | ✅/⚠️/❌ | |

## 共通出力: 確認依頼リスト

推論で埋めた箇所、自信がない箇所を明示する:

```
## 確認が必要な箇所
1. [spec_id] [箇所]: [推論内容] ← 確認してください
2. ...
```

## 確認

Spec が完成したら、以下のチェックリストを提示する:

- [ ] 確認チェックリストが全て ✅ になっているか
- [ ] 確認依頼リストの各項目について判断を返したか
- [ ] Decision Record の各判断について decision と reason を記入したか
- [ ] 技術選定 Decision Records の全項目にユーザー判断が記録されているか
- [ ] What Not に含まれるものが Spec に紛れ込んでいないか

承認されたら「`/apd:start` で Build を開始してください（ここから先、人間は基本介入しません）」と案内する。修正が必要な場合はフィードバックを受けてドラフトを更新する。
