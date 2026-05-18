# APD フェーズ定義

## フェーズ

```
Intent ── 人間 + AI 対話
  成果物: Design（北極星）

Spec ── AI ドラフト + 人間レビュー
  成果物: Spec（AC + 検証方針 + 成果物プレビュー記述）+ Decision Records

Build ── AI 自律
  成果物: 実装 + テスト全パス + PR（試し方記載済み）
  → Claude Code の `/goal` に委譲。評価器が AC・テスト pass・Handoff を判定

Acceptance ── 人間
  人間が PR の「試し方」に沿って実機で触り、受け入れ判断する
```

## 人間が関与する場
- **Intent**: 意図を決める
- **Spec**: 仕様を確認する
- **Acceptance**: 動く成果物が意図どおりか確認する

Build フェーズに人間は介入しない。

## Build の収束判定

Build は Claude Code の `/goal` の評価器が、condition（Spec の AC、テスト pass、PR の Handoff 記載）の達成を毎ターン後に判定する。

- **評価器はツールを呼ばない**。Claude が turn 内で test 実行ログ・PR diff・実装内容を会話に surface する必要がある
- 同一論点でループした場合は condition に明記した上限（turn 数や時間）で停止して報告する
- AI が自動検証できない AC（実機限定・人間の主観評価等）は、実装と「試し方」ドキュメント化をもって Build 側の完了とみなす（実際の判定は Acceptance に委ねる）

## Build 中のエスカレーションポリシー（デフォルト）

**Acceptance で人間に渡す:**
- 新しいビジネスルール（既存 Spec にないドメインロジック）
- 外部システムとのインターフェース変更
- セキュリティ・認証に関わる変更
- データモデルの破壊的変更
- パフォーマンス要件の緩和

**Build 内で完結してよい:**
- UI 調整（Design の範囲内）
- 既存ビジネスルール内のバリエーション追加
- リファクタリング（振る舞い変更なし）
- テストカバレッジ補強
- ドキュメント文言修正

## 並列実行

複数タスクを並列実行したい場合は Claude Code の以下を使う:
- **subagent**: 単一セッション内のサイドタスク委譲（`isolation: "worktree"` でファイル隔離可能）
- **agent teams** (experimental): リーダー + teammates + 共有 task list で複数セッションを協調
- **`/batch`**: 大規模変更を 5〜30 の worktree 隔離 subagent に分割

APD はこれらの選択を強制しない。Build の規模に応じてリーダーが判断する。
