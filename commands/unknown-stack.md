---
description: "Cautious analysis workflow for a repository with an unclear or ambiguous technology stack. Requires human review before implementation proceeds."
---

# /unknown-stack

Trigger this command when the repository stack cannot be confidently identified, or when detection signals are weak or conflicting.

## Gating Policy

- Trigger: Stack confidence LOW, or no known stack pattern matches.
- Milestone 2 requires scope authorization.
- Milestone 1 is the default detection pass for this workflow.

## Milestone Sequence

### Milestone 1 — Extended Detection

Agent: stack-analyzer
Skills: fingerprint, stack-detection
Output: docs/STACK_PROFILE.md (note LOW confidence)

Document all detected signals. Do not guess.

### Milestone 2 — Manual Inventory

Agent: repo-analyzer
Skills: repo-inventory
Output: docs/INVENTORY.md

List all detected technologies without assumptions. Record ambiguities explicitly.

### Milestone 3 — Human Review Request

Agent: solution-architect
Output: docs/ARCHITECTURE.md with `STATUS: NEEDS_HUMAN_REVIEW`

Planning only. No code changes. Stop the workflow pending human guidance.

The architecture document must explain:
- What signals were found.
- What is ambiguous.
- What questions must be answered before implementation can proceed.

## Hard Rules

1. Do NOT proceed to implementation without human confirmation.
2. Do NOT guess the stack — document evidence and ask.
3. Never auto-merge PRs.
4. If the stack is clarified later, switch to `/existing-repo` or `/new-project`.
