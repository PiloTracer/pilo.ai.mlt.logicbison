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

1. Confirm session is open (check `.work.mlt/sessions/` for an active session log)
   - If no session open, emit a BLOCKED report (per `skills/SKILL_DEPENDENCIES.md`) with `unlock: @mlt-session start` and stop
2. Confirm an active program exists under `.work.mlt/programs/`
   - If none, emit a BLOCKED report with `unlock: @mlt-program-standard install - <slug>` or `@mlt-program-custom - <request>` and stop
3. Read `.work.mlt/context/PROFILE.md` for learner context
4. Read active program's `progress.md` for current module
5. Read active program's `notes.md` for retrieval queue
6. **Retrieve** (5 min, binding):
   - Ask the learner to recall, without notes: their last session's commitment and whether they did it
   - Ask one concept from the retrieval queue (earlier module, spaced interval)
   - Compare recall against written record — note the gap
7. **Orient** (60 seconds): state the session goal and which module it serves
8. **Diagnose**: ask what the learner already knows about today's topic, surface assumptions
9. **Teach** (code-first):
   - Show the simplest working code example
   - Explain the theory tied to that code
   - Iterate with increasing complexity
   - Show expected output and failure modes
   - All code shown or generated follows `standards/code-quality.md` § Learner-facing code (detailed explanatory comments)
10. **Practice**: run a lab, drill, or coding exercise
    - Use `@mlt-lab setup - <topic>` or `@mlt-drill run - <type>` as appropriate
11. **Commit**: state one concrete action the learner will take before next session
12. **Log**: write into the session log opened by `@mlt-session start` (same file; never create a second log) — naming convention in `skills/mlt-session/skill.md`. Contents:
    - Date, module, topic
    - Retrieval results
    - What was taught and practiced
    - Artifacts produced (file paths)
    - Commitment for next session
13. Tick the task ledger in `progress.md`
14. Update retrieval queue in `notes.md`
15. Update `.work.mlt/plans/NEXT.md`

## Steps — prepare mode

1. Read progress.md and identify the next module
2. Read the module's sources and labs
3. Draft a session plan: retrieval questions, teaching points, practice exercise
4. Write preparation notes to the active session log or a draft file

## Completion criteria

- Session log written under `.work.mlt/sessions/`
- Task ledger ticked for the covered module
- Retrieval queue updated
- NEXT.md updated with commitment
- At least one artifact (code, lab output, drill score) exists
