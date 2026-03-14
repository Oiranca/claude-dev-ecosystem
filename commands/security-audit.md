---
description: "Focused security audit workflow. Prioritizes sensitive surfaces first, avoids reproducing secrets, and returns a remediation-oriented report."
---

# /security-audit

Run a focused security audit on this repository.

Usage: `/security-audit` — audits the full repository.
Usage: `/security-audit src/api/` — audits a specific surface.

## Scope Priority

Audit surfaces in this order, stopping when the stated scope is covered:

1. Secret and credential exposure (highest priority).
2. Dependency vulnerabilities.
3. Authentication and authorization configuration.
4. Environment variable hygiene.
5. Container and deployment configuration (if present).
6. Unsafe input handling patterns.

## Phase 1 — Secret Scan

Agent: security-reviewer
Skill: secret-scan-lite

Scan for:
- Committed API keys, tokens, or credentials.
- Private key material in source or config files.
- `.env` files not properly gitignored.
- Hard-coded credentials in application code.

Redaction rule: Never reproduce actual secret values in the report. Record file path, line number, pattern type, severity, and a redacted context snippet only.

## Phase 2 — Dependency Audit

Agent: security-reviewer
Skill: dependency-audit

Scan for:
- Known vulnerabilities in direct and transitive dependencies.
- Packages with no recent maintenance activity and known CVEs.
- Dependency version ranges that pin to vulnerable versions.

Limit output to the top 20 most critical findings.

## Phase 3 — Environment & Configuration Review

Agent: security-reviewer
Skill: env-consistency (when env template file exists)

Check:
- Undocumented environment variables used in code.
- Variables documented but never referenced.
- Deployment configuration exposing sensitive values.

Also review:
- CORS policy configuration.
- Authentication middleware configuration.
- Public debug or error exposure settings.

## Phase 4 — Container Security (if applicable)

Agent: devops-engineer

Check only if Dockerfile or docker-compose files exist:
- Running as root unnecessarily.
- Exposed ports that should not be public.
- Insecure base images.
- Secrets passed as build args.

Skip this phase entirely if no container configuration exists.

## Report Format

Return a single structured security report. Do not dump intermediate reasoning.

```markdown
# Security Audit Report

## Audit Scope
<what was reviewed>

## Overall Status
SAFE | WARNING | VULNERABLE

## Critical Issues
<must fix immediately>

## High Severity Issues
<must fix before next deployment>

## Medium Severity Issues
<should fix in next sprint>

## Low Severity Issues
<address when convenient>

## Remediation Plan
| Issue | Severity | Recommended Action | Effort |

## What Was Not Checked
<limitations of this audit>
```

## Hard Rules

- Never reproduce secret values. Redact all findings.
- Do not introduce security tooling automatically.
- Do not modify any files during the audit.
- Do not assume vulnerabilities without evidence from the repository.
- If a CRITICAL issue is found, escalate immediately to product-manager before continuing the audit.
- Log the audit in `docs/DECISIONS.md` when present.
