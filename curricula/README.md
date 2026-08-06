# Curricula — pilo.trainer.mlt Program Catalog

This directory contains the complete catalog of training programs for the pilo.trainer.mlt framework. Each program is a self-contained curriculum definition following the [program-spec.md](../standards/program-spec.md) standard.

## Program Dependency Graph

```
ml-foundations (Beginner)
└── deep-learning-essentials (Intermediate)
    └── nlp-and-transformers (Intermediate)
        ├── llm-training (Advanced)
        └── llm-finetuning (Intermediate-Advanced)
            └── llm-engineering (Advanced)
                ├── mlops-and-deployment (Advanced)
                └── ai-agents-and-apps (Intermediate-Advanced)
```

## Recommended Reading Order

| Order | Program | Slug | Level | Duration |
|-------|---------|------|-------|----------|
| 1 | ML Foundations | `ml-foundations` | Beginner | 4-6 weeks |
| 2 | Deep Learning Essentials | `deep-learning-essentials` | Intermediate | 6-8 weeks |
| 3 | NLP and Transformers | `nlp-and-transformers` | Intermediate | 6-8 weeks |
| 4a | LLM Training (Pre-training) | `llm-training` | Advanced | 8-10 weeks |
| 4b | LLM Fine-tuning | `llm-finetuning` | Intermediate-Advanced | 6-8 weeks |
| 5 | LLM Engineering | `llm-engineering` | Advanced | 6-8 weeks |
| 6a | MLOps and Deployment | `mlops-and-deployment` | Advanced | 4-6 weeks |
| 6b | AI Agents and Applications | `ai-agents-and-apps` | Intermediate-Advanced | 4-6 weeks |

Programs at the same tier (4a/4b, 6a/6b) can be taken in parallel or in either order.

## Prerequisites Summary

| Program | Prerequisites |
|---------|---------------|
| `ml-foundations` | None — start here |
| `deep-learning-essentials` | `ml-foundations` (all modules) |
| `nlp-and-transformers` | `deep-learning-essentials` (all modules) |
| `llm-training` | `nlp-and-transformers` (all modules) |
| `llm-finetuning` | `nlp-and-transformers` (all modules) |
| `llm-engineering` | `llm-finetuning` (all modules) |
| `mlops-and-deployment` | `llm-engineering` (all modules) |
| `ai-agents-and-apps` | `llm-engineering` (all modules) |

## Fast Tracks

- **ML Engineer track**: ml-foundations → deep-learning-essentials → nlp-and-transformers → llm-finetuning → llm-engineering
- **LLM Researcher track**: ml-foundations → deep-learning-essentials → nlp-and-transformers → llm-training → llm-finetuning
- **AI Application Builder track**: ml-foundations → deep-learning-essentials → nlp-and-transformers → llm-finetuning → llm-engineering → ai-agents-and-apps
- **Production ML track**: Full chain through mlops-and-deployment

## Installing a Program

```
@mlt-program-standard install - <slug>
```

This copies the curriculum to `.work.mlt/programs/<slug>/` and scaffolds `PROGRAM.md`, `progress.md`, and `notes.md`.

## Tools and Frameworks

All programs emphasize local-first tooling: PyTorch, Hugging Face Transformers, TRL, Unsloth, llama.cpp, ollama, scikit-learn, and other open-source tools that run on a workstation without cloud dependencies.
