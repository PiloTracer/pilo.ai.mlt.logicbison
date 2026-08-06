# Recipe pack — Quick lessons (labs, drills, sessions)

30-60 minute instruments for a training day. Each leaves an artifact in `.work.mlt/`.

---

## Hands-on lab (guided, code you run yourself)

```text
@mlt-lab setup - grad-descent
@mlt-lab setup - rag-pipeline
@mlt-lab setup - qlora-finetuning --gpu

@mlt-director - set up a lab where I implement a neural network in pure numpy
@mlt-director - I want to build a RAG system on my local machine, no cloud
```

Labs reuse the 33 ready-made templates in `drills/lab-templates/` when one matches — adapted to your hardware. A lab is: isolated `.venv`, README with prerequisites + objectives, runnable `.py` / `.ipynb` with detailed comments, expected output, troubleshooting (≥3 errors), cleanup instructions. Completed labs tick the program ledger's Lab cell.

## Practical drill (timed, scored on 4 dimensions)

```text
@mlt-drill list
@mlt-drill run - pytorch --difficulty easy --time 15
@mlt-drill run - training-loop --time 45

@mlt-director - drill me on tokenization, beginner level, 20 minutes
@mlt-director - give me a hard drill on backpropagation implementation
```

Scored 1–4 on Correctness, Understanding, Efficiency, Best practices. A model solution with detailed comments is provided after. Passing: average ≥3, no dimension at 1. Score goes into `progress.md`.

## Mentoring session (30-90 min, with retrieval opening)

```text
@mlt-session start
@mlt-mentor run --topic attention-scores
@mlt-session close

@mlt-director - start a mentoring session on loss functions
@mlt-mentor prepare --session 3
```

A session has a fixed structure: Retrieve (closed-book, 5 min) → Orient (60s) → Diagnose → Teach (code-first) → Practice → Commit (one action) → Log. The session log (`YYYY-MM-DD_<topic>.md`) records everything; `@mlt-session close` refreshes HANDOFF + NEXT. Log into your target project, run `@mlt-session status`, and you're oriented in under a minute.

## Combo — a full training hour

```text
@mlt-session start
@mlt-mentor run --topic gradient-descent  (retrieve + teach, ~20 min)
@mlt-lab setup - grad-descent             (hands-on, ~30 min)
@mlt-session close                        (log + commit + NEXT, ~5 min)
```

## Progress check (any time)

```text
@mlt-review status
@mlt-review status --full
@mlt-review certify - ml-foundations

@mlt-director - how am I doing?
@mlt-director - am I ready to move on to the next module?
```

BLOCKED on a gate? The report shows the exact unlock command. Run it and retry.
