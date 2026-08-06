# Lab: Model Evaluation

## Prerequisites
- Python 3.10+
- 8GB+ RAM (CPU-only is fine; GPU optional)
- 4GB disk space (two ~1GB model downloads + venv)

## Setup

```bash
python -m venv .work.mlt/labs/model-evaluation/.venv
source .work.mlt/labs/model-evaluation/.venv/bin/activate
pip install lm-eval torch transformers accelerate
```

One-time downloads on first run (stored in `~/.cache/huggingface/`):
- `Qwen/Qwen2.5-0.5B` (base model): ~1.0GB
- `Qwen/Qwen2.5-0.5B-Instruct` (the "fine-tuned" model): ~1.0GB
- `allenai/ai2_arc` dataset: <10MB

## Objectives
- Run a standard benchmark with lm-evaluation-harness on CPU
- Compare a base model against its fine-tuned (instruct) variant
- Read and interpret a benchmark results table
- Build a tiny hand-rolled eval with exact-match/keyword scoring

## Commands

### Part 1: Benchmark eval with lm-evaluation-harness

Evaluate the base model on a 100-sample subset of ARC-Easy (multiple-choice, scored by log-likelihood, no generation needed):

```bash
lm_eval --model hf \
  --model_args pretrained=Qwen/Qwen2.5-0.5B,dtype=float32 \
  --tasks arc_easy \
  --limit 100 \
  --device cpu \
  --batch_size 8 \
  --output_path ./eval-results/base
```

Evaluate the fine-tuned variant (same 100 samples, deterministic subset):

```bash
lm_eval --model hf \
  --model_args pretrained=Qwen/Qwen2.5-0.5B-Instruct,dtype=float32 \
  --tasks arc_easy \
  --limit 100 \
  --device cpu \
  --batch_size 8 \
  --output_path ./eval-results/instruct
```

Each run prints a results table to the terminal and writes a JSON file under `./eval-results/`. On a laptop CPU expect 5-15 minutes per run.

Optional second task: hellaswag is much slower (long contexts, 4 choices each). Use a smaller limit:

```bash
lm_eval --model hf \
  --model_args pretrained=Qwen/Qwen2.5-0.5B-Instruct,dtype=float32 \
  --tasks hellaswag \
  --limit 25 \
  --device cpu \
  --batch_size 4
```

If you fine-tuned a LoRA adapter in [ft-02-lora-finetuning](ft-02-lora-finetuning.md), evaluate it by pointing `lm_eval` at the base model plus adapter:

```bash
lm_eval --model hf \
  --model_args pretrained=TinyLlama/TinyLlama-1.1B-Chat-v1.0,peft=./lora-output/final \
  --tasks arc_easy --limit 100 --device cpu
```

### Part 2: Hand-built eval (20 custom prompts)

Save as `custom_eval.py`. Twenty short factual questions scored by exact match, falling back to keyword containment:

