# Next Action

**Recommended next:** Smoke-test the new verbs in this repo — `@mlt-session context` (read-only) and `@mlt-session status`.
**Reason:** The mlt-session rewrite (session-control parity + repo-context commit scope) is committed and verified statically; a live run of the read-only modes confirms the report templates render against real state.

## Queue

1. `@mlt-session context` — expect full context report, no writes
2. `@mlt-session status` — expect compact snapshot, tree clean
3. To resume the training pipeline: `@mlt-bootstrap init` → fill PROFILE → `@mlt-assess run`
