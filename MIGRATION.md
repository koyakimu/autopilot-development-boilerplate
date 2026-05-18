# APD Migration Guide (0.x → 1.x)

APD 1.0 で導入された変更により、`docs/apd/` の構造とフレームワーク用語が変わった。既存プロジェクトをアップグレードする手順をまとめる。

## アプローチ

**AI 主導の `/apd:migrate` スキルで移行する**。スクリプトでの一括置換ではなく、AI が個々のファイルを読んで文脈を踏まえて変換する。検証は `scripts/verify-migration.sh` で行う。

理由:
- frontmatter フィールドの変換は値の意味解釈が要る (`cycle_ref: "C-001"` → `issue_ref: <番号 or null>` は実 issue 確認が必要)
- 本文中のパス参照置換は文脈依存 (リンクなのか歴史的言及なのか)
- 命名規約に合わないファイル (`random.md` 等) の扱いは判断が要る
- CLAUDE.md の更新はプロジェクト固有

## 主な変更

| 項目 | 旧 (0.x) | 新 (1.x) |
|------|---------|---------|
| ディレクトリ | `docs/apd/{design,specs,decisions,cycles,previews}/` | `docs/apd/` フラット |
| Design | `docs/apd/design/product-design.md` | `docs/apd/design.md` |
| Spec | `docs/apd/specs/{name}.v{N}.md` | `docs/apd/spec-{name}.md` |
| Spec 修正 | `docs/apd/specs/{name}.v{N}.A-{NNN}.md` (Amendment) | `docs/apd/spec-{name}-patch-{NNN}.md` (Patch) |
| Decision | `docs/apd/decisions/D-{NNN}.md` | `docs/apd/decision-{NNN}.md` |
| Preview | `docs/apd/previews/C-{NNN}/` | `docs/apd/preview-{slug}/` |
| Cycle | `docs/apd/cycles/C-{NNN}.md` | **廃止** (GitHub issue で代替) |
| Build スキル | `/apd:build` | `/apd:start <spec>` + `/goal` |
| サイクル開始 | `/apd:cycle` | 会話 + `gh issue create` |
| 進行確認 | `/apd:progress` | `gh issue list` + `ls docs/apd/` + `/memory` |
| 機械検証 agent | `apd:checkpoint` | **廃止** (`/goal` 評価器が代替) |
| Handoff | サイクル定義ファイル | PR 本文の「## 試し方」セクション |
| Backlog | `docs/apd/todo.md` | GitHub issue (gh 環境) / `todo.md` (フォールバック) |
| 用語 | "Amendment" / "Human Checkpoint 2" | "Spec Patch" / "Acceptance" |

## 移行手順

### 1. プラグインを更新

```bash
/plugin update apd@apd-marketplace
```

### 2. プロジェクトでブランチを切る

```bash
cd /path/to/your/project
git checkout -b chore/apd-1.x-migration
```

未コミットの変更があれば commit / stash しておく。

### 3. AI 主導の移行を起動

Claude Code 内で:

```
/apd:migrate
```

AI が以下を実行する:

1. `docs/apd/` を読んで現状を把握
2. **移行プランを提示** (どのファイルがどう動くか、frontmatter / 本文がどう書き換わるか、手動レビューが必要な箇所はどれか)
3. ユーザーが yes と返したら実行
4. バックアップ → ファイル移動 → frontmatter 更新 → 本文参照更新
5. `scripts/verify-migration.sh` を呼んで結果を検証
6. レポート出力 (何をしたか・手動レビュー残項目)

**`--dry-run` 引数** を付けて起動すると、プラン提示と dry-run 出力のみで fs 操作はしない。

### 4. 検証

`/apd:migrate` 内部でも呼ばれるが、手動で再実行することもできる:

```bash
bash <path-to-apd-plugin>/scripts/verify-migration.sh
```

