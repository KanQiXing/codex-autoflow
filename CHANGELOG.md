# CHANGELOG

所有变更记录于此文件。格式基于 [Keep a Changelog](https://keepachangelog.com/)。

## [1.1.0] - 2026-09-12

### Added
- 文件锁机制（flock + PID fallback），防止并发 `flow run` 损坏共享状态（`FLOW_FORCE=1` 可绕过）
- 单任务超时保护（`FLOW_TASK_TIMEOUT`，默认 600 秒）
- `flow rollback TXXX` 命令：回滚指定任务（git revert + 重置 checkbox）
- `flow init` 自动生成安全 `.gitignore`（忽略 `.env` / `*.key` / `*.pem` / `.flow/last-run.log`）
- 依赖图执行：`next_task_id()` 按 `依赖:` 字段解析任务顺序，支持中英文逗号分隔；循环依赖输出 `BLOCKED` 并终止
- 零依赖 bash 测试体系（`tests/`），覆盖核心函数、init、run_loop、skill_body、status、dependency
- GitHub Actions CI（shellcheck + 单元测试）
- `install.sh` checksum 校验
- CONTRIBUTING.md + Issue/PR 模板

### Changed
- `skill_body()` 改用状态机解析，代码块内的 `---` 不再被误判为 frontmatter 结束
- `count_open` / `count_done` / `count_all` 先检查文件存在性，避免 grep 报错
- `codex_run` 不再用 `exec` 替换进程，保留 trap cleanup 能力
- `flow-execute` 技能禁止 `git add -A`，要求选择性暂存并列出禁止提交的文件类型
- `flow-execute` 技能任务选择逻辑尊重 PLAN.md 中的依赖顺序
- README 高级用法移除 `--full-auto` 示例，添加安全警告
- README / DESIGN.md / SKILL.md 中引用的社区仓库星数经 GitHub API 核实，失效链接替换为有效仓库

### Fixed
- `count_*` 函数在 grep 无匹配时输出重复 "0" 的 bug

### Known Limitations
- 暂未实现部分审批（`flow approve` 仍为全有或全无）
- 暂未实现 MEMORY.md 自动裁剪

## [1.0.0] - 2026-09-12

### Added
- 初始版本：访谈 → 规划 → 审批 → 执行 → 验证 → 复盘 六阶段闭环
- `flow powerup`：Codex 本体增强（AGENTS.md / 子代理 / config / 技能 / MCP）
- `flow hub`：技能生态中心（发现 / 安装 / 策展 / 安全审计）
- 8 个内置技能（interview / plan / execute / verify / review / powerup / skills-hub + AGENTS.md）
- 从 12 个开源项目蒸馏的设计取舍文档
