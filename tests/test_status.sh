#!/usr/bin/env bash
# tests/test_status.sh — 状态报告测试
set -uo pipefail

FLOW_SRC="${FLOW_SRC:-$(cd "$(dirname "$0")/.." && pwd)/flow}"
TESTDIR="$(mktemp -d)"
trap 'rm -rf "$TESTDIR"' EXIT

FAILS=0
assert_contains() {
  if echo "$1" | grep -qF "$2"; then
    printf '  \033[1;32m✓\033[0m 输出包含 [%s]\n' "$2"
  else
    printf '  \033[1;31m✗\033[0m 输出未包含 [%s]\n' "$2" >&2
    FAILS=$((FAILS + 1))
  fi
}

cd "$TESTDIR"
git init -q
mkdir -p .flow/VERIFICATIONS
printf -- '- [x] T001 完成\n- [ ] T002 未完成\n' > .flow/PLAN.md
printf '# log\n' > .flow/PROGRESS.md
printf '# mem\n' > .flow/MEMORY.md
printf 'approved\n' > .flow/APPROVED

output="$("$FLOW_SRC" status 2>&1)"

assert_contains "$output" "已批准"
assert_contains "$output" "1/2"
assert_contains "$output" "剩余 1"

echo
echo "未批准状态:"
rm -f .flow/APPROVED
output="$("$FLOW_SRC" status 2>&1)"
assert_contains "$output" "未批准"

echo
echo "=== 结果: $FAILS 失败 ==="
[ "$FAILS" -eq 0 ] || exit 1
