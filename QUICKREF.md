# APD クイックリファレンス

## フェーズ早見表

| Phase | 誰の時間 | やること | 成果物 | Checkpoint |
|-------|---------|---------|--------|------------|
| **0: Design** | 人間+AI | 対話でDesign文書作成 | `docs/apd/design/product-design.md` | Human CP 0（意図を決める） |
| **1: Spec** | 人間+AI | AIドラフト→人間FB | `docs/apd/specs/*.md` + `docs/apd/decisions/*.md` | Human CP 1（仕様を決める） |
| **2: Build** | AI自律 | プレビュー生成+実装+テスト | `docs/apd/previews/` + `src/` + `tests/` | Peer Review + AI CP → Human CP 2（完成品確認） |

## Skills 使用フロー

```
① 変更が発生
   └→ /apd:cycle でサイクル定義を作成（トリガー種別を自動判定）
      └→ 未着手ToDoがあれば提示・提案

② Phase 0（new_product のみ）
   └→ /apd:design で Design 文書を対話的に作成
      └→ スコープ外のアイデアは todo.md に記録

③ Phase 1
   └→ /apd:spec [full|add|bugfix] で Spec ドラフトを生成
   └→ full モードではスコーピング → スコープ外の機能を todo.md に記録
   └→ 確認依頼リストだけレビュー → フィードバック → 承認

④ Phase 2
   └→ /apd:build で AI が自律実行
   └→ プレビュー生成 → 実装 → ピアレビュー + AIチェックポイント自動実行
   └→ 完成品が意図通りか確認 → 承認

いつでも /apd:status で現在の進行状況を確認できます
```

## 初回セットアップ

```
/apd:init    → ルールファイルのコピー + ドキュメントディレクトリ + todo.md 作成
```

## 人間がやること（だけ）

### Phase 0-1: 意図を決める
- Design文書の対話的作成
- Specドラフトの確認依頼箇所をレビュー
- スコープの判断
- Decision Record の判断を記入

### Phase 2: 完成品を確認する
- 動く成果物が期待通りの動作をするか確認
- Success Criteria を満たしているか確認
- テスト結果サマリーを確認
- エスカレーション項目がある場合のみ判断を記入
- **コードレビューは求めない**

## 判断フロー

```
CLAUDE.md に書いてある？
  ├─ Yes → それに従う
  └─ No → リーダーエージェントが判断できる？
              ├─ Yes → リーダーが判断
              └─ No → Human Checkpoint にエスカレーション
```

## ファイル命名規則

| 種類 | パターン | 例 |
|------|---------|-----|
| Design | `docs/apd/design/product-design.md` | — |
| Spec | `docs/apd/specs/{context}.v{N}.md` | `docs/apd/specs/order-management.v1.md` |
| Amendment | `docs/apd/specs/{context}.v{N}.A-{NNN}.md` | `docs/apd/specs/order-management.v1.A-005.md` |
| Preview | `docs/apd/previews/C-{NNN}/` | `docs/apd/previews/C-001/architecture.md` |
| Decision | `docs/apd/decisions/D-{NNN}.md` | `docs/apd/decisions/D-001.md` |
| Cycle | `docs/apd/cycles/C-{NNN}.md` | `docs/apd/cycles/C-001.md` |
| ToDo | `docs/apd/todo.md` | — |
