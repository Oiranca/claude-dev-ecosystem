# Oiranca's Global Claude Dev Ecosystem — v2

This global configuration provides a parallel multi-agent coordination environment for Claude Code CLI. It applies to all local repositories accessed via this terminal.

---

## Operating Principles

- **Agent Teams First:** Complex tasks must be orchestrated using parallel Agent Teams. The Team Lead creates a task graph; agents claim and work tasks concurrently.
- **Task State Engine:** All work is tracked in `.agent-cache/tasks.json` via `python ~/.claude/scripts/agent-runtime.py`. Agents claim tasks, not assignments from the Team Lead.
- **Async Messaging:** Agents communicate between sessions via `messages.jsonl`. Use `message send` for handoffs, `message inbox` to read incoming work.
- **Context Isolation:** Context is not automatically shared between agents. Team Leads must put all necessary context in the task `--inputs` field.
- **Docs-First Behavior:** Agents check `docs/STACK_PROFILE.md`, `docs/INVENTORY.md`, `docs/ARCHITECTURE.md`, and `docs/DECISIONS.md` before reading source files. If they do not exist, proceed without requiring them.
- **Minimal Local Footprint:** Do not generate `.agent-cache/` or `reference/` in repositories unless explicitly requested. Rely on Claude's native session state for ephemeral context.

---

## Agent Roster

### Team Leads

| Agent | Model | Role |
|-------|-------|------|
| product-manager | sonnet | Plans, scopes, creates task graph, monitors for blockers |
| pr-comment-responder | sonnet | Specialized Team Lead for PR review response cycles |

### Discovery Agents

| Agent | Model | Role |
|-------|-------|------|
| context-manager | haiku | Repo discovery; produces scoped reading plans |
| stack-analyzer | haiku | Stack detection; produces `docs/STACK_PROFILE.md` |
| repo-analyzer | haiku | Repository structural inventory; produces `docs/INVENTORY.md` |
| solution-architect | sonnet | Architecture planning; produces `docs/ARCHITECTURE.md` |

### Execution Agents

| Agent | Model | Role |
|-------|-------|------|
| software-engineer | sonnet | Feature implementation and bug fixes |
| migration-engineer | sonnet | Framework and architecture migrations |
| devops-engineer | sonnet | Infrastructure and runtime review |

### Review Agents

| Agent | Model | Role |
|-------|-------|------|
| qa-engineer | haiku | Quality validation; APPROVE / REQUEST_CHANGES / BLOCKED |
| security-reviewer | sonnet | Security audit; APPROVE / REQUEST_CHANGES / ESCALATE |
| tech-writer | haiku | Documentation maintenance |

---

## How to Trigger Workflows

Invoke the appropriate Team Lead agent and describe the goal. The Team Lead will create the task graph and let agents self-coordinate:

- **Feature or bug fix:** Invoke `product-manager` (e.g., *"Run the product-manager to implement issue #42"*).
- **PR review response:** Invoke `pr-comment-responder` (e.g., *"Run the pr-comment-responder to address PR #17 comments"*).

The Team Lead creates tasks with explicit dependencies. Agents with no unblocked dependencies start immediately in parallel.

---

## Task State Engine

All work flows through the runtime:

```bash
# Team Lead creates tasks
python ~/.claude/scripts/agent-runtime.py task create --title "..." --owner <agent> [--depends-on id1,id2] [--inputs "..."]

# Agents claim and work
python ~/.claude/scripts/agent-runtime.py task claim --id <id> --owner <agent>
python ~/.claude/scripts/agent-runtime.py task update --id <id> --status running
python ~/.claude/scripts/agent-runtime.py task complete --id <id> --outputs "..."

# Agents communicate
python ~/.claude/scripts/agent-runtime.py message send --from <a> --to <b> --type handoff --summary "..."
python ~/.claude/scripts/agent-runtime.py message inbox --agent <agent> --unread
```

Valid task states: `pending` → `claimed` → `running` → `review` → `done` | `failed` | `blocked`

---

## Validation Order & Budgets

Always validate in this order. Stop at the lowest sufficient level:
1. `targeted-test-runner` — focused tests for changed files.
2. `ci-checks` — lint, typecheck, test, build.
3. `smoke-journeys` — end-to-end route smoke checks (expensive; requires explicit justification).

**Skill Budget Tiers:**
- *Low-cost* (fingerprint, stack-detection, repo-inventory, code-search, context-pruning): Run freely.
- *Broader validation* (ci-checks, route-mapper, architecture-drift-check): Max 2 runs/cycle, max 1/skill.
- *High-cost* (smoke-journeys, env-consistency, secret-scan-lite): Max 1/cycle, explicit justification required.

---

## Security

- Never expose secrets in outputs.
- Never commit credentials or tokens.
- Report vulnerabilities without reproducing sensitive values (location only: file:line).
- Never echo discovered secrets into generated documentation.

---

## Scope Rules

- Only one active milestone per cycle.
- Never batch unrelated milestones.
- Never expand scope beyond the active issue.
- Prefer minimal changes; avoid modifying unrelated files.
- Never auto-merge.
- Do not introduce GitHub Actions unless explicitly requested.

---

## Validation & Guardrails

All agents must strictly adhere to the local safety scripts:

1. **Pre-edit Safety**: Every file modification is automatically gated by `pre-edit-check.sh`. If it blocks an edit (protected directories or secrets), do not attempt to bypass it.
2. **Post-implementation QA**: After any code change, the `qa-engineer` or the Team Lead MUST run:
   `bash ~/.claude/scripts/validate-local.sh`
3. **Failure Handling**: If validation fails, read `docs/last-run/failure_summary.md` (if available) to identify the root cause before attempting a fix.
4. **Lock Hygiene**: Release locks after completing guarded operations. Locks expire after 30 minutes (TTL) and are auto-evicted.

---

## Reference

- Full architecture: `reference/ARCHITECTURE_V2.md`
- Team manual: `reference/TEAM_MANUAL.md`
- Guardrails: `reference/GUARDRAILS.md`
- Skill budgets: `reference/BUDGETS.md`
