#!/usr/bin/env bash
# tests/run.sh — 运行所有测试
set -uo pipefail

TESTDIR="$(cd "$(dirname "$0")" && pwd)"
FLOW_SRC="${FLOW_SRC:-$(cd "$TESTDIR/.." && pwd)/flow}"
export FLOW_SRC

total=0
fails=0

for t in "$TESTDIR"/test_*.sh; do
  total=$((total + 1))
  echo
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "运行: $(basename "$t")"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  if bash "$t"; then
    echo "  \033[1;32mPASS\033[0m"
  else
    echo "  \033[1;31mFAIL\033[0m"
    fails=$((fails + 1))
  fi
done

echo
echo "============================================"
echo "测试汇总: $((total - fails))/$total 通过"
echo "============================================"
[ "$fails" -eq 0 ] || exit 1
