---
name: deploy-basic
description: "Thin-client bootstrap — copies .cursorrules and .training.mlt/ skeleton to a target project, sets TRAINER_MLT_SOURCE pointer."
---

# deploy-basic — thin-client bootstrap

## Modes

| Mode | Invocation | Effect |
|------|-----------|--------|
| deploy | `@deploy-basic - /path/to/target` | Copy skeleton to target |
| update | `@deploy-basic - /path/to/target --update` | Re-sync skeleton, preserve learner memory |

## Parse

```text
@deploy-basic - <target-path> [--update] [--force]
```

- `<target-path>`: absolute or relative path to the target project root
- `--update`: merge updated `.cursorrules` rules into existing file, do not overwrite learner memory
- `--force`: overwrite existing `.cursorrules` (requires explicit user confirmation)

## Steps

1. Verify the source pilo.trainer.mlt repo is accessible (read `START_HERE.md` from this repo)
2. Resolve `<target-path>` to an absolute path
3. If `<target-path>` does not exist, ask user before creating it
4. Check if `<target-path>/.cursorrules` already exists
   - If yes and `--force` is not set, stop and report conflict
   - If yes and `--force` is set, confirm with user before overwriting
5. Copy `templates/cursorrules.template` to `<target-path>/.cursorrules`
6. Replace `REPLACE_BASICSOURCE` with the absolute path of this source pilo.trainer.mlt repo
7. Replace `REPLACE:PROJECT_NAME` with the target directory name
8. Replace `REPLACE:LEARNER_LEVEL` with `beginner` (default)
9. Replace `REPLACE:PRIMARY_GOAL` with placeholder text
10. Scaffold `.training.mlt/` directory structure in target:
    - `.training.mlt/context/` (empty PROFILE.md, HANDOFF.md templates)
    - `.training.mlt/plans/` (empty NEXT.md, UNKNOWNS.md templates)
    - `.training.mlt/programs/`
    - `.training.mlt/sessions/`
    - `.training.mlt/sources/`
11. Skip existing files in `.training.mlt/` unless `--force`
12. Verify `TRAINER_MLT_SOURCE` in target `.cursorrules` points to a readable path
13. Report what was created and what was skipped

## Completion criteria

- Target has a valid `.cursorrules` with `TRAINER_MLT_SOURCE` set
- Target has `.training.mlt/` skeleton with all subdirectories
- Target `.cursorrules` references resolve to readable paths
- No learner memory overwritten unless `--force` confirmed
- Summary lists: files created, files skipped, any conflicts
