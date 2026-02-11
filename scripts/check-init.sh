#!/bin/bash
# APD Plugin — SessionStart hook
# .claude/rules/apd/ が存在しない場合に初期化を案内する

if [ ! -d ".claude/rules/apd" ]; then
  echo "APD: ルールファイルが見つかりません。\`/apd:init\` を実行してプロジェクトを初期化してください。" >&2
fi
