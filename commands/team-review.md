---
description: "Parallel multi-agent code review workflow. Coordinates Security, Performance, and QA review lanes and produces a structured final report."
---

# /team-review [scope]

You are the **Main Agent (Team Lead)**. Orchestrate a parallel review over staged changes or modified files.

## Review Lanes (Parallel Execution)
Spawn all three lanes in parallel via the **Shared Task List**:

### Lane 1 — Security Specialist (security-reviewer)
- Focus: Exposed secrets, unsafe input, dependency vulnerabilities, permissive configs.
- Rule: Never reproduce secret values.

### Lane 2 — Performance Expert (software-engineer)
- Focus: Expensive operations, missing caching, bundle size, complexity.
- Rule: No micro-optimizations without clear scale evidence.

### Lane 3 — QA Engineer (qa-engineer)
- Focus: Missing/broken test coverage, edge cases, build/type issues, milestone compliance.

## Final Report
Consolidate results into the structured Team Review Report (Scope, Security, Performance, QA, Consolidated Verdict, Required Actions).

## Hard Rules
1. Never auto-merge. Do not reproduce secret values.
2. Scope stays on changed files only.