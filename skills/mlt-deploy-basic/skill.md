---
name: mlt-deploy-basic
description: "Thin-client bootstrap — copies .cursorrules and .work.mlt/ skeleton to a target project, sets TRAINER_MLT_SOURCE pointer."
---

# mlt-deploy-basic — thin-client bootstrap

## Modes

| Mode | Invocation | Effect |
|------|-----------|--------|
| deploy | `@mlt-deploy-basic - /path/to/target` | Copy skeleton to target, then verify |
| update | `@mlt-deploy-basic - /path/to/target --update` | Re-sync skeleton + pointer, preserve learner memory, then verify |
| status | `@mlt-deploy-basic status [/path/to/target]` | Read-only verification report (no writes) |

## Parse

```text
@mlt-deploy-basic - <target-path> [--update] [--force]
@mlt-deploy-basic <target-path> [update] [force]
@mlt-deploy-basic [status] [<target-path>]
```

**Argument equivalence (skill + shell script):** all forms are identical — the `-` / `--` separators are dropped, verbs accept the `--` prefix or bare form (`update` ≡ `--update`, `force` ≡ `--force`, `status` ≡ `--status`), and the target path may appear in any position relative to the verb:

```text
@mlt-deploy-basic "/mnt/work/Projects/system-erp" update   ≡   @mlt-deploy-basic /mnt/work/Projects/system-erp --update
```

- `<target-path>`: absolute or relative path to the target project root
- `--update`: merge MLT into an existing `.cursorrules` (see Merge procedure), re-sync `TRAINER_MLT_SOURCE` to the current source, re-sync skeleton, do not overwrite learner memory
- `--force`: overwrite existing `.cursorrules` (requires explicit user confirmation)
- `status`: read-only — runs `scripts/mlt-cursorrules-verify.sh` against the target and reports; exit non-zero on FAIL findings

**Shell:** `bash $TRAINER_MLT_SOURCE/scripts/mlt-deploy-basic.sh [status] <target-path> [update|force]` — same argument equivalence as above.

## Merge procedure (target already has a `.cursorrules`)

MLT content is always **additive** — never overwrite or restructure the target's identity, core principles, or other frameworks' sections.

1. If the target contract has structured per-framework sections (e.g. a Skills section with one subsection per framework), integrate MLT as a matching subsection there — not as a detached block at the end of the file. Otherwise appending `templates/thin-client-section.md` (with `REPLACE_BASICSOURCE` substituted) is acceptable.
2. Set `TRAINER_MLT_SOURCE` inline in the MLT section to the absolute path of this source repo.
3. **Alias collisions:** if the target already binds `{HANDOFF}`, `{NEXT}`, or other MLT placeholders to another framework, do not rebind them — define namespaced aliases in the MLT section (`{MLT_HANDOFF}` = `.work.mlt/context/HANDOFF.md`, `{MLT_NEXT}` = `.work.mlt/plans/NEXT.md`).
4. If the target has a skill-routing table, register `mlt-*` skills → MLT Training OS. If a heading counts frameworks, update the count.
5. Add a separation note: MLT learner artifacts stay inside `.work.mlt/`; MLT sessions must not rewrite other frameworks' memory dirs.
6. **Idempotent:** if an MLT section with a valid pointer already exists, refresh only stale content — never duplicate the section.
7. `scripts/mlt-deploy-basic.sh <target> --update` performs the mechanical append (step 1 fallback) idempotently; the agent reviews the result against steps 1-5.

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
10. Scaffold `.work.mlt/` directory structure in target (templates copied from `templates/training/`):
    - `.work.mlt/context/` (PROFILE.md, HANDOFF.md)
    - `.work.mlt/plans/` (NEXT.md, UNKNOWNS.md)
    - `.work.mlt/programs/`
    - `.work.mlt/sessions/`
    - `.work.mlt/sources/`
    - `.work.mlt/labs/`
    - `.work.mlt/tutorials/`
    - `.work.mlt/drills/`
    - `.work.mlt/exports/`
    - `.quick/` (operator cheat sheets at the target root)
11. Skip existing files in `.work.mlt/` unless `--force`
12. **Verify (mandatory, every deploy/update):** run `bash scripts/mlt-cursorrules-verify.sh <target-path>` (the shell script does this automatically). It checks, against the *current* source location:
    - `.cursorrules` present; `TRAINER_MLT_SOURCE` filled, reachable, and a valid framework root
    - no duplicate MLT sections; alias collisions surfaced (`{MLT_HANDOFF}` / `{MLT_NEXT}` required when another framework binds `{HANDOFF}` / `{NEXT}`)
    - `.work.mlt/` skeleton complete (dirs + PROFILE/HANDOFF/NEXT/UNKNOWNS)
    - remaining `REPLACE:` tokens reported for the operator to fill
    On FAIL: fix (or re-run with `update`, which re-syncs the pointer via `--fix`) and re-verify — do not report success with a red verification.
13. Report what was created and what was skipped

## Completion criteria

- Target has a `.cursorrules` with `TRAINER_MLT_SOURCE` set (fresh file, or merged section per the Merge procedure)
- Merged sections: aliases namespaced on collision, routing registered, no duplicated MLT content
- Target has `.work.mlt/` skeleton with all subdirectories
- `scripts/mlt-cursorrules-verify.sh <target>` exits 0 (all pointer/skeleton checks PASS)
- Target `.cursorrules` references resolve to readable paths — once deployed, "read .cursorrules" in the target surfaces the pointer, the full-ruleset location (`$TRAINER_MLT_SOURCE/.cursorrules`), entry points, and the local `.work.mlt/` memory layout
- No learner memory overwritten unless `--force` confirmed
- Summary lists: files created, files skipped, any conflicts
