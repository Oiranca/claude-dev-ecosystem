# Claude Dev Ecosystem

A Claude Code plugin providing a full multi-agent development environment. Migrated and adapted from a production Copilot CLI ecosystem.

## Structure

```
.claude-plugin/
  plugin.json           # Plugin manifest

agents/                 # 12 specialized agents (markdown)
skills/                 # 15 reusable skills (SKILL.md per skill)
commands/               # 7 slash commands (markdown)
hooks/
  hooks.json            # PreToolUse hooks for Write/Edit/MultiEdit
scripts/
  pre-edit-check.sh     # Hook script — safety checks before edits
  validate-local.sh     # Local validation runner (lint/typecheck/test/build)
templates/
  local-scaffold/       # Optional docs/ and mcp/ templates for new projects
reference/
  GUARDRAILS.md         # Concise operational guardrails
  GUARDRAILS_REFERENCE.md  # Detailed guardrail explanations
  BUDGETS.md            # Skill budget tier rules
  USAGE.md              # Usage guide
  TEAM_MANUAL.md        # Multi-agent system manual

.mcp.json               # MCP server config (filesystem + github)
CLAUDE.md               # Ecosystem rules loaded by Claude Code
settings.example.json   # Example Claude Code settings
```

## Agents

| Agent | Model | Purpose |
|-------|-------|---------|
| product-manager | sonnet | Coordination, scope, milestone control |
| context-manager | haiku | Context pruning before broad reads |
| stack-analyzer | haiku | Stack detection from config files |
| repo-analyzer | haiku | Repository structural inventory |
| solution-architect | sonnet | Architecture planning |
| software-engineer | sonnet | Implementation |
| qa-engineer | haiku | Validation |
| security-reviewer | sonnet | Security analysis |
| devops-engineer | sonnet | Infrastructure review |
| tech-writer | haiku | Documentation maintenance |
| migration-engineer | sonnet | Framework migrations |
| pr-comment-responder | sonnet | PR review response |

## Slash Commands

| Command | Purpose |
|---------|---------|
| `/existing-repo` | Full analysis workflow for existing repos |
| `/new-project` | Bootstrap workflow for new projects |
| `/unknown-stack` | Cautious analysis with human review gate |
| `/migration-react-vite-to-astro` | React + Vite → Astro migration |
| `/team-review` | Parallel multi-agent code review |
| `/refactor-module <path>` | Safe behavior-preserving refactor |
| `/security-audit` | Focused security audit |

## Skills

| Skill | Cost | Purpose |
|-------|------|---------|
| fingerprint | cheap | Change detection |
| stack-detection | cheap | Stack identification |
| repo-inventory | medium | Structural mapping |
| code-search | cheap | Symbol and file discovery |
| route-mapper | medium | Route inventory |
| architecture-drift-check | medium | Architecture drift detection |
| targeted-test-runner | medium | Focused test execution |
| ci-checks | medium | Lint/typecheck/test/build |
| smoke-journeys | expensive | End-to-end smoke checks |
| dependency-audit | medium | Vulnerability and outdated package scan |
| env-consistency | expensive | Environment variable consistency |
| secret-scan-lite | expensive | Regex-based secret hygiene scan |
| docs-writer | cheap | README and CHANGELOG sync |
| react-vite-to-astro-migration | expensive | Component migration skill |
| context-pruning | cheap | Minimal relevant file set identification |

## Local Testing

1. Copy or symlink this directory to your Claude Code plugin path.
2. Copy `settings.example.json` to `.claude/settings.json` in a test project and adjust as needed.
3. Run Claude Code in the test project — agents and slash commands will be available.
4. Optionally copy `templates/local-scaffold/docs/` into the test project's `docs/` to bootstrap knowledge artifacts.

## Optional Runtime Infrastructure

- `docs/` — repository knowledge artifacts. Agents create these when missing.
- `.agent-cache/` — runtime state. Always gitignored. Never commit.

Neither is required for the plugin to function. Agents degrade gracefully when they are absent.

## Security

Hooks run `scripts/pre-edit-check.sh` before every Write, Edit, or MultiEdit operation. This script:
- Blocks edits to protected directories (node_modules, .git, dist).
- Blocks edits to sensitive files (.env, private keys, credentials).
- Warns when an agent-owned artifact has an active lock.
