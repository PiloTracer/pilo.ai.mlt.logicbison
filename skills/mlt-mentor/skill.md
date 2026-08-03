---
name: mlt-mentor
description: "Mentoring sessions — follows standards/mentoring.md with retrieval opening, orient, diagnose, teach, practice, commit, and log."
---

# mlt-mentor — mentoring sessions

## Modes

| Mode | Invocation | Effect |
|------|-----------|--------|
| run | `@mlt-mentor run` | Execute a full mentoring session |
| prepare | `@mlt-mentor prepare` | Pre-session planning |

## Parse

```text
@mlt-mentor run [--module <name>] [--topic <text>]
@mlt-mentor prepare [--session <number>]
```

- `--module`: target a specific module from the active program
- `--topic`: override with a specific teaching topic
- `--session`: prepare for session N specifically

## Binding standard

Follow `standards/mentoring.md` for session structure, retrieval opening, and quality bar.

## Steps — run mode

1. Confirm session is open (check `.training.mlt/sessions/` for active session log)
   - If no session open, prompt to run `@session-mlt start` first
2. Read `.training.mlt/context/PROFILE.md` for learner context
3. Read active program's `progress.md` for current module
4. Read active program's `notes.md` for retrieval queue
5. **Retrieve** (5 min, binding):
   - Ask the learner to recall, without notes: their last session's commitment and whether they did it
   - Ask one concept from the retrieval queue (earlier module, spaced interval)
   - Compare recall against written record — note the gap
6. **Orient** (60 seconds): state the session goal and which module it serves
7. **Diagnose**: ask what the learner already knows about today's topic, surface assumptions
8. **Teach** (code-first):
   - Show the simplest working code example
   - Explain the theory tied to that code
   - Iterate with increasing complexity
   - Show expected output and failure modes
9. **Practice**: run a lab, drill, or coding exercise
   - Use `@mlt-lab setup - <topic>` or `@mlt-drill run - <type>` as appropriate
10. **Commit**: state one concrete action the learner will take before next session
11. **Log**: write session log to `.training.mlt/sessions/<date>-<topic>.md` containing:
    - Date, module, topic
    - Retrieval results
    - What was taught and practiced
    - Artifacts produced (file paths)
    - Commitment for next session
12. Tick the task ledger in `progress.md`
13. Update retrieval queue in `notes.md`
14. Update `.training.mlt/plans/NEXT.md`

## Steps — prepare mode

1. Read progress.md and identify the next module
2. Read the module's sources and labs
3. Draft a session plan: retrieval questions, teaching points, practice exercise
4. Write preparation notes to the active session log or a draft file

## Completion criteria

- Session log written under `.training.mlt/sessions/`
- Task ledger ticked for the covered module
- Retrieval queue updated
- NEXT.md updated with commitment
- At least one artifact (code, lab output, drill score) exists
