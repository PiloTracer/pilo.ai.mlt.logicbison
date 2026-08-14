---
name: mlt-bootstrap
description: "Scaffold .work.mlt/ directories and drive PROFILE intake interview to capture learner background and goals."
---

# mlt-bootstrap — scaffold and intake

> **Close:** operator-facing reports end per the **Operator handoff contract** (`skills/SKILL_DEPENDENCIES.md`) — Form A (`Next: nothing - …`) or Form B (`**Needs your approval:**` / `**Needs your answer:**` / `**Next step:**`).
> **Docs:** generated documents follow the **Document clarity contract** (`skills/SKILL_DEPENDENCIES.md`) — Status/Needs header, separate Decisions / Open questions lists, exactly one `## Next action`, no leftover scaffolding.

## Modes

| Mode | Invocation | Effect |
|------|-----------|--------|
| init | `@mlt-bootstrap init` | Create `.work.mlt/` tree and run PROFILE interview |
| status | `@mlt-bootstrap status` | Report what exists under `.work.mlt/` |

## Parse

```text
@mlt-bootstrap init [--force]
@mlt-bootstrap status
```

- `--force`: recreate skeleton even if directories exist (preserves existing files)

## Steps — init mode

1. Check if `.work.mlt/` already exists
   - If present and populated, report status and ask user before re-initializing
2. Create directory tree (the mechanical scaffold is `templates/bootstrap.sh` — prefer running it from the source framework over recreating directories by hand, so the layout stays single-sourced):
   - `.work.mlt/context/`
   - `.work.mlt/plans/`
   - `.work.mlt/programs/`
   - `.work.mlt/sessions/`
   - `.work.mlt/sources/`
   - `.work.mlt/labs/`
   - `.work.mlt/tutorials/`
   - `.work.mlt/drills/`
   - `.work.mlt/exports/`
   - `.quick/` (operator cheat sheets at the project root)
3. Create `PROFILE.md` in `.work.mlt/context/` from `templates/training/PROFILE.md` if not present
4. Create `HANDOFF.md` in `.work.mlt/context/` from `templates/training/HANDOFF.md`
5. Create `NEXT.md` in `.work.mlt/plans/` from `templates/training/NEXT.md`
6. Create `UNKNOWNS.md` in `.work.mlt/plans/` from `templates/training/UNKNOWNS.md`
7. Drive the PROFILE intake interview by asking the learner:
   - Programming experience (years, languages, projects)
   - Python level (syntax, OOP, libraries, advanced patterns)
   - ML/DL/LLM experience (courses taken, models trained, tools used)
   - Math background (algebra, calculus, linear algebra, probability, optimization)
   - Hardware available (GPU model and VRAM, RAM, disk)
   - Learning preferences (video, reading, hands-on, pair programming)
   - Primary goal (what they want to achieve with ML/LLM training)
   - Time commitment (hours per week, session frequency)
8. Write answers into `.work.mlt/context/PROFILE.md`
9. Initialize `NEXT.md` with: "Run `@mlt-assess run` to diagnose your level"

## Steps — status mode

1. List each directory under `.work.mlt/` and report:
   - exists / missing
   - file count
   - PROFILE completeness (filled / partial / empty)

## Completion criteria

- All directories under `.work.mlt/` exist
- `PROFILE.md` contains learner answers across all 8 interview dimensions
- `HANDOFF.md` and `NEXT.md` exist with initial content
- Status report confirms scaffold integrity
