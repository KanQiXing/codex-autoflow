# Sub-agents 子代理指南（MultiAgentV2 · Codex CLI v0.128+）

## 内置三代理

| 名字 | 定位 | 典型用途 |
|------|------|---------|
| `default` | 通用后备 | — |
| `worker` | 执行型（写码/修复） | 实现、重构、修 bug |
| `explorer` | 只读探索 | 代码库侦察、架构梳理 |

## 存放位置与优先级

```
~/.codex/agents/*.toml   ← 个人（全项目可用，优先级低）
.codex/agents/*.toml     ← 项目（仅本仓库，优先级高，同名覆盖全局）
```

## TOML 字段表（自定义代理必备 + 可选）

```toml
name = "reviewer"                      # 必需：调用名
description = "何时调用此代理"           # 必需：路由依据，写清触发场景
# model = "gpt-5.4"                    # 可选：缺省继承父会话
# model_reasoning_effort = "high"      # 可选：low|medium|high
# sandbox_mode = "read-only"           # 可选：read-only|workspace-write|...
# mcp_servers = [...]                  # 可选：该代理可用的 MCP 白名单
# nickname_candidates = ["Athena"]     # 可选：线程昵称

[instructions]                          # 必需：developer_instructions
text = """角色设定与专属检查清单"""
```

## 沙箱哲学（安全第一性原理）

- **审查/审计类** → `sandbox_mode = "read-only"`：不可能误改文件
- **实现/执行类** → `workspace-write`：只能写工作区
- 子代理继承父会话实时覆盖（`/permissions`、`--yolo` 优先于 TOML 默认值）

## 模型路由经济学

| 模型档位 | 适用 | 示例角色 |
|---------|------|---------|
| 旗舰 + high effort | 深度推理：架构评审、安全审计 | reviewer、architect |
| spark 系 + medium | 高频轻量：扫描、汇总、检索 | researcher、installer |

## 全局护栏（config.toml `[agents]`）

```toml
[agents]
max_threads = 6               # 并发线程上限（官方默认）
max_depth = 1                 # 嵌套深度：保持 1 防递归扇出烧钱
job_max_runtime_seconds = 1800
```

## 调用要点

- Codex **只在你明确要求时**才 spawn（不会自动扇出）
- 多代理提示词模板：「每点 spawn 一个代理，等全部完成，逐点汇总」
- CLI 用 `/agent` 在线程间切换检查；审批弹窗按 `o` 跳转来源线程
- Token 成本警告：子代理各自独立跑模型与工具，比单代理贵——并行探索类任务才值得

## 与 AGENTS.md 的分工

AGENTS.md = 全局行为准则（每轮生效）；agent TOML = 专职角色系统提示词（按需 spawn）。
角色专属规范写 TOML，通用规范写 AGENTS.md，不要两处重复。
