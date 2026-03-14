---
name: "targeted-test-runner"
description: "Run a focused subset of tests related to recently changed files to validate behavior quickly."
allowed-tools: ["read", "execute", "edit"]
---

# Targeted Test Runner

Use this skill to execute a focused subset of tests related to files changed in the current cycle.

This skill helps validate changes quickly without running the entire test suite.

## Purpose

Validate behavior changes by running tests that are likely affected by the modified files.

Prefer this skill before running full project test suites.

## Gating Policy

- Cost class: MEDIUM
- Skip if no code files changed
- Skip if no test framework detected in `docs/STACK_PROFILE.md`
- Skip if fingerprint unchanged
- Never run before code implementation

## Required Inputs

Read only:

- `.agent-cache/AGENT_STATE.json`
- `docs/STACK_PROFILE.md`
- `docs/INVENTORY.md`

Do not read full source files unless necessary.

## Test Framework Detection

Supported test frameworks include:

- Jest
- Vitest
- Mocha
- Pytest
- Go test
- Cargo test

Use commands from `docs/STACK_PROFILE.md`.

## Changed File Detection

Determine changed files using:

- fingerprint state
- current cycle changes

Focus on:

- application code
- API handlers
- route handlers
- libraries
- utilities

Ignore:

- documentation files
- configuration-only changes unless tests depend on them

## Test Discovery Strategy

Attempt to find tests related to changed files using:

1. Same directory test files
2. Adjacent `*.test.*` or `*.spec.*` files
3. Test folders referencing the module
4. Framework-specific test discovery patterns

Limit:

- Maximum 10 test files executed
- Maximum runtime per command: 5 minutes

## Execution Rules

- Run tests only for discovered files
- Continue running tests even if earlier tests fail
- Capture only the first 50 lines of failure output

If targeted execution is not supported by the detected test framework:

- fall back to running a minimal subset of tests
- or skip with explanation

## Result Classification

Each test execution must be classified as:

- PASS
- FAIL
- SKIP
- TIMEOUT

### PASS
Tests completed successfully.

### FAIL
Tests failed with assertion or runtime errors.

### SKIP
No relevant tests discovered.

### TIMEOUT
Test execution exceeded 5 minutes.

## Output

Write results to:

`docs/TEST_REPORT.md`

Append summary entry to:

`docs/DECISIONS.md`

## Required Output Structure

# Targeted Test Report

## Summary
Short overview of targeted test run.

## Changed Files
| File | Reason |

## Selected Tests
| Test File | Discovery Method |

## Test Results
| Test File | Result | Notes |

## Failures
| Test File | Error Snippet |

Include only first 50 lines of output.

## Limitations
Document skipped tests, discovery issues, or framework limitations.

## Completion Rules

If no tests are discovered:
- mark result as SKIP
- document discovery limitations

If tests fail:
- record failures
- do not attempt fixes

If tests pass:
- mark the change as validated for the tested scope