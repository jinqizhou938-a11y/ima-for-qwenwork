#!/usr/bin/env bash
# 安装/更新 ima 官方 skill 包。本仓库不内置 ima-skill 源码——这里现取现装官方 zip。
#
# 用法:
#   bash install_ima_skill.sh                       # 用内置默认版本
#   bash install_ima_skill.sh "https://app-dl.ima.qq.com/skills/ima-skills-1.1.x.zip"
#   IMA_ZIP_URL="https://..." bash install_ima_skill.sh
#
# 官方下载页: https://ima.qq.com/agent-interface （用最新链接覆盖默认版本最稳）

set -euo pipefail

DEFAULT_VERSION="1.1.10"
ZIP_URL="${1:-${IMA_ZIP_URL:-https://app-dl.ima.qq.com/skills/ima-skills-${DEFAULT_VERSION}.zip}}"
SKILLS_DIR="${IMA_SKILLS_DIR:-$HOME/.qwenworkcn/skills}"
TARGET="$SKILLS_DIR/ima-skill"

command -v curl >/dev/null || { echo "[err] 需要 curl"; exit 1; }
command -v unzip >/dev/null || { echo "[err] 需要 unzip"; exit 1; }

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
echo "==> 下载 $ZIP_URL"
curl -fL --retry 3 --connect-timeout 15 -o "$TMP/skill.zip" "$ZIP_URL"

echo "==> 解压并定位 ima-skill/"
unzip -q "$TMP/skill.zip" -d "$TMP/x"
SRC="$(find "$TMP/x" -type f -name ima_api.cjs -printf '%h\n' 2>/dev/null | head -1 || true)"
[ -n "$SRC" ] || { echo "[err] 未在包内找到 ima_api.cjs，包结构可能已变化"; exit 1; }

echo "==> 清理 macOS 残留"
find "$SRC" -name '.DS_Store' -delete 2>/dev/null || true
rm -rf "$SRC/.history" "$SRC/__MACOSX" 2>/dev/null || true

if [ -e "$TARGET" ]; then
  echo "==> 备份现有版本 -> $TARGET.bak.$(date +%Y%m%d%H%M%S)"
  mv "$TARGET" "$TARGET.bak.$(date +%Y%m%d%H%M%S)"
fi
mkdir -p "$SKILLS_DIR"
cp -r "$SRC" "$TARGET"

VER="$(node -e "console.log(require('$TARGET/meta.json').version)" 2>/dev/null || echo unknown)"
echo "==> 安装完成: $TARGET (版本 $VER)"
echo "==> 下一步: 在千问办公里说 \"配置 ima 接入\" 走 ima-setup"
echo "提示: 若安装的是插件形态, 千问办公可能需要重启一次以加载新技能"
