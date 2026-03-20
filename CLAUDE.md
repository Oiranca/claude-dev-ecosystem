# Claude Dev Ecosystem — Global Configuration

This file defines the global behavior, coordination model, and execution rules for the Claude development ecosystem.

It is designed to work across multiple repositories, stacks, and project sizes while remaining efficient, modular, and scalable.

---

# Core Principles

- Prefer **small, focused changes** over broad rewrites.
- Prefer **analysis before implementation** when scope is unclear.
- Prefer **minimal context usage** over full repository scans.
- Prefer **existing project conventions** over introducing new patterns.
- Prefer **gradual validation** over running full pipelines unnecessarily.

---

# Agent Teams Usage

## Mandatory: Always Use Agent Teams for Issue Work

Every GitHub issue — regardless of size — must go through the full agent pipeline.
The Team Lead never implements code directly. Implementation, QA, and review are always delegated.

---

## Issue Execution Pipeline

This is the **required sequential flow** for every issue:

```
Team Lead → software-engineer → qa-engineer ⟲ → security-reviewer (PR)
```

### Stage 1 — Team Lead (current session)
- Reads and analyzes the issue
- Identifies affected files and scope
- Creates the feature branch
- Defines tasks for each stage
- Hands off to software-engineer

### Stage 2 — software-engineer
- Claims the implementation task
- Implements the fix/feature on the branch
- Runs type-check and build to confirm no regressions
- Sends handoff to qa-engineer

### Stage 3 — qa-engineer (with feedback loop)
- Writes or updates tests needed to validate the change
- Runs the test suite
- **If tests fail** → sends back to software-engineer with details
- **If tests pass** → sends handoff to security-reviewer
- The software-engineer/qa-engineer loop repeats until QA is green

### Stage 4 — security-reviewer (Code Review + PR)
- Reviews the final diff for correctness, security, and style
- If issues found → sends back to software-engineer
- If approved → commits, pushes the branch, and opens the PR linked to the issue

---

## Team Model

- The current Claude session acts as the **Team Lead**.
- The Team Lead defines:
  - scope
  - task breakdown
  - sequencing
  - final output

- Teammates:
  - claim tasks sequentially per the pipeline above
  - communicate via handoff messages
  - never skip a stage

---

# Task State Engine (Ecosystem Layer)

This ecosystem may use a local runtime for structured coordination.

- Task state is stored in:
  `.agent-cache/tasks.json`

- Runtime entrypoint:
  `python ~/.claude/scripts/agent-runtime.py`

## Important

This is an **ecosystem-level coordination layer**, not a Claude-native requirement.

- Use it when:
  - running structured multi-agent workflows
  - coordinating complex parallel tasks
- Do NOT require it for simple or local tasks

---

# Agent Context Isolation

## Core Rule

The Team Lead MUST NOT read files, run searches, or make edits in the main session for tasks that are delegated to agents. Every `Read` / `Edit` / `Bash` call in the main session consumes the shared context window and is visible to the user as noise.

## What the Team Lead does

- Use `Grep` / `Glob` for at most 2–3 targeted queries to identify file paths.
- Write the agent prompt with: paths, scope, required change, acceptance criteria.
- Spawn the agent — let it own all reads, writes, and validation internally.
- Receive only the agent's summary result back.

## What the Team Lead does NOT do

- Read file contents to "understand before delegating" — put the paths in the prompt instead.
- Copy code snippets or file contents into agent prompts.
- Apply edits inline and then tell an agent what was changed.
- Run `yarn build` / `yarn test` / linters when an agent can run them internally.

## Delegation table

| Task type                  | Agent to spawn            | Use `isolation: "worktree"` |
|----------------------------|---------------------------|-----------------------------|
| PR comment fixes           | `pr-comment-responder`    | Yes                         |
| Bug fix / feature          | `software-engineer`       | Yes                         |
| Exploration / research     | `Explore` or `context-manager` | No                     |
| Security review            | `security-reviewer`       | No                          |
| QA / test validation       | `qa-engineer`             | No                          |
| Architecture planning      | `solution-architect`      | No                          |

## Worktree isolation

For all implementation agents (`software-engineer`, `pr-comment-responder`, `migration-engineer`):

- Set `isolation: "worktree"` so the agent's file reads and writes happen in an isolated git copy.
- The agent's internal tool calls are NOT visible in the main session — only its final summary is.
- The worktree is automatically cleaned up if no files were changed.

