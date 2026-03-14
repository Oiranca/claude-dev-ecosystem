---
description: "Parallel multi-agent code review workflow. Coordinates Security, Performance, and QA review lanes and produces a structured final report."
---

# /team-review

Run a parallel multi-agent code review over staged changes or the most relevant modified files in the current branch.

The current Claude session acts as Team Lead when Agent Teams are available.

## Scope

By default, review is scoped to:
- Staged changes (`git diff --cached`)
- Or, if nothing staged: files modified in the current branch vs main.

Override scope by passing a file path or directory: `/team-review src/api/`

## Review Lanes

Three review lanes run in parallel:

### Lane 1 — Security Specialist

Role: security-reviewer

Focus:
- Exposed secrets or credentials in changed files.
- Unsafe input handling, injection risks, authentication gaps.
- Dependency changes that introduce known vulnerabilities.
- Overly permissive configuration or CORS policy changes.

Constraints:
- Never reproduce secret values in output.
- Classify every finding as CRITICAL, HIGH, MEDIUM, or LOW.

### Lane 2 — Performance Expert

Role: software-engineer (performance mode)

Focus:
- Expensive operations in hot paths (N+1 queries, repeated large reads, blocking I/O).
- Missing caching or memoization where clearly beneficial.
- Bundle size regressions or unnecessarily large imports.
- Algorithmic complexity concerns when evidence is clear.

Constraints:
- Do not flag micro-optimizations unless they are clearly relevant to scale.
- Require evidence before classifying as blocking.

### Lane 3 — QA Engineer

Role: qa-engineer

Focus:
- Missing or broken test coverage for changed behavior.
- Edge cases not handled by existing tests.
- Build or type check issues introduced by the change.
- Milestone compliance: does the implementation match its intent?

Constraints:
- Classify failures as blocking, non-blocking, or suggestion.

## Execution

When Agent Teams are available:
- Spawn all three lanes in parallel.
- Each lane receives the scoped file list.
- Collect all three reports.

When running without Agent Teams:
- Run each lane sequentially in the order: Security → QA → Performance.

## Final Report

The Team Lead (current Claude session) consolidates results into a single structured Markdown report.

Do not dump intermediate reasoning. Return only the consolidated report.

```markdown
# Team Review Report

## Scope
Files reviewed: <list>
Branch: <branch name>

## Security Review
**Status**: SAFE | WARNING | VULNERABLE
<findings organized by severity>

## Performance Review
**Status**: PASS | WARNING | CONCERN
<findings organized by impact>

## QA Review
**Status**: PASS | PARTIAL | FAIL
<findings organized by blocking/non-blocking>

## Consolidated Verdict
**Overall**: APPROVED | APPROVED WITH NOTES | CHANGES REQUESTED | BLOCKED

## Required Actions (Blocking)
<list of changes that must happen before merge>

## Recommended Actions (Non-blocking)
<list of improvements worth addressing but not blocking>
```

## Hard Rules

- Never auto-merge based on this report.
- Do not reproduce secret values.
- Scope stays on changed files only — do not expand to unrelated parts of the repository.
- If no changed files can be determined, ask the user to specify scope.
