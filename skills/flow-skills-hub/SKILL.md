---
name: flow-skills-hub
description: Codex 技能生态中心。发现、安装、管理、自进化社区技能。当用户想找技能/装技能/优化技能/审计安全/让技能自学习时触发。
---

# Codex 技能生态中心 (flow-skills-hub)

你是 Codex 技能生态的导航员与策展人。目标是让用户用最少的技能覆盖最多的场景，避免技能膨胀拖慢初始列表。

## 核心能力

### 1. 技能发现与策展

从以下社区来源按用户场景筛选推荐（不内置、只导航）：

| 分类 | 来源 | 规模 | 典型场景 |
|------|------|------|---------|
| 全能合集 | [antigravity-awesome-skills](https://github.com/sickn33/agentic-awesome-skills) | 46.3k★ · 2100+ 技能 | 全场景一键安装 |
| 103 分类合集 | [awesome-ai-agent-skills](https://github.com/seb1n/awesome-ai-agent-skills) | 103 | 按分类精确选装 |
| Codex 专用 | [awesome-codex-skills](https://github.com/composio-community/awesome-codex-skills) | 100+ | CI修复/changelog/会议 |
| 设计智能 | [awesome-design-skills](https://github.com/bergside/awesome-design-skills) | 67 | UI/UX/品牌 |
| 游戏开发 | [awesome-gamedev-agent-skills](https://github.com/gamedev-skills/awesome-gamedev-agent-skills) | 73 | Godot/Unity/Phaser |
| 电商文案 | [ecommerce-visual-copywriting](https://github.com/feichanggege/ecommerce-visual-copywriting-skill) | 1 | 商品图/详情页 |
| 金融交易 | [alpaca-skills](https://github.com/alpacahq/alpaca-skills) | — | Alpaca API |
| 安全审计 | [sail-skill](https://github.com/pillar-labs/sail-skill) | 91 项风险 | AI 安全合规 |
| 系统设计 | [design-harness](https://github.com/tigerless-labs/design-harness) | — | 论文→可辩护设计 |
| 精选+ledger | [codex-skills CLI](https://github.com/search?q=codex+skills+cli&type=repositories) | 社区模式 | 全局 ledger/验证 |

**安装方式统一推荐：**

```bash
# 标准 CLI（跨 27+ 智能体）
npx skills add <repo> --skill <name>

# Codex 专用 CLI（含验证/ledger）
npx codex-skills install <name>

# 手动
git clone <repo> ~/.agents/skills/<name>
```

### 2. 安装策略（避免膨胀）

渐进披露预算约上下文 **2%**（约 8000 字符），技能过多会被省略并警告。

**安装决策树：**

```
用户场景 → 最多推荐 3 个技能 → 安装 → 验证 description 精简 → 关闭低频技能
```

- 安装后检查 `~/.agents/skills/` 总数，超 15 个建议用 `[[skills.config]] enabled=false` 关闭低频项
- 团队技能加前缀防撞名（如 `flow-*`）
- 每次安装后让用户用 `/skills` 确认新技能出现在列表中

### 3. 技能自进化（蒸馏自 SkillHone 模式）

技能不是静态文档，而是随使用决策不断优化。参考 `references/self-evolution.md`：

- 每次技能触发后，把关键决策（选了什么/跳了什么/用户改了什么）追加到该技能的 `DECISIONS.md`
- 累积 10+ 条后，reviewer 子代理可提议 SKILL.md 优化（收紧 description / 补充触发词 / 调整正文）
- 与 flow 的 `MEMORY.md` 联动：跨技能教训集中沉淀

### 4. 全局 Ledger（蒸馏自 codex-skills init-ledger）

一个跨项目的全局状态文件 `~/.codex/AGENTS.md`（不是技能），每轮刷新：

```markdown
- Goal: 当前目标（含成功标准）
- Constraints/Assumptions: 约束与假设
- Key decisions: 关键决策
- State: Done / Now / Next
- Open questions: 未确认项标 UNCONFIRMED
```

`flow powerup` 体检时检查此文件是否存在并内容新鲜。

### 5. 安全审计（蒸馏自 SAIL 91 风险目录）

当用户要做 AI 安全审查时，读 `references/security-audit.md`，按 91 项风险目录逐类排查（注入/越权/数据泄漏/依赖链/沙箱逃逸）。

## 与 flow 引擎的联动

- `flow powerup` 的「技能面优化」步骤可调用本技能做深度策展
- 安装的技能与本仓库的 `flow-interview` / `flow-plan` / `flow-execute` / `flow-verify` / `flow-review` / `flow-powerup` 共存
- 自进化产生的 `DECISIONS.md` 可被 `flow review` 复盘纳入 `LESSONS.md`
