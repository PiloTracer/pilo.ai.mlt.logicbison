# Lab: Model Merging

## Prerequisites
- Python 3.10+
- 8GB+ RAM (CPU only is fine)
- 3GB disk space (one-time model download ~550MB, merged outputs ~1.1GB)

## Setup

```bash
python -m venv .work.mlt/labs/model-merging/.venv
source .work.mlt/labs/model-merging/.venv/bin/activate
pip install mergekit transformers torch
```

## Objectives
- Merge two checkpoints of the same architecture with mergekit
- Write linear and SLERP merge configs
- Compare base, fine-tuned, and merged model outputs

## Code

Models: `HuggingFaceTB/SmolLM2-135M` (base) and `HuggingFaceTB/SmolLM2-135M-Instruct` (official fine-tune, same architecture and tokenizer). ~270MB download each.

Linear merge config — save as `merge_linear.yaml`:

```yaml
merge_method: linear
models:
  - model: HuggingFaceTB/SmolLM2-135M
    parameters:
      weight: 0.5
  - model: HuggingFaceTB/SmolLM2-135M-Instruct
    parameters:
      weight: 0.5
dtype: float32
```

SLERP merge config — save as `merge_slerp.yaml` (SLERP needs a `base_model` plus exactly one other model):

```yaml
merge_method: slerp
base_model: HuggingFaceTB/SmolLM2-135M
models:
  - model: HuggingFaceTB/SmolLM2-135M-Instruct
parameters:
  t: 0.5
dtype: float32
```

Run both merges (~1-2 minutes each on CPU):

```bash
mergekit-yaml merge_linear.yaml ./merged-linear
mergekit-yaml merge_slerp.yaml ./merged-slerp
```

Compare all four models — save as `compare.py`:

```python
import gc
import torch
from transformers import AutoModelForCausalLM, AutoTokenizer

torch.manual_seed(42)

MODELS = {
    "base": "HuggingFaceTB/SmolLM2-135M",
    "instruct": "HuggingFaceTB/SmolLM2-135M-Instruct",
    "merged-linear": "./merged-linear",
    "merged-slerp": "./merged-slerp",
}

PROMPTS = [
    "The capital of France is",
    "Explain gravity in one sentence:",
    "Write a haiku about the ocean:",
]

for name, path in MODELS.items():
    tokenizer = AutoTokenizer.from_pretrained(path)
    model = AutoModelForCausalLM.from_pretrained(path, dtype=torch.float32)
    print(f"\n=== {name} ===")
    for prompt in PROMPTS:
        inputs = tokenizer(prompt, return_tensors="pt")
        out = model.generate(
            **inputs,
            max_new_tokens=40,
            do_sample=False,  # greedy decoding for reproducibility
            pad_token_id=tokenizer.eos_token_id,
        )
        new_tokens = out[0][inputs["input_ids"].shape[1]:]
        print(f"\nPrompt: {prompt}")
        print(tokenizer.decode(new_tokens, skip_special_tokens=True))
    # free memory before loading the next model
    del model
    gc.collect()
```

```bash
python compare.py
```

## Expected Output
- Both merges complete with `Safetensors saved` / output dirs `./merged-linear` and `./merged-slerp` (~540MB each in fp32)
- `base` rambles or repeats; `instruct` follows the prompt format better
- Both merged models produce outputs qualitatively between the two parents — some instruct-style behavior at half the "dose"
- Linear and SLERP outputs differ from each other but are broadly similar at t/weight = 0.5

## Troubleshooting
- `slerp` config error: SLERP requires exactly `base_model` + one entry in `models`; do not list two models
- NaN or garbage output from SLERP: keep `dtype: float32` in the YAML — low-precision SLERP is numerically unstable on CPU
- Out of memory during comparison: close other apps; the script already loads one model at a time, but 4 x ~540MB fp32 checkpoints add up
- Merge fails with architecture mismatch: both checkpoints must share architecture and hidden sizes — stick to variants of the same base model
- Slow download: the two models total ~550MB on first run; later runs use the HF cache at `~/.cache/huggingface/`

## Cleanup
```bash
rm -rf ./merged-linear ./merged-slerp
deactivate
rm -rf .work.mlt/labs/model-merging/.venv
```
