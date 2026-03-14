# Oiranca's Global Claude Dev Ecosystem

This global configuration provides a structured, multi-agent Agent Teams environment for Claude Code CLI. It applies to all local repositories accessed via this terminal.

---

## Operating Principles

- **Agent Teams First:** Complex tasks must be orchestrated using parallel Agent Teams coordinated by a Main Agent (Team Lead) via a Shared Task List.
- **Context Isolation:** Context is not automatically shared among teammates. Team Leads must explicitly pass required file paths and context to downstream agents.
- **Docs-First Behavior:** Agents should look for repository-specific knowledge in `docs/STACK_PROFILE.md`, `docs/INVENTORY.md`, `docs/ARCHITECTURE.md`, and `docs/DECISIONS.md`. If they do not exist, proceed without requiring them.
- **Minimal Local Footprint:** Do not generate `.agent-cache/` directories or `reference/` folders in repositories unless explicitly requested by the user. Rely on Claude's native session state.

---

## Agent Roster (Available Teammates)

| Agent | Role | Model |
|-------|------|-------|
| product-manager | Team Lead: Scope control, milestone selection, coordination | sonnet |
| context-manager | Reduce context consumption, scope reads | haiku |
| stack-analyzer | Stack detection | haiku |
| repo-analyzer | Repository structural inventory | haiku |
| solution-architect | Architecture planning | sonnet |
| software-engineer | Implementation | sonnet |
| qa-engineer | Validation and testing | haiku |
| security-reviewer | Security analysis | sonnet |
| devops-engineer | Infrastructure and runtime review | sonnet |
| tech-writer | Documentation maintenance | haiku |
| migration-engineer | Framework and architecture migrations | sonnet |
| pr-comment-responder | Team Lead: Pull request review response | sonnet |

---

## How to Trigger Workflows

Do not use slash commands (like `/team-review`) to start workflows. Instead, invoke the appropriate Main Agent (Team Lead) and let them spawn the Agent Team:

- **For new features, bug fixes, or general tasks:** Ask Claude to invoke the `product-manager` agent (e.g., *"Run the product-manager to implement issue #42"*). The product-manager will create the Shared Task List and spawn the execution and validation teammates.
- **For Pull Request reviews:** Ask Claude to invoke the `pr-comment-responder` agent (e.g., *"Run the pr-comment-responder to address the latest code review feedback"*).

The Team Lead will automatically select the necessary downstream agents (`context-manager`, `software-engineer`, `qa-engineer`, etc.) to complete the task in parallel.

---

## Validation Order & Budgets

Always validate in this order. Stop at the lowest sufficient level:
1. `targeted-test-runner` — focused tests for changed files.
2. `ci-checks` — lint, typecheck, test, build.
3. `smoke-journeys` — end-to-end route smoke checks (expensive; requires explicit justification).

**Skill Budget Tiers:**
- *Low-cost* (fingerprint, stack-detection, repo-inventory, code-search): Run freely.
- *Broader validation* (ci-checks, route-mapper): Max 2 runs/cycle, max 1/skill.
- *High-cost* (smoke-journeys, env-consistency, secret-scan-lite): Max 1/cycle, explicit justification required.

---

## Security

- Never expose secrets in outputs.
- Never commit credentials or tokens.
- Report vulnerabilities without reproducing sensitive values.
- Never echo discovered secrets into generated documentation.

---

## Scope Rules

- Only one active milestone per cycle.
- Never batch unrelated milestones.
- Never expand scope beyond the active issue.
- Prefer minimal changes; avoid modifying unrelated files.
- Never auto-merge.
- Do not introduce GitHub Actions unless explicitly requested.

## Validation & Guardrails

All agents must strictly adhere to the local safety scripts:

1. **Pre-edit Safety**: Every file modification is automatically gated by `pre-edit-check.sh`. If it blocks an edit (e.g., protected directories or secrets), do not attempt to bypass it.
2. **Post-implementation QA**: After any code change, the `qa-engineer` or the Team Lead MUST run:
   `bash ~/.claude/scripts/validate-local.sh`
3. **Failure Handling**: If validation fails, read the generated `docs/failure_summary.md` (if available) to identify the root cause before attempting a fix.