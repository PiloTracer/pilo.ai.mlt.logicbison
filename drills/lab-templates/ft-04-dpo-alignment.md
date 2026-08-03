# Lab: DPO Alignment

## Prerequisites
- Python 3.10+
- CPU-only is fine (GPU optional); 8GB+ RAM, 16GB recommended
- 2GB disk space (SmolLM2-135M is ~550MB, dataset ~80MB one-time downloads)

## Setup

```bash
python -m venv .training.mlt/labs/dpo-alignment/.venv
source .training.mlt/labs/dpo-alignment/.venv/bin/activate
pip install torch transformers trl datasets accelerate peft
```

## Objectives
- Understand Direct Preference Optimization (chosen/rejected pairs, beta)
- Train a small model with TRL DPOTrainer, including reference model handling
- Compare model behavior before and after alignment

## Code

```python
import torch
from datasets import load_dataset
from transformers import AutoModelForCausalLM, AutoTokenizer
from trl import DPOConfig, DPOTrainer

torch.manual_seed(42)

# ~550MB one-time download. CPU-feasible. Swap to Qwen/Qwen2.5-0.5B-Instruct
# (~1GB) if you have a GPU or more RAM.
model_id = "HuggingFaceTB/SmolLM2-135M-Instruct"

tokenizer = AutoTokenizer.from_pretrained(model_id)
tokenizer.pad_token = tokenizer.eos_token
model = AutoModelForCausalLM.from_pretrained(model_id)

# Optional: start from your FT-01 SFT LoRA adapter instead of the raw model:
#   from peft import PeftModel
#   model = PeftModel.from_pretrained(model, "<ft-01-adapter-path>")
# DPOTrainer then uses the base model (adapters disabled) as the implicit reference.

# Preference dataset (~80MB one-time download), 1000-sample slice.
# Columns: system, question, chosen, rejected (chosen/rejected are chat message lists).
dataset = load_dataset("Intel/orca_dpo_pairs", split="train").select(range(1000))

# Convert to the standard DPO format: prompt / chosen / rejected strings.
def to_dpo_format(example):
    prompt = f"{example['system']}\n\n{example['question']}".strip()
    return {
        "prompt": prompt,
        "chosen": example["chosen"][-1]["content"],
        "rejected": example["rejected"][-1]["content"],
    }

dataset = dataset.map(to_dpo_format, remove_columns=dataset.column_names)
print(dataset[0]["prompt"][:200])
print("CHOSEN:", dataset[0]["chosen"][:200])
print("REJECTED:", dataset[0]["rejected"][:200])

eval_prompts = [
    "Explain the difference between a virus and a bacterium.",
    "How do I improve my time management skills?",
    "What are the main causes of climate change?",
]

def generate(model, label):
    print(f"\n=== {label} ===")
    model.eval()
    for p in eval_prompts:
        inputs = tokenizer(p, return_tensors="pt")
        with torch.no_grad():
            out = model.generate(
                **inputs,
                max_new_tokens=80,
                do_sample=False,
                pad_token_id=tokenizer.eos_token_id,
            )
        new_tokens = out[0][inputs["input_ids"].shape[1]:]
        print(f"\nPrompt: {p}")
        print(f"Response: {tokenizer.decode(new_tokens, skip_special_tokens=True)}")

# Baseline behavior before alignment
generate(model, "BEFORE DPO")

training_args = DPOConfig(
    output_dir="./dpo-output",
    beta=0.1,                       # strength of the KL penalty to the reference model
    max_steps=50,                   # ~15 min on CPU; raise to 200+ on GPU
    per_device_train_batch_size=1,
    gradient_accumulation_steps=4,
    learning_rate=5e-7,
    max_prompt_length=256,
    max_length=512,
    logging_steps=5,
    save_strategy="no",
    report_to="none",
    seed=42,
)

# ref_model=None with a full (non-PEFT) model: TRL clones the initial policy
# weights as the frozen reference model automatically.
trainer = DPOTrainer(
    model=model,
    ref_model=None,
    args=training_args,
    train_dataset=dataset,
    processing_class=tokenizer,
)

trainer.train()
trainer.save_model("./dpo-output/final")

# Behavior after alignment
generate(trainer.model, "AFTER DPO")
```

## Expected Output
- Sample prompt/chosen/rejected triple printed, chosen visibly better than rejected
- Training logs: loss decreasing, `rewards/accuracies` climbing above 0.5, `rewards/margins` growing
- After-DPO responses more helpful/on-topic than the repetitive or empty before-DPO ones
- Trained model saved to ./dpo-output/final

## Troubleshooting
- Out of RAM: close other apps, reduce `max_length` to 256 and `max_prompt_length` to 128
- Training too slow: lower `max_steps` (e.g. 20) — trends appear early; or use a GPU with `Qwen/Qwen2.5-0.5B-Instruct`
- Rewards stuck at ~0.5 accuracy: raise `beta` (e.g. 0.3) if outputs degrade, or train more steps; 50 steps is a smoke test
- `KeyError` or format error from the dataset: TRL expects exactly `prompt`/`chosen`/`rejected` string columns; check the `to_dpo_format` mapping

## Cleanup
```bash
rm -rf ./dpo-output
deactivate
rm -rf .training.mlt/labs/dpo-alignment/.venv
```
