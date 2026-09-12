#!/usr/bin/env bash
# tests/test_core.sh — 核心函数测试（count_* / skill_body 解析健壮性）
# 零依赖 bash 测试框架，兼容 bats-core 语法子集
set -uo pipefail

FLOW_SRC="${FLOW_SRC:-$(cd "$(dirname "$0")/.." && pwd)/flow}"
TESTDIR="$(mktemp -d)"
trap 'rm -rf "$TESTDIR"' EXIT

# 简易断言
assert_eq() {
  local actual="$1" expected="$2" msg="${3:-}"
  if [ "$actual" = "$expected" ]; then
    printf '  \033[1;32m✓\033[0m %s\n' "${msg:-equality}"
  else
    printf '  \033[1;31m✗\033[0m %s\n    expected: %s\n    actual:   %s\n' "${msg:-equality}" "$expected" "$actual" >&2
    FAILS=$((FAILS + 1))
  fi
}

# 加载 flow 中的函数（不执行路由）
load_flow_funcs() {
  # 提取函数定义（从 resolve_root 到最后一个函数结束，跳过 case 路由）
  awk '/^resolve_root\(\) {/{f=1} f{print} /^# ---------- 路由/{exit}' "$FLOW_SRC" > "$TESTDIR/funcs.sh"
  # 去掉 set -e 等冲突设置，注入测试用 FLOW_DIR
  sed -i 's/^set -uo pipefail//' "$TESTDIR/funcs.sh"
  # shellcheck disable=SC1090
  source "$TESTDIR/funcs.sh"
  FLOW_DIR="$TESTDIR/.flow"
  mkdir -p "$FLOW_DIR"
}

FAILS=0

echo "=== test_core.sh ==="
load_flow_funcs

# --- count_* 边界情况 ---
echo "count_* 边界:"

# 空 PLAN.md
: > "$FLOW_DIR/PLAN.md"
assert_eq "$(count_open)" "0" "空文件 count_open=0"
assert_eq "$(count_done)" "0" "空文件 count_done=0"
assert_eq "$(count_all)"  "0" "空文件 count_all=0"

# 全未完成
printf -- '- [ ] T001 任务一\n- [ ] T002 任务二\n' > "$FLOW_DIR/PLAN.md"
assert_eq "$(count_open)" "2" "全未完成 count_open=2"
assert_eq "$(count_done)" "0" "全未完成 count_done=0"
assert_eq "$(count_all)"  "2" "全未完成 count_all=2"

# 全完成
printf -- '- [x] T001 任务一\n- [x] T002 任务二\n' > "$FLOW_DIR/PLAN.md"
assert_eq "$(count_open)" "0" "全完成 count_open=0"
assert_eq "$(count_done)" "2" "全完成 count_done=2"
assert_eq "$(count_all)"  "2" "全完成 count_all=2"

# 混合 + 缩进
printf -- '  - [ ] T001 未完成\n    - [x] T002 已完成\n- [x] T003 已完成\n' > "$FLOW_DIR/PLAN.md"
assert_eq "$(count_open)" "1" "混合缩进 count_open=1"
assert_eq "$(count_done)" "2" "混合缩进 count_done=2"
assert_eq "$(count_all)"  "3" "混合缩进 count_all=3"

# 文件不存在
rm -f "$FLOW_DIR/PLAN.md"
assert_eq "$(count_open)" "0" "文件不存在 count_open=0"
assert_eq "$(count_done)" "0" "文件不存在 count_done=0"

echo
echo "=== 结果: $FAILS 失败 ==="
[ "$FAILS" -eq 0 ] || exit 1
