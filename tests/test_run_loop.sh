#!/usr/bin/env bash
# tests/test_run_loop.sh — Ralph 循环 + 熔断逻辑（用 mock codex）
set -uo pipefail

FLOW_SRC="${FLOW_SRC:-$(cd "$(dirname "$0")/.." && pwd)/flow}"
TESTDIR="$(mktemp -d)"
trap 'rm -rf "$TESTDIR"' EXIT

FAILS=0
assert() {
  if [ "$1" = "$2" ]; then
    printf '  \033[1;32m✓\033[0m %s\n' "$3"
  else
    printf '  \033[1;31m✗\033[0m %s (expected %s, got %s)\n' "$3" "$2" "$1" >&2
    FAILS=$((FAILS + 1))
  fi
}

cd "$TESTDIR"
git init -q
git config user.email test@test.com
git config user.name test

# 先 init 创建 .flow/ 结构
"$FLOW_SRC" init >/dev/null 2>&1

# 创建 mock codex：根据 MOCK_MODE 模拟不同行为
mkdir -p "$TESTDIR/bin"
cat > "$TESTDIR/bin/codex" <<'MOCK'
#!/usr/bin/env bash
# 根据第一个参数判断模式: exec 还是交互
# MOCK_MODE: success=完成一个任务; stall=不提交; fail=退出码非零
case "$MOCK_MODE" in
  success)
    # 模拟完成第一个未完成任务
    PLAN="$(pwd)/.flow/PLAN.md"
    if grep -q '^- \[ \]' "$PLAN" 2>/dev/null; then
      sed -i '0,/^- \[ \]/{s/^- \[ \]/- [x]/}' "$PLAN"
      echo "completed one task" >> .flow/PROGRESS.md
      git add -A 2>/dev/null
      git commit -q -m "flow(mock): completed task" 2>/dev/null
    fi
    exit 0
    ;;
  stall)
    echo "no progress"
    exit 0
    ;;
  fail)
    echo "error" >&2
    exit 1
    ;;
  *)
    echo "unknown mode" >&2
    exit 1
    ;;
esac
MOCK
chmod +x "$TESTDIR/bin/codex"

export PATH="$TESTDIR/bin:$PATH"

echo "测试 1: 全部任务完成触发复盘"
printf -- '- [ ] T001\n- [ ] T002\n' > .flow/PLAN.md 2>/dev/null
mkdir -p .flow/VERIFICATIONS
printf '# log\n' > .flow/PROGRESS.md 2>/dev/null
printf '# mem\n' > .flow/MEMORY.md 2>/dev/null
printf 'approved\n' > .flow/APPROVED
MOCK_MODE=success FLOW_AUTO_REVIEW=0 "$FLOW_SRC" run 5 >/dev/null 2>&1
assert "$(grep -c '^- \[x\]' .flow/PLAN.md)" "2" "两个任务都完成"

echo
echo "测试 2: 停滞熔断（连续 3 轮无提交）"
printf -- '- [ ] T001\n- [ ] T002\n' > .flow/PLAN.md
MOCK_MODE=stall FLOW_AUTO_REVIEW=0 "$FLOW_SRC" run 10 >/dev/null 2>&1
rc=$?
assert "$rc" "1" "停滞 3 轮后以非零退出"

echo
echo "测试 3: 未审批拒绝执行"
rm -f .flow/APPROVED
"$FLOW_SRC" run 5 >/dev/null 2>&1
rc=$?
assert "$rc" "1" "未审批时拒绝执行"

echo
echo "=== 结果: $FAILS 失败 ==="
[ "$FAILS" -eq 0 ] || exit 1
