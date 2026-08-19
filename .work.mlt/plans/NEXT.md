# Next Action

**Recommended next:** `@mlt-session status` — completes the read-only smoke-test queue (`context` verified 2026-08-19).
**Reason:** v0.6.1 is released; the only outstanding framework check is the compact `status` snapshot. Everything else is verified green.

## Queue

1. `@mlt-session status` — expect compact snapshot, tree clean
2. To resume the training pipeline: `@mlt-bootstrap init` → fill PROFILE → `@mlt-assess run`
