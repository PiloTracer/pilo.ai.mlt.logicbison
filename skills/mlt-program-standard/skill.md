---
name: mlt-program-standard
description: "Install catalog program — lists available programs in curricula/, copies selected program to .training.mlt/programs/, creates progress.md and notes.md."
---

# mlt-program-standard — install catalog program

## Modes

| Mode | Invocation | Effect |
|------|-----------|--------|
| list | `@mlt-program-standard list` | Show all available programs |
| install | `@mlt-program-standard install - <slug>` | Install a program into learner memory |

## Parse

```text
@mlt-program-standard list [--level <beginner|intermediate|advanced>]
@mlt-program-standard install - <slug> [--force]
```

- `<slug>`: program identifier (e.g., `ml-foundations`, `llm-finetuning`)
- `--force`: reinstall even if program already exists in `.training.mlt/programs/`

## Binding standard

Follow `standards/program-spec.md` for program structure requirements.

## Steps — list mode

1. Read all `.md` files in `curricula/`
2. Parse metadata from each: slug, name, level, duration, prerequisites
3. Check `.training.mlt/programs/` for already-installed programs
4. Render table:

```text
| Slug | Name | Level | Duration | Installed |
|------|------|-------|----------|-----------|
| ml-foundations | ML Foundations | Beginner | 4 weeks | yes |
| llm-finetuning | LLM Fine-tuning | Adv | 6 weeks | no |
```

## Steps — install mode

1. Read `.training.mlt/context/PROFILE.md` to confirm learner context
2. Read `.training.mlt/context/SCORECARD.md` if it exists
3. Validate `<slug>` exists in `curricula/<slug>.md`
   - If not found, list available slugs and stop
4. Check if `.training.mlt/programs/<slug>/` already exists
   - If yes and `--force` not set, stop and report
5. Create `.training.mlt/programs/<slug>/`
6. Copy `curricula/<slug>.md` to `.training.mlt/programs/<slug>/PROGRAM.md`
7. Annotate PROGRAM.md with learner-specific notes from PROFILE
8. Create `progress.md` with task ledger:
   - One row per module with columns: Module, Status, Lab, Score, Notes
   - All statuses initialized to `[ ]` (pending)
9. Create `notes.md` with:
   - Empty retrieval queue section
   - Concepts-to-revisit section (populated during mentoring)
10. Update `.training.mlt/plans/NEXT.md` with the first module of the installed program
11. Report: program installed, module count, first module name

## Completion criteria

- `.training.mlt/programs/<slug>/PROGRAM.md` exists with learner annotations
- `progress.md` has a complete task ledger with all modules listed
- `notes.md` exists with retrieval queue section
- NEXT.md points to the first module
