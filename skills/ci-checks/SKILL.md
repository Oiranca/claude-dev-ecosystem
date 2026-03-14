---
name: "ci-checks"
description: "Run available lint, type-check, test, and build commands and report results before pull request creation."
allowed-tools: ["read", "execute", "edit"]
---

# CI Checks

Use this skill to run available project validation checks before opening a pull request.

The skill executes local validation commands and reports their status.

This skill does not fix failures.

## Purpose

Validate that the repository passes its core quality checks:

- lint
- type-check
- test
- build

and document the results.

## Gating Policy

- Cost class: MEDIUM
- Requires milestone authorization
- Skip if no code changes were produced in the current cycle
- Skip if fingerprint unchanged
- Never run speculatively
- Check `.agent-cache/skill_budget_state.json` when present before rerunning broader validation in the same cycle
- Respect `.agent-cache/locks/qa.lock` when present before starting overlapping validation

## Hard Limits

- Max 4 documentation reads
- Max 2 CI config reads
- Max 4 command executions
- Max command runtime: 5 minutes
- Capture only first 50 lines of failure output

## Documentation reads

Read:

- `.agent-cache/AGENT_STATE.json`
- `docs/STACK_PROFILE.md`
- `docs/INVENTORY.md`
- `docs/QA_REPORT.md` (if exists)

Do not read source files.

## Command discovery

Commands must be obtained from `docs/STACK_PROFILE.md`.

Supported commands:

| Check | Description |
|------|-------------|
| lint | code linting |
| type-check | static type validation |
| test | unit or integration tests |
| build | production build |

If a command is missing from STACK_PROFILE, mark it as `SKIP`.

## Execution environment

- Run commands in repository root
- Do not install dependencies
- Do not modify environment
- Do not execute optional or custom scripts

## Execution order

Run checks in the following order:

1. lint
2. type-check
3. test
4. build

Continue execution even if earlier checks fail.

## Result classification

Each check must be classified as:

- PASS
- FAIL
- SKIP
- TIMEOUT

### PASS
Command completed successfully.

### FAIL
Command exited with non-zero status.

### SKIP
Command not defined in stack profile.

### TIMEOUT
Command exceeded 5 minutes.

## CI pipeline detection

Optionally inspect CI configuration files if present:

- `.github/workflows/*.yml`
- `gitlab-ci.yml`
- `circle.yml`

Only record whether a pipeline exists.

Do not attempt to interpret pipeline logic.

## Output

Write results to:
