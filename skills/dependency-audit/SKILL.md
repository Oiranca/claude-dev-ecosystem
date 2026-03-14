---
name: "dependency-audit"
description: "Audit project dependencies for known vulnerabilities and outdated packages using the repository's native package manager tooling."
allowed-tools: ["read", "execute", "edit"]
---

# Dependency Audit

Use this skill to audit repository dependencies for:
- known vulnerabilities
- outdated packages

Do not use this skill to detect unused packages.
That requires a different workflow and is intentionally out of scope here.

## Gating Policy

- Cost class: MEDIUM
- Run only when the active milestone authorizes dependency review
- Skip if the repository fingerprint is unchanged and `docs/DEPENDENCY_AUDIT.md` already exists
- Skip if no package manager is detected in `docs/STACK_PROFILE.md`
- Never run in every cycle

## Hard Rules

- Read at most 3 files:
  - dependency manifest
  - lockfile if present
  - previous `docs/DEPENDENCY_AUDIT.md` if present
- Do not read source files
- Execute at most 2 commands total:
  - one audit command
  - one outdated command
- If audit tooling is unavailable, record a warning and run only the outdated check
- If no lockfile exists, continue with manifest-only evidence
- If any command times out, write partial results and mark them clearly
- Limit vulnerability output to the top 20 most critical findings

## Package Manager Command Mapping

Use the native tool that matches the repository.

### npm
- audit: `npm audit --json`
- outdated: `npm outdated`

### yarn
- audit: `yarn audit`
- outdated: `yarn outdated`

### pnpm
- audit: `pnpm audit --json`
- outdated: `pnpm outdated`

### pip
- audit: `pip-audit`
- outdated: `pip list --outdated`

### cargo
- audit: `cargo audit`
- outdated: `cargo install-update -a` or report outdated status if available in repo tooling

If the package manager is detected but the required command is unavailable, write that limitation into the report.

## Output File

Write results to:

`docs/DEPENDENCY_AUDIT.md`

Also append a short completion note to:

`docs/DECISIONS.md`

## Required Report Structure

# Dependency Audit

## Summary
Short overview of the dependency health status.

## Package Manager
Detected package manager and evidence.

## Vulnerabilities
| Severity | Package | Version | Issue | Recommended Action |

Group findings by:
- Critical
- High
- Moderate
- Low

Only include the top 20 most critical findings.

## Outdated Packages
| Package | Current | Latest | Recommended Action |

## Recommendations

Classify recommendations as:
- Immediate action
- Scheduled update
- Monitor only

## Limitations
Document:
- missing lockfile
- unavailable tooling
- timeout
- partial results

## Decision Log Entry
Append a short summary to `docs/DECISIONS.md`.

## Completion Rules

If no package manager is detected:
- skip the skill
- log the skip in `docs/DECISIONS.md`

If no vulnerabilities or outdated packages are found:
- still write a report
- mark the audit as clean