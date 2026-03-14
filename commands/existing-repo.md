---
description: "Full analysis and improvement workflow for an existing repository. Runs stack detection, inventory, dependency audit, architecture review, targeted improvements, and QA."
---

# /existing-repo

Trigger this command when you are starting work on an existing repository that already has source files and a known structure.

## Gating Policy

- Trigger: Stack confidence HIGH and >= 10 source files.
- Milestones 2 and 3 require scope authorization before running.
- Milestone 1 is the default detection pass. Skip if fingerprint unchanged.

## Milestone Sequence

Execute milestones in order — one per cycle. Do not batch milestones.

### Milestone 1 — Detection & Cache Check

Agent: stack-analyzer
Skills: fingerprint, stack-detection
Output: docs/STACK_PROFILE.md

Run fingerprint first. If no material change is detected, skip the rest of this milestone.

### Milestone 2 — Full Inventory

Agent: repo-analyzer
Skills: repo-inventory, route-mapper
Output: docs/INVENTORY.md

### Milestone 3 — Dependency & Security Audit

Agent: security-reviewer
Skills: dependency-audit
Output: docs/SECURITY_REPORT.md

### Milestone 4 — Architecture Review

Agent: solution-architect
Skills: code-search, architecture-drift-check
Output: docs/ARCHITECTURE.md
Note: Planning only. No code changes.

### Milestone 5 — Targeted Improvements

Agent: software-engineer
Skills: code-search, targeted-test-runner
Note: Apply ARCHITECTURE.md recommendations. One improvement per cycle.

### Milestone 6 — QA Pass

Agent: qa-engineer
Skills: ci-checks
Output: docs/QA_REPORT.md

Agent: tech-writer
Skills: docs-writer
Output: README update when needed.

## Hard Rules

1. Execute milestones in order.
2. One milestone per cycle. No batching.
3. Respect existing code — minimal, non-destructive changes only.
4. Never auto-merge PRs.
5. Read repository docs before recommending source changes.
6. Log every cycle in docs/DECISIONS.md.
