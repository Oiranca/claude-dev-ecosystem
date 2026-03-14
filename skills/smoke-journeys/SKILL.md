---
name: "smoke-journeys"
description: "Run lightweight end-to-end smoke checks against a running dev or preview server to catch critical route regressions."
allowed-tools: ["read", "execute", "edit"]
---

# Smoke Journeys

Use this skill to run lightweight runtime smoke checks against a dev or preview server after a successful build.

This skill validates critical route availability and basic runtime health.
It does not perform deep browser automation.

## Purpose

Catch regressions that static checks may miss by validating a small set of critical routes against a live local server.

## Gating Policy

- Cost class: EXPENSIVE
- Requires explicit playbook justification naming this skill
- Skip if no code changes were made
- Skip if no web routes exist
- Skip if build did not pass
- Never run on every cycle
- Never run before a successful build
- Check `.agent-cache/skill_budget_state.json` when present before starting another high-cost specialized validation in the same cycle
- Respect `.agent-cache/locks/qa.lock` when present before starting overlapping smoke validation

## Required inputs

Read only:

- `.agent-cache/AGENT_STATE.json`
- `docs/STACK_PROFILE.md`
- `docs/ROUTE_MAP.md`
- `docs/QA_REPORT.md`

Do not read source files.

## Preconditions

Before running smoke checks:

- `docs/QA_REPORT.md` must show `build = PASS`
- `docs/ROUTE_MAP.md` must exist
- `docs/STACK_PROFILE.md` must provide a dev or preview run command

If any precondition fails:
- skip the skill
- record the reason
- append the reason to `docs/DECISIONS.md`

## Server startup policy

- Start the dev or preview server as a background process
- Use the run command from `docs/STACK_PROFILE.md`
- Wait up to 60 seconds for readiness
- Preferred readiness strategy:
  1. successful HTTP response from the root route
  2. successful HTTP response from a known route
  3. confirmed listening server process

If the server does not become ready within 60 seconds:
- kill the process
- mark the run as `BLOCKED`
- stop execution

The server process must always be terminated, even on failure.

## Route selection policy

Select at most 10 routes total from `docs/ROUTE_MAP.md`.

Priority order:
1. homepage
2. primary navigation pages
3. important static pages
4. resolvable dynamic routes
5. API endpoints, only if explicitly useful for runtime verification

Maximum total requests: 20

If a route is dynamic but no concrete testable path is available:
- skip it
- record the limitation

## Route validation rules

For each selected route, record:

- URL
- classification
- HTTP status
- response size
- result

A route passes if:
- HTTP status is 200
- response is not empty
- no obvious error indicators appear

Basic error indicators include:
- `500`
- `Internal Server Error`
- stack trace signatures
- framework error overlays if easily detectable

Do not parse HTML deeply.
Do not take screenshots.
Do not run browser automation.

## Result classification

Each checked route must be classified as:

- PASS
- FAIL
- BLOCKED
- SKIP

### PASS
Route returned a healthy response.

### FAIL
Route responded but showed error behavior.

### BLOCKED
Server startup failed or the test could not run.

### SKIP
Route was not testable under current constraints.

## Output

Write results to:

`docs/SMOKE_REPORT.md`

Append a short decision entry to:

`docs/DECISIONS.md`

## Required Output Structure

# Smoke Report

## Summary
Short overview of the smoke run.

## Server Startup
| Command | Result | Notes |

## Selected Routes
| URL | Classification | Reason Selected |

## Route Results
| URL | Status | Response Size | Result |

## Blocked or Skipped Routes
| URL | Reason |

## Overall Result
PASS | PARTIAL | FAIL | BLOCKED

## Limitations
List skipped dynamic routes, startup uncertainty, or request truncation.

## Completion Rules

If server startup fails:
- mark all journeys as `BLOCKED`
- stop immediately
- append a critical note to `docs/DECISIONS.md`

If all tested routes fail:
- mark overall result as `FAIL`
- append a critical note to `docs/DECISIONS.md`

If at least one critical route passes and no blocking startup issue exists:
- record partial or full success accordingly
