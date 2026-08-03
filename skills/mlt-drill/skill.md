---
name: mlt-drill
description: "Practical drills and exercises — runs timed coding exercises with scoring rubric using cases from drills/case-library.md."
---

# mlt-drill — practical drills and exercises

## Modes

| Mode | Invocation | Effect |
|------|-----------|--------|
| run | `@mlt-drill run - <type>` | Execute a drill exercise |
| list | `@mlt-drill list` | Show available drill types |

## Parse

```text
@mlt-drill run - <type> [--difficulty <easy|medium|hard>] [--time <minutes>]
@mlt-drill list
```

- `<type>`: drill category (e.g., `pytorch`, `training-loop`, `tokenization`, `finetuning`, `evaluation`)
- `--difficulty`: override difficulty (default: match learner level)
- `--time`: time limit in minutes (default: 30)

## Binding standards

Follow `standards/assessment.md` for drill rubric and `standards/lab-safety.md` for environment setup.

## Steps — run mode

1. Read `.training.mlt/context/PROFILE.md` for learner level and hardware
2. Read `drills/case-library.md` for available drill cases matching `<type>`
3. Select or generate a drill exercise:
   - Match the requested type and difficulty
   - Ensure it is runnable on learner's hardware
   - If from case library, adapt the case to a timed exercise
4. Set up the drill environment:
   - Create isolated venv: `.mlt-lab-drill-<type>`
   - Install required packages
   - Provide starter code template if appropriate
5. Present the drill to the learner:
   - Problem statement with clear requirements
   - Starter code or empty template
   - Expected output or behavior
   - Time limit
   - Scoring rubric (4 dimensions per assessment.md)
6. Start the timer
7. When time expires or learner submits:
   - Evaluate code against the rubric:
     - **Correctness** (1-4): does it run and produce correct output
     - **Understanding** (1-4): can the learner explain their code
     - **Efficiency** (1-4): performance and resource usage
     - **Best practices** (1-4): follows ML/Python conventions
   - Compute total score and per-dimension breakdown
8. Provide feedback:
   - What worked well
   - What could improve
   - Model solution with explanation
9. Write drill result to `.training.mlt/drills/<date>-<type>.md`:
   - Score breakdown
   - Learner's code
   - Model solution
   - Feedback notes
10. Update program's `progress.md` with drill score

## Steps — list mode

1. Read `drills/case-library.md`
2. List available drill types with description and difficulty range

## Completion criteria

- Drill result written to `.training.mlt/drills/`
- Score breakdown across 4 dimensions recorded
- Model solution provided
- progress.md updated with drill score
- Feedback includes specific improvement suggestions
