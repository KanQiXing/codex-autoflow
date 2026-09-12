# 设计蒸馏：六大项目 → codex-autoflow

> 蒸馏的原则：**保留思想，丢弃复杂度**。每一项取舍都有理由，都写在这里。

## 来源映射

| # | 来源 | 规模 | 蒸馏出的核心 | 丢弃的部分 | 丢弃理由 |
|---|------|------|------------|-----------|---------|
| 1 | [oh-my-codex](https://github.com/Yeachan-Heo/oh-my-codex) | 33k★ | 访谈→规划→**人工审批**的门禁式流程；`.omx/` 持久化目录思想 | 多智能体团队、HUD、插件生态 | 编排收益不稳定，复杂度上升是确定的 |
| 2 | [Ralph 模式](https://ghuntley.com/ralph/) (Geoffrey Huntley) | — | 外层循环 + 每轮全新会话 + **单任务约束** + git 即记忆 | 无界循环、默认无人值守 | 无界循环 = 失控烧钱；改为确定性完成门禁 + 停滞熔断 |
| 3 | [planning-with-files](https://github.com/OthmanAdi/planning-with-files) | 27k★ | 文件即计划；每轮**重注入**对抗上下文腐烂；确定性完成门禁 | npm 分发、60+ agent 适配层 | bash + markdown 即可达成同样效果，零依赖 |
| 4 | [codex_autoworker](https://github.com/Frank-Opus/codex_autoworker) | — | 「一切落盘」「**证据即完成**」；崩溃安全的恢复锚点 | 多 harness 抽象 | 聚焦 Codex，砍掉间接层 |
| 5 | [Skills 生态](https://github.com/vercel-labs/skills) / SKILL.md 格式 | — | SKILL.md **渐进披露**格式；技能=提示词=文档三位一体 | 市场化分发、跨 agent 兼容层 | 直接复用格式，不需要包管理器 |
| 6 | [coding-agent-toolkit](https://github.com/stefan-jansen/coding-agent-toolkit) | — | align→plan→ship 的**阶段化**流程；收尾复盘 | GitHub Issue/PR 投影、双 harness 状态 | 单仓库闭环已覆盖；投影可由用户自行叠加 |

## 五条铁律（系统的物理学）

1. **一切落盘** — 计划、进度、记忆、证据全部是 git 内的 markdown。
   会话随时可能被杀，磁盘不会。恢复不靠记忆，靠文件。
2. **先审后动** — PLAN.md 未经 `flow approve`，执行引擎拒绝开工。
   人类只审一份文档，就控制了后续全部自主执行。
3. **单任务循环** — 每轮全新会话只做一个任务。
   干净上下文 > 长上下文；一个任务一个提交，天然回滚点。
4. **证据即完成** — 验证命令与输出必须写入 `VERIFICATIONS/`。
   「模型说完成」不算完成，「证据说完成」才算完成。
5. **上下文重注入** — 每轮第一步永远是重读 `.flow/*`。
   长任务最大的敌人是上下文腐烂与目标漂移。

## 安全机制

| 机制 | 作用 |
|------|------|
| 审批印章 (.flow/APPROVED) | 双重强制：flow 脚本与 execute 提示词都会拒绝未审批执行 |
| 最大迭代上限 (flow run N) | 循环必然有界 |
| 停滞熔断（连续 3 轮无新提交即停） | 检测模型空转 / 死循环 |
| 确定性完成门禁（grep 统计 PLAN.md 勾选） | 完成判定不依赖模型自述 |
| 每任务一提交 | 任意回滚、断点续做、审计轨迹 |

## 刻意不做的（负空间）

- **多智能体编排** — 单循环已覆盖大部分场景，剩余场景的复杂度不值
- **TUI / HUD** — `tail -f .flow/last-run.log` 就是最好的仪表盘
- **跨 agent 兼容层** — 换 agent 时改一个 `codex_run` 函数即可
- **数据库 / Web 面板** — git log 就是历史，grep 就是查询
- **无限自治** — 停滞熔断 + 迭代上限：自主但可控

## 什么时候不该用 codex-autoflow

- 一次性小改动：直接 `codex "改一下 x"` 更快
- 探索性 spike：不需要计划审批，直接聊
- 多仓库 / 多 agent 编排：去看 [agent-orchestrator](https://github.com/Untrivial-ai/agent-orchestrator) 或 [multi-agent-orchestration](https://github.com/formiat/multi-agent-orchestration)

## 致谢

本项目是站在巨人肩膀上的蒸馏，向全部来源项目及其作者致敬。
