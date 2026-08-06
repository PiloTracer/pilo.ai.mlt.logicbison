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
4. Check prerequisites declared in `curricula/<slug>.md` metadata:
   - For each prerequisite program, check whether it is installed under `.training.mlt/programs/` and whether it is complete (`CERTIFICATE.md` present or all exit criteria met)
   - If any prerequisite is missing or incomplete, warn the learner, name the gap, and ask for explicit confirmation before installing (or recommend the prerequisite program first). Install anyway only with `--force` or explicit confirmation
5. Check if `.training.mlt/programs/<slug>/` already exists
   - If yes and `--force` not set, stop and report
6. Create `.training.mlt/programs/<slug>/`
7. Copy `curricula/<slug>.md` to `.training.mlt/programs/<slug>/PROGRAM.md`
8. Annotate PROGRAM.md with learner-specific notes from PROFILE
9. Create `progress.md` with task ledger:
   - One row per module with columns: Module, Status, Lab, Score, Notes
   - All statuses initialized to `[ ]` (pending)
10. Create `notes.md` with:
    - Empty retrieval queue section
    - Concepts-to-revisit section (populated during mentoring)
11. Update `.training.mlt/plans/NEXT.md` with the first module of the installed program
12. Report: program installed, module count, first module name

## Completion criteria

- `.training.mlt/programs/<slug>/PROGRAM.md` exists with learner annotations
- `progress.md` has a complete task ledger with all modules listed
- `notes.md` exists with retrieval queue section
- NEXT.md points to the first module
