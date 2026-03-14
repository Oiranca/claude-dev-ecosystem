---
description: "Incremental migration workflow from React + Vite to Astro using islands architecture. Validates preconditions, inventories routes, plans architecture, migrates components in batches, and validates."
---

# /migration-react-vite-to-astro

Trigger this command to execute a structured incremental migration from a React + Vite application to Astro.

## Gating Policy

Require HIGH confidence evidence of BOTH conditions before proceeding:

1. React is the primary framework (`react-dom` in deps AND React entry point exists).
2. Vite is the bundler (`vite.config.*` exists AND `vite` in devDependencies).

Fall back to `/existing-repo` or `/unknown-stack` if either condition fails.

Pre-conditions:
- `docs/STACK_PROFILE.md` must exist.
- Astro must NOT already be detected as the active framework.
- Milestone 2 requires scope authorization.
- Milestone 4 uses `react-vite-to-astro-migration` and must be explicitly justified.
- Milestone 5 uses `smoke-journeys` and should only run when needed for end-to-end regression validation.

## Milestone Sequence

One milestone per cycle. No batching.

### Milestone 1 — Validation

Agent: stack-analyzer
Skills: fingerprint, stack-detection
Action: Confirm both pre-conditions. STOP if any fail.

### Milestone 2 — Inventory & Route Map

Agent: repo-analyzer
Skills: repo-inventory, route-mapper
Output: docs/INVENTORY.md, docs/ROUTE_MAP.md

### Milestone 3 — Migration Architecture

Agent: solution-architect
Skills: code-search, architecture-drift-check
Output: docs/ARCHITECTURE.md with:
- Component classification (STATIC, ISLAND, SHARED)
- Route plan
- Island candidates
Note: Planning only. No code changes.

### Milestone 4 — Incremental Migration

Agent: migration-engineer
Skill: react-vite-to-astro-migration
Rules:
- Migrate maximum 5 components per cycle. No exceptions.
- Prefer STATIC components first, then SHARED/layout, then ISLAND.
- Never delete original React files.
- If migration breaks the build, stop immediately and log to docs/DECISIONS.md.

### Milestone 5 — Smoke Testing

Agent: qa-engineer
Skills: smoke-journeys
Output: docs/QA_REPORT.md
Note: Only run when runtime or end-to-end regression validation is needed.

### Milestone 6 — Cleanup

Agent: software-engineer + security-reviewer
Skills: dependency-audit
Actions:
- Remove unused Vite/React dependencies.
- Update docs.

## Hard Rules

1. One milestone per cycle. No batching.
2. If migration breaks the build, stop immediately.
3. Never auto-merge PRs.
4. Log every decision in docs/DECISIONS.md.
5. Component classification must be evidence-based. When uncertain, defer.
