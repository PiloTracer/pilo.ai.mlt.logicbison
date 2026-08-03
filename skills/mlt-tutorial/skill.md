---
name: mlt-tutorial
description: "Generate tutorials and short training sessions — produces complete tutorials with prerequisites, setup, theory, code, and troubleshooting."
---

# mlt-tutorial — tutorial generation

## Modes

| Mode | Invocation | Effect |
|------|-----------|--------|
| generate | `@mlt-tutorial generate - <topic>` | Produce a complete tutorial |

## Parse

```text
@mlt-tutorial generate - <topic> [--level <beginner|intermediate|advanced>] [--length <short|medium|long>]
```

- `<topic>`: the tutorial subject (e.g., `attention-mechanism`, `qlora-finetuning`, `vector-databases`)
- `--level`: target audience level (default: match learner PROFILE)
- `--length`: short (15 min read), medium (30 min), long (60 min) — default: medium

## Binding standards

Follow `standards/citation.md` for all references and `standards/code-quality.md` for code.

## Steps

1. Read `.training.mlt/context/PROFILE.md` for learner level and hardware
2. Read `.training.mlt/context/SCORECARD.md` if available
3. Determine tutorial scope based on `<topic>` and `--level`:
   - What prior knowledge is needed
   - What code will be demonstrated
   - What the learner will build by the end
4. Generate the tutorial as a single markdown file under `.training.mlt/tutorials/<topic>.md`:

### Tutorial structure

- **Title and summary**: one-paragraph description of what the tutorial covers
- **Prerequisites**: Python version, packages, hardware, prior knowledge
- **Setup**: step-by-step environment setup (isolated venv per lab-safety.md)
- **Theory overview**: concise explanation of the core concept (no more than 30% of tutorial length)
- **Step-by-step code**: numbered sections with runnable code:
  - Each step has a clear instruction
  - Code is copy-pasteable and produces visible output
  - Expected output is shown after each step
- **Putting it together**: a complete working example combining all steps
- **Expected output**: what the final result looks like
- **Troubleshooting**: at least 5 common errors with fixes
- **Exercises**: 2-3 extension challenges for the learner
- **Next steps**: what to learn after this tutorial, with source links
- **References**: all cited sources per `standards/citation.md`

5. Verify all code is runnable, no hardcoded secrets, no invented packages
6. Verify all cited sources are real with title, author, and URL
7. Adapt code for learner's hardware (prefer small models, quantized if needed)
8. Report: tutorial path, estimated time, difficulty level

## Completion criteria

- Tutorial written to `.training.mlt/tutorials/<topic>.md`
- All code runs and produces documented output
- All sources cited are real and verifiable
- Troubleshooting section covers at least 5 errors
- No hardcoded API keys, paths, or credentials
- Adapted to learner's hardware constraints