検査項目:
- 旧サブディレクトリ (`design/`, `specs/`, `decisions/`, `cycles/`, `previews/`) が消えているか
- 旧命名 (`*.A-*.md`, `*.v{N}.md`, `D-*.md`) のファイルが残っていないか
- 旧 frontmatter フィールド (`amendment_id:`, `cycle_ref:`) が残っていないか
- `docs/apd/` 配下に旧パス参照がないか
- CLAUDE.md の旧スキル言及 (`/apd:build` 等) — warning のみ

PASS / FAIL を表示し、FAIL があれば exit 1。

### 5. ルールファイルを最新版に更新

```
/apd:init
```

`.claude/rules/apd/*.md` が新方針版で上書きされる。`docs/apd/` は既に flat なので追加は発生しない。

### 6. 残った手動レビュー項目を対応

`/apd:migrate` のレポートに「手動レビュー」として出た項目を順番に処理する。典型的なもの:

- 命名規約に合わなかったファイル (`random.md` 等): 用途を判断して新名で配置 or 削除
- 古い version の Spec: backup から拾うか、backup のみで済ますか
- CLAUDE.md の `/apd:build` 等の言及: 新スキル名に書き換え or 削除

### 7. 動作確認

```bash
ls docs/apd/
# 期待: design.md, spec-*.md, decision-*.md, preview-*/, todo.md (gh 未使用なら)
```

新フローでサイクルを通す:

```
# Claude Code 内で (動作確認用、本物のサイクルでなくても)
/apd:spec     # 既存 Spec が新形式で読み込めるか
/apd:start spec-{slug}.md  # /goal condition が組み立てられるか
```

### 8. コミット

```bash
git add -A
git commit -m "chore: migrate to APD 1.x"
```

backup ディレクトリ (`docs/apd.backup-{timestamp}/`) は安全のためコミットに含めて残し、数サイクル運用して問題なければ別 PR で削除するのが安全。

## ロールバック

問題があれば backup から戻せる:

```bash
rm -rf docs/apd
mv docs/apd.backup-{timestamp} docs/apd
git checkout -- .  # frontmatter 等の Edit が staged されている場合
```

または `/plugin install apd@apd-marketplace --version 0.5.1` で旧プラグインに戻す。

## トラブルシューティング

### `/apd:migrate` が「already migrated」と返す

`docs/apd/design.md` が存在し、`docs/apd/design/` ディレクトリが存在しない場合、AI は既に移行済みと判定する。誤検知の場合は手動で対応するか、状況を AI に伝えて部分移行を指示する。

### 検証スクリプトが FAIL を返す

`scripts/verify-migration.sh` の出力を見て、FAIL 項目を特定する。よくあるケース:

- **`docs/apd/specs/` がまだ存在する**: 認識できないファイル (random.md 等) が残っているため。中身を確認して新名で配置 or 削除
- **`amendment_id:` の frontmatter が残っている**: AI が変換漏れ。Edit で手動修正、または `/apd:migrate` を再実行
- **本文に旧パス参照が残っている**: 該当ファイルを開いて確認、コンテキスト判断して置換 or 残置

### backup から特定のファイルを救出したい

```bash
cp docs/apd.backup-{timestamp}/cycles/C-001.md docs/apd/decision-historical-C-001.md
```

過去サイクルの意思決定で重要なものは、Decision Record 形式に救出できる。

## 関連スクリプトの責務分担

| ツール | 何をする | しないこと |
|--------|---------|-----------|
| `/apd:migrate` (skill) | 実際の移行 (ファイル移動・rename・frontmatter 更新・本文置換) を AI 判断で実行 | 検証は外部スクリプトに委ねる |
| `scripts/verify-migration.sh` | 新構造が成立しているかを機械的にチェック | 何も書き換えない |

## 不明点

スクリプトや移行で想定外のケースを踏んだら GitHub issue を切ってください: https://github.com/koyakimu/autopilot-development-boilerplate/issues
