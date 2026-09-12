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

## 第二波蒸馏：Codex 本体增强（flow-powerup）

> 来源：2026 官方文档（Skills 四作用域 / sub-agents TOML / AGENTS.md 分层链）+ 社区高星实践

| 来源 | 规模 | 取 | 舍 | 舍弃理由 |
|------|------|----|----|---------|
| [awesome-codex-subagents](https://github.com/VoltAgent/awesome-codex-subagents) | 6.2k★ · 130+ 代理 | 沙箱哲学（审查只读/执行受限写）、模型路由经济学、TOML 字段规范 | 全量代理 | 精馏为 3 个普适角色（reviewer/implementer/researcher），覆盖 90% 场景 |
| Codex 官方文档 2026 | — | Skills 四作用域（`.agents/skills`）、渐进披露 2% 预算、`agents/openai.yaml`、`[agents]` 护栏 | — | 直接采用 |
| CLAUDE.md 治理经验（社区广泛流传） | — | 四行为铁则（Think Before Coding / Simplicity First / Surgical Changes / Goal-Driven） | 逐条规则 | 原则可迁移，具体规则不可 |
| [cc-switch](https://github.com/farion1231/cc-switch) | 132k★ | 多 harness 配置管理思路 | 桌面 App 形态 | bash 覆盖核心路径，无 GUI 依赖 |
| [ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) | 127k★ | 作为技能面推荐项 | 内置进引擎 | 非普适场景，按需选装 |

**统一为一个技能的设计**：`flow-powerup` 单入口覆盖五大增强面（AGENTS.md / 子代理 / config / 技能面 / MCP+界面端），深度资料放 `references/`（渐进披露）、可安装资产放 `assets/`（三个 TOML）——符合官方技能解剖结构，description 即广告位。

## 第三波蒸馏：技能生态中心（flow-skills-hub）

> 来源：10+ 社区技能仓库 + SkillHone 自进化 + SAIL 安全审计 + codex-skills CLI

| 来源 | 规模 | 取 | 舍 | 舍弃理由 |
|------|------|----|----|---------|
| [awesome-ai-agent-skills](https://github.com/seb1n/awesome-ai-agent-skills) | 179★ · 103 技能 | 10 分类法 / 策展方法论 | 全量内置 103 技能 | 按需导航而非全量打包，避免膨胀 |
| [SkillHone](https://github.com/Tencent/SkillHone) | 149★ | 决策记录 → 自进化循环 | Git issue/PR/wiki 自动化 | 保留核心循环（DECISIONS.md → reviewer 审计 → 优化），bash 实现更轻 |
| [codex-skills CLI（社区模式）](https://github.com/search?q=codex+skills+cli&type=repositories) | — | 全局 Ledger 模式 / verify 命令 / catalog + `--ref` pinning | npm CLI 工具 | 纳入 flow hub 技能正文，不需要独立 CLI |
| [sail-skill](https://github.com/pillar-labs/sail-skill) | 119★ | 91 项 AI 安全风险目录（9 大类） | 独立安装与品牌 | 纳入 `references/security-audit.md` 供按需触发 |
| [design-harness](https://github.com/tigerless-labs/design-harness) | 217★ | 论文 → 可辩护系统设计 + provenance 思维 | Python 可视化画布 | 保留思维模式，去掉工具依赖 |
| [antigravity-awesome-skills](https://github.com/sickn33/agentic-awesome-skills) | 46.3k★ · 2100+ 技能 | npx 安装标准 / bundle 策略 / 分类导航 | 全量打包 | 策展导航而非打包，推荐标准安装路径 |
| [awesome-design-skills](https://github.com/bergside/awesome-design-skills) | 2.7k★ · 67 技能 | 设计技能策展 | — | 列入推荐清单 |
| [awesome-gamedev-agent-skills](https://github.com/gamedev-skills/awesome-gamedev-agent-skills) | 963★ · 73 技能 | 游戏引擎适配 + 路由器模式 | — | 列入推荐清单 |
| [ok-skills](https://github.com/mxyhi/ok-skills) | 485★ | AGENTS.md playbook 模式 | — | 列入推荐清单 |

**统一为一个技能的设计**：`flow-skills-hub` 单入口覆盖技能发现/安装/策展/自进化/安全审计。三份深度参考文档（`skill-taxonomy.md` / `self-evolution.md` / `security-audit.md`）按需渐进披露。不内置任何社区技能——只做策展导航，避免技能膨胀拖慢初始列表。

## 致谢

本项目是站在巨人肩膀上的蒸馏，向全部来源项目及其作者致敬。
