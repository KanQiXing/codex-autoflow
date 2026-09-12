#!/usr/bin/env bash
# tests/test_dependency.sh — 依赖图执行（next_task_id）测试
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

# 加载 next_task_id 函数
awk '/^next_task_id\(\) {/{f=1} f{print} /^# 统一调用/{exit}' "$FLOW_SRC" > "$TESTDIR/func.sh"
# shellcheck disable=SC1090
source "$TESTDIR/func.sh"
FLOW_DIR="$TESTDIR/.flow"
mkdir -p "$FLOW_DIR"

echo "=== test_dependency.sh ==="

# 测试 1: 无依赖，返回第一个
cat > "$FLOW_DIR/PLAN.md" <<'EOF'
- [ ] T001: 第一个
  - 依赖: 无
- [ ] T002: 第二个
  - 依赖: 无
EOF
assert_eq "$(next_task_id)" "T001" "无依赖返回第一个"

# 测试 2: 依赖未满足，跳过该任务
cat > "$FLOW_DIR/PLAN.md" <<'EOF'
- [ ] T001: 第一个
  - 依赖: 无
- [ ] T002: 第二个
  - 依赖: T001
EOF
assert_eq "$(next_task_id)" "T001" "依赖未满足时返回无依赖的任务"

# 测试 3: 依赖已满足，返回依赖任务
cat > "$FLOW_DIR/PLAN.md" <<'EOF'
- [x] T001: 第一个
  - 依赖: 无
- [ ] T002: 第二个
  - 依赖: T001
EOF
assert_eq "$(next_task_id)" "T002" "依赖满足时返回被依赖的任务"

# 测试 4: 循环依赖 → BLOCKED
cat > "$FLOW_DIR/PLAN.md" <<'EOF'
- [ ] T001: 第一个
  - 依赖: T002
- [ ] T002: 第二个
  - 依赖: T001
EOF
assert_eq "$(next_task_id)" "BLOCKED" "循环依赖返回 BLOCKED"

# 测试 5: 多依赖（英文逗号），部分满足
cat > "$FLOW_DIR/PLAN.md" <<'EOF'
- [x] T001: 第一个
  - 依赖: 无
- [ ] T002: 第二个
  - 依赖: 无
- [ ] T003: 第三个
  - 依赖: T001, T002
EOF
assert_eq "$(next_task_id)" "T002" "多依赖部分满足时跳过"

# 测试 6: 多依赖（中文顿号），全部满足
cat > "$FLOW_DIR/PLAN.md" <<'EOF'
- [x] T001: 第一个
  - 依赖: 无
- [x] T002: 第二个
  - 依赖: 无
- [ ] T003: 第三个
  - 依赖: T001、T002
EOF
assert_eq "$(next_task_id)" "T003" "中文顿号分隔的多依赖"

# 测试 7: 全部完成 → 空
cat > "$FLOW_DIR/PLAN.md" <<'EOF'
- [x] T001: 第一个
  - 依赖: 无
- [x] T002: 第二个
  - 依赖: T001
EOF
assert_eq "$(next_task_id)" "" "全部完成返回空"

# 测试 8: 被阻塞的任务不应返回（即使它在前面）
cat > "$FLOW_DIR/PLAN.md" <<'EOF'
- [ ] T001: 被阻塞
  - 依赖: T003
- [x] T002: 已完成
  - 依赖: 无
- [ ] T003: 可执行
  - 依赖: 无
EOF
assert_eq "$(next_task_id)" "T003" "跳过被阻塞的前置任务"

echo
echo "=== 结果: $FAILS 失败 ==="
[ "$FAILS" -eq 0 ] || exit 1
