# config.toml 调优指南

## 配置优先级

CLI 参数 > 环境变量 > 项目 `.codex/config.toml` > 全局 `~/.codex/config.toml`

## 高价值片段

### 子代理护栏
```toml
[agents]
max_threads = 6            # 并发上限（默认即 6，按机器调）
max_depth = 1              # 保持 1：防递归扇出（深层嵌套 = token 爆炸）
job_max_runtime_seconds = 1800
```

### 模型与推理力度
```toml
model = "gpt-5.4"                # 主会话：深度任务
model_reasoning_effort = "high"  # low|medium|high；轻任务调 medium 省 token
```

### 沙箱与审批
```toml
sandbox_mode = "workspace-write"   # 日常开发平衡点
approval_policy = "on-request"     # 需要时才问
```

### 技能开关（技能过多拖慢初始列表）
```toml
[[skills.config]]
path = "/abs/path/to/skill/SKILL.md"
enabled = false
```

### MCP 服务器
```toml
[mcp_servers.示例名]
command = "npx"
args = ["-y", "@example/mcp-server"]
```
工具级审批：MCP 工具调用默认走审批，敏感工具可在服务器配置中收紧。

## 审计要点

1. `model_reasoning_effort` 是否对所有任务都 high（浪费）？
2. 技能总数是否超 20（初始列表预算约上下文 2%，超限会被省略并警告）？
3. `[agents]` 是否被调大 max_depth（成本失控风险）？
4. MCP 服务器是否有长期不用仍注册的（启动开销 + 上下文占用）？

## 生效规则

config.toml 修改需**重启会话**；全局 AGENTS.md 同理。
