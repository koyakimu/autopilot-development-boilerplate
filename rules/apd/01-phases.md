# APD フェーズ定義

## フェーズ

```
Intent ── 人間 + AI 対話
  成果物: Design（北極星）

Spec ── AI ドラフト + 人間レビュー
  成果物: Spec（AC + 検証方針 + 成果物プレビュー記述）+ Decision Records

Build ── AI 自律（実装中は止まらない自動完走）
  成果物: 実装 + テスト全パス + PR（試し方記載済み）
  → Claude Code の `/goal` に委譲。AC 準拠の Spec チェックは Build の達成条件に組み込み、ビルド AI 自身が照合する
  → 実装中は人間に問い合わせない。判断は Spec に先出しするか完成後の実機確認で次サイクルに回す

完成後の実機確認 ── 人間
  人間が PR の「試し方」に沿って実機で触り、受け入れ判断する
  差異があれば差し戻さず次サイクル（Spec 修正 → Build）へ進む
```

## 人間が関与する場
- **Intent**: 意図を決める
- **Spec**: 仕様を確認する
- **完成後の実機確認**: 動く成果物が意図どおりか確認する

Build フェーズに人間は介入しない。

## Build の収束判定

Build は Claude Code の `/goal` の評価器が、condition（Spec の AC、テスト pass、PR の Handoff 記載）の達成を毎ターン後に判定する。

- **評価器はツールを呼ばない**。Claude が turn 内で test 実行ログ・PR diff・実装内容を会話に surface する必要がある
- 同一論点でループした場合は condition に明記した上限（turn 数や時間）で停止して報告する
- AI が自動検証できない AC（実機限定・人間の主観評価等）は、実装と「試し方」ドキュメント化をもって Build 側の完了とみなす（実際の判定は完成後の実機確認に委ねる）

## Build 中は止まらない

実装中はエスカレーションしない。新しいビジネスルールや外部インターフェース変更など Spec にない判断が必要な場合は、**Spec に先出し**（Spec フェーズで人間が確認済み）するか、**完成後の実機確認で気づき次サイクルで Spec を修正する**。

Build の番人は `/goal` の評価器と、`/apd:go` が condition に組み込む Spec チェック。AC 準拠・テスト pass・Handoff 記載を毎ターン後に判定し、ビルド AI が照合結果を surface して自律修正する。

## 並列実行

複数タスクを並列実行したい場合は Claude Code の以下を使う:
- **subagent**: 単一セッション内のサイドタスク委譲（`isolation: "worktree"` でファイル隔離可能）
- **agent teams** (experimental): リーダー + teammates + 共有 task list で複数セッションを協調
- **`/batch`**: 大規模変更を 5〜30 の worktree 隔離 subagent に分割

APD はこれらの選択を強制しない。Build の規模に応じてリーダーが判断する。
