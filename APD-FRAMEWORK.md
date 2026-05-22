# Autopilot Development (APD)

> **人間は意思決定だけ、AI が自律で完走する**

Autopilot Development（APD）は、AI エージェントが自律的にソフトウェアを開発し、人間が「意図を決める」と「動く成果物を受け入れる」の2点のみで関わる開発フレームワークである。自動運転のメタファーに基づき、人間が目的地とルートを決め、AI が Autopilot で走り、到着時に人間が「ここで合っている」と確認する。

---

## 設計原則

### AI に任せられる部分を限りなく増やす

AI フェーズの途中では人間の介入をゼロにする。モック・ユーザーストーリー・テストを含め、人間が意図した通りの機能実装が AI で完走する。人間の介入が必要で実装が止まることを避ける。

### 「人間の時間」と「AI の時間」の分離

- **Intent / Spec = 人間の時間**: 対話し、意思決定を注入する
- **Build = AI の時間**: 自律実行
- **Acceptance = 人間の時間（軽量）**: 動く成果物を実機で触り、受け入れる

### 人間は意図を決め、動く成果物を受け入れる

- **上流（Intent / Spec）**: 意図を決める — プロダクトビジョン、仕様、技術選定を判断する
- **下流（Acceptance）**: 動く成果物が意図通りかを実機で確認する
- **コードレビューは求めない** — 品質検証は AI 自身のループ（`/goal` 評価器、subagent、テスト）が担保する

### 薄い規約レイヤに留まる

APD は **Design / Spec / Decision の規約と最小限のスキル** だけを提供する。Claude Code 本体に存在する機能は再実装しない:

| やりたいこと | 使う Claude Code 機能 |
|------|-----------|
| Build の自律ループ | `/goal`（session-scoped、condition 達成までターン継続） |
| サイドタスク分離 | subagent（`isolation: "worktree"` でファイル隔離可） |
| 複数セッション協調 | agent teams |
| 大規模並列化 | `/batch` |
| in-session todo | `TaskCreate` |
| 累積知識 | auto memory |
| ファイル変更追跡・rewind | checkpointing |
| GitHub 連携 | `gh` CLI（ローカル中心、十分）。チーム運用や非同期トリガーが必要なら GitHub Actions / routines を任意で追加 |
| backlog | GitHub issue（あれば一次）/ `docs/apd/todo.md`（フォールバック） |

---

## フェーズ

```
Intent     ── 人間 + AI 対話
  成果物: Design 文書（北極星、滅多に変わらない）

Spec       ── AI ドラフト + 人間レビュー
  成果物: Spec（AC + 検証方針 + 成果物プレビュー記述）+ Decision Records

Build      ── AI 自律
  成果物: 実装 + テスト全パス + PR（試し方記載済み）
  実装: Claude Code の /goal に委譲

Acceptance ── 人間
  人間が PR の「試し方」に沿って実機で触り、受け入れ判断する
```

### Intent (Design)

プロダクトのビジョン・誰のための何か・スコープ外を Amazon PR/FAQ 形式で文書化する。「北極星」として全サイクル共通で参照される。

- 場所: `docs/apd/design.md`
- スキル: `/apd:design`
- 進め方: ヒアリング → ドラフト → 信頼度明示 → フィードバックループ
- 制約: 技術選定を含めない、What Not を最低 5 項目、FAQ 最低 10 問

### Spec

Design を実装可能な単位に分割し、各機能について受け入れ条件（AC）と検証方針を定める。

- 場所: `docs/apd/spec-{feature}.md`（`{feature}` は issue 番号や短い名前）
- スキル: `/apd:spec [full|add|bugfix]`
- 3 モード:
  - **full**: 初回フル Spec 生成（Design スコーピング込み）
  - **add**: 機能追加 Spec（新規 spec ファイル）
  - **bugfix**: 既存 Spec を直接編集して `version` を上げる
- 各 Spec の構成: User Story、Acceptance Criteria（Given/When/Then）、UI 記述、Context Boundary、Test Strategy（AC Coverage）、Deliverable Previews

### Build

Spec から実装する。Claude Code の `/goal` に処理を委譲し、APD は condition 組み立て役に徹する。

- スキル: `/apd:start <spec ファイル>`
- 動作:
  1. Spec を読み、AC・テスト戦略・成果物プレビュー要件を抽出
  2. `/goal` 用 condition を組み立てる（AC 全充足 + テスト pass + PR に「試し方」記載）
  3. ユーザーに condition を提示
  4. ユーザーが `/goal` を実行 → 評価器が毎ターン後に達成判定
- 並列化: 必要なら subagent / agent teams / `/batch` を選ぶ（APD は強制しない）
- 収束判定: 評価器は会話に surface された情報のみ判定するため、AI が turn 内でテスト実行ログ・PR diff を会話に出すことが前提

### Acceptance

PR の「試し方」セクションに沿って人間が実機で触る。

- OK → PR merge → issue 自動 close（GitHub 環境）
- NG → コメントで返す → 次サイクル（Spec を編集、Decision を追記など）
- AI が自動検証できない AC（実機限定、人間の主観評価等）は Acceptance で判定する

---

## ドキュメント管理

### 生きたドキュメント + git が正史

ドキュメントは **作ったら同じ場所で編集し続ける**。差分を別ファイル（Amendment / Patch）で積まない。「過去どうだったか」は git log / git blame が正史。

