<!-- Spec Patch（差分ドキュメント）テンプレート -->
<!-- 既存ドキュメントを上書きせず、差分として発行する -->

---
patch_id: "P-{NNN}"
target_document: "{修正対象のドキュメントパス}"
issue_ref: "{関連 GitHub issue 番号、なければ null}"
created_at: "YYYY-MM-DDTHH:MM:SSZ"
decision_ref: "{関連 Decision Record、なければ null}"
reason: "{修正理由の概要}"
---

## Changes

### Section: {変更対象のセクション}

**Type**: {add / modify / remove}

**Before**:

```
{変更前の内容（modify / remove の場合）}
```

**After**:

```
{変更後の内容（add / modify の場合）}
```

## Impact

### Affected Specs
- {spec-{issue#}.md}

### Affected Tests
- {tests/unit/{name}.test.ts}

### Cascade Patch Required

{true / false — true の場合、他ドキュメントの patch も必要}
