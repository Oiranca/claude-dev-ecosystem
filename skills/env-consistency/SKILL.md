---
name: "env-consistency"
description: "Check whether environment variables are documented, referenced in code, and visible in deployment-related configuration."
allowed-tools: ["read", "search", "edit"]
---

# Env Consistency

Use this skill to compare environment variable documentation against source usage patterns and deployment-related configuration.

This skill detects likely consistency gaps.
It does not prove that deployment variables are missing from external platform UIs.

## Purpose

Identify environment variable issues such as:

- undocumented variables
- documented but unreferenced variables
- deployment visibility gaps
- suspicious naming mismatches

## Gating Policy

- Cost class: EXPENSIVE
- Requires explicit playbook justification naming this skill
- Skip if fingerprint unchanged
- Skip if no env example/template file exists
- Never run on every cycle

## Hard Rules

- Max 3 documentation reads:
  - `.agent-cache/AGENT_STATE.json`
  - `docs/STACK_PROFILE.md`
  - `docs/INVENTORY.md`
- Max 1 env template read:
  - `.env.example`
  - `.env.sample`
  - `.env.template`
  - fallback to `.env.local.example`, `.env.development.example`, `.env.production.example`
- Max 2 deployment config reads:
  - `netlify.toml`
  - `vercel.json`
  - `docker-compose.yml`
  - first 2 found only
- Max 20 source files scanned via grep-like pattern search
- Do not read full source file contents
- Do not scan:
  - `node_modules/`
  - `.git/`
  - `dist/`
  - `build/`
  - `vendor/`

## Data extraction

## Documented variables
Extract variable names from the env template file.

## Deployment-visible variables
Extract variable names visible in deployment-related config files only.

Note:
Absence from reviewed deployment files does not prove absence from platform UI secrets.

## Source usage
Scan source paths only for environment variable patterns:

- `process.env.`
- `import.meta.env.`
- `os.environ["..."]`
- `os.getenv("...")`
- `env("...")`

Search only in likely app code paths such as:

- `src/`
- `lib/`
- `app/`
- `pages/`

## Issue categories

Classify findings as:

### undocumented
Used in code but not documented in env template files.

### unused-documentation
Documented in env template files but not referenced in scanned code.

### deployment-visibility-gap
Used in code or documented in env template files, but not visible in reviewed deployment config files.

### naming-mismatch
Likely same variable purpose expressed with inconsistent names, only when evidence is strong.

## Output

Write results to:

`docs/ENV_REPORT.md`

Append a short entry to:

`docs/DECISIONS.md`

## Required Output Structure

# Environment Consistency Report

## Summary
Short overview of environment variable consistency.

## Documented Variables
| Variable | Source |

## Referenced Variables
| Variable | Evidence Pattern |

## Deployment-Visible Variables
| Variable | Config Source |

## Issues

### Undocumented Variables
| Variable | Evidence |

### Unused Documentation
| Variable | Source |

### Deployment Visibility Gaps
| Variable | Reason |

### Naming Mismatches
| Variable Pair | Reason |

## Recommendations
Short practical next steps.

## Limitations
Document:
- missing deployment config
- partial grep coverage
- uncertainty caused by UI-managed platform secrets

## Completion Rules

If no env template file exists:
- skip the skill
- log the reason in `docs/DECISIONS.md`

If no issues are found:
- still write `docs/ENV_REPORT.md`
- mark the report as clean