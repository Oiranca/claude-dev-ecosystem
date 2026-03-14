---
name: "fingerprint"
description: "Detect repository changes using a git-first fingerprint strategy and classify them as none, non-material, or material to control downstream agent execution."
allowed-tools: ["read", "execute", "edit"]
---

# Fingerprint

Use this skill as the mandatory first step of every cycle.

Its job is to detect whether the repository changed in a meaningful way and decide whether downstream agents should run.

This skill does not analyze code.
It only detects and classifies change.

## Gating Policy

- Cost class: CHEAP
- Always run at the beginning of every cycle
- Never skip
- No authorization needed
- If `.agent-cache/AGENT_STATE.json` is missing or corrupt, run anyway and rebuild state

## Primary goal

Update:

- `.agent-cache/AGENT_STATE.json`

Append a short decision entry to:

- `docs/DECISIONS.md`

## Detection strategy

Use a git-first working-tree strategy.

Preferred commands:

1. `git diff --name-only --cached`
2. `git diff --name-only`
3. `git ls-files --others --exclude-standard`

Combine results to detect:
- staged files
- unstaged files
- untracked files

If git is unavailable, the repo is not a git repository, git commands fail, or changed file count exceeds 200, use legacy fallback mode.

## Change classification

Classify the cycle as one of:

- `none`
- `non-material`
- `material`

### none
No changed files detected.

Behavior:
- stop downstream execution
- return exit code 2
- set `material_change = false`

### non-material
Changed files detected, but none match material patterns.

Behavior:
- allow downstream execution with limited scope
- set `material_change = false`

### material
At least one changed file matches material patterns, or legacy fallback is used.

Behavior:
- allow full downstream execution
- set `material_change = true`

## Material file categories

Treat these as material signals.

### Dependency and package signals
- `package.json`
- lockfiles
- workspace manifests

### Build and stack signals
- `tsconfig.*`
- `astro.config.*`
- `vite.config.*`
- `next.config.*`
- `nuxt.config.*`
- `svelte.config.*`

### Container and runtime signals
- `Dockerfile`
- `docker-compose.*`

### Deployment signals
- `netlify.toml`
- `vercel.json`
- `.github/workflows/*`

### App surface signals
- `src/pages/**`
- `src/routes/**`
- `app/**`

## Fingerprint generation

For changed files only:

- prioritize material files first
- hash at most 15 files
- hash raw bytes only
- do not parse file contents
- sort file hashes
- concatenate them
- compute a final SHA-256 fingerprint

Deleted files should still count as changes and should be recorded in `changed_files`.

## Legacy fallback mode

Use fallback mode if:
- not inside a git repository
- git commands fail
- changed file count exceeds 200

Fallback behavior:
- use legacy 15 high-signal files
- treat all fallback detections as material
- set `detection_mode = "legacy-fallback"`

Otherwise set:

- `detection_mode = "git-working-tree"`

## State file behavior

Read only:

- `.agent-cache/AGENT_STATE.json`

Do not read source files for context.

If `.agent-cache/AGENT_STATE.json` is corrupt JSON:
- delete it
- treat the cycle as first run

If `docs/` does not exist:
- create it

If a file cannot be hashed due to permissions:
- skip that file
- continue
- record the limitation

## Required state output

Write the following fields to `.agent-cache/AGENT_STATE.json`:

- `fingerprint`
- `previous_fingerprint`
- `cycle_count`
- `last_run`
- `material_change`
- `change_type`
- `detection_mode`
- `changed_files`
- `files_hashed`

## Console output rules

Print only short structured summary lines:
- changed files count
- change type
- material change yes/no
- fingerprint hash

Do not print inline code.
Do not print verbose debug output.

## Completion rules

If `change_type = "none"`:
- stop downstream execution
- return exit code 2
- log the skip in `docs/DECISIONS.md`

If `change_type = "non-material"`:
- continue with limited downstream scope
- log the reduced-scope path in `docs/DECISIONS.md`

If `change_type = "material"`:
- continue with full downstream evaluation
- log the full path in `docs/DECISIONS.md`