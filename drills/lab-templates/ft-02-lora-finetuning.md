# Lab: Fine-tune a Model with LoRA

## Prerequisites
- Python 3.10+
- GPU with 4+ GB VRAM (or CPU for small models)
- 4GB disk space

## Setup

```bash
python -m venv .work.mlt/labs/lora-finetuning/.venv
source .work.mlt/labs/lora-finetuning/.venv/bin/activate
pip install torch transformers peft trl datasets accelerate bitsandbytes
```

## Objectives
- Understand LoRA (Low-Rank Adaptation)
- Fine-tune a small LLM with minimal VRAM
- Compare full fine-tuning vs LoRA parameter counts

## Code

```python
import torch
from transformers import AutoModelForCausalLM, AutoTokenizer, BitsAndBytesConfig
from peft import LoraConfig, get_peft_model, TaskType
from trl import SFTConfig, SFTTrainer
from datasets import load_dataset

model_id = "TinyLlama/TinyLlama-1.1B-Chat-v1.0"

tokenizer = AutoTokenizer.from_pretrained(model_id)
tokenizer.pad_token = tokenizer.eos_token

bnb_config = BitsAndBytesConfig(
    load_in_4bit=True,
    bnb_4bit_quant_type="nf4",
    bnb_4bit_compute_dtype=torch.float16,
)

model = AutoModelForCausalLM.from_pretrained(
    model_id,
    quantization_config=bnb_config,
    device_map="auto",
)

lora_config = LoraConfig(
    r=16,
    lora_alpha=32,
    target_modules=["q_proj", "v_proj"],
    lora_dropout=0.05,
    bias="none",
    task_type=TaskType.CAUSAL_LM,
)

model = get_peft_model(model, lora_config)
model.print_trainable_parameters()

dataset = load_dataset("tatsu-lab/alpaca", split="train[:500]")

def format_instruction(example):
    return f"### Instruction:\n{example['instruction']}\n\n### Response:\n{example['output']}"

dataset = dataset.map(lambda x: {"text": format_instruction(x)})

training_args = SFTConfig(
    output_dir="./lora-output",
    num_train_epochs=1,
    per_device_train_batch_size=2,
    gradient_accumulation_steps=4,
    learning_rate=2e-4,
    fp16=True,
    logging_steps=10,
    save_strategy="epoch",
    max_seq_length=512,
)

trainer = SFTTrainer(
    model=model,
    args=training_args,
    train_dataset=dataset,
    processing_class=tokenizer,
)

trainer.train()
model.save_pretrained("./lora-output/final")
print("Training complete! Model saved to ./lora-output/final")
```

## Expected Output
- Trainable parameters: ~0.5-2% of total
- Training loss decreasing over epochs
- Saved LoRA adapters in ./lora-output/final

## Troubleshooting
- CUDA out of memory: reduce batch_size to 1, or use a smaller model
- bitsandbytes error: ensure CUDA toolkit matches PyTorch CUDA version
- Slow training: reduce dataset size or num_train_epochs

## Cleanup
```bash
rm -rf ./lora-output
deactivate
rm -rf .work.mlt/labs/lora-finetuning/.venv
```
