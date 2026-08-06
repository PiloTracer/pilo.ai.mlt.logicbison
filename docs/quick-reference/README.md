# Quick reference — MLT recipes

Copy-paste starting points for the three things people generate most: **programs**, **tutorials**, and **quick lessons** (labs/drills/sessions). Run these inside your *target project* (where `.work.mlt/` lives), talking to your AI agent.

| File | Contents |
|------|----------|
| [`recipes-programs.md`](recipes-programs.md) | Install catalog programs, design custom ones — 8 ready prompts |
| [`recipes-tutorials.md`](recipes-tutorials.md) | Generate written and video tutorials — 10 ready prompts |
| [`recipes-quick-lessons.md`](recipes-quick-lessons.md) | 30-minute lessons, labs, drills, sessions — 10 ready prompts |

## The two invocation styles

Every skill accepts both:

```text
@mlt-tutorial generate - attention-mechanism --level beginner    # exact form
@mlt-director - write me a short tutorial about attention        # free text, director routes it
```

When in doubt, use `@mlt-director - <plain language>` — it picks the skill, checks prerequisites, and tells you what it dispatched.

## Golden rules

1. **One target project** — all artifacts land in that project's `.work.mlt/`; the agent never scatters them elsewhere
2. **Open/close sessions** — `@mlt-session start` / `close` keep your history coherent (one log per session, `YYYY-MM-DD_<topic>.md`)
3. **Trust the gates** — a BLOCKED report is a checklist, not an error; run the `unlock` line and retry
