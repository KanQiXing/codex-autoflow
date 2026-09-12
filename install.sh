#!/usr/bin/env bash
# codex-autoflow 安装器 — 复制引擎到 ~/.autoflow-codex 并链接 flow 命令
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)"
DEST="${FLOW_HOME:-$HOME/.autoflow-codex}"
BIN_DIR="${FLOW_BIN:-$HOME/.local/bin}"
CODEX_HOME_DIR="${CODEX_HOME:-$HOME/.codex}"
SKILLS_DIR="$CODEX_HOME_DIR/skills"

command -v codex >/dev/null 2>&1 \
  || echo "[warn] 未找到 codex 命令，可稍后安装: https://github.com/openai/codex"

mkdir -p "$DEST" "$BIN_DIR"
cp -R "$SRC/flow" "$SRC/skills" "$SRC/templates" "$SRC/docs" "$DEST/"
chmod +x "$DEST/flow"
ln -sf "$DEST/flow" "$BIN_DIR/flow"

# 可选: 技能装入 Codex 全局技能目录，供交互式会话渐进发现
if [ -d "$CODEX_HOME_DIR" ] || command -v codex >/dev/null 2>&1; then
  mkdir -p "$SKILLS_DIR"
  for s in "$SRC"/skills/*/; do
    [ -d "$s" ] || continue
    name="$(basename "$s")"
    rm -rf "$SKILLS_DIR/$name"
    cp -R "$s" "$SKILLS_DIR/$name"
  done
  echo "[ ok ] 技能已安装 -> $SKILLS_DIR"
fi

case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *) echo "[warn] $BIN_DIR 不在 PATH。请将此行加入 shell 配置:"
     echo "       export PATH=\"\$PATH:$BIN_DIR\"" ;;
esac

echo "[ ok ] 安装完成 -> $DEST"
echo "        下一步: cd your-project && flow init"