ファイルを移動・追加し続けると移動漏れや不整合が出る。**移動を前提にしない**設計にする。

### 3 ファイル種別

```
docs/apd/
├── design.md            ← 北極星（編集し続ける）
├── decisions.md         ← 判断の追記ログ（単一ファイル）
└── spec-{feature}.md    ← 機能ごと 1 枚（編集し続ける）
```

- サブディレクトリは作らない
- ファイルが増えるのは新機能を作るときだけ（本質的な増加なので許容）
- 機能が削除されたら、その Spec も削除する（これが唯一の「削除」）
- 成果物プレビューを作る場合のみ `docs/apd/preview-{feature}/` を追加（任意）

### 人間の確認面 = GitHub

`docs/apd/` の spec 群は **AI の作業材料**であって、人間が日常的にスキャンする場所ではない。人間が見るのは:

| 知りたいこと | 見る場所 |
|------------|---------|
| 進行中・backlog | `gh issue list` |
| 個別の変更を受け入れたい | その PR の「試し方」（Acceptance） |
| プロダクト全体像 | `docs/apd/design.md` |

`docs/apd/` 内に人間用ダッシュボード（INDEX 等）は置かない。同期対象が増えて移動漏れと同類のリスクになるため、GitHub（issue + PR）を人間のダッシュボードとして使う。

### Spec の更新と Decision の記録

- **Spec 修正**: 既存 `spec-{feature}.md` を直接編集し `version` を上げる。変更理由は git のコミットメッセージへ
- **Decision 記録**: 単一の `docs/apd/decisions.md` に追記する。Spec から特定の判断を引きたい場合は `decisions.md#d-001` のようにアンカー参照

### Handoff（試し方）はファイル化しない

Build が完了したら PR 本文の「## 試し方」セクションに記載する。理由:
- PR 本文は人間が次に見る場所
- レビュー時に diff と並べて確認できる
- 同じ機能の再 build で PR が新しく作られると Handoff も自然に最新化

### Backlog

`gh auth status` が成功する環境では **GitHub issue を一次 backlog** として使う。1 issue = 1 サイクルが基本。issue 番号と Spec / PR が相互リンクされることでサイクルの trail が自動で残る。**操作はローカルの `gh` CLI で完結する**（issue 作成・閲覧・コメント・PR との link すべて）。GitHub Actions を立てる必要はない。

`gh` が使えない環境では `docs/apd/todo.md` をフォールバックとして使う（append-only）。

### GitHub Actions / routines は任意

チームでの非同期トリガー（PR open で自動レビュー等）が必要なら GitHub Actions や routines を任意で追加できる。ただし個人開発や少人数チームでは **ローカルの `gh` + Claude Code のスキル呼び出しだけで十分** であり、APD は workflow ファイルを同梱しない。

---

## エスカレーション

判断が発生したとき:

1. **CLAUDE.md に明記されている** → それに従う
2. **CLAUDE.md に書かれていない** → リーダーエージェントが判断する
3. **リーダーエージェントが判断できない** → Acceptance として人間にエスカレーション

頻出の判断は CLAUDE.md に昇格させて自律範囲を広げていく。

### Build 中のエスカレーションポリシー（デフォルト）

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

---

## サイクル型統一フロー

すべての変更を「サイクル」として統一する。修正は新しいサイクルで行う（出戻りではなく前進）。

| トリガー | フロー |
|---------|--------|
| 新プロダクト / 大きな方向転換 | Intent → Spec → Build → Acceptance |
| 新機能追加 | Spec（既存 Design 参照）→ Build → Acceptance |
| バグ修正 / 仕様変更 | 既存 Spec を編集 (version↑) → Build → Acceptance |
| 技術的変更（リファクタ等）| Decision Record → Build → Acceptance |

### バグのトリアージ

バグ報告・テスト失敗が来たとき、AI がまず原因を判定する:

- **Spec 起因**（仕様漏れ・曖昧さ）→ 人間にエスカレーション → 既存 Spec を編集するサイクルへ
- **Build 起因**（実装が Spec と合っていない）→ AI 自律で修正 → 人間に上げない

---

## Git 運用

### ブランチ

- GitHub issue がある: `feat/{issue#}-{slug}` / `fix/{issue#}-{slug}` / `chore/{slug}`
- issue がない: `{type}/{slug}`

`main` から作成し、サイクル完了時に PR 経由でマージする。

### 並列実行

Build で複数タスクを並列実行する場合は git worktree を使う。Claude Code の subagent は `isolation: "worktree"` でファイル隔離込みで起動できるので、APD 独自の worktree 管理スクリプトは持たない。

### コミット規約

- Conventional Commits 準拠（`feat:`, `fix:`, `refactor:` 等）
- 関連する Spec ID / issue 番号を本文か footer に含める（例: `Refs: spec-42 / Closes: #42`）

---

## テスト方針

- テストが全パスしていることが必須
- 何をどうテストするかは Spec の Test Strategy セクションと AC Coverage テーブルで定義する
- 自動検証できない品質軸（実機限定、人間の主観評価等）は Acceptance で人間が確認する

### Build の収束は `/goal` 評価器が判定する

`/goal` 評価器は会話に surface された情報のみで判定するため、AI は turn 内で:

- テスト実行ログを出力する
- 実装変更内容を要約する
- PR diff や PR 本文を surface する

これにより評価器が AC 達成・テスト pass・Handoff 記載を判定できる。
