---
name: apd-design
description: >
  This skill should be used when the user asks to "create a design document",
  "start Phase 0", "design a product", "Design文書を作成", "プロダクトを設計",
  or wants to create or refine the product Design document (the north star)
  through interactive dialogue.
tools: ["Read", "Write", "Glob", "Grep"]
---

# APD Phase 0: Design — Design文書の対話的作成

APDフレームワークにおけるDesignフェーズのファシリテーターとして、プロダクトのDesign文書（北極星）を対話的に作成する。

Phase 0は「人間の時間」であり、並列化しない。数往復の対話で収束させる。

## 事前準備

以下のファイルを読み込む:

1. **CLAUDE.md** — プロジェクト設定を確認
2. **アクティブサイクル** — `docs/apd/cycles/` の最新ファイルを読み込み、サイクル情報を確認

## 対話の進め方

### 1. ヒアリング

ユーザーからプロダクトのアイデアや概要を聞く。まだ伝えられていない場合は質問する。
不明点があれば追加で質問する。

### 2. ドラフト生成

以下のAmazon PR/FAQ形式でDesign文書のドラフトを一気に生成する:

1. **Who（誰のため）**: ターゲットユーザーのペルソナ、課題、コンテキスト
2. **Why（なぜ今）**: 市場機会、タイミングの根拠、既存ソリューションの限界
3. **What（何ができるか）**: ユーザー視点での機能・体験の記述（技術ではなく価値）
4. **What Not（何をやらないか）**: スコープ外の明示。曖昧な境界を排除する
5. **FAQ**: 想定される疑問と回答。ステークホルダー・ユーザー・エンジニア視点を含む
6. **Success Criteria**: 定量・定性の成功指標

### 3. 信頼度の明示

各セクションについて以下を明示する:
- **自信がある部分** — ユーザーの入力から明確に導出できた内容
- **推論で埋めた部分（確認が必要）** — ユーザーの入力からは不明で、AIが補完した内容

### 4. フィードバックループ

ユーザーのフィードバックを受けて修正する。数往復で収束させる。

## 制約

- 技術的な実装方法には踏み込まない（Phase 1以降の責務）
- **What Not は必ず5項目以上** 記述する
- **FAQ は最低10問** 設定する
- **Success Criteria には測定可能な指標** を含める

## 出力

Design文書を `docs/apd/design/product-design.md` にMarkdown形式（YAML frontmatter付き）で書き出す。
CLAUDE.mdに定義されたフォーマットに従う。

## Human Checkpoint 0

Design文書が完成したら、以下のチェックリストを提示する:

- [ ] Who: ターゲットユーザーが明確に定義されているか
- [ ] Why: 作る理由と今のタイミングが説得力あるか
- [ ] What: ユーザー価値が技術用語なしで記述されているか
- [ ] What Not: スコープ外が十分に明示されているか（最低5項目）
- [ ] FAQ: 主要な疑問が網羅されているか（最低10問）
- [ ] Success Criteria: 測定可能な指標があるか

承認されたら「`/apd-spec full` を実行してPhase 1に進んでください」と案内する。
修正が必要な場合はフィードバックを受けて対話を続ける。
