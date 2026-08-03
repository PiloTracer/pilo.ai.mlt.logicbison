# LLM Fine-tuning

**Slug:** `llm-finetuning`
**Duration:** 6-8 weeks · 3-4 sessions/week
**Level:** Intermediate-Advanced
**Prerequisites:** `nlp-and-transformers` (all modules)

## Audience
Learners who can fine-tune BERT-class models and want to specialize in 7B+ LLMs. Common misconception: "LoRA is always sufficient" and "DPO eliminates reward models entirely."

## Duration & Cadence
6-8 weeks, 3-4 sessions/week. Sessions: 90 min (technique + hands-on). Async: fine-tuning runs, eval experiments.

## Outcomes
1. Fine-tune an LLM with LoRA/QLoRA using Unsloth on a single GPU (7B+ on ≥16GB VRAM; 1-3B models like Qwen2.5-1.5B or Llama-3.2-1B on smaller cards)
2. Apply DPO and GRPO for preference alignment
3. Merge fine-tuned models with mergekit
4. Evaluate with benchmarks, human eval, and LLM-as-judge
5. Produce a complete post-training pipeline

## Modules

### Module 1: Post-training Datasets (Week 1-2)
**Objectives:** Build instruction and preference datasets for fine-tuning.
**Content:** Formats (Alpaca, ShareGPT, ChatML). Synthetic data (evol-instruct, self-instruct, LLM generation). Enhancement (back-translation, rejection sampling). Filtering (perplexity, reward scoring, dedup, clustering). Dataset mixing and balancing.
**Lab:** Generate synthetic instruction data with ollama, filter by quality, deduplicate, format for TRL `SFTTrainer`.
**Sources:** [distilabel](https://github.com/argilla-io/distilabel) · [mlabonne/llm-course](https://github.com/mlabonne/llm-course) · [HF Chat Templates](https://huggingface.co/docs/transformers/chat_templating)
**Exit check:** Curated dataset with provenance, quality metrics, format validation.

### Module 2: Supervised Fine-tuning (Week 2-4)
**Objectives:** Master SFT with LoRA/QLoRA on consumer hardware.
**Content:** Full vs parameter-efficient fine-tuning tradeoffs. LoRA (rank, target modules, merging). QLoRA (4-bit, NF4, double quant, paged optimizers). Unsloth (2x speed, memory optimization). TRL `SFTTrainer` (packing, max seq length). Axolotl (YAML config, multi-model).
**Lab:** Fine-tune Llama 3.1 8B with Unsloth QLoRA on a single GPU (or Qwen2.5-1.5B / Llama-3.2-1B on ≤8GB VRAM). Compare Unsloth vs standard HF training speed/memory.
**Sources:** [Unsloth](https://docs.unsloth.ai/) · [TRL SFTTrainer](https://huggingface.co/docs/trl/sft_trainer) · [Axolotl](https://axolotl-ai-cloud.github.io/axolotl/) · [Raschka](https://magazine.sebastianraschka.com/)
**Exit check:** QLoRA fine-tune of a 1.5B-8B model (scaled to available VRAM) showing measurable task improvement.

### Module 3: Preference Alignment (Week 4-6)
**Objectives:** Align LLMs with DPO, GRPO, and PPO.
**Content:** RLHF overview (reward model, PPO, reward hacking). DPO (Bradley-Terry, beta, reference model). GRPO (group sampling, no critic). PPO with TRL (reward/value models, KL penalty). Preference data (pairwise, ranking, synthetic).
**Lab:** Train DPO model with `DPOTrainer` on preference pairs. Try GRPO with `GRPOTrainer` for math reasoning. Compare alignment quality.
**Sources:** [TRL DPOTrainer](https://huggingface.co/docs/trl/dpo_trainer) · [TRL GRPOTrainer](https://huggingface.co/docs/trl/grpo_trainer) · [DPO Paper](https://arxiv.org/abs/2305.18290) · [GRPO Paper](https://arxiv.org/abs/2402.03300)
**Exit check:** DPO and GRPO runs with documented preference improvement.

### Module 4: Model Merging (Week 5-6)
**Objectives:** Combine models without additional training.
**Content:** Techniques (linear, SLERP, TIES, DARE). mergekit (YAML config, layer-wise merging). Multi-model merging (3+ models, FrankenMerging). Tokenizer compatibility and architecture matching.
**Lab:** Merge two LoRA adapters fine-tuned on different tasks using mergekit. Try SLERP and DARE. Evaluate on both tasks.
**Sources:** [mergekit](https://github.com/arcee-ai/mergekit) · [mlabonne/llm-course](https://github.com/mlabonne/llm-course)
**Exit check:** Merged model retains capabilities from both sources.

### Module 5: Evaluation (Week 6-8)
**Objectives:** Rigorously evaluate fine-tuned models.
**Content:** Benchmarks (MMLU, HellaSwag, ARC, TruthfulQA, GSM8K). Frameworks (lighteval, lm-evaluation-harness). Human evaluation (rating scales, pairwise, agreement). LLM-as-judge (prompt design, limitations). Task-specific (HumanEval, GSM8K, ROUGE, IFEval).
**Lab:** Evaluate fine-tuned model with lighteval. Design custom eval suite. Run LLM-as-judge comparison (base vs SFT vs DPO).
**Sources:** [lighteval](https://github.com/huggingface/lighteval) · [lm-eval-harness](https://github.com/EleutherAI/lm-evaluation-harness) · [HF Evaluate](https://huggingface.co/docs/evaluate/index)
**Exit check:** Comprehensive eval report comparing base, SFT, and DPO models.

## Assessment

| Criterion | Pass condition |
|-----------|----------------|
| Data curation | Validated dataset with quality metrics |
| SFT mastery | QLoRA fine-tune (1.5B-8B, scaled to hardware) showing task improvement |
| Alignment | DPO/GRPO with measurable preference gains |
| Merging | Merged model retains both source capabilities |
| Evaluation | Report with benchmarks + human/LLM-judge results |

## Exit Criteria
All exit checks met. Artifacts in `.training.mlt/`: dataset, SFT checkpoint, DPO checkpoint, merge config, eval report.
