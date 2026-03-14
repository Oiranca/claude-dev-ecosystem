---
name: "react-vite-to-astro-migration"
description: "Incrementally migrate React + Vite components to Astro using islands architecture while preserving behavior and deferring risky components."
allowed-tools: ["read", "search", "edit"]
---

# React Vite to Astro Migration

Use this skill to migrate a React + Vite application incrementally toward Astro using islands architecture.

This is a migration playbook skill.
It must never run outside an approved migration workflow.

## Purpose

Convert selected React + Vite components into Astro-compatible structure by classifying them as:

- STATIC
- ISLAND
- SHARED

and migrating them in small, reversible batches.

## Gating Policy

- Cost class: EXPENSIVE
- Requires explicit playbook justification
- Only allowed when `MIGRATION_REACT_VITE_TO_ASTRO` playbook is active
- Only allowed when `docs/STACK_PROFILE.md` confirms React + Vite with HIGH confidence
- Only allowed during Milestone 4: Incremental Migration
- Skip if Astro is already detected as the active framework
- Skip if the build is currently failing
- Skip if `docs/ROUTE_MAP.md` is missing
- Skip if `docs/ARCHITECTURE.md` does not contain migration classification

## Hard Rules

- Maximum 5 components per cycle
- Prefer homogeneous batches:
  - STATIC first
  - then SHARED / layout
  - then ISLAND
- Maximum 13 file reads total:
  - 6 documentation reads
  - 5 source component reads
  - 2 config reads
- Create new files only
- Never delete original React files
- Never migrate more than one route surface family in the same batch unless explicitly planned
- Never guess interactivity classification
- If uncertainty exists, defer the component

## Required documentation reads

Read:

- `.agent-cache/AGENT_STATE.json`
- `docs/STACK_PROFILE.md`
- `docs/ROUTE_MAP.md`
- `docs/ARCHITECTURE.md`
- `docs/INVENTORY.md`
- `docs/MIGRATION_STATE.md` if present

## Precondition check

Abort immediately if any of the following fail:

- Framework is not React
- Bundler is not Vite
- Confidence is not HIGH
- Migration playbook is not active
- Architecture classification is missing

## Classification rules

## STATIC
A component may be classified as STATIC if it has:
- no hooks
- no local state
- no effects
- no browser-only APIs
- no required runtime interactivity

Migration target:
- `.astro`

Transformation rules:
- remove React imports
- move props access to `Astro.props`
- convert JSX to Astro template syntax
- convert `className` to `class`

## ISLAND
A component must remain interactive if it uses:
- hooks
- state
- effects
- event-driven browser behavior
- runtime interactivity

Migration target:
- keep the interactive component as `.tsx` or `.jsx`
- create an Astro wrapper file

Hydration directive policy:
- use `client:load` only when immediate interactivity is required
- prefer `client:idle` for non-critical interactivity
- use `client:visible` for deferred or below-the-fold UI

## SHARED
A shared structural component such as layout may be migrated to:
- `.astro`

Transformation rules:
- convert layout shell to Astro
- replace child rendering with `<slot />`

## Styling policy

Preserve the existing styling strategy.

Do not rewrite:
- Tailwind usage
- CSS modules
- global stylesheet strategy
- asset references

unless the architecture plan explicitly requires it.

## Route update policy

Only update route files if the active milestone explicitly includes route migration.

Do not perform broad route restructuring inside the same batch as component migration unless required by the architecture plan.

## Defer policy

Defer a component if it has:

- complex shared state
- router coupling
- browser-only API coupling
- animation-heavy behavior
- difficult third-party library integration
- unclear static vs interactive classification

Record every deferred component with a reason.

## Traceability requirements

Every migrated component must record:

- source file
- target file
- classification
- classification reason
- status: migrated | deferred | failed

## Output

Update:
- migrated `.astro` files
- wrapper `.astro` files when needed
- route files only when explicitly in scope

Write or update:
- `docs/MIGRATION_STATE.md`

Append a short entry to:
- `docs/DECISIONS.md`

## Required Migration State Structure

# Migration State

## Current Batch
Short description of the active batch.

## Migrated Components
| Source | Target | Classification | Reason | Status |

## Deferred Components
| Source | Reason |

## Failed Components
| Source | Reason | Rollback Performed |

## Notes
Short summary of progress and blockers.

## Completion Rules

If a migrated component breaks the batch:
- mark it as failed
- record rollback in `docs/MIGRATION_STATE.md`
- do not delete originals

If no safe components are available:
- write an empty batch result
- mark the batch as deferred