---
name: mlt-deploy-repo
description: "Full repository deploy — git clone or archive the entire pilo.trainer.mlt framework to a target location."
---

# mlt-deploy-repo — full repo deploy

## Modes

| Mode | Invocation | Effect |
|------|-----------|--------|
| clone | `@mlt-deploy-repo clone - <url> <target>` | Git clone the framework repo |
| archive | `@mlt-deploy-repo archive - <dir>` | Create a compressed archive of the framework |

## Parse

```text
@mlt-deploy-repo clone - <url> <target-path> [--branch <branch>]
@mlt-deploy-repo archive - <output-dir> [--format zip|tar.gz]
```

- `<url>`: git remote URL of the framework repository
- `<target-path>`: destination directory for the clone
- `<output-dir>`: directory where the archive file will be written
- `--branch`: optional branch to clone (default: main)
- `--format`: archive format, default `tar.gz`

## Steps — clone mode

1. Verify `<url>` is a valid git remote (check format, do not fetch)
2. Resolve `<target-path>` to an absolute path
3. Check if `<target-path>` already exists and is non-empty
   - If non-empty, stop and ask user to confirm overwrite or choose new path
4. Run `git clone <url> <target-path>` (with `--branch` if specified)
5. Verify clone succeeded by checking `README.md` exists in target
6. Scaffold `.work.mlt/` skeleton in target if not present
7. Report: commit SHA, branch, files present, any missing expected paths

## Steps — archive mode

1. Resolve `<output-dir>` to an absolute path
2. Verify the framework source is accessible
3. Create archive of framework directories: `skills/`, `curricula/`, `standards/`, `references/`, `drills/`, `templates/`, `scripts/`, plus root docs
4. Exclude `.work.mlt/` learner memory, `.git/`, `__pycache__/`, `node_modules/`
5. Name the archive `pilo.trainer.mlt-<date>.<format>`
6. Write archive to `<output-dir>`
7. Report: archive path, size, file count, format

## Completion criteria

- clone: target directory contains full framework, `.work.mlt/` scaffolded, commit SHA reported
- archive: archive file exists at output path, size and count reported, no learner memory included
