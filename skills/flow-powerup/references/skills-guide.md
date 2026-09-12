# Skills 技能面指南（agentskills.io 开放标准）

## 四作用域

| 作用域 | 路径 | 用途 |
|--------|------|------|
| REPO | `.agents/skills/`（含父目录至仓库根） | 团队共享、随仓库走 |
| USER | `~/.agents/skills/` | 个人跨仓库 |
| ADMIN | `/etc/codex/skills/` | 机器/容器级（SDK、自动化） |
| SYSTEM | OpenAI 内置 | 不可删 |

同名技能**不合并**，都会出现在选择器 → 团队技能加前缀防撞名。

## 渐进披露机制（决定生死）

1. 初始只加载每个技能的 `name` + `description` + 路径
2. 初始列表预算 ≈ 上下文窗口 **2%**（窗口未知按 8000 字符）
3. 超预算处理：先压缩 description → 再直接省略部分技能并警告
4. 选中后才加载 SKILL.md 全文 → `references/` 等重资料按需再读

**推论：description 是唯一广告位**——触发词前置、两行以内、写明"何时该触发与何时不该"。

## SKILL.md 骨架

```markdown
---
name: skill-name
description: 一句话说清何时触发、何时不触发（含关键词）
---
正文 = 注入给 Codex 的指令。
可选增强：scripts/（可执行）、references/（深度文档）、assets/（模板资产）、
agents/openai.yaml（图标/品牌色/policy.allow_implicit_invocation: false 禁隐式触发）
```

## 三种创建方式

1. **Record & Replay**：Codex 录制你演示一遍流程，自动起草技能（演示比描述容易时首选）
2. `$skill-creator`：内置创建器问答式生成
3. 手写：按上面骨架放对应作用域目录

## 三条激活入口

- 显式：prompt 提技能名 / `/skills` 面板 / 输入 `$` 补全
- 隐式：Codex 将任务与 description 匹配（可在 openai.yaml 关闭）
- 安装精选：`$skill-installer <名字>`

## 高星实用技能推荐（按需选装，勿贪多）

| 技能 | 星数 | 适用场景 |
|------|------|---------|
| ui-ux-pro-max | 127k★ | 前端/UI 专业设计智能 |
| graphify | — | 代码库+文档+SQL → 可查询知识图谱 |
| awesome-codex-skills 合集 | 16k★ | 会议分析/邮件/CI修复/changelog 等 100+ |

## 审计要点

- description 是否含触发词且 ≤ 2 行？
- 总数是否超 20？低频的用 `[[skills.config]]` 关掉
- 团队与个人技能是否撞名？
