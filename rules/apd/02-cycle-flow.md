# APD サイクル型統一フロー

## サイクル型統一フロー

すべての変更を「サイクル」として統一する。修正は新しいサイクルで行う（出戻りではなく前進）。

| トリガー | フロー |
|---------|--------|
| 新プロダクト / 大きな方向転換 | Intent (Design) → Spec → Build → Acceptance |
| 新機能追加 | Spec（既存 Design 参照）→ Build → Acceptance |
| バグ修正 / 小さな改善 | Spec Patch → Build → Acceptance |
| 技術的変更（リファクタ等）| Decision Record → Build → Acceptance |

GitHub issue がある環境では **1 issue = 1 サイクル** を基本とする。issue 番号と Spec / PR を相互リンクすることでサイクルの trail が自動で残る。issue がない環境では `docs/apd/` 内のファイルだけでサイクルを表現する。

## バグのトリアージ

バグ報告・テスト失敗が来たとき、AI がまず原因を判定する:

- **Spec 起因**（仕様漏れ・曖昧さ）→ 人間にエスカレーション → Spec Patch サイクルへ
- **Build 起因**（実装が Spec と合っていない）→ AI 自律で修正 → 人間に上げない
