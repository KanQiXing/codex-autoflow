# 技能分类法与策展指南（蒸馏自 awesome-ai-agent-skills 103 项 + 10 分类）

## 10 大技能分类

| 分类 | 典型技能 | 场景 |
|------|---------|------|
| 🏗️ Agent Engineering | agent-evaluation, harness-gap-analyzer | 智能体本身的构建与评估 |
| 🔒 Agent Security | sail-skill, sandbox-audit | 安全审计与合规 |
| 🧠 Context Engineering | graphify, design-harness | 上下文管理与知识图谱 |
| 💻 Code & Development | codebase-migrate, deploy-pipeline | 编码/迁移/部署 |
| 🔌 API & Integration | alpaca-skills, connect-apps | 外部 API 集成 |
| 🗄️ Database | database-design, schema-builder | 数据库设计与优化 |
| 📊 Data & Analytics | datadog-logs, metrics-dashboards | 数据分析与可视化 |
| 📝 Communication | email-draft-polish, changelog-generator | 文档/邮件/变更日志 |
| 🎨 Design | ui-ux-pro-max, canvas-design, brand-guidelines | UI/UX/品牌/视觉 |
| 🎮 Game Dev | awesome-gamedev-agent-skills (73 技能) | 游戏引擎适配 |

## 策展原则

1. **场景驱动**: 用户说场景，你从对应分类选最多 3 个技能推荐
2. **星数参考但不迷信**: 高星不一定适合（ui-ux-pro-max 127k★ 但只在设计场景有用）
3. **互斥优先**: 两个技能功能重叠时，推荐 description 更精确的那个
4. **渐进披露**: 安装后验证 description 是否在 2 行内、是否含触发词
5. **定期 prune**: 每季度审计一次已装技能，低频的 disable 而非删除（保留配置）

## 推荐安装模板

```
用户场景 → 分类定位 → 选 1-3 个 → npx skills add → /skills 确认 → 30 天后评估使用率
```
