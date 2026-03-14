---
name: "docs-writer"
description: "Synchronize human-facing documentation such as README and CHANGELOG using existing agent-generated documentation as the source of truth."
allowed-tools: ["read", "edit"]
---

# Docs Writer

Use this skill to update human-facing documentation after a cycle that produced or changed repository documentation.

This skill does not generate documentation from scratch.
It only summarizes and synchronizes information from existing agent-generated docs.

## Purpose

Keep the following documentation aligned with the latest validated repository state:

- README.md
- CHANGELOG.md
- selected human-facing documentation sections

## Gating Policy

- Cost class: CHEAP
- Run only after a cycle that produced or updated docs
- Skip if no docs changed in the current cycle
- Skip if the repository fingerprint is unchanged
- Never run as a standalone cycle without upstream documentation changes

## Hard Rules

- Never read source code
- Never read config files
- Maximum 7 file reads total:
  - AGENT_STATE.json
  - docs/STACK_PROFILE.md
  - docs/INVENTORY.md
  - docs/ARCHITECTURE.md
  - docs/DECISIONS.md
  - README.md
  - CHANGELOG.md
- Never rewrite the entire README
- Never delete existing README content
- Only update agent-managed sections when markers are present
- If markers are absent, append new agent-managed sections to the end
- Never invent undocumented features
- Never summarize from memory
- Use existing docs only

## Managed README sections

Preferred markers:

- `<!-- agent:project-overview-start -->` / `<!-- agent:project-overview-end -->`
- `<!-- agent:development-workflow-start -->` / `<!-- agent:development-workflow-end -->`
- `<!-- agent:architecture-summary-start -->` / `<!-- agent:architecture-summary-end -->`
- `<!-- agent:recent-changes-start -->` / `<!-- agent:recent-changes-end -->`

If markers do not exist:
- append a new `## Agent-managed project summary` section at the end of README.md

## CHANGELOG policy

- Update `CHANGELOG.md` only with a minimal new entry for the current cycle
- Do not rewrite historical entries
- If `CHANGELOG.md` is missing, create a minimal one
- Use this structure:

## [YYYY-MM-DD]

### Added
### Changed
### Fixed
### Security

Only include sections relevant to the current cycle.

## Missing file behavior

If README.md is missing:
- create a minimal README with agent-managed sections only

If any docs file is missing:
- skip the corresponding summary section
- add a warning to the output
- append a short warning note to `docs/DECISIONS.md`

## Output

Update:
- `README.md`
- `CHANGELOG.md` when relevant

Append a short entry to:
- `docs/DECISIONS.md`

## Completion Rules

The skill is successful if:
- documentation was updated non-destructively
- no undocumented claims were introduced
- README existing content was preserved