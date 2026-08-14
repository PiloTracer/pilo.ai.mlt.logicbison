# Next Action

**Recommended next:** Commit the framework changes from the mlt-session parity work (outside `.work.mlt/` scope, intentionally left uncommitted by the session commit).
**Reason:** Session close only stages `.work.mlt/`; the skill rewrite and registry syncs are framework files awaiting a separate, user-driven commit.

## Queue

1. Commit framework files (`.cursorrules`, `CHANGELOG.md`, `PROCESS_ROUTER.md`, `START_HERE.md`, `skills/`, `templates/`) with a `feat:` message
2. Optional: smoke-test the new verbs — `@mlt-session context` (read-only) and `@mlt-session status`
3. To resume the training pipeline: `@mlt-bootstrap init` → fill PROFILE → `@mlt-assess run`
