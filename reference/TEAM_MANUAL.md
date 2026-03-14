# Copilot CLI Multi-Agent System — User Manual

Location:

the plugin directory/COPILOT_TEAM_MANUAL.md

This file documents how the global Claude Code multi-agent environment works.

It describes the structure, responsibilities, and workflow of the agent system used by Claude Code.

This is a **global configuration document** and should not be copied into project repositories.

---

# Purpose of this Document

This manual exists for two audiences:

1. Humans configuring or maintaining the Claude Code multi-agent system.
2. Agents that need to understand how the system is structured.

It explains:

- how agents collaborate
- how skills are used
- how playbooks guide execution
- how guardrails enforce safe behavior
- how repository knowledge artifacts persist information across cycles

---

# 1. System Overview

Your Copilot environment is organized as a **multi-agent system** where each agent has a specialized role.

High-level workflow:

User request  
↓  
product-manager  
↓  
analysis agents  
(stack-analyzer + repo-analyzer)  
↓  
solution-architect  
↓  
software-engineer  
↓  
qa-engineer + security-reviewer  
↓  
tech-writer

Agents use several shared system components:

skills → reusable capabilities  
playbooks → execution flows  
guardrails → operational rules  
policies → system execution policies  
docs/ → repository knowledge  
.agent-cache/ → runtime state

Operational rules are defined in:

- GUARDRAILS.md
- GUARDRAILS_REFERENCE.md
- BUDGETS.md

---

# 2. Folder Architecture

Global configuration lives in:

the plugin directory/

Main folders:

agents/  
skills/  
commands/  
policies/  
templates/  
mcp/  
scripts/

Important global files:

GUARDRAILS.md  
GUARDRAILS_REFERENCE.md  
BUDGETS.md  
README.md  
USAGE.md  
COPILOT_TEAM_MANUAL.md  

These files define how the Claude Code multi-agent system behaves globally.

---

# 3. Repository Knowledge Files

Each repository using this system maintains knowledge artifacts inside:

docs/

Typical artifacts:

docs/DECISIONS.md  
docs/STACK_PROFILE.md  
docs/INVENTORY.md  
docs/ARCHITECTURE.md  
docs/QA_REPORT.md  
docs/SECURITY_REPORT.md  
docs/ROUTE_MAP.md  

Purpose of these artifacts:

STACK_PROFILE  
Detected stack and framework information.

INVENTORY  
Repository file and component inventory.

ARCHITECTURE  
System structure and module boundaries.

QA_REPORT  
Validation results produced by QA agents.

SECURITY_REPORT  
Security findings and risk analysis.

DECISIONS  
Chronological engineering decisions.

These documents allow agents to avoid rediscovering the repository every cycle.

---

# 4. Runtime Cache

Runtime data lives in:

.agent-cache/

Examples:

.agent-cache/AGENT_STATE.json  
.agent-cache/MCP_TOOL_CACHE.json  
.agent-cache/artifact_freshness.json  
.agent-cache/skill_budget_state.json  
.agent-cache/locks/  
.agent-cache/last-run/  

These files:

- track execution cycles
- manage skill budgets
- store artifact freshness metadata
- manage execution locks

Runtime cache should **never be committed to git**.

---

# 5. Guardrails

Operational rules are defined in:

GUARDRAILS.md

Key rules include:

- one milestone per cycle
- documentation-first workflow
- avoid repeating expensive skills
- never modify unrelated files
- never expose secrets
- follow the validation ladder

Validation ladder:

1. targeted-test-runner  
2. ci-checks  
3. smoke-journeys  

This escalation pattern keeps validation predictable and cost-aware.

---

# 6. Agents

Your system includes the following agents:

product-manager  
Orchestration and milestone planning.

stack-analyzer  
Stack detection and framework analysis.

repo-analyzer  
Repository inventory and structural analysis.

solution-architect  
Architecture planning and module boundaries.

software-engineer  
Implementation of approved milestones.

qa-engineer  
Validation and testing.

devops-engineer  
CI/CD and infrastructure-related tasks.

security-reviewer  
Security analysis and risk detection.

tech-writer  
Documentation updates.

pr-comment-responder  
Handles pull request review comments.

migration-engineer  
Framework and architecture migrations.

Each agent has a clearly defined role and should avoid expanding scope beyond its responsibility.

---

# 7. Skills

Skills represent reusable capabilities used by agents.

Core skills:

fingerprint  
stack-detection  
repo-inventory  
code-search  

QA skills:

ci-checks  
smoke-journeys  
targeted-test-runner  

Security skills:

env-consistency  
secret-scan-lite  

Migration skills:

react-vite-to-astro  

Skills allow agents to perform specialized analysis without embedding that logic inside the agents themselves.

---

# 8. Playbooks

Playbooks define execution flows depending on repository type.

Examples:

EXISTING_REPO  
NEW_PROJECT  
UNKNOWN_STACK  
MIGRATION_REACT_VITE_TO_ASTRO  

