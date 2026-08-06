# Lab: SFT with TRL

## Prerequisites
- Python 3.10+
- 8GB+ RAM (CPU-only works; small GPU optional)
- 3GB free disk (model + dataset + checkpoints)

## Setup

```bash
python -m venv .work.mlt/labs/sft-trl/.venv
source .work.mlt/labs/sft-trl/.venv/bin/activate
pip install torch transformers trl datasets accelerate
```

## Objectives
- Format an instruction dataset for supervised fine-tuning
- Train a small model with TRL `SFTTrainer` (with packing)
- Run a full fine-tune on CPU or a small GPU
- Compare generations before and after fine-tuning

## Code

Downloads (one-time, cached in `~/.cache/huggingface/`):
- `HuggingFaceTB/SmolLM2-135M` — ~530MB
- `databricks/databricks-dolly-15k` — ~13MB (only a 1000-sample slice is used)

```python
import torch
from datasets import load_dataset
from transformers import AutoModelForCausalLM, AutoTokenizer, set_seed
from trl import SFTConfig, SFTTrainer

set_seed(42)

MODEL = "HuggingFaceTB/SmolLM2-135M"          # 135M params, ~530MB download
DATASET = "databricks/databricks-dolly-15k"   # ~13MB download

device = "cuda" if torch.cuda.is_available() else "cpu"
dtype = torch.bfloat16 if device == "cuda" else torch.float32  # CPU trains in fp32
print(f"Training on: {device}")

tokenizer = AutoTokenizer.from_pretrained(MODEL)
if tokenizer.pad_token is None:
    tokenizer.pad_token = tokenizer.eos_token

model = AutoModelForCausalLM.from_pretrained(MODEL, dtype=dtype).to(device)

# --- Formatting function: instruction/context/response -> single text ---
def format_example(example):
    text = f"### Instruction:\n{example['instruction']}\n\n"
    if example["context"]:
        text += f"### Context:\n{example['context']}\n\n"
    text += f"### Response:\n{example['response']}"
    return text

# --- Generation helper for before/after comparison ---
PROMPT = "### Instruction:\nExplain what a neural network is in one sentence.\n\n### Response:\n"

def generate(model, prompt, max_new_tokens=60):
    inputs = tokenizer(prompt, return_tensors="pt").to(model.device)
    model.eval()
    with torch.no_grad():
        out = model.generate(
            **inputs,
            max_new_tokens=max_new_tokens,
            do_sample=False,
            pad_token_id=tokenizer.pad_token_id,
        )
    return tokenizer.decode(out[0][inputs["input_ids"].shape[1]:], skip_special_tokens=True)

print("\n=== BEFORE fine-tuning ===")
print(generate(model, PROMPT))

# --- Dataset: 1000-sample slice of databricks-dolly-15k ---
dataset = load_dataset(DATASET, split="train").select(range(1000))

# --- SFT training ---
config = SFTConfig(
    output_dir=".work.mlt/labs/sft-trl/checkpoints",
    per_device_train_batch_size=4,
    num_train_epochs=1,
    learning_rate=2e-5,
    max_length=512,        # older trl: use max_seq_length instead
    packing=True,          # pack formatted examples into full 512-token sequences
    logging_steps=10,
    save_strategy="no",
    bf16=(device == "cuda"),
    report_to="none",
    seed=42,
)

trainer = SFTTrainer(
    model=model,
    args=config,
    train_dataset=dataset,
    formatting_func=format_example,
    processing_class=tokenizer,
)
trainer.train()

print("\n=== AFTER fine-tuning ===")
print(generate(model, PROMPT))
```

Expected runtime: ~10-20 minutes on CPU, a few minutes on a small GPU.

## Expected Output
- Training loss printed every 10 steps, trending down (e.g. from ~2.5 toward ~1.5)
- BEFORE generation: rambling, repetitive, or ignores the instruction format
- AFTER generation: a short, on-topic answer in the style of the training data (Dolly-style concise responses)
- Qualitative win matters more than the exact numbers at this scale

## Troubleshooting
- `TypeError: unexpected keyword argument 'max_length'`: your trl version is older; rename `max_length` to `max_seq_length`
- Out of memory or too slow on CPU: set `per_device_train_batch_size=1`, or cap training with `max_steps=50`
- Model download fails or stalls: check connectivity and retry; files resume in `~/.cache/huggingface/`
- Loss flat or generations unchanged: raise `learning_rate` to `5e-5` or train 2 epochs

## Cleanup
```bash
deactivate
rm -rf .work.mlt/labs/sft-trl/.venv
rm -rf .work.mlt/labs/sft-trl/checkpoints
```
The model and dataset stay in the HF cache (`~/.cache/huggingface/`); remove them with `hf cache rm` if you want the disk back.
