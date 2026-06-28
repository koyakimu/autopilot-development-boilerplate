# APD クイックリファレンス

## フェーズ早見表

| フェーズ | 誰の時間 | やること | 成果物 | 完了の合図 |
|---------|---------|---------|--------|------------|
| **Intent** | 人間+AI | 対話で Design 文書作成 | `docs/apd/design.md` | 人間の合意 |
| **Spec** | 人間+AI | AI ドラフト → 人間確認 | `docs/apd/spec-*.md` + `docs/apd/decisions.md` | 人間の合意 |
| **Build** | AI 自律 | 実装 + テスト + PR | `src/` + `tests/` + PR（試し方記載済み） | `/goal` 評価器の収束 |
| **実機確認** | 人間 | 実機で触る | merge or 差し戻し | 人間の判断 |

## スキル使用フロー

```
① 変更が発生
   └→ GitHub issue を起票（gh 環境）or todo.md に追記
      └→ 必要なら /apd:design で Design 文書を作成・更新

② Spec
   └→ /apd:spec [full|add|bugfix] で Spec ドラフト生成
   └→ full モードではスコーピング → スコープ外は backlog へ
   └→ 確認依頼箇所のみレビュー → フィードバック → 合意

③ Build
   └→ /apd:go <spec ファイル> で /goal condition を組み立て
   └→ ユーザーが /goal に condition を貼って実行 → AI 自律ループ開始（途中で止まらない）
   └→ 並列化が必要なら subagent / agent teams / /batch を使う
   └→ 完了時に PR 本文に「試し方」が記載される

④ 実機確認
   └→ 人間が PR の「試し方」に沿って実機で触る
   └→ OK → merge → issue 自動 close
   └→ NG → コメントで返す → 次サイクル（Spec 編集 等）
```

## 初回セットアップ

```
/apd:init  → ルールファイルコピー + docs/apd/ 作成 + backlog 案内
```

## 人間がやること（だけ）

### Intent / Spec: 意図を決める
- Design 文書の対話的作成
- Spec ドラフトの確認依頼箇所をレビュー
- スコープの判断
- Decision Record の判断を記入

### 実機確認: 受け入れる
- PR 本文の「試し方」に沿って実機で触る
- 動く成果物が期待通りか確認
- OK なら merge、NG なら差し戻し（次サイクル）
- **コードレビューは求めない**

## 判断フロー

```
CLAUDE.md に書いてある？
  ├─ Yes → それに従う
  └─ No → リーダーエージェントが判断できる？
              ├─ Yes → リーダーが判断
              └─ No → 完成後の実機確認としてエスカレーション
```

## ファイル構成（3 種別）

```
docs/apd/
├── design.md            ← 北極星（編集し続ける）
├── decisions.md         ← 判断の追記ログ（単一ファイル）
└── spec-{feature}.md    ← 機能ごと 1 枚（編集し続ける）
```

- **ドキュメントは生きた 1 枚**。差分を別ファイルで積まない。修正は既存ファイルを編集して `version` を上げる。履歴は git が正史
- ファイルが増えるのは新機能を作るときだけ
- 成果物プレビューを作る場合のみ `docs/apd/preview-{feature}/` を追加（任意）
- `{feature}` は GitHub issue 番号があれば issue 番号（例: `spec-42.md`）、なければ短い slug

## Claude Code 機能の使い分け

| 用途 | 使う機能 |
|------|---------|
| Build の自律ループ | `/goal` |
| サイドタスクの分離 | subagent（必要なら `isolation: "worktree"`） |
| 複数セッション協調 | agent teams（experimental） |
| 大規模並列化 | `/batch` |
| in-session todo | `TaskCreate` |
| 累積知識 | auto memory |
| backlog | GitHub issue（`gh` 環境）or `docs/apd/todo.md` |
| GitHub 連携 | ローカルの `gh` CLI で十分。GitHub Actions/routines は任意 |
| Handoff（試し方） | PR 本文 |
| 人間の確認面 | GitHub（PR + issue）。`docs/apd/` は AI の作業場で、日常的にスキャンしない |
| ドキュメント履歴 | git log / git blame（差分ファイルを積まない） |
