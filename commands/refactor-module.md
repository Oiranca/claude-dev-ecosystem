---
description: "Safe, behavior-preserving refactor workflow for a specific module or file set. Includes planning, scoped implementation, and validation."
---

# /refactor-module

Run a focused, safe refactor on a specific module, file, or feature area.

Usage: `/refactor-module <path-or-description>`

Example: `/refactor-module src/utils/auth.ts`

## Principles

- Preserve existing behavior. This is a refactor, not a rewrite.
- Avoid unrelated cleanup. Do not touch files outside the stated scope.
- Keep the change reviewable. Prefer small, sequential edits over large atomic changes.
- Do not introduce new dependencies or frameworks.

## Phase 1 — Planning

Agent: solution-architect (or context-manager for scope reduction first)

Steps:
1. Identify the target module and its boundaries.
2. Read only the files directly involved — use `code-search` to avoid broad reads.
3. Classify the refactor type:
   - **Extract**: Pull duplicated logic into a shared utility.
   - **Rename**: Rename symbols, files, or modules for clarity.
   - **Simplify**: Reduce complexity within a function or class.
   - **Restructure**: Move code between files while preserving behavior.
4. Produce a refactor plan with:
   - Files to change (list them explicitly).
   - Files NOT to change (state this explicitly).
   - Rollback strategy (how to revert if validation fails).
   - Test strategy (which tests cover the changed behavior).

Output: Short planning summary returned to user before implementation begins.

Do not proceed to implementation without a clear plan.

## Phase 2 — Implementation Scope

Agent: software-engineer

Rules:
- Implement only the refactor plan. Do not expand scope.
- Do not mix refactor changes with feature additions or bug fixes.
- Do not reformat unrelated code.
- Prefer editing existing files over creating new ones.
- If a rename affects imports, update all affected import sites.
- Update tests only when they reference renamed or restructured symbols.

Atomic change sets:
- Structural changes (move/rename) in one commit.
- Logic simplification in a separate commit if combined scope is large.

## Phase 3 — Validation

Agent: qa-engineer

Steps:
1. Run targeted tests for the refactored module first.
2. If targeted tests pass and scope is contained, stop.
3. Escalate to `ci-checks` only if the refactor touched shared utilities or public API surfaces.

Pass criteria:
- All pre-existing tests pass.
- No new type errors.
- No lint regressions.
- Build succeeds.

## Hard Rules

- Do not introduce behavior changes. If behavior must change, that is a feature, not a refactor.
- Do not touch files outside the declared scope.
- Do not auto-merge.
- Log the refactor decision in `docs/DECISIONS.md` when present.
- If the refactor reveals a bug, stop and report it rather than silently fixing it.