## What to pass in the agent prompt

**Pass:**
- File paths identified from Grep/Glob (never file content)
- The change described in plain language
- Branch name, acceptance criteria, PR/issue references

**Never pass:**
- Full file contents copied from a prior `Read`
- Large code blocks or diffs
- Tool call output copied from the main session

---

# Context Strategy

## Core Rule

Always identify the **smallest useful working surface** before deep analysis or implementation.

## Preferred Approach

1. Use `Grep` and `Glob` before reading files.
2. Identify:
   - entry points
   - routing layers
   - module boundaries
   - config files
3. Read only the files that are directly relevant.

## Avoid

- scanning entire repositories
- reading large directories blindly
- loading unrelated documentation

---

# Documentation Strategy

## Docs-First When Available

If the repository contains:

- `docs/STACK_PROFILE.md`
- `docs/INVENTORY.md`
- `docs/ARCHITECTURE.md`
- `docs/DECISIONS.md`

Agents should read them **when relevant to the task**.

## Important

- If these files do NOT exist → proceed normally
- Do NOT require documentation to exist
- Do NOT generate documentation unless explicitly requested

---

# Agent Roles

## Lead-Oriented Agents

These agents influence planning and coordination behavior.

They do NOT replace Claude’s native Team Lead role.

- product-manager
- pr-comment-responder

---

## Core Specialists (sonnet)

- solution-architect
- software-engineer
- migration-engineer
- security-reviewer
- devops-engineer

---

## Lightweight Specialists (haiku)

- context-manager
- repo-analyzer
- stack-analyzer
- qa-engineer
- tech-writer

---

# Execution Rules

## Scope Discipline

- Work only within the **active milestone**.
- Avoid modifying unrelated files.
- Do not expand scope unless explicitly required.

## Milestone Rule

- Only **one active milestone per cycle**.
- Within that milestone:
  - parallel subtasks are allowed
  - coordination must remain controlled

---

# Validation Strategy

## Validation Order

1. Targeted validation (closest to the change)
2. Repository-level validation (if needed)
3. Full pipeline validation (only when necessary)

Stop at the **lowest sufficient level**.

---

## Post-Implementation QA

After any code change:

- Prefer running:
  `bash ~/.claude/scripts/validate-local.sh`

- If not available:
  - use the repository’s native validation flow

---

# Safety & Guardrails

- Never expose secrets or credentials.
- Never log or output sensitive values.
- Avoid destructive operations unless explicitly requested.
- Highlight risks without leaking sensitive data.

---

# Minimal Local Footprint

- `.agent-cache/` is:
  - created automatically when needed
  - required for runtime coordination only
  - never committed to git

- Use:
  - Claude session state → for reasoning
  - local runtime → for structured coordination only

---

# Tool Usage Strategy

## Prefer

- Grep
- Glob
- Read (targeted)

## Limit

- Bash (only when needed)
- Write/Edit (only for relevant files)

## Avoid

- broad file reads
- unnecessary command execution
- full repository scans

---

# TypeScript Project Rules

## Test Files Must Be Excluded from the App tsconfig

When a project uses Vitest (or any test runner) with `@testing-library/jest-dom` or similar test-only type packages, **always** ensure `tsconfig.app.json` (or equivalent app tsconfig) excludes test files:

```json
"include": ["src"],
"exclude": ["src/**/*.test.ts", "src/**/*.test.tsx", "src/test"]
```

**Why:** `tsc -b` runs during `npm run build` and type-checks `tsconfig.app.json`. Test files reference matchers like `toHaveAttribute`, `toBeInTheDocument`, `toHaveClass` whose types only exist in the test tsconfig (e.g. `tsconfig.vitest.json`). Including test files in the app tsconfig causes TS2339 build failures.

**How to apply:**
- When adding test files to a project, always verify `tsconfig.app.json` has the `exclude` block above.
- Never remove this `exclude` block.
- The test tsconfig (e.g. `tsconfig.vitest.json`) should extend the app tsconfig and add test-specific `types` — it must NOT be referenced in the root `tsconfig.json` references array.
- After writing any test file, run `npm run build` (not just `npm test`) to confirm the app tsconfig is not broken.

---

# Final Rule

Be precise.

Be minimal.

Be structured.

Only use complexity when it provides clear value.