```python
import re
import string
import torch
from transformers import AutoModelForCausalLM, AutoTokenizer

torch.manual_seed(42)

model_id = "Qwen/Qwen2.5-0.5B-Instruct"  # already cached from Part 1
tokenizer = AutoTokenizer.from_pretrained(model_id)
model = AutoModelForCausalLM.from_pretrained(model_id, dtype=torch.float32)
model.eval()

# 20 prompts: (question, expected answer, acceptable keywords)
EVAL_SET = [
    ("What is the capital of France?", "Paris", ["paris"]),
    ("What is 7 + 8?", "15", ["15"]),
    ("What planet is closest to the Sun?", "Mercury", ["mercury"]),
    ("How many days are in a leap year?", "366", ["366"]),
    ("What is the chemical symbol for gold?", "Au", ["au"]),
    ("Who wrote Romeo and Juliet?", "William Shakespeare", ["shakespeare"]),
    ("What is the largest ocean on Earth?", "Pacific", ["pacific"]),
    ("What is the boiling point of water in Celsius?", "100", ["100"]),
    ("How many continents are there?", "7", ["7", "seven"]),
    ("What language is primarily spoken in Brazil?", "Portuguese", ["portuguese"]),
    ("What is the square root of 81?", "9", ["9", "nine"]),
    ("Which organ pumps blood through the body?", "heart", ["heart"]),
    ("What is the capital of Japan?", "Tokyo", ["tokyo"]),
    ("How many sides does a hexagon have?", "6", ["6", "six"]),
    ("What gas do plants absorb from the air?", "carbon dioxide", ["carbon dioxide", "co2"]),
    ("What is the currency of the United Kingdom?", "pound", ["pound", "sterling", "gbp"]),
    ("In which direction does the Sun rise?", "east", ["east"]),
    ("What is 12 multiplied by 5?", "60", ["60", "sixty"]),
    ("What is the largest planet in the solar system?", "Jupiter", ["jupiter"]),
    ("What is the freezing point of water in Celsius?", "0", ["0", "zero"]),
]

def normalize(text):
    text = text.lower()
    text = re.sub(f"[{re.escape(string.punctuation)}]", " ", text)
    return " ".join(text.split())

def generate(question):
    messages = [
        {"role": "system", "content": "Answer with a single word or number only."},
        {"role": "user", "content": question},
    ]
    inputs = tokenizer.apply_chat_template(
        messages, add_generation_prompt=True, return_tensors="pt"
    )
    with torch.no_grad():
        out = model.generate(inputs, max_new_tokens=16, do_sample=False)
    return tokenizer.decode(out[0][inputs.shape[1]:], skip_special_tokens=True)

exact_hits = 0
keyword_hits = 0
print(f"{'OK':<3} {'Question':<45} {'Expected':<20} Model answer")
print("-" * 100)
for question, expected, keywords in EVAL_SET:
    answer = generate(question)
    norm = normalize(answer)
    exact = normalize(expected) in norm
    keyword = any(k in norm for k in keywords)
    exact_hits += exact
    keyword_hits += keyword
    mark = "Y" if (exact or keyword) else "N"
    print(f"{mark:<3} {question:<45} {expected:<20} {answer.strip()}")

n = len(EVAL_SET)
print("-" * 100)
print(f"Exact-match accuracy: {exact_hits}/{n} = {exact_hits / n:.0%}")
print(f"Keyword accuracy:     {keyword_hits}/{n} = {keyword_hits / n:.0%}")
```

Run it:

```bash
python custom_eval.py
```

Exact match is strict (the normalized expected string must appear in the answer); keyword is lenient (any acceptable synonym). A pass is exact OR keyword.

## Expected Output
- Part 1: a results table per run, e.g.

```
|  Tasks   |Version|Filter|n-shot|Metric|   |Value |   |Stderr|
|arc_easy  |      1|none  |     0|acc   |↑  |0.4xxx|±  |0.0xxx|
|          |       |none  |     0|acc_norm|↑|0.4xxx|±  |0.0xxx|
```

- Base vs Instruct scores within a few points of each other on 100 samples (Instruct typically at or slightly above base); small `--limit` means wide stderr, so differences under ~5 points are noise.
- Part 2: 20 rows with per-prompt Y/N, final keyword accuracy typically 60-90% for this model.

## Troubleshooting
- `lm_eval: command not found`: activate the venv, or reinstall with `pip install lm-eval`.
- Too slow on CPU: lower `--limit` (e.g. 50), skip hellaswag, or switch to `--device cuda` if a GPU is available.
- Out of memory: set `--batch_size 1` and close other applications; the 0.5B model in fp32 needs ~2GB RAM.
- Task not found: list available tasks with `lm_eval --tasks list` and check spelling.
- Model answers are rambling in Part 2: confirm the chat template is applied (`apply_chat_template`) and keep `max_new_tokens` small.
- Download stalls: retry; the HF cache resumes partial downloads. Point `HF_HOME` at a disk with 4GB+ free if needed.

## Cleanup
```bash
rm -rf ./eval-results
deactivate
rm -rf .work.mlt/labs/model-evaluation/.venv
```

Models stay in the HF cache (`~/.cache/huggingface/`). To reclaim ~2GB, remove them with `hf cache ls` and `hf cache rm`.
