# AGENTS.md 分层指南（蒸馏自官方文档 + 20万星 CLAUDE.md 实践）

## 加载链（每轮任务执行前构建）

```
~/.codex/AGENTS.md          ← 全局个人偏好（所有项目生效）
└─ 仓库根 AGENTS.md          ← 团队约定（构建/测试命令、目录结构、审查规范）
   └─ 子目录 AGENTS.md       ← 局部规则（仅该目录任务生效）
      └─ AGENTS.override.md  ← 该目录强制覆盖（优先于同目录 AGENTS.md）
```

- 合并顺序 root-first：离工作目录越近的文件越靠后注入 → **越近优先级越高**
- 每目录至多一个：`AGENTS.override.md` > `AGENTS.md` > `project_doc_fallback_filenames` 自定义名
- 跨工具兼容：CLAUDE.md 写一句 `Strictly follow the rules in ./AGENTS.md` 即可全 agent 共享

## 分层内容清单

| 层 | 该放 | 不该放 |
|----|------|--------|
| 全局 `~/.codex/` | 个人语言偏好、常用工具习惯、回复风格 | 任何项目特定信息 |
| 仓库根 | 构建/测试/lint 命令、框架与命名约定、目录结构、PR 审查要点、遗留代码禁区 | 临时性说明、会被遗忘的 TODO |
| 子目录 | 该模块独有规则（如 `services/api/` 用不同测试框架） | 重复仓库根已写的内容 |

## 四条行为铁则（源自 20万星 CLAUDE.md 治理经验，防"暴走"）

1. **Think Before Coding** — 动手前先复述对需求的理解；两可时先问
2. **Simplicity First** — 最小可工作实现；拒绝没人要的抽象与防御式过度设计
3. **Surgical Changes** — 只改与任务直接相关的行；不顺手重排格式、不改无关风格
4. **Goal-Driven Execution** — 每一步对齐任务目标；发现范围蔓延立即停下汇报

## 反模式（审计时扣分项）

- ❌ 不可判定规则：「代码要优雅」「注释要充分」
- ❌ 过时信息：命令已改但文档没更新（比没有更糟）
- ❌ 全文超长：全局+仓库根合计建议 < 150 行，越短遵循率越高
- ❌ 与 AGENTS.override.md 冲突未察觉

## 修改后必做

- 让 Codex 复述当前加载的指令链以验证生效
- 已开会话需重启才会重新加载
