# Agentic Workflow — Harness Engineering Kit

> "Humans steer. Agents execute."

A complete system for running Claude Code with sub-agent orchestration, Ralph loops, and quality gates.

## Quick Start

```bash
# 1. Write your spec
cp spec-template.md my-project/spec.md
# Edit spec with requirements

# 2. Generate tasks.json (Claude Code)
# "Read spec.md and generate tasks.json following tasks-schema.md"

# 3. Run orchestration
./dispatch.sh my-project/tasks.json

# 4. Review PRs and merge
```

## Kit Contents

| File | Purpose |
|------|---------|
| `spec-template.md` | How to write project specs |
| `principles.md` | Coding rules for Claude Code |
| `agents-md-template.md` | AGENTS.md structure for repos |
| `ralph-prompt-template.md` | Build/Polish prompt templates |
| `tasks-schema.md` | tasks.json format for orchestration |
| `dispatch.sh` | Orchestration script |
| `example-tasks.json` | Example tasks.json (todo app) |
| `todo-app-spec.md` | Test spec for validation |
| `odyssey-spec.md` | Production spec (Odyssey) |

## Workflow

```
Spec → Claude Code plans → tasks.json → dispatch.sh
                                            │
                    ┌───────────────────────┼───────────────────────┐
                    ▼                       ▼                       ▼
              Sub-agent A            Sub-agent B            Sub-agent C
              (worktree)             (worktree)             (worktree)
                    │                       │                       │
              Ralph: Build            Ralph: Build            Ralph: Build
              Ralph: Polish           Ralph: Polish           Ralph: Polish
                    │                       │                       │
                   PR ──────────────────────┴───────────────────── PR
                                            │
                                      Merge in order
```

## Key Concepts

### Ralph Loops
External iteration loop that feeds the same prompt until completion:
```bash
while :; do cat PROMPT.md | claude ; done
```
Fresh context each run. Agent reads its own notes from previous iterations.

### Two Phases
1. **Build** — Make it work (tests pass)
2. **Polish** — Make it clean (lint, types, naming)

### Task Dependencies
Tasks declare dependencies. dispatch.sh respects them:
- Independent tasks run in parallel
- Dependent tasks wait for deps to complete

### Logging
- `INFO` — App behavior (production)
- `DEBUG` — Agent debugging (dev only, read by agent)

## Testing

Validate the workflow on the todo app before production use:
```bash
# Dry run (no actual execution)
./dispatch.sh example-tasks.json --dry-run

# Real run
./dispatch.sh example-tasks.json
```

---

*Version: 1.0 — 2026-02-19*