Playbooks guide how agents collaborate and determine the correct sequence of operations.

---

# 9. Validation Helper

Local validation is handled by:

scripts/validate-local.sh

Validation order:

lint  
typecheck  
test  
coverage  
build  

Only scripts present in package.json are executed.

The validation script:

- never commits changes
- never pushes to remote
- never opens pull requests
- respects git hooks such as husky

---

# 10. Legacy Compatibility

Legacy helpers remain available but are not the primary workflow.

Examples:

scripts/autopilot.sh  
scripts/optional/autopilot-ship.sh  
agent-ask  
agent-run  

The primary workflow is now:

Claude Code + agents.

---

# 11. First-Time Setup for a Repository

Bootstrap a repository with:

bash the plugin directory/scripts/agent-init

This creates:

docs/  
.agent-cache/  

and initializes minimal knowledge artifacts.

---

# 12. Recommended Workflow

Typical workflow when working inside a repository:

Step 1 — Understand repository

product-manager  
stack-analyzer  
repo-analyzer  

Step 2 — Plan architecture

solution-architect  

Step 3 — Implement changes

software-engineer  

Step 4 — Validate

qa-engineer  

Step 5 — Security review

security-reviewer  

Step 6 — Update documentation

tech-writer  

---

# 13. Best Practices

Keep tasks small.

Prefer:

- small milestones
- clear objectives
- single responsibility

Avoid rewriting entire repositories unless explicitly performing a migration.

Use repository docs as persistent memory.

Agents rely heavily on:

docs/STACK_PROFILE.md  
docs/INVENTORY.md  
docs/ARCHITECTURE.md  

Updating these improves future runs.

Avoid repeating expensive analysis when artifacts are fresh.

Use validation early and frequently when implementing changes.

---

# 14. Example Prompts for Copilot CLI

Prompt 1 — Analyze the repository

Act as the product-manager agent.

Your goal is to understand the repository and coordinate initial analysis.

Steps:

1. Run stack-analyzer to detect the stack.
2. Run repo-analyzer to build the repository inventory.
3. Ensure docs/STACK_PROFILE.md and docs/INVENTORY.md are created or updated.
4. Summarize the system structure and main components.

---

Prompt 2 — Detect architecture boundaries

Act as solution-architect.

Using docs/STACK_PROFILE.md and docs/INVENTORY.md:

1. Identify major architectural components.
2. Define module boundaries.
3. Generate docs/ARCHITECTURE.md describing the system structure.
4. Highlight potential architectural risks.

---

Prompt 3 — Detect technical debt

Act as solution-architect.

Analyze the repository for:

- architectural drift
- outdated patterns
- duplicated logic
- missing boundaries

Update docs/ARCHITECTURE.md with a "Technical Debt" section.

---

Prompt 4 — Generate repository documentation

Act as tech-writer.

Your goal is to improve repository documentation.

Tasks:

1. Review docs/STACK_PROFILE.md, docs/INVENTORY.md, and docs/ARCHITECTURE.md.
2. Generate a clear README explaining:
   - project purpose
   - architecture
   - main components
   - how to run the project

---

Prompt 5 — Implement a small feature

Act as software-engineer.

Before writing code:

1. Review docs/ARCHITECTURE.md.
2. Confirm which module should contain the feature.

Then:

3. Implement the feature with minimal changes.
4. Avoid touching unrelated files.
5. Prepare the system for QA validation.

---

Prompt 6 — Run QA validation

Act as qa-engineer.

Your goal is to validate the repository.

Steps:

1. Run lint, typecheck, test, and build if available.
2. Generate docs/QA_REPORT.md summarizing results.
3. If failures occur, include failure summaries and affected files.

---

Prompt 7 — Security scan

Act as security-reviewer.

Perform a security audit focusing on:

- exposed secrets
- unsafe environment variables
- dependency risks
- insecure API usage

Write results to docs/SECURITY_REPORT.md.

---

Prompt 8 — Fix PR review comments

Act as pr-comment-responder.

Your goal is to address pull request comments.

Steps:

1. Read each comment carefully.
2. Determine whether code or documentation changes are required.
3. Apply minimal fixes.
4. Update documentation if necessary.

---

Prompt 9 — Plan a migration

Act as migration-engineer.

Plan migration from React + Vite to Astro.

Steps:

1. Analyze current component structure.
2. Identify reusable components.
3. Identify parts that must be rewritten.
4. Produce docs/MIGRATION_PLAN.md describing the migration strategy.

---

Prompt 10 — Investigate a bug

Act as software-engineer.

Goal: diagnose a bug without introducing unrelated changes.

Steps:

1. Locate the responsible module.
2. Trace the code path producing the issue.
3. Identify root cause.
4. Propose the minimal fix.
5. Update tests if necessary.

---

# 15. Long-Term Usage Strategy

Recommended pattern when working with this system:

1. Analyze the repository
2. Plan architecture
3. Implement the feature
4. Validate changes
5. Document results

Following this sequence keeps the system stable, predictable, and scalable even in large repositories.