# LLM Training (Pre-training)

**Slug:** `llm-training`
**Duration:** 8-10 weeks · 3-4 sessions/week
**Level:** Advanced
**Prerequisites:** `nlp-and-transformers` (all modules)

## Audience
Learners who understand transformers and want to train LLMs from scratch. Comfortable with PyTorch and GPU training. Common misconception: "pre-training is just scaling up fine-tuning."

## Duration & Cadence
8-10 weeks, 3-4 sessions/week. Sessions: 90-120 min (paper study + infra work). Async: dataset curation, training runs, monitoring.

## Outcomes
1. Curate, clean, and deduplicate a pre-training dataset from raw web text
2. Set up distributed training with DeepSpeed or FSDP
3. Pre-train a small GPT (<1B params) on curated data
4. Explain scaling laws and compute-optimal training
5. Produce a reproducible pre-training pipeline with experiment tracking

## Modules

### Module 1: LLM Architecture (Week 1-2)
**Objectives:** Understand decoder-only architecture and scaling laws.
**Content:** Decoder-only (causal masking, autoregressive, KV cache). Innovations (GQA, SwiGLU, RoPE, RMSNorm). Scaling laws (Chinchilla, compute-optimal). Tokenizer design (domain-specific BPE, vocab size).
**Lab:** Analyze Llama 2/Mistral/Qwen2 configs. Implement a ~10M param GPT with modern components following nanoGPT.
**Sources:** [nanoGPT](https://github.com/karpathy/nanoGPT) · [Scaling Laws (Kaplan)](https://arxiv.org/abs/2001.08361) · [Chinchilla (Hoffmann)](https://arxiv.org/abs/2203.15556) · [Raschka — LLMs from Scratch](https://github.com/rasbt/LLMs-from-scratch)
**Exit check:** Derive parameter count from config; explain Chinchilla-optimal ratios.

### Module 2: Data Curation (Week 2-4)
**Objectives:** Build high-quality pre-training datasets.
**Content:** Sources (Common Crawl, Wikipedia, FineWeb, GitHub). Cleaning (HTML strip, language detect, encoding). Deduplication (exact, MinHash, SimHash). Filtering (perplexity, classifier-based, heuristics). Data mixing and scheduling.
**Lab:** Build a pipeline: download FineWeb subset, clean with `datatrove`, MinHash dedup, quality filter, tokenize for training.
**Sources:** [FineWeb](https://huggingface.co/datasets/HuggingFaceFW/fineweb) · [datatrove](https://github.com/huggingface/datatrove) · [LLM360](https://github.com/LLM360) · [mlabonne/llm-course](https://github.com/mlabonne/llm-course)
**Exit check:** Cleaned, deduplicated, tokenized dataset with documented provenance.

### Module 3: Pre-training (Week 4-7)
**Objectives:** Train a language model with distributed techniques.
**Content:** Causal LM objective, next-token prediction. Distributed (data/tensor/pipeline parallelism, ZeRO). DeepSpeed (ZeRO 1-3, offloading). FSDP (native sharding, wrapping). Mixed precision (FP16/BF16, loss scaling). LR scheduling (warmup, cosine, WSD).
**Lab:** Set up distributed training with DeepSpeed/FSDP. Pre-train ~100M GPT on curated data. Monitor loss, gradients, throughput.
**Sources:** [DeepSpeed](https://www.deepspeed.ai/) · [PyTorch FSDP](https://pytorch.org/tutorials/intermediate/FSDP_tutorial.html) · [nanotron](https://github.com/huggingface/nanotron) · [LLM360 Amber](https://github.com/LLM360/amber)
**Exit check:** Complete pre-training run with documented hyperparams and loss curves.

### Module 4: Training Infrastructure (Week 5-8)
**Objectives:** Manage GPU training infrastructure and profiling.
**Content:** Hardware (A100/H100, consumer RTX, VRAM). Networking (NVLink, NCCL). Monitoring (W&B, throughput, MFU). Checkpointing (save/resume/convert). Cost estimation.
**Lab:** Profile training: measure tokens/sec, MFU, VRAM, communication. Optimize batch size and gradient accumulation.
**Sources:** [NVIDIA Training Best Practices](https://docs.nvidia.com/deeplearning/performance/index.html) · [PyTorch Perf Guide](https://pytorch.org/tutorials/recipes/recipes/tuning_guide.html)
**Exit check:** Profiling report with throughput optimization and resource analysis.

### Module 5: Small-scale Pre-training Project (Week 7-10)
**Objectives:** Execute a complete end-to-end pre-training project.
**Content:** Project planning (capabilities, compute budget, data). Training execution and intervention. Evaluation (probe tasks, perplexity, emergent abilities). Post-training analysis and comparison.
**Lab:** Pre-train a 50-200M GPT. Evaluate on downstream tasks. Write technical report covering architecture, data, training dynamics, results.
**Sources:** [OLMo (Allen AI)](https://github.com/allenai/OLMo) · [LLM360 Analysis](https://github.com/LLM360/analysis360) · [mlabonne/llm-course](https://github.com/mlabonne/llm-course)
**Exit check:** Technical report covering full pipeline with reproducible results.

## Assessment

| Criterion | Pass condition |
|-----------|----------------|
| Architecture | Implement modern GPT (RoPE, SwiGLU, RMSNorm) from scratch |
| Data curation | Cleaned dataset with provenance docs and quality metrics |
| Distributed training | Multi-GPU training with DeepSpeed or FSDP |
| Technical report | Reproducible report covering full pre-training pipeline |

## Exit Criteria
All exit checks met. Artifacts in `.training.mlt/`: dataset pipeline, training config, model checkpoint, report.
