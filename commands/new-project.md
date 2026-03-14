---
description: "Workflow for a new or bootstrapped project with few source files. Runs stack detection, inventory, architecture planning, initial implementation, and QA."
---

# /new-project

Trigger this command when starting work on a new or recently scaffolded project with few existing source files.

## Gating Policy

- Trigger: Stack confidence HIGH and < 10 source files.
- Milestone 2 requires scope authorization.
- Milestone 1 is the default detection pass for this workflow.

## Milestone Sequence

Execute milestones in order — one per cycle. Do not batch milestones.

### Milestone 1 — Detection & Inventory

Agent: stack-analyzer
Skills: fingerprint, stack-detection
Output: docs/STACK_PROFILE.md

Never skip this milestone.

### Milestone 2 — Scaffold Audit

Agent: repo-analyzer
Skills: repo-inventory
Output: docs/INVENTORY.md

### Milestone 3 — Architecture Plan

Agent: solution-architect
Skills: code-search
Output: docs/ARCHITECTURE.md
Note: Planning only. No code changes.

### Milestone 4 — Initial Implementation

Agent: software-engineer
Skills: code-search, targeted-test-runner
Note: Apply docs/ARCHITECTURE.md. One milestone per cycle.

### Milestone 5 — QA & Documentation

Agent: qa-engineer
Skills: ci-checks
Output: docs/QA_REPORT.md

Agent: tech-writer
Skills: docs-writer
Output: Updated README.md

## Hard Rules

1. Execute milestones in order. Never skip Milestone 1.
2. One milestone per cycle. No batching.
3. Never auto-merge PRs.
4. Log every cycle in docs/DECISIONS.md.
