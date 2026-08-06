---
name: mlt-bootstrap
description: "Scaffold .training.mlt/ directories and drive PROFILE intake interview to capture learner background and goals."
---

# mlt-bootstrap — scaffold and intake

## Modes

| Mode | Invocation | Effect |
|------|-----------|--------|
| init | `@mlt-bootstrap init` | Create `.training.mlt/` tree and run PROFILE interview |
| status | `@mlt-bootstrap status` | Report what exists under `.training.mlt/` |

## Parse

```text
@mlt-bootstrap init [--force]
@mlt-bootstrap status
```

- `--force`: recreate skeleton even if directories exist (preserves existing files)

## Steps — init mode

1. Check if `.training.mlt/` already exists
   - If present and populated, report status and ask user before re-initializing
2. Create directory tree (the mechanical scaffold is `templates/bootstrap.sh` — prefer running it from the source framework over recreating directories by hand, so the layout stays single-sourced):
   - `.training.mlt/context/`
   - `.training.mlt/plans/`
   - `.training.mlt/programs/`
   - `.training.mlt/sessions/`
   - `.training.mlt/sources/`
   - `.training.mlt/labs/`
   - `.training.mlt/tutorials/`
   - `.training.mlt/drills/`
   - `.training.mlt/exports/`
   - `.quick/` (operator cheat sheets at the project root)
3. Create `PROFILE.md` in `.training.mlt/context/` from `templates/training/PROFILE.md` if not present
4. Create `HANDOFF.md` in `.training.mlt/context/` from `templates/training/HANDOFF.md`
5. Create `NEXT.md` in `.training.mlt/plans/` from `templates/training/NEXT.md`
6. Create `UNKNOWNS.md` in `.training.mlt/plans/` from `templates/training/UNKNOWNS.md`
7. Drive the PROFILE intake interview by asking the learner:
   - Programming experience (years, languages, projects)
   - Python level (syntax, OOP, libraries, advanced patterns)
   - ML/DL/LLM experience (courses taken, models trained, tools used)
   - Math background (algebra, calculus, linear algebra, probability, optimization)
   - Hardware available (GPU model and VRAM, RAM, disk)
   - Learning preferences (video, reading, hands-on, pair programming)
   - Primary goal (what they want to achieve with ML/LLM training)
   - Time commitment (hours per week, session frequency)
8. Write answers into `.training.mlt/context/PROFILE.md`
9. Initialize `NEXT.md` with: "Run `@mlt-assess run` to diagnose your level"

## Steps — status mode

1. List each directory under `.training.mlt/` and report:
   - exists / missing
   - file count
   - PROFILE completeness (filled / partial / empty)

## Completion criteria

- All directories under `.training.mlt/` exist
- `PROFILE.md` contains learner answers across all 8 interview dimensions
- `HANDOFF.md` and `NEXT.md` exist with initial content
- Status report confirms scaffold integrity
