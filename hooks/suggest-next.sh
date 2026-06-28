#!/bin/bash
# APD: プロジェクト状態を見て次に打つコマンドを提案する（止めない）
set -euo pipefail

INPUT=$(cat)
# 無限ループ防止: 継続トリガー済みなら何もしない
if [ "$(printf '%s' "$INPUT" | jq -r '.stop_hook_active // false')" = "true" ]; then
  exit 0
fi

PROJ="${CLAUDE_PROJECT_DIR:-.}"
APD_DIR="$PROJ/docs/apd"

suggest() {
  jq -n --arg msg "$1" '{ "hookSpecificOutput": { "hookEventName": "Stop", "additionalContext": $msg } }'
}

if [ ! -f "$APD_DIR/design.md" ]; then
  suggest "APD: まだ Design がありません。/apd:design でプロダクトの軸を作りましょう。"
elif ! ls "$APD_DIR"/spec-*.md >/dev/null 2>&1; then
  suggest "APD: Design はあります。/apd:spec で Spec を作りましょう。"
else
  suggest "APD: Spec があります。実装は /apd:go で達成条件を作り、出力を /goal に貼って開始します。"
fi
exit 0
