#!/bin/bash
# APD: プロジェクト状態を見て次に打つコマンドを提案する（止めない）
set -euo pipefail

INPUT=$(cat)
# 無限ループ防止: 継続トリガー済みなら何もしない
if [ "$(printf '%s' "$INPUT" | jq -r '.stop_hook_active // false')" = "true" ]; then
  exit 0
fi

# 実際のイベント名（Stop / SessionStart など）を stdin から取得して返す
EVENT=$(printf '%s' "$INPUT" | jq -r '.hook_event_name // "Stop"')

PROJ="${CLAUDE_PROJECT_DIR:-.}"
APD_DIR="$PROJ/docs/apd"

suggest() {
  jq -n --arg msg "$1" --arg ev "$EVENT" '{ "hookSpecificOutput": { "hookEventName": $ev, "additionalContext": $msg } }'
}

if [ ! -f "$APD_DIR/design.md" ]; then
  suggest "APD: まだ Design がありません。/apd:design でプロダクトの軸を作りましょう。"
elif ! ls "$APD_DIR"/spec-*.md >/dev/null 2>&1; then
  suggest "APD: Design はあります。/apd:spec で Spec を作りましょう。"
else
  suggest "APD: Spec があります。実装は /apd:go で達成条件を作り、出力を /goal に貼って開始します。"
fi
exit 0
