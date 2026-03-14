---
name: "route-mapper"
description: "Map application routes from framework routing conventions and configuration to produce a route inventory for web projects."
allowed-tools: ["read", "search", "edit"]
---

# Route Mapper

Use this skill to build a route inventory for web applications that use file-based or convention-based routing.

This skill is for route discovery only.
It does not inspect business logic or component internals.

## Purpose

Produce a route map that helps architecture, migration, documentation, and validation workflows understand the exposed route surface of the application.

## Gating Policy

- Cost class: MEDIUM
- Requires active milestone authorization
- Skip if the project is not a web project
- Skip if `docs/STACK_PROFILE.md` does not confirm a routable framework
- Skip if the fingerprint is unchanged and `docs/ROUTE_MAP.md` already exists
- Never run speculatively
- Check `.agent-cache/artifact_freshness.json` and `.agent-cache/locks/route-mapper.lock` when present before regenerating `docs/ROUTE_MAP.md`

## Supported frameworks

Use routing conventions from `docs/STACK_PROFILE.md`.

Supported routable frameworks include:

- Astro → `src/pages/`
- Next.js → `app/` or `pages/`
- Nuxt → `pages/`
- SvelteKit → `src/routes/`
- Remix → `app/routes/`

If no supported routable framework is detected, skip and log the reason.

## Hard Rules

- Scan only the route directory identified from the stack profile
- Do not scan `src/`, `lib/`, or `components/` broadly
- Maximum 50 route files enumerated
- Maximum 5 file reads for dynamic route interpretation
- Map file path to URL route
- Classify each route as:
  - page
  - api
  - middleware
  - special file
- Identify whether the route is:
  - static
  - dynamic
  - catch-all
- Flag ambiguous routing conventions, such as both `pages/` and `app/`
- Each listed route must include its source file
- If no route directory is found, write an empty route map with `confidence = LOW`
- If more than 50 route files are detected, list the first 50 and note truncation clearly

## Special file handling

Recognize and classify framework-specific special files where applicable, such as:

- layout files
- loading files
- error files
- not-found files
- middleware
- route handlers

Do not treat all special files as user-facing pages.

## Output file

Write results to:

`docs/ROUTE_MAP.md`

Append a short completion note to:

`docs/DECISIONS.md`

## Required Output Structure

# Route Map

## Summary
Short overview of the routed application surface.

## Framework
Detected framework and route directory used.

## Confidence
HIGH | MEDIUM | LOW

## Route Counts
- total route files detected
- total routes listed
- truncation: yes/no

## Page Routes
| URL Route | Type | Dynamic | Source File |

## API Routes
| URL Route | Type | Dynamic | Source File |

## Middleware and Special Files
| File | Classification | Source File |

## Ambiguities
List conflicting routing conventions or unclear cases.

## Limitations
Document truncation, missing route directories, or unsupported conventions.

## Completion Rules

If no routes are found:
- still write `docs/ROUTE_MAP.md`
- mark confidence as LOW
- explain why

If ambiguous routing is detected:
- record the ambiguity explicitly
- do not guess a preferred convention without evidence
