# APD クイックリファレンス

## フェーズ早見表

| Phase | 誰の時間 | やること | 成果物 | Checkpoint |
|-------|---------|---------|--------|------------|
| **0: Design** | 人間+AI | 対話でDesign文書作成 | `docs/apd/design/product-design.md` | Human CP 0 |
| **1: Spec** | 人間+AI | AIドラフト→人間FB | `docs/apd/specs/*.md` + `docs/apd/decisions/*.md` | Human CP 1 |
| **2: Contract** | AI自律 | 技術仕様を自動生成 | `docs/apd/contract/*.md` | AI CP → Human CP 2（軽量）|
| **3: Execute** | AI自律 | 実装+テスト | `src/` + `tests/` | AI CP → Human CP 3（軽量）|

## Skills 使用フロー

```
① 変更が発生
   └→ /apd:cycle でサイクル定義を作成（トリガー種別を自動判定）

② Phase 0（new_product のみ）
   └→ /apd:design で Design 文書を対話的に作成

③ Phase 1
   └→ /apd:spec [full|add|bugfix] で Spec ドラフトを生成
   └→ 確認依頼リストだけレビュー → フィードバック → 承認

④ Phase 2
   └→ /apd:contract で AI が自律実行 + AIチェックポイント自動実行
   └→ AI Checkpoint 結果のサマリーだけ確認 → 承認

⑤ Phase 3
   └→ /apd:execute で AI が自律実行 + ピアレビュー + AIチェックポイント自動実行
   └→ AI Checkpoint 結果のサマリーだけ確認 → 承認

いつでも /apd:status で現在の進行状況を確認できます
```

## 初回セットアップ

```
/apd:init    → ルールファイルのコピー + ドキュメントディレクトリ作成
```

## 人間がやること（だけ）

### Phase 0-1: しっかり関与
- Design文書の対話的作成
- Specドラフトの確認依頼箇所をレビュー
- Decision Record の判断を記入

### Phase 2-3: 軽量レビュー
- AI Checkpoint サマリーを読む（2-5分）
- escalation_items があれば判断を記入
- 問題なければ承認

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
| Contract | `docs/apd/contract/project-contract.v{N}.md` | `docs/apd/contract/project-contract.v1.md` |
| Decision | `docs/apd/decisions/D-{NNN}.md` | `docs/apd/decisions/D-001.md` |
| Cycle | `docs/apd/cycles/C-{NNN}.md` | `docs/apd/cycles/C-001.md` |
