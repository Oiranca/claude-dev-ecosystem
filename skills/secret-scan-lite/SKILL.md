---
name: "secret-scan-lite"
description: "Run a lightweight regex-based scan for accidentally committed secrets, tokens, credentials, and unsafe secret hygiene signals."
allowed-tools: ["read", "search", "edit"]
---

# Secret Scan Lite

Use this skill to perform a lightweight secret hygiene scan before opening a pull request.

This skill is intentionally lightweight.
It uses pattern matching and repository hygiene checks.
It does not replace dedicated secret scanning tools.

## Purpose

Detect likely accidental exposure of:

- API keys
- tokens
- credentials
- private keys
- unsafe secret hygiene patterns

before changes are proposed for review.

## Gating Policy

- Cost class: EXPENSIVE
- Requires explicit playbook justification naming this skill
- Skip if fingerprint unchanged
- Skip if no code or config changes were made
- Never run on every cycle

## Hard Rules

- Max 4 document reads:
  - `.agent-cache/AGENT_STATE.json`
  - `docs/STACK_PROFILE.md`
  - `docs/SECURITY_REPORT.md`
  - `.gitignore`
- Max 30 files scanned via grep/pattern matching only
- Do not perform full source reads
- Do not scan:
  - `node_modules/`
  - `.git/`
  - `dist/`
  - `build/`
  - binary files
  - images
  - lockfiles
  - minified files
- Redact secret-like values in all outputs
- Never print the actual matched secret value
- If more than 50 findings exist, report the first 50 and note truncation

## Pre-flight repository hygiene checks

Check whether the following are ignored in `.gitignore`:

- `.env`
- `.env.local`
- `.env.*.local`
- `.env.production`
- `.env.development`
- `.env.test`

Classify hygiene issues as:

- CRITICAL: `.env` not ignored
- HIGH: `.env.local` not ignored
- MEDIUM: other sensitive env variants not ignored

## Pattern severity categories

## CRITICAL
Examples:
- private key headers such as `BEGIN PRIVATE KEY`
- obvious live credentials with strong secret indicators

## HIGH
Examples:
- API key assignments with long literal values
- AWS access keys (`AKIA...`)
- JWT secret assignments
- database URLs containing embedded credentials

## MEDIUM
Examples:
- generic `secret=`, `password=`, `token=` assignments with non-trivial literal values
- bearer tokens
- suspicious auth headers

## LOW
Examples:
- TODO or FIXME notes mentioning secrets
- localhost credentials embedded in examples
- weak hygiene indicators with low certainty

## Output redaction policy

For every finding, record only:

- file path
- line number
- pattern category
- severity
- 10-character redacted context snippet

Never record:
- full secret values
- full tokens
- private key material
- full credential strings

## Output

Write results to:

`docs/SECURITY_REPORT.md`

Append a short completion entry to:

`docs/DECISIONS.md`

## Required Output Structure

# Security Report

## Summary
Short overview of the scan outcome.

## Repository Hygiene Issues
| Issue | Severity | Evidence |

## Potential Secret Findings
| File | Line | Pattern Type | Severity | Redacted Context |

## Severity Summary
- Critical count
- High count
- Medium count
- Low count

## Recommendations
Short practical next steps.

## Limitations
State clearly:
- regex-based scan only
- false positives possible
- false negatives possible
- partial file coverage if scan limit was reached

## Completion Rules

If no files are eligible for scanning:
- still write `docs/SECURITY_REPORT.md`
- mark the scan as clean with limitations

If no findings are detected:
- still write the report
- include hygiene check results

If a pattern-matching error occurs:
- skip that pattern
- continue scanning
- note the limitation