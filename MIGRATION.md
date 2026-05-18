# APD Migration Guide (0.x → 1.x)

APD 1.0 で導入された変更により、`docs/apd/` の構造とフレームワーク用語が変わった。既存プロジェクトをアップグレードする手順をまとめる。

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

### 3. 移行スクリプトを dry-run で確認

スクリプトはプラグインのインストール先にある。`${CLAUDE_PLUGIN_ROOT}` が解決できないシェルで使う場合は、絶対パスで指定する:

```bash
bash <path-to-apd-plugin>/scripts/migrate-to-1.0.sh --dry-run
```

何が動くかを出力するだけで、ファイルは触らない。

### 4. 実行

```bash
bash <path-to-apd-plugin>/scripts/migrate-to-1.0.sh
```

実行内容:

1. `docs/apd/` を `docs/apd.backup-{timestamp}/` に丸ごと複製
2. サブディレクトリ構造を flat 化 (`design/`, `specs/`, `decisions/`, `previews/`)
3. ファイル命名を新規約にリネーム (Amendment → Patch、`D-NNN` → `decision-NNN` 等)
4. `cycles/` は backup にのみ残す (新 APD では GH issue が代替)
5. 何が動いたか・何が要手動レビューかをレポート出力

### 5. ルールファイルを最新版に更新

```
# Claude Code 内で
/apd:init
```

`.claude/rules/apd/*.md` が新方針版で上書きされる (既存ファイルは差し替え)。`docs/apd/` は既に flat 化済みなので追加作成はされない。

### 6. 手動レビュー (スクリプトでは触らない箇所)

スクリプトはファイル名と配置だけ変える。**ファイルの中身は変更しない**。以下を手動で対応する:

#### 6a. Spec の frontmatter

旧 Spec の frontmatter:
```yaml
spec_id: "OM-001"
context: "order-management"
version: 1
cycle_ref: "C-001"
```

新 Spec の frontmatter:
```yaml
spec_id: "OM-001"
context: "order-management"
version: 1
issue_ref: "{GitHub issue 番号 or null}"
```

- `cycle_ref` → `issue_ref` に置き換え (該当 issue があれば番号、なければ `null`)

#### 6b. Spec Patch の frontmatter

旧 Amendment:
```yaml
amendment_id: "A-005"
cycle_ref: "C-007"
```

新 Patch:
```yaml
patch_id: "P-005"
issue_ref: "{番号 or null}"
```

- `amendment_id` → `patch_id` (値の `A-NNN` を `P-NNN` に変更してもしなくてもよい。意味は同じ)

#### 6c. ファイル本文中のパス参照

スクリプトはファイル本文は触らない。以下のような旧パス参照は手動で更新:

```bash
grep -rn 'docs/apd/specs/' docs/ src/ tests/ CLAUDE.md README.md 2>/dev/null
grep -rn 'docs/apd/decisions/' docs/ src/ tests/ CLAUDE.md README.md 2>/dev/null
grep -rn 'docs/apd/cycles/' docs/ src/ tests/ CLAUDE.md README.md 2>/dev/null
grep -rn 'docs/apd/design/product-design.md' docs/ src/ tests/ CLAUDE.md README.md 2>/dev/null
```

#### 6d. `CLAUDE.md`

プロジェクトの `CLAUDE.md` が APD パスや旧スキル名を参照していれば更新:

- `/apd:cycle` `/apd:build` `/apd:progress` の言及を削除
- 「サイクル定義は `docs/apd/cycles/` に」のような記述を「GitHub issue で」に変更
- "Checkpoint" の用語を "Acceptance" 等に置き換え

#### 6e. 認識されなかったファイル

スクリプトのレポートに「unrecognized」「older version」と出たファイルは元の場所に残されている。それぞれ:

- **古いバージョンの Spec** (`{name}.v1.md` 等で v2 以降があったもの): backup には全部残っている。flat 構造には最新版だけ持ち込まれているので、古い版を「歴史」として残したければ backup から `docs/apd/spec-{name}-archive-v1.md` 等として戻すか、backup のみで済ます
- **命名規約に合わなかったファイル**: 用途を判断して `docs/apd/{適切な名前}.md` にリネームするか削除する

### 7. 動作確認

```bash
ls docs/apd/
# 期待: design.md, spec-*.md, decision-*.md, preview-*/, todo.md (gh 未使用なら)
```

新スキルでフローを通す:

```
# Claude Code 内で
/apd:design   # Design を見直したい場合
/apd:spec     # 新 Spec を作りたい場合
/apd:start <spec-file>  # Build を開始
```

### 8. コミット

```bash
git add -A
git commit -m "chore: migrate to APD 1.x"
```

backup ディレクトリ (`docs/apd.backup-{timestamp}/`) は安全のためコミットに含めて残し、数サイクル運用して問題なければ別 PR で削除する、というのが安全。

## ロールバック

問題があれば backup から戻せる:

```bash
rm -rf docs/apd
mv docs/apd.backup-{timestamp} docs/apd
# プラグインを古いバージョンに戻す
/plugin install apd@apd-marketplace --version 0.5.1
```

## トラブルシューティング

### スクリプトが「already migrated」と出る

`docs/apd/design.md` が存在し、`docs/apd/design/` ディレクトリが存在しない場合、スクリプトは既に移行済みと判定する。誤検知の場合は手動で対応するか、`design.md` を一旦移動してから再実行する。

### `docs/apd/specs/` `decisions/` が空にならない

認識できないファイル (random.md 等) が残るとサブディレクトリも空にならない。レポートの WARNINGS を見て手動で対処する。

### git working tree が dirty で確認プロンプトが出る

`docs/apd/` 配下に未コミットの変更があると確認を求められる。先に commit/stash するか、`y` で続行する。

## 不明点

スクリプトが想定外のケースを踏んだ場合は GitHub issue を切ってください: https://github.com/koyakimu/autopilot-development-boilerplate/issues
