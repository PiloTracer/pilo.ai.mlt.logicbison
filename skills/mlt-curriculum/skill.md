---
name: mlt-curriculum
description: "Module design and sequencing — refine modules, reorder content, add or remove labs within an active program."
---

# mlt-curriculum — module design and sequencing

## Modes

| Mode | Invocation | Effect |
|------|-----------|--------|
| design | `@mlt-curriculum design - <program-slug>` | Design modules for a new or existing program |
| refine | `@mlt-curriculum refine - <program-slug> [<module>]` | Refine a specific module or the full sequence |

## Parse

```text
@mlt-curriculum design - <program-slug> [--from <source>]
@mlt-curriculum refine - <program-slug> [<module-name>] [--add-lab | --remove-lab | --reorder]
```

- `<program-slug>`: the installed program to work with
- `<module-name>`: optional, target a specific module
- `--add-lab`: add a lab exercise to the module
- `--remove-lab`: remove a lab exercise from the module
- `--reorder`: suggest a new module ordering

## Binding standards

Follow `standards/program-spec.md` for module structure and `standards/lab-safety.md` for any lab additions.

## Steps — design mode

1. Read `.training.mlt/programs/<program-slug>/PROGRAM.md`
2. If `--from <source>` is specified, read the source material (URL, file, or description)
3. Analyze the current module structure:
   - List all modules with their objectives and labs
   - Identify gaps, redundancies, or sequencing issues
4. Propose module design or restructure:
   - Each module: objectives, topics, lab/drill, sources, exit check
   - Dependencies between modules
   - Suggested ordering (prerequisites first)
5. Present proposal to learner for approval
6. On approval, update PROGRAM.md with revised modules

## Steps — refine mode

1. Read the target program's PROGRAM.md and progress.md
2. If `<module-name>` specified, focus on that module:
   - Review objectives and content
   - Check lab quality and relevance
   - Assess exit criteria
   - Propose improvements
3. If `--reorder`, analyze full module sequence:
   - Check prerequisite dependencies
   - Identify modules that should come earlier or later
   - Propose new ordering with rationale
4. If `--add-lab`, design a new lab following `standards/lab-safety.md`:
   - Specify environment, dependencies, steps, expected output
   - Add to the module's lab list
5. If `--remove-lab`, confirm with learner before removing
6. Update PROGRAM.md and progress.md accordingly

## Completion criteria

- PROGRAM.md updated with refined modules
- progress.md task ledger synchronized with module changes
- All labs follow `standards/lab-safety.md`
- Learner approved the changes
- Module dependencies are explicitly documented
