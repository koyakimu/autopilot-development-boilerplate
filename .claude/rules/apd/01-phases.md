# APDフェーズ定義

## フェーズ

```
Phase 0: Design ── 人間 + AI 対話（並列化しない）
  成果物: プロジェクトデザイン文書（北極星）
  ─────────────── Human Checkpoint 0 ───────────────

Phase 1: Spec ── AIドラフト + 人間フィードバック（並列化しない）
  成果物: スペック集 + Decision Records
  ─────────────── Human Checkpoint 1 ───────────────
  ここから先、人間は基本介入しない

Phase 2: Contract ── AI自律
  成果物: プロジェクト契約
  AI Checkpoint → Human Checkpoint 2（軽量）

Phase 3: Execute ── AI自律・並列実行
  成果物: 実装 + テスト全パス
  AI Checkpoint → Human Checkpoint 3（軽量）
```

## Checkpointの原則

- **Human Checkpoint**: フェーズ境界に置く。方向性を確認して必要なら調整する確認ポイント
- **AI Checkpoint**: Human Checkpointの手前に置く。エージェント間クロスチェック
- Human Checkpointに上がる時点で、AIレビューサマリー + 要判断項目リストが付く
- 人間は「全量レビュー」ではなく「例外レビュー」を行う

## AI Checkpointエスカレーションポリシー（デフォルト）

**Human Checkpoint必須:**
- 新しいビジネスルール（既存Specにないドメインロジック）
- 外部システムとのインターフェース変更
- セキュリティ・認証に関わる変更
- データモデルの破壊的変更
- パフォーマンス要件の緩和

**AI Checkpoint完結:**
- UI調整（Design文書の範囲内）
- 既存ビジネスルール内のバリエーション追加
- リファクタリング（振る舞い変更なし）
- テストカバレッジ補強
- ドキュメント文言修正
