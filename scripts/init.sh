#!/bin/bash
# APD Boilerplate — プロジェクト初期化スクリプト
# Usage: ./scripts/init.sh /path/to/project "プロジェクト名"

set -euo pipefail

PROJECT_DIR="${1:?Usage: $0 <project-dir> <project-name>}"
PROJECT_NAME="${2:?Usage: $0 <project-dir> <project-name>}"
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "🚀 APD Boilerplate — プロジェクト初期化"
echo "   プロジェクト: ${PROJECT_NAME}"
echo "   ディレクトリ: ${PROJECT_DIR}"
echo ""

# ディレクトリ作成
mkdir -p "${PROJECT_DIR}"/{design,specs,contract,decisions,cycles,src,tests}

# CLAUDE.md コピー
if [ ! -f "${PROJECT_DIR}/CLAUDE.md" ]; then
  cp "${SCRIPT_DIR}/templates/CLAUDE.md" "${PROJECT_DIR}/CLAUDE.md"
  # プロジェクト名を置換
  sed -i "s/{{プロジェクト名}}/${PROJECT_NAME}/g" "${PROJECT_DIR}/CLAUDE.md"
  echo "✅ CLAUDE.md を作成しました"
else
  echo "⚠️  CLAUDE.md は既に存在します（スキップ）"
fi

# テンプレートをコピー（参照用）
mkdir -p "${PROJECT_DIR}/.apd-templates"
cp "${SCRIPT_DIR}/templates/"*.yaml "${PROJECT_DIR}/.apd-templates/"
echo "✅ テンプレートを .apd-templates/ にコピーしました"

# プロンプトをコピー（参照用）
mkdir -p "${PROJECT_DIR}/.apd-prompts"
cp "${SCRIPT_DIR}/prompts/"*.md "${PROJECT_DIR}/.apd-prompts/"
echo "✅ プロンプトを .apd-prompts/ にコピーしました"

# .gitignore に追加
if [ ! -f "${PROJECT_DIR}/.gitignore" ]; then
  cat > "${PROJECT_DIR}/.gitignore" << 'EOF'
node_modules/
.env
.env.local
dist/
build/
*.log
EOF
  echo "✅ .gitignore を作成しました"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 初期化完了！"
echo ""
echo "次のステップ:"
echo "  1. CLAUDE.md のプロジェクトレベル設定を編集"
echo "  2. .apd-prompts/phase-0-design.md のプロンプトで Design 文書を作成"
echo "  3. git init && git add -A && git commit -m 'Initial APD setup'"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
