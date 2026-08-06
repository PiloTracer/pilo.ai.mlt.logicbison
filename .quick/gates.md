# Gates and Readiness

> Gate definitions are static; the "Current Gate Status" table is refreshed by `@mlt-review status`.

## Gate Definitions

| Gate | Requirement | Unlock |
|------|-------------|--------|
| **profile-ready** | PROFILE.md filled with no REPLACE tokens | `@mlt-bootstrap init` |
| **assessed** | Assessment scorecard exists | `@mlt-assess run` |
| **program-active** | A program is installed and has progress | `@mlt-program-standard install - <slug>` or `@mlt-program-custom - <request>` |
| **session-open** | A session is currently in progress | `@session-mlt start` |
| **module-complete** | All exit checks for a module are met | Complete all deliverables |
| **program-complete** | All modules complete + labs artifact-verified | `@mlt-review status` |
| **certified** | program-complete + average drill score >= 3, no dimension at 1 | `@mlt-review certify` |

## Current Gate Status

> One row per defined gate; refreshed by `@mlt-review status`.

| Gate | Status | Blocker |
|------|--------|---------|
| profile-ready | blocked | Run `@mlt-bootstrap init` |
| assessed | blocked | profile-ready required |
| program-active | blocked | assessed required |
| session-open | blocked | run `@session-mlt start` |
| module-complete | blocked | program-active required |
| program-complete | blocked | all module-complete required |
| certified | blocked | program-complete required |

## BLOCKED Report Format

Canonical format (identical to `skills/SKILL_DEPENDENCIES.md`):

```
BLOCKED: <skill-name> <verb>
  reason: <short reason>
  missing: <list of missing prerequisites>
  unlock: <command or action to resolve>
```
