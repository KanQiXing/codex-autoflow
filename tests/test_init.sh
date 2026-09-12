#!/usr/bin/env bash
# tests/test_init.sh — flow init 流程测试
set -uo pipefail

FLOW_SRC="${FLOW_SRC:-$(cd "$(dirname "$0")/.." && pwd)/flow}"
TESTDIR="$(mktemp -d)"
trap 'rm -rf "$TESTDIR"' EXIT

FAILS=0
assert_file() {
  if [ -e "$1" ]; then
    printf '  \033[1;32m✓\033[0m 存在: %s\n' "$1"
  else
    printf '  \033[1;31m✗\033[0m 缺失: %s\n' "$1" >&2
    FAILS=$((FAILS + 1))
  fi
}
assert_contains() {
  local file="$1" pattern="$2"
  if grep -qF "$pattern" "$file" 2>/dev/null; then
    printf '  \033[1;32m✓\033[0m %s 包含 [%s]\n' "$file" "$pattern"
  else
    printf '  \033[1;31m✗\033[0m %s 未包含 [%s]\n' "$file" "$pattern" >&2
    FAILS=$((FAILS + 1))
  fi
}

cd "$TESTDIR"
git init -q
git config user.email test@test.com
git config user.name test

"$FLOW_SRC" init

echo "init 文件结构:"
assert_file ".flow/PRD.md"
assert_file ".flow/PLAN.md"
assert_file ".flow/PROGRESS.md"
assert_file ".flow/MEMORY.md"
assert_file ".flow/VERIFICATIONS"
assert_file "AGENTS.md"
assert_file ".gitignore"

echo
echo "安全 .gitignore 规则:"
assert_contains ".gitignore" ".flow/last-run.log"
assert_contains ".gitignore" "*.env"
assert_contains ".gitignore" "*.key"
assert_contains ".gitignore" "*.pem"

echo
echo "幂等性（第二次 init 不覆盖）:"
echo "CUSTOM" >> .flow/MEMORY.md
"$FLOW_SRC" init
assert_contains ".flow/MEMORY.md" "CUSTOM"

echo
echo "=== 结果: $FAILS 失败 ==="
[ "$FAILS" -eq 0 ] || exit 1
