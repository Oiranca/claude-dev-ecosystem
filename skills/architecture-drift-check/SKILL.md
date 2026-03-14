---
name: "architecture-drift-check"
description: "Detect likely drift between documented architecture and the current repository structure, file boundaries, and dependency patterns."
allowed-tools: ["read", "search", "edit"]
---

# Architecture Drift Check

Use this skill to compare the documented architecture with the current repository structure and identify likely signs of architectural drift.

This skill detects structural inconsistencies and suspicious dependency patterns.
It does not rewrite architecture documents and does not enforce architecture automatically.

## Purpose

Identify signs that the repository may have drifted away from its documented architecture, including:

- boundary violations
- unexpected cross-layer dependencies
- missing or outdated architectural assumptions
- repository shape changes not reflected in documentation

## Gating Policy

- Cost class: MEDIUM
- Run only when a milestone affects architecture-sensitive areas
- Skip if `docs/ARCHITECTURE.md` is missing
- Skip if fingerprint unchanged and no structural files changed
- Never run on every cycle

## Required Inputs

Read:

- `.agent-cache/AGENT_STATE.json`
- `docs/STACK_PROFILE.md`
- `docs/INVENTORY.md`
- `docs/ARCHITECTURE.md`

Optional:
- `docs/DECISIONS.md` if needed for recent architectural changes

## Hard Rules

- Maximum 8 file reads total
- Maximum 10 targeted searches
- Do not read source files in full unless necessary
- Prefer structure, import, and path-level evidence
- Do not edit source code
- Do not rewrite architecture docs
- Do not guess undocumented architectural rules

## Drift Detection Areas

## Repository shape drift

Check whether the repository shape described in `docs/ARCHITECTURE.md` still matches:

- single app vs monorepo
- number of applications
- service boundaries
- presence of libraries or packages

## Boundary drift

Look for likely violations such as:

- frontend importing backend-only modules
- route handlers depending directly on deep infrastructure internals
- shared packages depending on app-specific code
- circular-looking coupling signals across boundaries

## Dependency drift

Look for changes in:

- major framework signals
- bundler/build assumptions
- newly introduced tooling that is not reflected in architecture documentation

## Path drift

Check whether key documented paths still exist and whether new important paths appeared without being reflected in architecture notes.

## Result Classification

Classify findings as:

- HIGH
- MEDIUM
- LOW

### HIGH
Strong evidence that the current repo shape or dependency flow contradicts documented architecture.

### MEDIUM
A likely mismatch exists, but the evidence is partial or indirect.

### LOW
Minor architectural inconsistency or outdated documentation signal.

## Output

Write results to:

`docs/ARCHITECTURE_DRIFT_REPORT.md`

Append a short summary to:

`docs/DECISIONS.md`

## Required Output Structure

# Architecture Drift Report

## Summary
Short overview of whether drift was detected.

## Repository Shape Drift
| Finding | Severity | Evidence |

## Boundary Drift
| Finding | Severity | Evidence |

## Dependency Drift
| Finding | Severity | Evidence |

## Path Drift
| Finding | Severity | Evidence |

## Recommended Follow-up
Short practical next steps.

## Limitations
Document uncertainty, weak signals, or missing evidence.

## Completion Rules

If no drift is detected:
- still write the report
- mark the architecture as aligned

If `docs/ARCHITECTURE.md` is missing:
- skip the skill
- record the reason in `docs/DECISIONS.md`

If evidence is weak:
- record findings as LOW or MEDIUM
- do not escalate without clear structural evidence