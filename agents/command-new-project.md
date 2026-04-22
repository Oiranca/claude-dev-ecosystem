---
name: command-new-project
description: "Workflow for a new or bootstrapped project with few source files. Runs stack detection, inventory, architecture planning, initial implementation, and QA."
model: gemini-3-pro-preview
tools: ["*"]
---


## Gemini CLI Native Note

- This skill runs natively in Gemini CLI.
- Any references to `local metadata cache` in this document are optional local metadata hints, not required control-plane dependencies.

# Command `new-project`

## Gemini CLI Native Orchestration (v2)

1. Drive orchestration from the current Gemini CLI thread.
2. Split work into independent lanes and run them with `delegate` when parallelism helps.
3. Use `interact` to refine or redirect delegated lanes.
4. Integrate outputs in this thread with explicit ownership, files changed, and validation status.
5. Treat legacy runtime scripts as optional compatibility only, not a required control plane.

# /new-project

You are the **Main Agent (Team Lead)**. Trigger this command when starting work on a new or recently scaffolded project with few existing source files.

## Gating Policy
- **Trigger**: Stack confidence HIGH and < 10 source files.
- Milestone 2 requires scope authorization.
- Milestone 1 is the default detection pass for this workflow.

## Milestone Sequence (Swarm Orchestration)

### Milestone 1 — Detection & Inventory
Spawn an Agent Team via the **current Gemini CLI thread**:
1. **stack-analyzer**: Run fingerprint and stack-detection. Output `docs/STACK_PROFILE.md`. Never skip this milestone.
2. **repo-analyzer**: Run repo-inventory. Output `docs/INVENTORY.md`.
*Wait for both to communicate completion to the current Gemini CLI thread.*

### Milestone 2 — Architecture Plan
Assign to **solution-architect**:
- Use `code-search` to analyze the scaffold.
- Output `docs/ARCHITECTURE.md`. 
*Note: Planning only. No code changes.*

### Milestone 3 — Initial Implementation
Assign to **software-engineer**:
- Apply `docs/ARCHITECTURE.md`. Use `code-search` and `targeted-test-runner`.
- Execute only one milestone per cycle.

### Milestone 4 — QA & Documentation Swarm
Spawn in parallel:
1. **qa-engineer**: Run `ci-checks`. Output `docs/QA_REPORT.md`.
2. **tech-writer**: Update `README.md` using `docs-writer`.

## Hard Rules
1. Execute milestones in order. Never skip Milestone 1.
2. One milestone per cycle. No batching.
3. Never auto-merge PRs.
4. Log every cycle in `docs/DECISIONS.md`.
