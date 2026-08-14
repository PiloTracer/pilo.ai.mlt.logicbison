# Session Log — mlt-session repo-context commit scope

**Date:** 2026-08-13
**Type:** framework-dev (not a learner training session)
**Log created at:** `@mlt-session close` (continuation of the parity work; no `@mlt-session start` preceded this session)

## Agenda

User directive: commits/pushes from the framework source repo must apply to **all** modified/added/new files; when the skill is invoked from a target project, scope stays the `.work.*` directory of the target repo.

## What was done

- Added **Commit scope resolution (binding)** to `skills/mlt-session/skill.md`:
  - Self-hosted framework source (`.cursorrules` pilo.trainer.mlt identity + local `skills/` + `TRAINER_MLT_SOURCE` unset) → full repo (`git add -A`)
  - Thin-client target (`TRAINER_MLT_SOURCE` set) → `.work.mlt/` only
  - Fat-client target (framework under `.ai.mlt/`) → `.work.mlt/` only (never app code or vendored `.ai.mlt/`)
  - Ambiguous → `.work.mlt/` only (safe default)
  - `scoped` still narrows to bookend files in any repo
- Updated hard rules, C1–C5 commit protocol, commit-report template, combination semantics, edge cases, wrong prompts, anti-patterns, completion checklist, frontmatter
- Framework-scope commit messages follow the `.cursorrules` `type: description` format (not the `chore: close MLT session` template)
- Synced: `.cursorrules` git exception + skills table, `PROCESS_ROUTER.md`, `skills/README.md`, `CHANGELOG.md`

## Verification

- `scripts/framework-verify.sh` → PASSED (0 errors, 0 warnings)

## Artifacts

- `skills/mlt-session/skill.md` (scope resolution section + protocol updates)
- `.work.mlt/sessions/2026-08-13_mlt-session-commit-scope.md` (this log)
- `.cursorrules`, `PROCESS_ROUTER.md`, `skills/README.md`, `CHANGELOG.md` (sync)
