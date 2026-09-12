# AGENTS.md — 本仓库开发约定（给 Codex 的说明）

本仓库是 codex-autoflow 引擎本身，修改它时严格遵守以下约定。

## 结构铁则

- `flow` 是唯一可执行入口：所有命令、Ralph 循环、熔断逻辑都在这一个 bash 文件里，禁止拆分成多脚本
- `skills/*/SKILL.md` 三位一体：技能 = 提示词 = 文档。YAML frontmatter 供发现与路由，正文被 `flow` 剥离 frontmatter 后直接注入 codex
- `skills/flow-powerup/` 是 Codex 增强套件：`references/` 放深度指南（渐进披露），`assets/` 放可安装的子代理 TOML
- `skills/flow-skills-hub/` 是技能生态中心：`references/` 放技能分类法/自进化/安全审计指南。只做策展导航，不内置社区技能
- `templates/` 是 `flow init` 复制到用户项目的初始状态文件
- `docs/DESIGN.md` 是设计蒸馏说明：改动核心设计前必读，改动后同步更新

## 硬性约束

1. 零运行时依赖：bash + git + codex。禁止引入 node/python/perl
2. 兼容 macOS bash 3.2：不用 `readlink -f`、关联数组、`mapfile`
3. 错误提示全部走 `die`/`warn`：中文、一句话说清、给出下一步命令
4. 每条给模型的规则必须可判定：不写「写清楚一点」，要写「禁止 TODO 占位」

## 修改技能提示词时

- 保持「执行序列」的编号结构（模型对编号步骤的遵循度显著更高）
- 规则改动必须能在 README 的流程描述中找到对应
- 改完跑 `bash -n flow` 做语法检查

## 本仓库自身的开发（dogfood）

用本引擎开发本引擎：`flow init -> flow interview -> flow plan -> flow approve -> flow run`。
