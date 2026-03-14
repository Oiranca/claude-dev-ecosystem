# Claude Dev Ecosystem

This plugin provides a structured multi-agent development environment for Claude Code.

---

## Operating Principles

- Prefer minimal changes. Avoid modifying unrelated files.
- Analyze the repository before implementing anything.
- Always read existing docs (`docs/STACK_PROFILE.md`, `docs/INVENTORY.md`, `docs/ARCHITECTURE.md`, `docs/DECISIONS.md`) before making recommendations or writing code. These files are optional — when they are absent, agents create them during their first run.
- Favor targeted reads over broad repository scans. Use context-manager or context-pruning to scope reads before delegating.

---

## Workflow

1. Understand the repository (stack-analyzer + repo-analyzer)
2. Plan the architecture (solution-architect)
3. Implement the milestone (software-engineer)
4. Validate changes (qa-engineer)
5. Review security (security-reviewer)
6. Update documentation (tech-writer)

Use slash commands to trigger structured workflows:
- `/existing-repo` — full analysis and improvement workflow.
- `/new-project` — new project bootstrap workflow.
- `/unknown-stack` — cautious analysis with human review gate.
- `/migration-react-vite-to-astro` — incremental React + Vite to Astro migration.
- `/team-review` — parallel multi-agent code review.
- `/refactor-module <path>` — safe, behavior-preserving module refactor.
- `/security-audit` — focused security audit.

---

## Agent Roster

| Agent | Role | Model |
|-------|------|-------|
| product-manager | Scope control, milestone selection, coordination | sonnet |
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
| pr-comment-responder | Pull request review response | sonnet |

---

## Validation Order

Always validate in this order. Stop at the lowest sufficient level:

1. `targeted-test-runner` — focused tests for changed files.
2. `ci-checks` — lint, typecheck, test, build.
3. `smoke-journeys` — end-to-end route smoke checks (expensive; requires explicit justification).

---

## Skill Budget Tiers

| Tier | Examples | Limit |
|------|----------|-------|
| Low-cost | fingerprint, stack-detection, repo-inventory, code-search | Run freely when relevant |
| Broader validation | ci-checks, route-mapper | Max 2 runs/cycle, max 1/skill |
| High-cost | smoke-journeys, env-consistency, secret-scan-lite | Max 1/cycle, explicit justification required |

---

## Context Strategy

- Avoid loading entire repositories.
- Prefer targeted file reads and module-level analysis.
- Use context-manager before any agent that would otherwise scan broadly.
- Check `.agent-cache/artifact_freshness.json` before regenerating owned artifacts.
- Check `.agent-cache/locks/` before running overlapping validations.

---

## Optional Runtime Infrastructure

The following are **optional** — they improve agent efficiency but are not required:

- `docs/` — repository knowledge artifacts. Created by agents when missing.
- `.agent-cache/` — runtime state (always gitignored, never commit).

Agents must degrade gracefully when these are absent.

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
- Never auto-merge.
- Do not introduce GitHub Actions unless explicitly requested.

---

## Guardrails

Full guardrail documentation: `reference/GUARDRAILS.md` and `reference/GUARDRAILS_REFERENCE.md`.
Budget documentation: `reference/BUDGETS.md`.
