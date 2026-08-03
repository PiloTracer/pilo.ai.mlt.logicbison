# Assessment standard

Binding for `@mlt-assess` and `@mlt-review`.

## Diagnostic dimensions

Assess the learner across these dimensions:

| Dimension | Beginner | Intermediate | Advanced |
|-----------|----------|--------------|----------|
| **Math foundations** | Basic algebra, no calculus | Linear algebra, calculus basics | Probability, optimization, advanced stats |
| **Python** | Basic syntax, scripts | OOP, libraries (NumPy, Pandas) | Advanced patterns, optimization, packaging |
| **ML theory** | Supervised vs unsupervised | Bias-variance, regularization | Advanced architectures, research papers |
| **Deep Learning** | Knows what a NN is | Can train CNNs/RNNs | Custom architectures, distributed training |
| **LLMs** | Uses APIs, basic prompting | Fine-tunes with LoRA/QLoRA | Pre-training, RLHF, evaluation |
| **Tools** | Jupyter, basic PyTorch | Transformers, Hugging Face | TRL, Unsloth, llama.cpp, vLLM |
| **Deployment** | Local scripts | Docker, FastAPI | Production MLOps, monitoring |

## Scoring

Each dimension scored 1-5:

1. **Novice**: No experience or exposure
2. **Aware**: Has read about it, hasn't done it
3. **Practicing**: Has done basic exercises or tutorials
4. **Competent**: Can do it independently with guidance
5. **Proficient**: Can do it independently and teach others

## Drill rubric

When assessing through drills, score on four dimensions:

| Dimension | 1 (fail) | 2 (pass) | 3 (good) | 4 (excellent) |
|-----------|----------|----------|----------|---------------|
| **Correctness** | Code doesn't run or wrong output | Runs with minor issues | Runs correctly, handles edge cases | Robust, efficient, well-tested |
| **Understanding** | Cannot explain the code | Can explain at high level | Can explain implementation details | Can explain trade-offs and alternatives |
| **Efficiency** | Very inefficient | Acceptable performance | Optimized appropriately | State-of-the-art approach |
| **Best practices** | Ignores conventions | Follows some conventions | Follows ML/Python conventions | Follows conventions + adds value |

## Gate criteria

- **Program complete**: All modules have exit checks met
- **Certification**: Average drill score >= 3, no dimension at 1
- **Readiness for next program**: Previous program certified + prerequisites met

## Anti-patterns to challenge

- Claiming understanding without running code
- "I watched a video" without building something
- Confusing API usage with understanding the model
- Thinking bigger models are always better
- Ignoring data quality for model complexity
- Skipping evaluation and testing

## Completion evidence

Every assessment must produce:
1. A scorecard with dimension scores
2. Specific examples of what the learner demonstrated
3. Recommended next steps with program slug
4. Any gaps that need remediation
