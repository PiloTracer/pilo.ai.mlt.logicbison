# Skill dependencies — gate graph

## Prerequisites

Skills may require prior state before they can execute. The gate graph below defines which skills block others. Gate names (`profile-ready`, `assessed`, `program-active`, `session-open`, `module-complete`, `program-complete`, `certified`) are defined in `.quick/gates.md` and used identically there and in `@mlt-review` reports.

```text
deploy-basic / deploy-files / deploy-repo
                │
                ▼
          mlt-bootstrap
                │
                ├──► mlt-assess ──► mlt-review
                │       │
                │       └──► mlt-program-custom ──┐
                ├──► mlt-program-standard ────────┤
                │                                 ▼
                │                         (active program) ──► mlt-curriculum
                │                                 │
                ├──► session-mlt ─────────────────┴──► mlt-mentor
                │       (mlt-mentor needs BOTH an open session and an active program)
                ├──► mlt-lab
                ├──► mlt-drill
                ├──► mlt-tutorial
                └──► mlt-sources ──► mlt-update
```

## Gate table

| Skill | Gate | Requires | Unlock condition |
|-------|------|----------|-----------------|
| mlt-bootstrap | — | deploy-basic OR deploy-files OR deploy-repo | Framework assets accessible |
| mlt-assess | profile-ready | mlt-bootstrap (PROFILE exists) | `.training.mlt/context/PROFILE.md` present |
| mlt-program-standard | profile-ready | mlt-bootstrap | `.training.mlt/programs/` directory exists |
| mlt-program-custom | assessed | mlt-bootstrap, mlt-assess | PROFILE and scorecard exist |
| mlt-curriculum | program-active | mlt-program-standard OR mlt-program-custom | Active program in `.training.mlt/programs/` |
| session-mlt | profile-ready | mlt-bootstrap | PROFILE present |
| mlt-mentor | session-open + program-active | session-mlt (active), active program | Session open AND program installed |
| mlt-lab | profile-ready | mlt-bootstrap | `.training.mlt/` scaffolded |
| mlt-drill | profile-ready | mlt-bootstrap | `.training.mlt/` scaffolded |
| mlt-tutorial | profile-ready | mlt-bootstrap | `.training.mlt/` scaffolded |
| mlt-sources | profile-ready | mlt-bootstrap | `.training.mlt/sources/` directory exists |
| mlt-review | assessed | mlt-assess (scorecard exists) | Assessment completed at least once |
| mlt-update | — | mlt-sources | Source list exists in `.training.mlt/sources/` |

`module-complete`, `program-complete`, and `certified` are progress gates evaluated by `@mlt-review status` / `certify`, not entry gates — see `.quick/gates.md` for their criteria.

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
