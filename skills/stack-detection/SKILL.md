---
name: "stack-detection"
description: "Identify the repository technology stack using configuration and manifest files and produce a structured stack profile with evidence."
allowed-tools: ["read", "search", "edit"]
---

# Stack Detection

Use this skill to identify the repository technology stack using configuration and manifest files.

This skill does not analyze source code.
It only reads configuration and manifest files.

## Purpose

Produce a structured stack profile describing:

- language
- framework
- runtime
- bundler
- package manager
- tooling signals
- deployment indicators
- run commands

## Gating Policy

- Cost class: CHEAP
- Runs after `fingerprint`
- Skip if `material_change = false`
- Skip if `docs/STACK_PROFILE.md` exists and fingerprint unchanged
- Never run without fingerprint completing first

## Hard Rules

- Maximum files read: 15
- Only read configuration or manifest files
- Never read source directories (`src/`, `lib/`, `components/`)
- Never infer technologies without file evidence
- Every detection must cite its source file
- Stop reading files once 15 files are processed

## File priority order

1. `package.json`
2. `pnpm-workspace.yaml`
3. `tsconfig.json`
4. `astro.config.*`
5. `vite.config.*`
6. `next.config.*`
7. `nuxt.config.*`
8. `angular.json`
9. `svelte.config.*`
10. `turbo.json`
11. `nx.json`
12. `Dockerfile`
13. `docker-compose.yml`
14. `.github/workflows/*.yml` (first match)
15. `netlify.toml` or `vercel.json`
16. `pyproject.toml` or `requirements.txt`
17. `Cargo.toml`
18. `go.mod`

Stop after 15 files.

## Detection targets

Extract signals for:

- language
- framework
- runtime
- bundler
- styling tools
- package manager
- testing framework
- deployment platform
- build tooling

## Package manager detection

Detect:

- npm
- yarn
- pnpm
- bun
- pip
- cargo
- go modules

Evidence must come from manifest files.

## Run command extraction

Detect run commands for:

- dev
- build
- test
- lint

Primary source:

- `package.json` scripts

Fallback sources:

- Makefile
- CI workflow commands

## Confidence rules

Confidence levels:

- HIGH → 3+ independent evidence signals
- MEDIUM → 1–2 evidence signals
- LOW → weak or conflicting signals

If conflicting framework signals appear:

- mark detection as `CONFLICTING`
- set confidence = LOW
- list both sources

## Detection mode

Record detection mode as one of:

- `config-evidence`
- `partial-detection`
- `conflicting`

## Output

Write results to:
