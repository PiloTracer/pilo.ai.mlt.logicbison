# pilo.trainer.mlt — Machine Learning and AI Training

**MLT** (Machine Learning and AI Training) is an Agent OS Framework for generating training courses, programs, lessons, and serving as a mentor for anyone who wants to learn Machine Learning and how to train Large Language Models.

## What is MLT?

MLT is a structured framework that orchestrates skills, knowledge bases, and training materials to:

- Generate personalized learning programs for ML and LLM training
- Provide hands-on tutorials and labs that run on local workstations
- Mentor students through structured sessions with retrieval practice
- Create short training sessions, comprehensive courses, and practical drills
- Guide practitioners from fundamentals to advanced LLM engineering

## Key Features

- **Local-first**: All labs and tutorials designed to run on local workstations with small models (<3B params) and efficient frameworks
- **Skill-based orchestration**: Modular skills for assessment, curriculum design, mentoring, lab setup, tutorial generation
- **Knowledge base**: Curated references to the best ML/LLM resources (PyTorch, Hugging Face, fast.ai, DeepLearning.AI, etc.)
- **Hands-on labs**: Practical exercises using real tools (PyTorch, Transformers, TRL, Unsloth, llama.cpp, ollama)
- **Progress tracking**: Structured learner memory, assessments, and certification gates
- **No cloud dependency**: Prefer quantized models, efficient fine-tuning (LoRA, QLoRA), and local inference

## Quick Start

### For Learners

1. **First time?** Read [`START_HERE.md`](START_HERE.md)
2. **Bootstrap your training:** `@mlt-bootstrap init`
3. **Assess your level:** `@mlt-assess run`
4. **Install a program:** `@mlt-program-standard install - ml-foundations`
5. **Start a session:** `@session-mlt start` → `@mlt-mentor run`

### For Framework Developers

- Skills live in `skills/`
- Curricula in `curricula/`
- Standards in `standards/`
- References in `references/`
- Drills and labs in `drills/`

## Available Programs

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

## Core Principles

1. **Truth before comfort** — Correct flawed assumptions early
2. **Evidence over vibes** — Progress requires artifacts and outcomes
3. **Local-first, practical** — Run on your workstation, no cloud dependency
4. **Hands-on labs** — Build real things with real tools
5. **Retrieval practice** — Durable learning through spaced retrieval

## Framework Structure

```
pilo.trainer.mlt/
├── .cursorrules          # Agent contract
├── .training.mlt/        # Learner memory (profile, programs, sessions)
├── curricula/            # Training program catalog
├── standards/            # Binding standards (mentoring, assessment, etc.)
├── references/           # Knowledge base and source library
├── drills/               # Practical lab exercises and templates
├── skills/               # Agent skills (orchestration)
├── templates/            # Bootstrap and deployment templates
├── scripts/              # Utility scripts
├── docs/                 # Documentation
├── START_HERE.md         # Decision tree
├── PROCESS_ROUTER.md     # How-to → skill mapping
└── README.md             # This file
```

## Tools and Frameworks Covered

- **Core ML**: PyTorch, scikit-learn, NumPy, Pandas
- **LLM Training**: Hugging Face Transformers, TRL, Unsloth, Axolotl
- **Inference**: llama.cpp, ollama, vLLM, transformers
- **Data**: Hugging Face Datasets, distilabel
- **Evaluation**: lighteval, lm-evaluation-harness
- **Deployment**: FastAPI, Gradio, Streamlit

## Resources

- [Hugging Face Courses](https://huggingface.co/learn)
- [fast.ai](https://www.fast.ai/)
- [DeepLearning.AI](https://www.deeplearning.ai/)
- [PyTorch Tutorials](https://pytorch.org/tutorials/)
- [LLM Course (mlabonne)](https://github.com/mlabonne/llm-course)

## License

Apache 2.0
