---
name: mlt-review
description: "Progress review and gate certification — checks task ledger, drill scores, and exit criteria for program completion."
---

# mlt-review — progress review and gate certification

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

1. Read `.training.mlt/programs/<slug>/progress.md` for task ledger
2. Read `.training.mlt/programs/<slug>/PROGRAM.md` for exit criteria
3. Read `.training.mlt/drills/` for drill scores
4. Read `.training.mlt/context/SCORECARD.md` for assessment scores
5. Compute progress:
   - Modules completed / total modules
   - Labs completed / total labs
   - Average drill score
   - Exit criteria met / total criteria
6. For short status, render:

```text
Program: <name>
Progress: <X>/<Y> modules complete (<%>)
Labs: <X>/<Y> complete
Avg drill score: <score>/4
Exit criteria: <X>/<Y> met
Gate: <OPEN|CLOSED> — <reason if closed>
```

7. For `--full`, add per-module detail:
   - Each module: status, lab result, drill score, exit check pass/fail
   - Strongest and weakest areas
   - Time spent (if session logs available)

## Steps — certify mode

1. Read all progress data (same as status)
2. Evaluate against gate criteria from `standards/assessment.md`:
   - All module exit checks met
   - Average drill score >= 3
   - No dimension scored at 1
   - All labs completed with passing output
3. For each gate criterion, report PASS or FAIL with evidence
4. If all gates pass:
   - Issue certification in `.training.mlt/programs/<slug>/CERTIFICATE.md`
   - Include: program name, date, scores, artifacts produced
   - Recommend next program(s) based on completed program
5. If any gate fails:
   - List each failed gate with specific deficiency
   - Provide remediation plan: what to do to pass
   - Emit BLOCKED report format from `skills/SKILL_DEPENDENCIES.md`

## Completion criteria

- status: progress report rendered with gate state
- certify: all gates evaluated with PASS/FAIL and evidence
- If certified: CERTIFICATE.md written, next program recommended, NEXT.md updated
- If blocked: BLOCKED report with remediation steps
