# Recipe pack — Programs

Install a catalog program, design a custom one, or combine both.

---

## Install a standard program

```text
@mlt-program-standard list
@mlt-program-standard install - ml-foundations
```

If you already have an assessment scorecard, the install validates prerequisites (e.g. `deep-learning-essentials` requires `ml-foundations` done). Override with `--force` when you know what you're doing.

## Design a custom program (free-text)

The director and program-custom accept plain language:

```text
@mlt-director - I'm a backend engineer with 10 years of Python. I want to fine-tune a 1B model on my company's support tickets in 8 weeks, evenings only.

@mlt-program-custom - 6-week program for a data analyst who knows SQL + pandas and wants to add ML to their dashboard stack. Notebook-first, no GPU.

@mlt-program-custom - 3-week sprint: get me from zero DL to training a CNN on CIFAR-10 that beats 80% accuracy.

@mlt-director - my team of 4 engineers needs ML literacy — we don't need to train models, we need to read papers and evaluate vendors. Design a weekly 1h seminar program.
```

## Refine an existing program

```text
@mlt-curriculum refine   (runs against the active program)
@mlt-curriculum design   (restructure from scratch)
```

## Catalog cheat sheet (`@mlt-program-standard list`)

| Slug | Focus | Level |
|------|-------|-------|
| `ml-foundations` | Math, Python, ML basics | Beginner |
| `deep-learning-essentials` | NN, PyTorch, training | Intermediate |
| `nlp-and-transformers` | NLP, Transformers, tokenization | Intermediate |
| `llm-training` | Pre-training, data curation, distributed | Advanced |
| `llm-finetuning` | SFT, LoRA, QLoRA, DPO | Intermediate-Advanced |
| `llm-engineering` | RAG, agents, deployment, inference | Advanced |
| `mlops-and-deployment` | MLOps, monitoring, serving | Advanced |
| `ai-agents-and-apps` | Building AI applications and agents | Intermediate-Advanced |

## What gets produced

`@mlt-program-standard install - <slug>` writes three files under `.training.mlt/programs/<slug>/`:

- `PROGRAM.md` — the program (audience, modules, labs, exit criteria), annotated with your profile (pacing, hardware, goal alignment)
- `progress.md` — **the task ledger of record**: one row per module (Status, Lab, Score, Notes), plus an exit-criteria ledger. Mentor, lab, drill, and session skills all write back here
- `notes.md` — retrieval queue + concepts to revisit, populated during mentoring sessions
