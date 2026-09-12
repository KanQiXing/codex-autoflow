# 贡献指南

感谢你对 codex-autoflow 的关注！

## 如何贡献

### 报告 Bug

请使用 [Issue 模板](.github/ISSUE_TEMPLATE/bug_report.md)，包含：
- 复现步骤
- 预期行为 vs 实际行为
- 环境信息（OS、bash 版本、codex 版本）

### 提议新功能

请使用 [Feature Request 模板](.github/ISSUE_TEMPLATE/feature_request.md)，说明：
- 解决什么问题
- 期望的行为
- 为什么不应该是外部技能而非核心功能

### 提交代码

1. Fork 仓库并创建 feature 分支
2. 确保 `bash tests/run.sh` 全部通过
3. 确保 `bash -n flow` 语法检查通过
4. 提交信息遵循 Conventional Commits（`feat:` / `fix:` / `docs:` / `refactor:`）
5. 发起 Pull Request，填写 PR 模板

## 代码风格

- bash 脚本：通过 `shellcheck -x flow`（警告可接受，错误必须修复）
- 函数命名：`cmd_*` 为命令入口，其他为辅助函数
- 状态即文件：所有状态写入 `.flow/`，不依赖进程内存
- 注释用中文，与项目主体语言一致

## 设计原则

- **零依赖**：只依赖 bash + git + codex，不引入 node/python/perl
- **最小化**：保留思想，丢弃复杂度。新功能必须有明确的取舍理由
- **安全优先**：不引入 `git add -A`、不建议 `--full-auto`、敏感文件必须 gitignore
- **可测试**：核心逻辑可被 mock codex 测试

## 发布

- 语义版本：MAJOR.MINOR.PATCH
- 每次发布更新 CHANGELOG.md 并打 git tag
- 破坏性变更在 CHANGELOG 中标注

## 安全报告

如发现安全漏洞，请不要公开提 Issue，直接通过 GitHub Security Advisory 报告。
