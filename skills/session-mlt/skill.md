---
name: session-mlt
description: "Session lifecycle management — opens and closes training sessions, manages HANDOFF.md and NEXT.md context files."
---

# session-mlt — session open and close

## Modes

| Mode | Invocation | Effect |
|------|-----------|--------|
| start | `@session-mlt start` | Load context, set agenda |
| status | `@session-mlt status` | Report current session progress |
| close | `@session-mlt close` | Write handoff, update NEXT |

## Parse

```text
@session-mlt start [--agenda <text>]
@session-mlt status
@session-mlt close [--note <text>]
```

- `--agenda`: optional session agenda override
- `--note`: optional closing note to append to handoff

## Steps — start mode

1. Read `.training.mlt/context/PROFILE.md` — confirm learner identity and level
2. Read `.training.mlt/context/HANDOFF.md` — load last session state
3. Read `.training.mlt/plans/NEXT.md` — load planned next action
4. Read active program's `progress.md` under `.training.mlt/programs/<slug>/` if present
5. Assemble session context:
   - Learner level and current program
   - Last session summary and open items
   - Planned next action and whether it was completed
6. Set the session agenda:
   - Use `--agenda` if provided
   - Otherwise derive from NEXT.md and progress.md
7. Announce session open with: learner name, program, module, agenda
8. Create the session log file under `.training.mlt/sessions/`

### Session log naming convention (binding)

- Format: `YYYY-MM-DD_<topic-slug>.md` (local date, kebab-case topic), e.g. `2026-08-05_grad-descent-walkthrough.md`
- If the topic is not yet known at `start`, use the agenda or module name; rename once at `close` if the topic sharpened during the session
- Exactly **one log file per session**: `session-mlt` creates it at `start`, and every other skill that logs the session (`mlt-mentor`, `mlt-lab`, `mlt-drill`) writes into this same file — never a second one
- The log records: date, agenda, modules/topics covered, retrieval results, artifacts produced (paths under `.training.mlt/`), commitments

## Steps — status mode

1. Read current session log
2. Read active program progress
3. Report: session duration, items covered, items remaining, open unknowns

## Steps — close mode

1. Summarize what was accomplished this session
2. Write session summary to the session log file (rename it to the final `YYYY-MM-DD_<topic-slug>.md` if the placeholder topic changed)
3. Update `.training.mlt/context/HANDOFF.md` with:
   - What was done
   - What was learned
   - What was left incomplete
   - Key decisions made
4. Update `.training.mlt/plans/NEXT.md` with:
   - Concrete next action
   - Recommended skill to run next
   - Any blockers or prerequisites
5. Append `--note` to handoff if provided
6. Tick completed items in the program's task ledger

## Completion criteria

- start: session log created, context loaded, agenda announced
- status: progress report rendered with current state
- close: HANDOFF.md updated, NEXT.md set, session log finalized, task ledger ticked
