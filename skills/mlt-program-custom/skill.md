---
name: mlt-program-custom
description: "Design bespoke program — takes a learner request and designs a custom training program with modules, labs, and sources."
---

# mlt-program-custom — design bespoke program

## Modes

| Mode | Invocation | Effect |
|------|-----------|--------|
| design | `@mlt-program-custom - <request>` | Design a custom program |

## Parse

```text
@mlt-program-custom - <description> [--duration <weeks>] [--sessions <per-week>]
```

- `<description>`: natural language description of the desired training program
- `--duration`: target duration in weeks (default: derive from content)
- `--sessions`: sessions per week (default: 3)

## Binding standards

Follow `standards/program-spec.md` for structure and `standards/citation.md` for all references.

## Steps

1. Read `.training.mlt/context/PROFILE.md` for learner background
2. Read `.training.mlt/context/SCORECARD.md` if available for dimension scores
3. Parse the learner's request into:
   - Primary topic or goal
   - Implied level (beginner, intermediate, advanced)
   - Specific technologies or concepts mentioned
   - Constraints (time, hardware, prior knowledge)
4. Check for existing catalog programs that partially match
   - If a catalog program covers >70% of the request, suggest it first before designing custom
5. Design the program structure:
   - Program name and slug (kebab-case)
   - Duration and cadence
   - Audience and level assumptions
   - 3-5 measurable outcomes
   - 4-8 modules, each containing:
     - Learning objectives
     - Topics covered
     - Hands-on lab or drill
     - Sources (real, verified references only)
     - Exit check criteria
6. Order modules by dependency (prerequisites before dependents)
7. Verify all cited sources exist and are accessible
8. Present the proposed program to the learner for approval
9. On approval, write to `.training.mlt/programs/<slug>/`:
   - `PROGRAM.md` — full program specification
   - `progress.md` — task ledger with all modules
   - `notes.md` — retrieval queue (empty)
10. Update `.training.mlt/plans/NEXT.md` with the first module

## Completion criteria

- Learner approved the program design
- `PROGRAM.md` written with all required sections per `standards/program-spec.md`
- `progress.md` has task ledger with all modules
- `notes.md` exists
- All sources cited are real and verifiable
- NEXT.md updated
