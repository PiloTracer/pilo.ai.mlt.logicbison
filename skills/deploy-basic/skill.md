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
@deploy-basic <target-path> [update] [force]
```

Both forms are identical: the `-` separator before the path is optional, and the flags may be written with or without dashes (`update` = `--update`, `force` = `--force`).

- `<target-path>`: absolute or relative path to the target project root
- `--update`: merge MLT into an existing `.cursorrules` (see Merge procedure), re-sync skeleton, do not overwrite learner memory
- `--force`: overwrite existing `.cursorrules` (requires explicit user confirmation)

## Merge procedure (target already has a `.cursorrules`)

MLT content is always **additive** — never overwrite or restructure the target's identity, core principles, or other frameworks' sections.

1. If the target contract has structured per-framework sections (e.g. a Skills section with one subsection per framework), integrate MLT as a matching subsection there — not as a detached block at the end of the file. Otherwise appending `templates/thin-client-section.md` (with `REPLACE_BASICSOURCE` substituted) is acceptable.
2. Set `TRAINER_MLT_SOURCE` inline in the MLT section to the absolute path of this source repo.
3. **Alias collisions:** if the target already binds `{HANDOFF}`, `{NEXT}`, or other MLT placeholders to another framework, do not rebind them — define namespaced aliases in the MLT section (`{MLT_HANDOFF}` = `.training.mlt/context/HANDOFF.md`, `{MLT_NEXT}` = `.training.mlt/plans/NEXT.md`).
4. If the target has a skill-routing table, register `mlt-*` and `session-mlt` → MLT Training OS. If a heading counts frameworks, update the count.
5. Add a separation note: MLT learner artifacts stay inside `.training.mlt/`; MLT sessions must not rewrite other frameworks' memory dirs.
6. **Idempotent:** if an MLT section with a valid pointer already exists, refresh only stale content — never duplicate the section.
7. `scripts/deploy-basic.sh <target> --update` performs the mechanical append (step 1 fallback) idempotently; the agent reviews the result against steps 1-5.

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
10. Scaffold `.training.mlt/` directory structure in target (templates copied from `templates/training/`):
    - `.training.mlt/context/` (PROFILE.md, HANDOFF.md)
    - `.training.mlt/plans/` (NEXT.md, UNKNOWNS.md)
    - `.training.mlt/programs/`
    - `.training.mlt/sessions/`
    - `.training.mlt/sources/`
    - `.training.mlt/labs/`
    - `.training.mlt/tutorials/`
    - `.training.mlt/drills/`
11. Skip existing files in `.training.mlt/` unless `--force`
12. Verify `TRAINER_MLT_SOURCE` in target `.cursorrules` points to a readable path
13. Report what was created and what was skipped

## Completion criteria

- Target has a `.cursorrules` with `TRAINER_MLT_SOURCE` set (fresh file, or merged section per the Merge procedure)
- Merged sections: aliases namespaced on collision, routing registered, no duplicated MLT content
- Target has `.training.mlt/` skeleton with all subdirectories
- Target `.cursorrules` references resolve to readable paths
- No learner memory overwritten unless `--force` confirmed
- Summary lists: files created, files skipped, any conflicts
