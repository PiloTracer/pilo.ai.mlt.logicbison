# Skill dependencies — gate graph

## Prerequisites

Skills may require prior state before they can execute. The gate graph below defines which skills block others.

```text
deploy-basic ─────────────────────────────────┐
deploy-files ─┐                               │
deploy-repo  ─┤                               │
              ▼                               ▼
         mlt-bootstrap ──► mlt-assess ──► mlt-program-standard
                                │          mlt-program-custom
                                ▼               │
                          session-mlt ◄─────────┘
                                │
                    ┌───────────┼───────────┐
                    ▼           ▼           ▼
                mlt-mentor   mlt-lab    mlt-drill
                    │           │           │
                    ▼           ▼           ▼
                mlt-tutorial  mlt-curriculum
                    │
                    ▼
                mlt-review ──► certify
```

## Gate table

| Skill | Requires | Unlock condition |
|-------|----------|-----------------|
| mlt-bootstrap | deploy-basic OR deploy-files OR deploy-repo | Framework assets accessible |
| mlt-assess | mlt-bootstrap (PROFILE exists) | `.training.mlt/context/PROFILE.md` present |
| mlt-program-standard | mlt-bootstrap | `.training.mlt/programs/` directory exists |
| mlt-program-custom | mlt-bootstrap, mlt-assess | PROFILE and scorecard exist |
| mlt-curriculum | mlt-program-standard OR mlt-program-custom | Active program in `.training.mlt/programs/` |
| session-mlt | mlt-bootstrap | PROFILE present |
| mlt-mentor | session-mlt (active), active program | Session open, program installed |
| mlt-lab | mlt-bootstrap | `.training.mlt/` scaffolded |
| mlt-drill | mlt-bootstrap | `.training.mlt/` scaffolded |
| mlt-tutorial | mlt-bootstrap | `.training.mlt/` scaffolded |
| mlt-review | mlt-assess (scorecard exists) | Assessment completed at least once |
| mlt-update | mlt-sources | Source list exists in `.training.mlt/sources/` |

## BLOCKED report format

When a skill is blocked, emit this exact structure:

```text
BLOCKED: <skill-name> <verb>
  reason: <short reason>
  missing: <list of missing prerequisites>
  unlock: <command or action to resolve>
```

### Example

```text
BLOCKED: mlt-assess run
  reason: PROFILE.md not found
  missing: .training.mlt/context/PROFILE.md
  unlock: @mlt-bootstrap init
```

## Resolution

1. Read the BLOCKED report
2. Run the unlock command shown
3. Re-run the originally requested skill
4. If the unlock itself is blocked, recurse until a runnable skill is found
