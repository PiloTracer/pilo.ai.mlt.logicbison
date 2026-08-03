# Lab: QLoRA Fine-tuning

## Prerequisites
- Python 3.10+
- NVIDIA GPU with 6-8GB VRAM (CUDA); QLoRA requires GPU via bitsandbytes
- 6GB disk space
- CPU-only? QLoRA does not run on CPU. Do the LoRA lab on CPU instead: [ft-02-lora-finetuning](ft-02-lora-finetuning.md)

## Setup

```bash
python -m venv .training.mlt/labs/qlora-finetuning/.venv
source .training.mlt/labs/qlora-finetuning/.venv/bin/activate
pip install torch transformers peft trl datasets accelerate bitsandbytes
```

## Objectives
- Load a 1.5B model in 4-bit NF4 with bitsandbytes
- Attach LoRA adapters and measure trainable parameters
- Fine-tune on a small instruction set within 6-8GB VRAM
- Save the adapter and track peak VRAM usage

## Code

```python
import torch
from datasets import Dataset
from transformers import (
    AutoModelForCausalLM,
    AutoTokenizer,
    BitsAndBytesConfig,
    set_seed,
)
from peft import LoraConfig, get_peft_model, prepare_model_for_kbit_training
from trl import SFTConfig, SFTTrainer

set_seed(42)

assert torch.cuda.is_available(), "QLoRA needs a CUDA GPU; for CPU do ft-02 LoRA instead."
print(f"GPU: {torch.cuda.get_device_name(0)}")

def vram_gb():
    """Allocated and peak-reserved VRAM in GB."""
    alloc = torch.cuda.memory_allocated() / 1e9
    peak = torch.cuda.max_memory_reserved() / 1e9
    return f"allocated={alloc:.2f}GB peak_reserved={peak:.2f}GB"

# ~3.1GB one-time download into ~/.cache/huggingface/
model_id = "Qwen/Qwen2.5-1.5B-Instruct"

tokenizer = AutoTokenizer.from_pretrained(model_id)
tokenizer.pad_token = tokenizer.eos_token

# QLoRA: 4-bit NF4 weights + double quantization, compute in bf16
bnb_config = BitsAndBytesConfig(
    load_in_4bit=True,
    bnb_4bit_quant_type="nf4",
    bnb_4bit_use_double_quant=True,
    bnb_4bit_compute_dtype=torch.bfloat16,
)

model = AutoModelForCausalLM.from_pretrained(
    model_id,
    quantization_config=bnb_config,
    device_map="auto",
)
print(f"After 4-bit load: {vram_gb()}")

# Small embedded instruction set: teach a fixed response style
examples = [
    {"instruction": "What is overfitting?", "output": "Overfitting is when a model memorizes training data and fails to generalize to new data."},
    {"instruction": "Define a learning rate.", "output": "The learning rate is the step size used to update model weights during gradient descent."},
    {"instruction": "What is a loss function?", "output": "A loss function measures how far the model's predictions are from the true values."},
    {"instruction": "Explain gradient descent in one sentence.", "output": "Gradient descent iteratively moves weights downhill on the loss surface to reduce error."},
    {"instruction": "What is a validation set?", "output": "A validation set is held-out data used to tune hyperparameters and detect overfitting."},
    {"instruction": "Define regularization.", "output": "Regularization adds penalties or constraints to reduce model complexity and overfitting."},
    {"instruction": "What is an epoch?", "output": "An epoch is one full pass of the training data through the training loop."},
    {"instruction": "What is a transformer?", "output": "A transformer is a neural architecture built on self-attention instead of recurrence."},
    {"instruction": "Define tokenization.", "output": "Tokenization splits raw text into tokens, the integer-indexed units a model processes."},
    {"instruction": "What is a checkpoint?", "output": "A checkpoint is a saved snapshot of model weights taken during training."},
    {"instruction": "Explain fine-tuning.", "output": "Fine-tuning continues training a pretrained model on task-specific data."},
    {"instruction": "What is quantization?", "output": "Quantization stores weights in lower precision, such as 4-bit, to shrink memory use."},
    {"instruction": "Define LoRA.", "output": "LoRA trains small low-rank adapter matrices while freezing the base model weights."},
    {"instruction": "What is a batch size?", "output": "Batch size is the number of examples processed together in one training step."},
    {"instruction": "Explain self-attention briefly.", "output": "Self-attention lets each token weigh the relevance of every other token in the sequence."},
    {"instruction": "What is the Hugging Face Hub?", "output": "The Hugging Face Hub is a public repository for sharing models, datasets, and demos."},
]

def format_instruction(example):
    return f"### Instruction:\n{example['instruction']}\n\n### Response:\n{example['output']}"

dataset = Dataset.from_list(
    [{"text": format_instruction(e)} for e in examples]
)

# Freeze 4-bit base, train only the low-rank adapters
model = prepare_model_for_kbit_training(model)
model.config.use_cache = False

lora_config = LoraConfig(
    r=16,
    lora_alpha=32,
    target_modules=["q_proj", "k_proj", "v_proj", "o_proj"],
    lora_dropout=0.05,
    bias="none",
    task_type="CAUSAL_LM",
)

model = get_peft_model(model, lora_config)
model.print_trainable_parameters()

training_args = SFTConfig(
    output_dir="./qlora-output",
    num_train_epochs=3,
    per_device_train_batch_size=2,
    gradient_accumulation_steps=4,
    learning_rate=2e-4,
    bf16=True,
    logging_steps=5,
    save_strategy="no",
    max_seq_length=256,
    report_to="none",
    seed=42,
)

trainer = SFTTrainer(
    model=model,
    args=training_args,
    train_dataset=dataset,
    processing_class=tokenizer,
)

trainer.train()
print(f"After training: {vram_gb()}")

# Save only the adapter weights (a few MB, not the full model)
model.save_pretrained("./qlora-output/final")
tokenizer.save_pretrained("./qlora-output/final")
print("Adapter saved to ./qlora-output/final")
```

## Scaling Up

| GPU VRAM | Model | Changes |
|----------|-------|---------|
| 6-8GB | Qwen/Qwen2.5-1.5B-Instruct (default) | none |
| 16GB+ | Qwen/Qwen2.5-7B-Instruct | swap `model_id`, keep everything else |
| 16GB+ | meta-llama/Llama-3.1-8B-Instruct | swap `model_id`; gated repo, requires accepting the license and `hf auth login` |

If VRAM is tight at 7B, drop `per_device_train_batch_size` to 1 and raise `gradient_accumulation_steps` to 8.

## Expected Output
- 4-bit model load using roughly 1.5-2GB VRAM
- Trainable parameters: ~0.5-1.5% of total
- Training loss decreasing over logged steps; peak VRAM under ~6GB
- Adapter files (`adapter_model.safetensors`, ~10-30MB) in ./qlora-output/final

## Troubleshooting
- CUDA out of memory: reduce batch size to 1, lower `max_seq_length`, or close other GPU processes
- bitsandbytes import or CUDA error: no GPU detected, or PyTorch CUDA build mismatch; reinstall torch with the CUDA wheel for your driver, or do ft-02 on CPU
- 401/403 downloading Llama-3.1-8B-Instruct: gated model; accept the license on its HF page and run `hf auth login`, or use the ungated Qwen2.5-7B-Instruct
- Loss stuck or NaN: verify `bf16=True` matches GPU support (use `fp16=True` on older GPUs) and lower the learning rate to 1e-4

## Cleanup
```bash
rm -rf ./qlora-output
deactivate
rm -rf .training.mlt/labs/qlora-finetuning/.venv
```
