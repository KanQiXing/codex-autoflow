#!/usr/bin/env bash
# codex-autoflow 安装器 — 复制引擎到 ~/.autoflow-codex 并链接 flow 命令
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)"
DEST="${FLOW_HOME:-$HOME/.autoflow-codex}"
BIN_DIR="${FLOW_BIN:-$HOME/.local/bin}"
CODEX_HOME_DIR="${CODEX_HOME:-$HOME/.codex}"
# 2026 官方 USER 作用域优先；~/.codex/skills 作为旧版兼容保留
SKILLS_DIR="$HOME/.agents/skills"
SKILLS_DIR_LEGACY="$CODEX_HOME_DIR/skills"

command -v codex >/dev/null 2>&1 \
  || echo "[warn] 未找到 codex 命令，可稍后安装: https://github.com/openai/codex"

mkdir -p "$DEST" "$BIN_DIR"
cp -R "$SRC/flow" "$SRC/skills" "$SRC/templates" "$SRC/docs" "$DEST/"
chmod +x "$DEST/flow"
ln -sf "$DEST/flow" "$BIN_DIR/flow"

# 技能装入 Codex 技能目录，供交互式会话渐进发现（含 flow-powerup 增强套件）
install_skills() {
  local dir="$1"
  [ -d "$dir" ] || mkdir -p "$dir"
  for s in "$SRC"/skills/*/; do
    [ -d "$s" ] || continue
    name="$(basename "$s")"
    rm -rf "$dir/$name"
    cp -R "$s" "$dir/$name"
  done
  echo "[ ok ] 技能已安装 -> $dir"
}
if [ -d "$CODEX_HOME_DIR" ] || command -v codex >/dev/null 2>&1; then
  install_skills "$SKILLS_DIR"
  [ -d "$SKILLS_DIR_LEGACY" ] && install_skills "$SKILLS_DIR_LEGACY"
fi

case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *) echo "[warn] $BIN_DIR 不在 PATH。请将此行加入 shell 配置:"
     echo "       export PATH=\"\$PATH:$BIN_DIR\"" ;;
esac

echo "[ ok ] 安装完成 -> $DEST"
echo "        下一步: cd your-project && flow init"
