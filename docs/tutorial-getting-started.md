# Getting Started with MLT — Full Tutorial

**Audience:** anyone who wants to learn Machine Learning / LLM training with an AI agent as their professor.
**Time:** ~20 minutes to a fully working setup, then your first training session.
**Platform:** built on and for Linux; Windows users see [README.md § Windows compatibility](../README.md#windows-compatibility).

---

## 0. What you are setting up

MLT (Machine Learning and AI Training) is an **Agent OS Framework**. It is not an app you run — it is a contract and toolkit your AI agent (Cursor, or any agent that reads `.cursorrules`) follows to become a rigorous ML professor and mentor.

Two layers, never mixed:

| Layer | Where | What lives there |
|-------|-------|------------------|
| **Framework** | this repo (`skills/`, `curricula/`, `standards/`, `references/`, `drills/`, `templates/`, `scripts/`) | Skills, program catalog, binding standards, knowledge base — shared, read-only |
| **Learner memory** | `.training.mlt/` inside *your target project* | Your profile, programs, sessions, labs, tutorials, drills, progress — yours forever |

The agent reads the framework's rules and writes only into your target project's `.training.mlt/`. That boundary is enforced by the contract.

---

## 1. Requirements

- A Linux machine (any modern distro) with `bash`, `git`, `sed`, `grep`, `awk`, `find` — all standard
- `python3` ≥ 3.9 for the labs themselves (not needed for setup)
- An AI coding agent: [Cursor](https://cursor.com) is the reference target (it reads `.cursorrules` natively); any agent that can follow a rules file works
- Optional: `gh` (GitHub CLI) if you want releases; not required

---

## 2. Install: clone and verify

```bash
git clone https://github.com/PiloTracer/pilo.trainer.mlt.git
cd pilo.trainer.mlt
bash scripts/install.sh check
```

Expected end of output:

```text
=== Results ===
  Errors:   0
  Warnings: 0

  Framework verification: PASSED
```

`install.sh check` verifies your environment and the framework checkout (skills registry sync, curricula catalog, templates, links). If it fails, fix what it reports before continuing.

---

## 3. Deploy into your learning project

MLT trains you *inside a project*. Create (or pick) the repo where your learning artifacts will live:

```bash
# still from the pilo.trainer.mlt root:
bash scripts/install.sh deploy /path/to/my-learning-project
```

This (thin-client deploy):

1. Writes `/path/to/my-learning-project/.cursorrules` — the agent contract, pointing back at this framework via `TRAINER_MLT_SOURCE`
2. Scaffolds `.training.mlt/` (context, plans, programs, sessions, sources, labs, tutorials, drills, exports) and `.quick/` cheat sheets
3. Never overwrites existing files without `--force` / `--update`

Deploying into a repo that already has code or another `.cursorrules`? Use `--update` — MLT merges additively and never clobbers:

```bash
bash scripts/deploy-basic.sh /path/to/existing-repo --update
```

> Keep the `pilo.trainer.mlt` checkout on disk: the target's `.cursorrules` points at it (`TRAINER_MLT_SOURCE`). Do not move or delete it.

---

## 4. Open the target and load context

```bash
cd /path/to/my-learning-project
cursor .        # or open the folder with your agent of choice
```

In Cursor the `.cursorrules` loads automatically. With any other agent, start the conversation with:

> Read `.cursorrules` and follow it. Then read `START_HERE.md` from the MLT source at `$TRAINER_MLT_SOURCE`.

From here on, everything happens **inside the target project** — the framework is the engine, the target is the classroom.

---

## 5. Bootstrap your learner memory

Tell the agent:

```text
@mlt-bootstrap init
```

The agent scaffolds anything missing and interviews you (8 dimensions: programming, Python, ML/DL/LLM experience, math, hardware, preferences, goal, time budget), then writes your answers into `.training.mlt/context/PROFILE.md`. Answer honestly — the whole system calibrates to this, and it corrects you later if reality disagrees.

---

## 6. Assess your level

```text
@mlt-assess run
```

A diagnostic across 7 dimensions (math, Python, ML theory, DL, LLMs, tools, deployment), scored 1–5 with evidence. Output: `.training.mlt/context/SCORECARD.md` plus recommended programs. This is not a personality quiz — claims without demonstrated evidence score low.

---

## 7. Install a program

See the catalog first:

```text
@mlt-program-standard list
```

Typical starting points:

| Your situation | Install |
|----------------|---------|
| New to ML | `@mlt-program-standard install - ml-foundations` |
| Can already train basic models | `@mlt-program-standard install - deep-learning-essentials` |
| Want to fine-tune LLMs now | `@mlt-program-standard install - llm-finetuning` |
| Something bespoke | `@mlt-program-custom - "6 weeks, evenings only, goal: fine-tune a 1B model on my domain data"` |

Install copies the curriculum into `.training.mlt/programs/<slug>/` as three files: `PROGRAM.md` (the program, annotated with your profile), `progress.md` (the task ledger — the system's ledger of record), `notes.md` (retrieval queue). Prerequisites are validated at install; the agent warns before letting you skip one.

---

## 8. Your first training session

```text
@session-mlt start
@mlt-mentor run
```

- `start` loads your profile, last handoff, and planned next action, sets the agenda, and opens the session log: `.training.mlt/sessions/YYYY-MM-DD_<topic-slug>.md`
- `run` executes the session per the mentoring standard: **retrieve** (closed-book recall first), orient, diagnose, teach code-first, practice (lab or drill), commit to one action, log

Everything produced is written into `.training.mlt/` — labs under `labs/<topic>/`, drill scores under `drills/`, ledger ticks in `progress.md`. When done:

```text
@session-mlt close
```

Close refreshes `HANDOFF.md` (what happened, decisions, open questions) and `NEXT.md` (the single concrete next action). Next time you sit down, those two files are your resume point — `@session-mlt status` or `@mlt-review status` re-orients you in under a minute.

---

## 9. Labs, tutorials, drills — the daily instruments

```text
@mlt-lab setup - grad-descent            # guided hands-on lab with isolated venv
@mlt-tutorial generate - attention-mechanism   # complete written tutorial
@mlt-tutorial generate - gradient-descent --format video   # video-entry tutorial
@mlt-drill run - pytorch --time 30       # timed, scored drill (4 dimensions)
```

- Labs reuse the 33 ready-made templates in `drills/lab-templates/` when one fits, adapted to your hardware — local-first, small models, no cloud dependency
- Lab code is heavily commented by standard: every non-trivial block explains the *concept*, not just the syntax
- Completed labs tick the matching module's Lab cell in your program ledger, and `@mlt-review` cross-verifies the tick against the actual artifacts

---

## 10. Progress, gates, certification

```text
@mlt-review status            # short: modules, labs, drills, gate, next action
@mlt-review status --full     # per-module breakdown, strengths/weaknesses
@mlt-review certify - ml-foundations
```

Gates (defined in `.quick/gates.md`): `profile-ready` → `assessed` → `program-active` → `session-open` → `module-complete` → `program-complete` → `certified`. If a skill can't run, you get a BLOCKED report with the exact unlock command — follow it and re-run.

Certification is evidence-based: artifact-verified labs + drill average ≥ 3 with no dimension at 1. It writes `CERTIFICATE.md` into the program directory.

---

## 11. When you feel lost

Read `START_HERE.md` (decision tree) or just describe what you want in plain language:

```text
@mlt-director - I have 45 minutes and want to practice tokenizers
```

The director maps intent → skill, checks prerequisites, and dispatches.

---

## 12. Reference layout (what goes where, in your target)

```text
my-learning-project/
├── .cursorrules                     # agent contract (points at the framework)
├── .quick/                          # operator cheat sheets (generated views)
└── .training.mlt/                   # ALL learner memory
    ├── context/                     # PROFILE.md, HANDOFF.md, SCORECARD.md
    ├── plans/                       # NEXT.md, UNKNOWNS.md
    ├── programs/<slug>/             # PROGRAM.md, progress.md, notes.md, CERTIFICATE.md
    ├── sessions/                    # YYYY-MM-DD_<topic-slug>.md (one per session)
    ├── labs/<topic>/                # README, setup.sh, code, expected_output, .venv
    ├── tutorials/                   # <topic>.md or <YYYYMMDD>-<slug>/ bundles
    ├── drills/                      # dated score files, .venv-<type>
    ├── sources/                     # curated sources, update reports
    └── exports/                     # exports you choose to keep
```

Worked examples of every one of these ship with the framework itself — see `.training.mlt/programs/ml-foundations/`, `.training.mlt/labs/grad-descent/`, `.training.mlt/tutorials/20260804-learn-today/`, and `.training.mlt/sessions/` in the `pilo.trainer.mlt` repo.

---

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `BLOCKED: ...` report | Read `reason`/`missing`, run the `unlock` command, retry |
| `pilo.trainer.mlt source unreachable: <path>` | The framework checkout moved or was deleted — restore it or re-deploy with `bash scripts/deploy-basic.sh <target> --update` |
| Agent doesn't know MLT skills | Make sure it read `.cursorrules` (Cursor: automatic; otherwise paste the instruction from §4) |
| `install.sh` fails on `python3` | Python is only needed for labs; setup itself still works — install Python ≥ 3.9 before your first lab |
| Windows | Use WSL2 or Git Bash — see [README.md § Windows compatibility](../README.md#windows-compatibility) |

---

## Where to go from here

- [`docs/quick-reference/`](quick-reference/README.md) — copy-paste recipes for programs, tutorials, and quick lessons
- [`PROCESS_ROUTER.md`](../PROCESS_ROUTER.md) — every how-to mapped to its skill
- [`skills/README.md`](../skills/README.md) — full skill registry and canonical verbs
- [`references/core-library.md`](../references/core-library.md) — the curated knowledge base the professor draws on
