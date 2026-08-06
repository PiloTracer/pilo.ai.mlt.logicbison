---
name: mlt-assess
description: "Diagnostic assessment — evaluates the learner across 7 dimensions and produces a scorecard with program recommendations."
---

# mlt-assess — diagnostic assessment

## Modes

| Mode | Invocation | Effect |
|------|-----------|--------|
| run | `@mlt-assess run` | Full diagnostic across 7 dimensions |

## Parse

```text
@mlt-assess run [--focus <dimension>]
```

- `--focus`: optional, assess only the named dimension (e.g., `python`, `llm`, `math`)

## Binding standard

Follow `standards/assessment.md` for scoring anchors, dimensions, and rubric.

## Dimensions assessed

| # | Dimension | What is tested |
|---|-----------|---------------|
| 1 | Math foundations | Algebra, linear algebra, calculus, probability, optimization |
| 2 | Python | Syntax, OOP, NumPy/Pandas, advanced patterns, packaging |
| 3 | ML theory | Supervised/unsupervised, bias-variance, regularization, architectures |
| 4 | Deep Learning | Neural networks, CNNs, RNNs, training loops, distributed training |
| 5 | LLMs | API usage, prompting, fine-tuning, pre-training, RLHF, evaluation |
| 6 | Tools | Jupyter, PyTorch, Transformers, TRL, Unsloth, llama.cpp, vLLM |
| 7 | Deployment | Local scripts, Docker, FastAPI, MLOps, monitoring |

## Steps

1. Read `.work.mlt/context/PROFILE.md` for existing self-reported background
2. Read any prior scorecard from `.work.mlt/context/` (if re-assessment)
3. For each dimension (or the focused dimension if `--focus`):
   - Ask 3-5 diagnostic questions mixing conceptual and practical
   - Include at least one code-reading or code-writing question for dimensions 2-7
   - Score responses on the 1-5 scale per `standards/assessment.md`
   - Note specific evidence for each score
4. Compute the overall profile:
   - Average score across dimensions
   - Strongest dimension(s)
   - Weakest dimension(s)
   - Readiness level: beginner / intermediate / advanced
5. Recommend a program based on the weakest dimensions:
   - Score 1-2 average → `ml-foundations`
   - Score 2-3 average → `deep-learning-essentials` or `nlp-and-transformers`
   - Score 3-4 average → `llm-finetuning`, `llm-engineering`, or `ai-agents-and-apps`
   - Score 4-5 average → `llm-training` or `mlops-and-deployment`
6. Challenge any anti-patterns found (per `standards/assessment.md`)
7. Write the scorecard to `.work.mlt/context/SCORECARD.md`

## Scorecard format

```markdown
# Assessment Scorecard — <date>

| Dimension | Score (1-5) | Evidence |
|-----------|-------------|----------|
| Math | <score> | <what learner demonstrated> |
| Python | <score> | <evidence> |
| ML theory | <score> | <evidence> |
| Deep Learning | <score> | <evidence> |
| LLMs | <score> | <evidence> |
| Tools | <score> | <evidence> |
| Deployment | <score> | <evidence> |

**Average:** <avg>
**Level:** <beginner|intermediate|advanced>
**Strongest:** <dimension>
**Weakest:** <dimension>
**Recommended program:** `<slug>`
**Gaps to address:** <list>
```

## Completion criteria

- Scorecard written to `.work.mlt/context/SCORECARD.md`
- All 7 dimensions scored with evidence
- Program recommendation included
- NEXT.md updated with recommended next step
