#!/usr/bin/env bash
# tests/test_skill_body.sh — SKILL.md frontmatter 解析健壮性
set -uo pipefail

FLOW_SRC="${FLOW_SRC:-$(cd "$(dirname "$0")/.." && pwd)/flow}"
TESTDIR="$(mktemp -d)"
trap 'rm -rf "$TESTDIR"' EXIT

FAILS=0
assert_eq() {
  local actual="$1" expected="$2" msg="${3:-}"
  if [ "$actual" = "$expected" ]; then
    printf '  \033[1;32m✓\033[0m %s\n' "${msg:-equality}"
  else
    printf '  \033[1;31m✗\033[0m %s\n    expected: [%s]\n    actual:   [%s]\n' "${msg:-equality}" "$expected" "$actual" >&2
    FAILS=$((FAILS + 1))
  fi
}

# 加载 skill_body 函数
awk '/^skill_body\(\) {/{f=1} f{print} /^require_flow/{exit}' "$FLOW_SRC" > "$TESTDIR/sb.sh"
sed -i 's/^set -uo pipefail//' "$TESTDIR/sb.sh"
# shellcheck disable=SC1090
source "$TESTDIR/sb.sh"
ROOT="$TESTDIR"

# 构造测试技能目录
mkdir -p "$ROOT/skills/test-skill"

# --- 测试 1: 正常 frontmatter ---
cat > "$ROOT/skills/test-skill/SKILL.md" <<'EOF'
---
name: test
description: test skill
---
这是正文
第二行
EOF
result="$(skill_body test-skill)"
assert_eq "$result" $'这是正文\n第二行' "正常 frontmatter 解析"

# --- 测试 2: 代码块内含 --- 不应被误判为 frontmatter 结束 ---
cat > "$ROOT/skills/test-skill/SKILL.md" <<'EOF'
---
name: test
description: test
---
正文开头

```bash
echo "code"
---
echo "still in code"
```

正文结尾
EOF
result="$(skill_body test-skill)"
# 代码块内的 --- 不应导致 frontmatter 提前结束，正文应完整
if echo "$result" | grep -q "still in code" && echo "$result" | grep -q "正文结尾"; then
  printf '  \033[1;32m✓\033[0m 代码块内 --- 不被误判\n'
else
  printf '  \033[1;31m✗\033[0m 代码块内 --- 被误判为 frontmatter 结束\n' >&2
  FAILS=$((FAILS + 1))
fi

# --- 测试 3: 无 frontmatter（整个文件都是正文） ---
cat > "$ROOT/skills/test-skill/SKILL.md" <<'EOF'
没有 frontmatter
直接正文
EOF
result="$(skill_body test-skill)"
assert_eq "$result" $'没有 frontmatter\n直接正文' "无 frontmatter 时全文为正文"

# --- 测试 4: 空正文 ---
cat > "$ROOT/skills/test-skill/SKILL.md" <<'EOF'
---
name: test
---
EOF
result="$(skill_body test-skill)"
assert_eq "$result" "" "空正文返回空"

echo
echo "=== 结果: $FAILS 失败 ==="
[ "$FAILS" -eq 0 ] || exit 1
