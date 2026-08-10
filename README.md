# pilo.trainer.mlt — ML/AI Training Agent OS Framework

> Built on Linux. Used through an AI agent (Cursor, or any agent that reads `.cursorrules`).

**MLT** (Machine Learning and AI Training) is an Agent OS Framework — a contract and toolkit that turns your AI coding agent into a rigorous ML professor and mentor. It generates personalized programs, tutorials, labs, drills, and mentoring sessions. Everything runs **local-first** on your workstation with small models and efficient frameworks. No cloud dependency.

---

## Quick start (3 commands)

```bash
git clone https://github.com/PiloTracer/pilo.trainer.mlt.git
cd pilo.trainer.mlt
bash scripts/install.sh deploy /path/to/my-learning-project
```

Then open the target with your AI agent:

```bash
cd /path/to/my-learning-project
cursor .                     # or open with any agent that reads .cursorrules
```

The agent reads `.cursorrules` automatically. From here, everything happens inside the target project. Try:

```text
@mlt-bootstrap init                                        # scaffold memory + profile interview
@mlt-assess run                                            # diagnostic assessment
@mlt-program-standard install - ml-foundations              # install a program
@mlt-session start && @mlt-mentor run                      # first training session
```

Or with free-text:

```text
@mlt-director - I have 45 minutes and want to learn about gradient descent
@mlt-director - design me a 6-week program on fine-tuning LLMs, evenings only
@mlt-director - create a tutorial about how Transformers work, with code I can run
```

---

## What it does

| You want to… | Run |
|--------------|-----|
| Install a standard program | `@mlt-program-standard install - <slug>` |
| Design a custom program | `@mlt-program-custom - <your request>` |
| Start a training session | `@mlt-session start` → `@mlt-mentor run` |
| Hands-on lab | `@mlt-lab setup - <topic>` |
| Written or video tutorial | `@mlt-tutorial generate - <topic>` |
| Timed, scored drill | `@mlt-drill run - <type>` |
| Check progress & gates | `@mlt-review status` |
| Free-text (any of the above) | `@mlt-director - <plain language>` |

---

## Available programs

| Slug | Focus | Level |
|------|-------|-------|
| `ml-foundations` | Math, Python, ML basics | Beginner |
| `deep-learning-essentials` | Neural networks, PyTorch, training | Intermediate |
| `nlp-and-transformers` | NLP, Transformers, tokenization | Intermediate |
| `llm-training` | Pre-training, data curation, distributed training | Advanced |
| `llm-finetuning` | SFT, LoRA, QLoRA, preference alignment | Intermediate-Advanced |
| `llm-engineering` | RAG, agents, deployment, inference | Advanced |
| `mlops-and-deployment` | MLOps, monitoring, serving | Advanced |
| `ai-agents-and-apps` | Building AI applications and agents | Intermediate-Advanced |

---

## How it works

Two layers, never mixed:

| Layer | Location | What |
|-------|----------|------|
| **Framework** | this repo (`skills/`, `curricula/`, `standards/`, etc.) | 18 skills, 8 programs, 6 binding standards, 33 lab templates — shared, read-only |
| **Learner memory** | `.work.mlt/` inside your target project | Your profile, programs, sessions, labs, tutorials, drills, progress — yours forever |

The agent reads the framework's rules and writes only into `.work.mlt/`. That boundary is enforced by the contract.

## Or pick a program and go

You can also just look at the self-contained working examples that ship with the framework:

```text
.work.mlt/programs/ml-foundations/     # an installed program (PROGRAM.md + progress.md + notes.md)
.work.mlt/labs/grad-descent/            # a completed lab with heavily commented code
.work.mlt/tutorials/20260804-learn-today/  # written + video tutorial pair
.work.mlt/sessions/                     # an example session log
```

---

## Documentation

| File | Content |
|------|---------|
| [`START_HERE.md`](START_HERE.md) | Decision tree — "what do I do right now?" |
| [`docs/tutorial-getting-started.md`](docs/tutorial-getting-started.md) | Full walkthrough: install → deploy → first session |
| [`docs/quick-reference/`](docs/quick-reference/) | Copy-paste recipes for programs, tutorials, quick lessons |
| [`PROCESS_ROUTER.md`](PROCESS_ROUTER.md) | Every how-to mapped to its skill |
| [`skills/README.md`](skills/README.md) | Skill registry and canonical verbs |
| [`CONTRIBUTING.md`](CONTRIBUTING.md) | How to extend the framework |

---

## Framework structure

```
pilo.trainer.mlt/
├── .cursorrules              # Agent contract (the professor's rules)
├── .work.mlt/              # Example learner memory (self-hosted skeleton)
├── curricula/                # 8 training programs catalog
├── standards/                # 6 binding standards (mentoring, assessment, lab safety, ...)
├── references/               # Knowledge base and source library
├── drills/                   # 33 lab templates + case library
├── skills/                   # 18 agent skills (orchestration)
├── templates/                # Bootstrap and deployment templates
├── docs/                     # Tutorial + quick-reference recipes
├── scripts/                  # install.sh, mlt-deploy-basic.sh, mlt-cursorrules-verify.sh, framework-verify.sh
├── .quick/                   # Operator cheat sheets (generated views)
├── START_HERE.md             # Decision tree
├── PROCESS_ROUTER.md         # How-to → skill mapping
└── README.md                 # This file
```

---

## Windows compatibility

MLT is built on Linux and uses bash scripts (`sed`, `find`, `grep`, `awk`). On Windows, use:

- **WSL2** (recommended) — clone and run inside a WSL2 distribution. All scripts, venv activation (`source .venv/bin/activate`), and path separators work natively.
- **Git Bash** — `scripts/install.sh` and `mlt-deploy-basic.sh` run under Git Bash. Venv activation differs: use `.venv\Scripts\activate` instead (the agent and lab code handle this).

The `.cursorrules` contract itself is OS-agnostic. Only the shell scripts and venv paths need a bash-compatible shell.

---

## Core principles

1. **Truth before comfort** — Correct flawed assumptions early
2. **Never claim mastery without evidence** — Progress requires artifacts
3. **Verify before "done"** — Labs, tutorials, and sessions leave concrete files
4. **Local-first, practical** — Run on your workstation, <3B models, no cloud dependency
5. **Evidence-first, never memory-first** — Back claims with data
6. **Educational comments mandatory** — All learner-facing code is heavily commented; the code *is* the textbook

---

## Tools and frameworks covered

**Core ML:** PyTorch, scikit-learn, NumPy, Pandas · **LLM Training:** Transformers, TRL, Unsloth, Axolotl · **Inference:** llama.cpp, ollama, vLLM · **Data:** Hugging Face Datasets, distilabel · **Evaluation:** lighteval, lm-evaluation-harness · **Deployment:** FastAPI, Gradio, Streamlit

---

## License

Apache 2.0 — see [LICENSE](LICENSE)
