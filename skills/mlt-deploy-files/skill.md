---
name: mlt-deploy-files
description: "Fat-client vendor — copies the entire framework as .ai.mlt/ into a target project for self-contained operation."
---

# mlt-deploy-files — fat-client vendor

## Modes

| Mode | Invocation | Effect |
|------|-----------|--------|
| copy | `@mlt-deploy-files copy - /path/to/target` | Copy full framework into target |

## Parse

```text
@mlt-deploy-files copy - <target-path> [--force]
```

- `<target-path>`: absolute or relative path to the target project root
- `--force`: overwrite existing `.ai.mlt/` contents (requires user confirmation)

## Steps

1. Verify the source framework is accessible (read `README.md` from this repo)
2. Resolve `<target-path>` to an absolute path
3. If `<target-path>` does not exist, ask user before creating it
4. Check if `<target-path>/.ai.mlt/` already exists
   - If yes and `--force` is not set, stop and report conflict
   - If yes and `--force` is set, confirm with user before overwriting
5. Create `<target-path>/.ai.mlt/` directory
6. Copy the following framework directories into `.ai.mlt/`:
   - `skills/` (all skill definitions)
   - `curricula/` (program catalog)
   - `standards/` (binding standards)
   - `references/` (knowledge base)
   - `drills/` (lab exercises and templates)
   - `templates/` (bootstrap templates)
   - `scripts/` (utility scripts)
7. Copy `START_HERE.md`, `PROCESS_ROUTER.md`, `README.md` into `.ai.mlt/`
8. Copy `.cursorrules` to target root (merge if existing, do not overwrite)
9. Scaffold `.work.mlt/` in target root if not present
10. Update target `.cursorrules` to resolve framework paths from `.ai.mlt/`
11. Leave `TRAINER_MLT_SOURCE` unset (fat-client resolves locally)
12. Report file count, total size, and any skipped files

## Completion criteria

- Target has complete `.ai.mlt/` with all framework assets
- Target `.cursorrules` resolves skills, curricula, standards from `.ai.mlt/`
- Target `.work.mlt/` skeleton exists
- `TRAINER_MLT_SOURCE` is unset in target
- Summary lists: directories copied, total file count, any conflicts
