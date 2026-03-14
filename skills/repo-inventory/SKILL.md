---
name: "repo-inventory"
description: "Build or update a lightweight repository inventory covering directory structure, manifests, dependencies, scripts, tooling, and key configuration files."
allowed-tools: ["read", "search", "edit"]
---

# Repo Inventory

Use this skill to build or update `docs/INVENTORY.md` so downstream agents can understand the repository structure without exploring blindly.

This skill is structural only.
It does not read source file contents.

## Gating Policy

- Cost class: MEDIUM
- Requires an active milestone
- Skip if the fingerprint is unchanged and `docs/INVENTORY.md` already exists
- Never run on every cycle

## Hard Rules

- Maximum directory depth: 3 levels
- Maximum file reads: 10
- Read only manifests, config files, and existing documentation
- Do not read source code contents
- Exclude:
  - `node_modules/`
  - `.git/`
  - `dist/`
  - `build/`
  - `vendor/`
  - `.next/`
  - `.turbo/`
- If `docs/INVENTORY.md` exists, use incremental update mode
- Preserve any `<!-- manual -->` annotations
- If `docs/INVENTORY.md` is corrupt, discard it and rebuild from scratch

## Inventory Goals

Document:

- repository shape
- directory structure
- project surfaces
- dependency signals
- scripts
- tooling signals
- key configuration files

## What to inspect

Typical high-signal files include:

- `package.json`
- `pnpm-workspace.yaml`
- `turbo.json`
- `nx.json`
- `tsconfig.json`
- `vite.config.*`
- `astro.config.*`
- `next.config.*`
- `Dockerfile`
- `docker-compose.*`
- `.husky/*` first relevant file
- `README.md` only if needed for repo context

## Output file

Write to:

`docs/INVENTORY.md`

Append a short completion note to:

`docs/DECISIONS.md`

## Required Output Structure

# Repository Inventory

## Summary
Short overview of the repository shape.

## Repository Shape
State one of:
- Single application
- Multi-application
- Monorepo
- Hybrid

## Directory Structure
A tree view up to 3 levels deep.

## Project Surfaces
| Surface | Path | Type |
|---------|------|------|

Types may include:
- frontend
- backend
- library
- tooling
- infrastructure

## Dependency Signals
List major dependency sources and important framework/tool signals.

## Scripts
List key runnable scripts and their commands where available.

## Tooling Signals
Detect and list:
- husky
- lint-staged
- eslint
- prettier
- jest
- vitest
- playwright
- turbo
- nx

## Key Configuration Files
List important config files and their locations.

## Limitations
Record truncation, missing manifests, or uncertainty.

## Completion Rules

If no manifest is found:
- catalog directory structure only
- add a warning to `docs/INVENTORY.md`
- append a warning to `docs/DECISIONS.md`

If the repository appears to be a monorepo:
- record that explicitly
- stop traversal at 3 levels
- note truncation clearly

If incremental mode is used:
- update only changed sections
- preserve manual annotations