---
name: start
description: >
  This skill should be used when the user asks to "start build",
  "start implementation", "実装を開始", "ビルドを開始",
  "/apd:start", or wants to begin autonomous build from an
  approved Spec. Constructs a /goal condition from the Spec's
  Acceptance Criteria and hands off to Claude Code's /goal loop.
tools: ["Read", "Glob", "Grep", "Bash"]
---

# APD Start — Spec から /goal condition を組み立てて自律 build に入る

このスキルは APD の Phase 2 (Build) のエントリーポイント。**自前で実装ループを回さず、Claude Code の `/goal` 機能に処理を委譲する**。

`/goal` は v2.1.139+ で導入された session-scoped な「条件達成までターン継続」機能。haiku ベースの評価器が毎ターン後に条件達成を判定する。APD はこの評価器に渡す condition の組み立て役に徹する。

## 手順

### 1. 対象 Spec を特定する

ユーザーが引数で指定:
- `spec-{issue#}.md` のような file path
- issue 番号のみ (`123`)
- 何も指定なし → `docs/apd/` を Glob して候補を提示

優先順位:
1. ユーザーの明示指定
2. 直近に更新された `docs/apd/spec-*.md` ファイル
3. ユーザーに確認

### 2. Spec を読み込み、condition 構築素材を抽出する

Read で Spec ファイル全体を読む。以下を抽出する:

- **spec_id** (frontmatter)
- **title** (frontmatter)
- **Acceptance Criteria セクション** の AC ID 一覧 (AC-001, AC-002, ...)
- **Test Strategy / AC Coverage テーブル** から想定テスト種別
- **Deliverable Previews** セクション (該当する場合)

並行して以下も読む (存在する場合のみ):
- `CLAUDE.md` — テスト実行コマンド、コーディング規約の手がかり
- `docs/apd/design.md` — Success Criteria の確認

### 3. /goal condition を組み立てる

以下の構造で condition を作る (4000字以内に収める):

```
{spec_id}: {title} を完了する。具体的に:

【受け入れ条件 (すべて満たす)】
- AC-001: {Given/When/Then 要約}
- AC-002: {同上}
- AC-003: {同上}
...

【検証】
- すべての自動テストが pass する ({CLAUDE.mdから検出したテストコマンド、例: npm test})
- ユニット/結合テストの実装が AC Coverage テーブルの方針に沿っている
- 既存テストを壊していない

【Handoff (人間に渡す準備)】
- PR を作成または更新し、PR 本文に「## 試し方」セクションを記載する
- 「## 試し方」には各 AC を人間が実機で検証できる手順を記述する
  (例: 「Simulator起動 → ログイン画面で X を入力 → Y が表示される (AC-001)」)
- PR 本文の最後に `Spec: docs/apd/{spec_path}` のリンクを記載する

【制約】
- Spec に書かれていない新ビジネスルールを足さない
- Spec 範囲外のリファクタリングをしない
- 判断に迷ったら Human Checkpoint にエスカレーション
- 同一論点を 3 ラウンド連続で議論したら一旦停止して報告
```

condition は箇条書きで具体的に書く。**「Claude の出力に現れる証拠で判定できる」表現**にすること。`/goal` の評価器はツールを呼ばないため、Claude が turn 内で test 実行ログや PR diff を surface する必要がある。

### 4. ユーザーに condition を提示する

組み立てた condition を以下の形式で出力する:

````markdown
## /apd:start — Build 準備完了

**Spec**: `docs/apd/spec-XXX.md` ({title})

以下の `/goal` コマンドを次のメッセージで送信してください:

```
/goal {組み立てた condition}
```

### 補足
- このコマンドを送ると Claude Code が自律 build ループに入ります
- 進捗確認: `/goal` (引数なし) で現在の状態を表示
- 中断: `/goal clear`
- 並列化したい場合: コマンド送信前に **agent team** を要求してください (例: "3 つの teammate で並列に進めて")
- worktree 隔離が必要な場合: コマンド送信前に worktree で session を起動してください
````

**重要**: スキル自身は `/goal` を実行できない (slash command は user input チャネルから発火する)。スキルは condition を組み立てて提示するところまで責任を持ち、`/goal` 送信は user action として残す。

### 5. (Optional) Decision Records / Previews の事前チェック

condition 提示の前に、以下を warning として伝える:

- Spec に `decision_refs` が記載されているが `docs/apd/decision-*.md` が存在しない → 「Decision Record が見つかりません。Spec の前提と矛盾しないか確認してください」
- Spec に `Deliverable Previews` セクションがあるが該当ファイルが未生成 → 「Preview が未生成です。/goal condition に preview 生成を含めるか確認してください」

## このスキルが意図的にやらないこと

- **自前のループ実装** — `/goal` が担当
- **peer-review の起動** — Build 中に必要なら Claude が `apd:peer-review` subagent を呼ぶ。スキル側で強制しない
- **AI checkpoint 機械検証** — `/goal` の評価器が収束を判定する
- **Handoff doc のファイル生成** — PR 本文に書く方針なのでファイルは作らない
- **サイクル定義の更新** — GH issue が一次。issue 番号と PR を link することで自動で trail が残る

## トラブルシューティング

- **`/goal` が無いと言われる** → Claude Code v2.1.139 以上が必要。`claude --version` で確認
- **評価器が永遠に no を返す** → condition が抽象的すぎる可能性。AC を引用するなど具体化する
- **token 消費が膨大** → condition に turn 上限を含める (例: 「20 turn 以内に達成、超過時は中断して報告」)
