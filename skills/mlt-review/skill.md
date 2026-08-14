---
name: mlt-review
description: "Progress review and gate certification — checks task ledger, drill scores, and exit criteria for program completion."
---

# mlt-review — progress review and gate certification

> **Close:** operator-facing reports end per the **Operator handoff contract** (`skills/SKILL_DEPENDENCIES.md`) — Form A (`Next: nothing - …`) or Form B (`**Needs your approval:**` / `**Needs your answer:**` / `**Next step:**`).
> **Docs:** generated documents follow the **Document clarity contract** (`skills/SKILL_DEPENDENCIES.md`) — Status/Needs header, separate Decisions / Open questions lists, exactly one `## Next action`, no leftover scaffolding.

## Modes

| Mode | Invocation | Effect |
|------|-----------|--------|
| status | `@mlt-review status [--full]` | Report progress against program goals |
| certify | `@mlt-review certify - <program-slug>` | Evaluate against gate criteria for certification |

## Parse

```text
@mlt-review status [--full] [--program <slug>]
@mlt-review certify - <program-slug>
```

- `--full`: detailed report with per-module breakdown
- `--program`: focus on a specific program (default: active program)

## Binding standard

Follow `standards/assessment.md` for gate criteria and scoring.

## Steps — status mode

1. If no program exists under `.work.mlt/programs/`, emit a BLOCKED report (per `skills/SKILL_DEPENDENCIES.md`) with `unlock: @mlt-program-standard install - <slug>` or `@mlt-program-custom - <request>` and stop
2. Read `.work.mlt/programs/<slug>/progress.md` for task ledger
3. Read `.work.mlt/programs/<slug>/PROGRAM.md` for exit criteria
4. Read `.work.mlt/drills/` for drill scores
5. Read `.work.mlt/context/SCORECARD.md` for assessment scores
6. Read `.work.mlt/plans/NEXT.md` for the planned next action
7. Cross-verify lab claims against artifacts: for every module whose Lab cell is ticked in `progress.md`, confirm a matching artifact directory exists under `.work.mlt/labs/<topic>/` (with code/output files). Report any ledger entry with no artifact as unverified — never count it as complete.
8. Compute progress:
   - Modules completed / total modules
   - Labs completed / total labs (artifact-verified per step 7)
   - Average drill score
   - Exit criteria met / total criteria
9. For short status, render:

```text
Program: <name>
Progress: <X>/<Y> modules complete (<%>)
Labs: <X>/<Y> complete
Avg drill score: <score>/4
Exit criteria: <X>/<Y> met
Gate: <OPEN|CLOSED> — <reason if closed>
Next: <next action from NEXT.md>
```

10. For `--full`, add per-module detail:
   - Each module: status, lab result, drill score, exit check pass/fail
   - Strongest and weakest areas
   - Time spent (if session logs available)
11. Refresh the operator views so they never go stale:
    - Rewrite `.quick/progress.md` from the computed data (active programs, completed sessions from `.work.mlt/sessions/`, drill scores, totals)
    - Update the "Current Gate Status" table in `.quick/gates.md` from the current gate states — one row per defined gate, all 7 (keep the gate definitions and BLOCKED format sections intact)

## Steps — certify mode

1. Read all progress data (same as status)
2. Evaluate against gate criteria from `standards/assessment.md` (two distinct gates):
   - **program-complete**: all module exit checks met + all labs completed with artifact-verified passing output
   - **certified**: average drill score >= 3 and no drill dimension scored at 1
3. For each gate criterion, report PASS or FAIL with evidence (artifact paths, drill files)
4. If all gates pass:
   - Issue certification in `.work.mlt/programs/<slug>/CERTIFICATE.md`
   - Include: program name, date, scores, artifacts produced
   - Recommend next program(s) based on completed program
5. If any gate fails:
   - List each failed gate with specific deficiency
   - Provide remediation plan: what to do to pass
   - Emit BLOCKED report format from `skills/SKILL_DEPENDENCIES.md`

## Completion criteria

- status: progress report rendered with gate state and next action; `.quick/progress.md` and `.quick/gates.md` refreshed from current data
- certify: all gates evaluated with PASS/FAIL and evidence
- If certified: CERTIFICATE.md written, next program recommended, NEXT.md updated
- If blocked: BLOCKED report with remediation steps
