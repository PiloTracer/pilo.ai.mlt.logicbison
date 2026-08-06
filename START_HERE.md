# START HERE — MLT learner decision tree

**Purpose:** Answer one question fast: *"What do I learn or train on right now?"*

**Read this when you sit down, are interrupted, or feel lost.**

**Rule:** If something below contradicts a `skill.md` or binding standard, the **skill / standard wins**.

**Paths:** Fat-client nested → prefix with `.ai.mlt/`. Self-hosted / thin-client source → no prefix. Learner memory is always **`.training.mlt/`** at the project root.

---

## 0. Three things to know

1. **Truth before comfort.** The professor corrects flawed assumptions. Labs beat lectures.
2. **Skills orchestrate. Standards bind. Memory persists.** Almost never read everything at once.
3. **Framework vs `.training.mlt/`:** skills/curricula/standards (framework) vs profile, plans, programs, sessions, labs, tutorials, drills, sources, exports (learner memory).

---

## 1. Decision tree

**First fork — which repo/session is this?** If you are editing `skills/`, `curricula/`, `standards/`, `templates/`, `scripts/`, or `.cursorrules` themselves (framework-dev work on this OS), **stop here** — everything below is for a *training project* (a learner using the pipeline). Do not run `@mlt-bootstrap init` or chain into the learner pipeline just because a self-hosted `.training.mlt/` looks empty; that only applies when you (or the user) explicitly want to create/initialize a training project.

```text
┌──────────────────────────────────────────┐
│  Where am I right now?                   │
└──────────────────────────────────────────┘
       │
       ├── "Setting up a NEW training project" ──► `@deploy-basic - <path>` (from source) or `@mlt-bootstrap init`
       │
       ├── "Empty / no .training.mlt" AND explicit training intent ──► `@mlt-bootstrap init`
       │
       ├── "Just opened / lost"           ──► §2 Resume
       │
       ├── "Don't know my level / gaps"   ──► `@mlt-assess run`
       │
       ├── "Want a standard program"      ──► `@mlt-program-standard list`
       │
       ├── "Want a custom program"        ──► `@mlt-program-custom - <request>`
       │
       ├── "Ready to train today"         ──► `@session-mlt start` → `@mlt-mentor run`
       │
       ├── "Need a tutorial"              ──► `@mlt-tutorial generate - <topic>`
       │
       ├── "Want a hands-on lab"          ──► `@mlt-lab setup - <topic>`
       │
       ├── "Want a practical drill"       ──► `@mlt-drill run - <type>`
       │
       ├── "Refresh sources / trends"     ──► `@mlt-update run`
       │
       ├── "Check progress / gates"       ──► `@mlt-review status`
       │
       ├── "Don't know which skill"       ──► `@mlt-director - <describe>`
       │
       └── "Closing for the day"          ──► `@session-mlt close`
```

---

## 2. Resume / orient (<=5 minutes)

| Need | Command |
|------|---------|
| Where am I / what's next? | `@session-mlt status` + `.training.mlt/context/HANDOFF.md` + `.training.mlt/plans/NEXT.md` |
| Free-text / unknown skill | `@mlt-director - <what you want>` |
| Gate / readiness state | `@mlt-review status` |

---

## 3. First-time setup

**Brand-new target project, thin-client (recommended):** create the repo (`mkdir` + `git init`) → from **this source** repo/chat run `@deploy-basic - /path/to/new-repo` (only the source session knows its own path) → open the target and continue below.

| Step | Run |
|------|-----|
| 1. Scaffold memory (if not already done by `@deploy-basic`) | `@mlt-bootstrap init` |
| 2. Fill profile | Edit `.training.mlt/context/PROFILE.md` (or let bootstrap interview) |
| 3. Assess | `@mlt-assess run` |
| 4. Install or design program | `@mlt-program-standard install - <slug>` **or** `@mlt-program-custom - <request>` |
| 5. First session | `@session-mlt start` → `@mlt-mentor run` |

---

## 4. Standard catalog (quick)

| Slug | Focus |
|------|-------|
| `ml-foundations` | Math, Python, ML basics |
| `deep-learning-essentials` | Neural networks, PyTorch, training |
| `nlp-and-transformers` | NLP, Transformers, tokenization |
| `llm-training` | Pre-training, data curation, distributed training |
| `llm-finetuning` | SFT, LoRA, QLoRA, preference alignment |
| `llm-engineering` | RAG, agents, deployment, inference |
| `mlops-and-deployment` | MLOps, monitoring, serving |
| `ai-agents-and-apps` | Building AI applications and agents |

---

## 5. Closing the day

1. `@session-mlt close` — refreshes HANDOFF + NEXT
2. Optionally draft a commit of `.training.mlt/` changes (you committed; agent does not unless asked)

---

## 6. Reading order (understanding the system)

1. This file
2. [`README.md`](README.md) — bird's-eye
3. [`PROCESS_ROUTER.md`](PROCESS_ROUTER.md) — how-to → skill, plus the binding-standards table
4. [`skills/README.md`](skills/README.md) — registry and canonical verbs
5. Active program under `.training.mlt/programs/` — `PROGRAM.md`, then `progress.md` (the task ledger)

Then, as needed rather than up front:

| Read | When |
|------|------|
| [`.quick/progress.md`](.quick/progress.md) | "What have I finished and what's left?" |
| [`.quick/gates.md`](.quick/gates.md) | Blocked on a readiness gate |
| [`references/core-library.md`](references/core-library.md) | Looking for something to read |
| [`drills/case-library.md`](drills/case-library.md) | Want a drill built on a real case |
| [`standards/`](standards/) | Only the one that matches the work — the table in `PROCESS_ROUTER.md` says which |
