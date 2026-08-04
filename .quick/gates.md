# Gates and Readiness

> Gate definitions are static; the "Current Gate Status" table is refreshed by `@mlt-review status`.

## Gate Definitions

| Gate | Requirement | Unlock |
|------|-------------|--------|
| **profile-ready** | PROFILE.md filled with no REPLACE tokens | `@mlt-bootstrap init` |
| **assessed** | Assessment scorecard exists | `@mlt-assess run` |
| **program-active** | A program is installed and has progress | `@mlt-program-standard install - <slug>` |
| **session-open** | A session is currently in progress | `@session-mlt start` |
| **module-complete** | All exit checks for a module are met | Complete all deliverables |
| **program-complete** | All modules complete + artifacts verified | `@mlt-review status` |
| **certified** | Average drill score >= 3, no dimension at 1 | `@mlt-review certify` |

## Current Gate Status

| Gate | Status | Blocker |
|------|--------|---------|
| profile-ready | blocked | Run `@mlt-bootstrap init` |
| assessed | blocked | profile-ready required |
| program-active | blocked | assessed required |

## BLOCKED Report Format

```
BLOCKED: <skill-id>
Gate: <gate-name>
Required: <what's needed>
Unlock: @<skill> <verb>
```
