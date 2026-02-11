# APD Git運用戦略

## ブランチ戦略

### サイクルブランチ

各APDサイクルは専用ブランチで作業する:

- ブランチ名: `apd/C-{NNN}/{short-description}`
- mainブランチから作成し、サイクル完了時にmainへマージする

### Phase 3: 並列実行時のgit worktree

Phase 3で複数タスクを並列実行する場合、git worktreeでタスクごとに独立した作業ディレクトリを確保する。

#### worktreeの作成

```bash
# サイクルブランチからタスクブランチを作成
git worktree add ../project-task-{N} -b apd/C-{NNN}/task-{N}
```

#### worktreeの統合

全タスク完了後、サイクルブランチに統合する:

```bash
# サイクルブランチに各タスクブランチをマージ
git checkout apd/C-{NNN}/{short-description}
git merge apd/C-{NNN}/task-{N}
```

#### worktreeのクリーンアップ

統合後にworktreeを削除する:

```bash
git worktree remove ../project-task-{N}
```

### 並列実行しない場合

タスクが少数で並列化不要の場合は、サイクルブランチ上で直接作業してよい。worktreeは必須ではない。

## コミット規約

- コミットメッセージにタスクIDを含める: `[C-{NNN}/task-{N}] 実装内容の説明`
- 1タスク = 1つ以上のコミット（意味のある単位でコミットする）
