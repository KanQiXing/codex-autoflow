# codex-autoflow

> **访谈 → 规划 → 审批 → 持续执行 → 验证 → 复盘**
> 蒸馏自六大开源工作流的 Codex CLI 自治执行引擎。
> 零依赖（bash + git + codex），状态即文件，历史即 git。

[English](README.en.md) · [设计蒸馏说明](docs/DESIGN.md)

![shell](https://img.shields.io/badge/shell-bash-4EAA25) ![deps](https://img.shields.io/badge/dependencies-0-00ADD8) ![license](https://img.shields.io/badge/license-MIT-blue)

## 裸用 Codex 的四种死法

| 失败模式 | 症状 | autoflow 的解法 |
|---------|------|----------------|
| 金鱼记忆 | 新会话忘光上次进展 | `.flow/` 状态契约 + 每轮上下文重注入 |
| 无头苍蝇 | 没规划就开干，改一半返工 | 访谈 → 规划 → **人工审批**门禁 |
| 假完成 | 「done!」但测试没跑过 | 验证门禁：证据即完成 |
| 断线失踪 | 中断后无法安全恢复 | 每任务一提交，磁盘即断点 |

## 60 秒上手

```bash
git clone https://github.com/KanQiXing/codex-autoflow.git
bash codex-autoflow/install.sh        # 安装 flow 命令 + Codex 技能

cd your-project
flow init                             # 建状态目录 + 注入 AGENTS.md 契约
flow interview "我想给系统加用户认证"   # 1.深度访谈（交互式）-> .flow/PRD.md
flow plan                             # 2.生成任务清单     -> .flow/PLAN.md
#    ...人工审阅 PLAN.md，直接改到满意...
flow approve                          # 3.批准印章
flow run 10                           # 4.自治循环：每轮全新会话完成一个任务
```

人类只审两份文档（PRD 与 PLAN），其余自主执行；`tail -f .flow/last-run.log` 即实时仪表盘。

## 架构

```
你 ——只审两份文档:PRD 与 PLAN——▶ flow approve
│
flow interview ─▶ Codex 访谈 ─▶ .flow/PRD.md
flow plan ─▶ Codex 规划 ─▶ .flow/PLAN.md (DRAFT)
flow approve ─▶ 盖章 .flow/APPROVED
flow run ─▶ Ralph 循环（每轮全新 Codex 会话）
   │  1. 重读 .flow/* 重建上下文
   │  2. 取 PLAN.md 第一个未完成任务（只做一个）
   │  3. 完整实现（禁止 stub / TODO）
   │  4. 验证门禁：证据写入 VERIFICATIONS/
   │  5. 勾选任务 + 追加 PROGRESS + 沉淀 MEMORY
   │  6. git commit（断点锚点）
   └─ 无剩余任务 ─▶ flow review ─▶ .flow/LESSONS.md

停滞熔断：连续 3 轮无新提交 -> 停止，等待人工介入
```

## 命令

| 命令 | 作用 | 产物 |
|------|------|------|
| `flow init` | 初始化状态目录 + AGENTS 契约 | `.flow/` |
| `flow interview "想法"` | 深度访谈澄清需求（交互式） | `.flow/PRD.md` |
| `flow plan` | PRD → 单会话粒度任务清单 | `.flow/PLAN.md` |
| `flow approve` | 人工批准计划 | `.flow/APPROVED` |
| `flow run [N]` | 自治循环（默认 10 轮，停滞 3 轮熔断） | 代码 + 证据 + 提交 |
| `flow once` | 单轮执行（调试提示词用） | — |
| `flow verify` | 重验全部已完成任务 | 刷新 `VERIFICATIONS/` |
| `flow review` | 复盘蒸馏 | `.flow/LESSONS.md` |
| `flow status` | 进度概览 | — |

## `.flow/` 状态契约

| 文件 | 角色 | 谁写 |
|------|------|------|
| `PRD.md` | 需求唯一事实来源 | interview |
| `PLAN.md` | 任务清单 `- [ ]` / `- [x]` | plan 生成，execute 勾选 |
| `PROGRESS.md` | 追加式执行日志 | execute |
| `MEMORY.md` | 跨会话记忆（教训 / 约定） | execute / review |
| `VERIFICATIONS/` | 验证证据（每任务一份） | execute / verify |
| `APPROVED` | 审批印章 | 你 |
| `last-run.log` | 最近一轮 codex 输出 | run |

## 五条铁律

1. **一切落盘** — 会话随时会被杀，磁盘不会；恢复靠文件不靠记忆
2. **先审后动** — 未审批的计划，引擎拒绝执行
3. **单任务循环** — 每轮全新会话只做一个任务，干净上下文胜过长上下文
4. **证据即完成** — 没有验证证据不许勾选任务
5. **上下文重注入** — 每轮第一步永远是重读 `.flow/*`

## 设计蒸馏

| 来源 | 取 | 舍 |
|------|----|----|
| [oh-my-codex](https://github.com/Yeachan-Heo/oh-my-codex) 33k★ | 访谈→规划→审批门禁 | 多智能体 / HUD |
| [Ralph 模式](https://ghuntley.com/ralph/) | 新会话循环 + 单任务 + git 锚点 | 无界循环 |
| [planning-with-files](https://github.com/OthmanAdi/planning-with-files) 27k★ | 文件即计划 + 重注入 | npm 分发 |
| [codex_autoworker](https://github.com/Frank-Opus/codex_autoworker) | 一切落盘 + 证据即完成 | 多 harness 层 |
| [Skills 生态](https://github.com/vercel-labs/skills) | SKILL.md 渐进披露 | 市场化分发 |
| [coding-agent-toolkit](https://github.com/stefan-jansen/coding-agent-toolkit) | 阶段化流程 + 复盘 | Issue 投影 |

取舍理由详见 [docs/DESIGN.md](docs/DESIGN.md)。

## 高级用法

```bash
# 给 codex 传额外参数（模型 / 沙箱策略）
FLOW_CODEX_ARGS="--model gpt-5.2 --full-auto" flow run 20

# 关闭完成后的自动复盘
FLOW_AUTO_REVIEW=0 flow run

# 自定义安装位置
FLOW_HOME=~/.autoflow-codex FLOW_BIN=~/.local/bin bash install.sh

# 实时仪表盘
tail -f .flow/last-run.log

# 技能也可在交互式 codex 会话中被自然触发（渐进披露）
codex    # 然后说"帮我规划这个功能"
```

## 致谢

站在巨人肩膀上的蒸馏，向以下项目致敬：

[Ralph 模式](https://ghuntley.com/ralph/) ·
[oh-my-codex](https://github.com/Yeachan-Heo/oh-my-codex) ·
[planning-with-files](https://github.com/OthmanAdi/planning-with-files) ·
[codex_autoworker](https://github.com/Frank-Opus/codex_autoworker) ·
[Vercel Skills CLI](https://github.com/vercel-labs/skills) ·
[coding-agent-toolkit](https://github.com/stefan-jansen/coding-agent-toolkit) ·
[awesome-codex-cli](https://github.com/ELM-labs-projects/awesome-codex-cli)

## License

[MIT](LICENSE)
