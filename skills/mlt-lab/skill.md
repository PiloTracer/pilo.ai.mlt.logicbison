---
name: mlt-lab
description: "Hands-on lab setup — generates isolated lab environments with step-by-step guided exercises and runnable code."
---

# mlt-lab — hands-on lab setup

## Modes

| Mode | Invocation | Effect |
|------|-----------|--------|
| setup | `@mlt-lab setup - <topic>` | Create a lab environment and guided exercise |

## Parse

```text
@mlt-lab setup - <topic> [--python <version>] [--gpu]
```

- `<topic>`: the lab subject (e.g., `pytorch-basics`, `lora-finetuning`, `rag-pipeline`)
- `--python`: Python version override (default: 3.10)
- `--gpu`: flag that GPU is available for this lab

## Binding standards

Follow `standards/lab-safety.md` for environment setup, resource limits, and safety rules, and `standards/code-quality.md` § Learner-facing code for lab code (detailed explanatory comments are mandatory).

## Steps

1. Read `.training.mlt/context/PROFILE.md` for hardware (GPU, RAM, disk) and Python level
2. Read `standards/lab-safety.md` for resource constraints
3. **Reuse before generating:** check `drills/lab-templates/` for a template matching `<topic>` (see `drills/case-library.md` for the ID map, e.g. `ml-01-linear-regression.md`). If one exists, adapt it (learner level, hardware, package versions) instead of writing a lab from scratch. Generate from scratch only when no template fits.
4. Determine lab requirements based on `<topic>`:
   - Required Python packages and versions
   - Model sizes needed (respect VRAM limits from lab-safety.md)
   - Dataset requirements (prefer synthetic or small public datasets)
   - Estimated disk usage
5. Check learner hardware against requirements:
   - If GPU required but unavailable, adapt to CPU-only approach
   - If model too large for available VRAM, use quantized version
6. Generate the lab structure under `.training.mlt/labs/<topic>/` (`<topic>` is a kebab-case slug, e.g. `grad-descent`):
   - `README.md` with prerequisites, setup steps, learning objectives
   - `setup.sh` with environment creation commands:
     - `python -m venv .training.mlt/labs/<topic>/.venv` (or conda/uv equivalent, per lab-safety.md)
     - Package installation commands with pinned versions
   - `lab.py` or `lab.ipynb` with the guided exercise:
     - Numbered steps with clear instructions
     - Runnable code cells that produce visible output
     - Expected output shown after each major step
     - Detailed explanatory comments on every non-trivial block (per code-quality.md § Learner-facing code)
   - `expected_output.md` documenting what success looks like
   - `troubleshooting.md` with common errors and fixes
   - `.env.example` if API keys are needed (never hardcode keys)
7. Verify all package names are real and installable
8. Verify model names reference verified publishers on Hugging Face
9. Run a dry-check: confirm all imports resolve, no hardcoded paths, no API keys in code
10. Present the lab to the learner with setup instructions
11. When the learner completes the lab and the output matches `expected_output.md`, record the result:
   - If the lab maps to a module of an active program, tick that module's **Lab** cell in `.training.mlt/programs/<slug>/progress.md` (with date and pass/notes)
   - Standalone labs (no program mapping) are still recorded by their artifact directory under `.training.mlt/labs/<topic>/`
   - Log the completion in the open session log (`.training.mlt/sessions/`) if a session is active

## Completion criteria

- Lab directory created under `.training.mlt/labs/<topic>/`
- README.md has prerequisites, setup, objectives, and cleanup instructions
- Code is runnable, produces expected output, and has no hardcoded secrets
- Environment setup script uses isolated virtual environment
- All model downloads are <10GB or approved by user
- Troubleshooting guide covers at least 3 common errors
- Completed labs tick the matching module's Lab cell in the active program's `progress.md`
