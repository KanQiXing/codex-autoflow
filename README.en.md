# codex-autoflow

> **Interview → Plan → Approve → Execute → Verify → Retrospective.**
> A distilled autonomous execution harness for OpenAI Codex CLI.
> Zero dependencies (bash + git + codex). State is files; history is git.

[中文文档](README.md) · [Design: what we distilled and what we dropped](docs/DESIGN.md)

## The four failure modes of bare Codex

| Failure | Symptom | Fix here |
|---------|---------|----------|
| Goldfish memory | Fresh session forgets all progress | `.flow/` state contract + per-turn context re-injection |
| No plan | Codes first, rewrites later | Interview → plan → **human approval** gate |
| Fake done | "Done!" with zero tests run | Verification gate: evidence or it didn't happen |
| Lost on crash | Cannot safely resume | One commit per task; the disk is the checkpoint |

## Quick start

```bash
git clone https://github.com/KanQiXing/codex-autoflow.git
bash codex-autoflow/install.sh

cd your-project
flow init
flow interview "add user authentication"   # 1. deep interview -> .flow/PRD.md
flow plan                                  # 2. task breakdown -> .flow/PLAN.md
#    ... review & edit PLAN.md by hand ...
flow approve                               # 3. approval stamp
flow run 10                                # 4. autonomous loop, one task per fresh session
```

You review exactly two documents (PRD and PLAN); everything else runs itself.
`tail -f .flow/last-run.log` is your live dashboard.

## The Ralph loop (core engine)

Each iteration launches a **brand-new Codex session** that:

1. Re-reads `.flow/*` to rebuild context (fights context rot)
2. Picks the **first open task** in PLAN.md — only one, never more
3. Implements it fully (stubs and TODOs are forbidden)
4. Runs verification and writes evidence to `VERIFICATIONS/` — no evidence, no checkbox
5. Updates PLAN / PROGRESS / MEMORY on disk
6. Makes one clean git commit (rollback anchor)

Loop ends when PLAN.md has no `- [ ]` left (deterministic gate, not model self-report).
A circuit breaker stops everything after 3 consecutive iterations with no new commit.

## Five iron laws

1. **Everything on disk** — sessions die, files don't
2. **Approve before acting** — unapproved plans are refused by both script and prompt
3. **One task per session** — clean context beats long context
4. **Evidence or it didn't happen** — verification output is the only proof of done
5. **Re-inject context every turn** — the first step of every iteration is re-reading state

## Credits

Distilled with respect from:
[Ralph pattern](https://ghuntley.com/ralph/) ·
[oh-my-codex](https://github.com/Yeachan-Heo/oh-my-codex) ·
[planning-with-files](https://github.com/OthmanAdi/planning-with-files) ·
[codex_autoworker](https://github.com/Frank-Opus/codex_autoworker) ·
[Vercel Skills CLI](https://github.com/vercel-labs/skills) ·
[coding-agent-toolkit](https://github.com/stefan-jansen/coding-agent-toolkit)

## License

[MIT](LICENSE)
