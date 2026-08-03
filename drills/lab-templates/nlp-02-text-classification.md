# Lab: Text Classification

## Prerequisites
- Python 3.10+
- 8GB+ RAM (CPU-only is fine)
- 3GB disk space
- One-time downloads: distilbert-base-uncased model (~270MB) + imdb dataset (~180MB)

## Setup

```bash
python -m venv .training.mlt/labs/text-classification/.venv
source .training.mlt/labs/text-classification/.venv/bin/activate
pip install torch transformers datasets
```

## Objectives
- Fine-tune distilbert-base-uncased for sentiment analysis with the HF Trainer
- Subset the imdb dataset (2000 train / 500 test) so training runs on CPU
- Evaluate accuracy on the held-out test subset

## Code

```python
import numpy as np
from datasets import load_dataset
from transformers import (
    AutoModelForSequenceClassification,
    AutoTokenizer,
    Trainer,
    TrainingArguments,
    set_seed,
)

set_seed(42)

MODEL_NAME = "distilbert-base-uncased"  # ~270MB download on first run
tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME)

# imdb is ~180MB; subsets keep CPU training time reasonable
dataset = load_dataset("imdb")
train_ds = dataset["train"].shuffle(seed=42).select(range(2000))
test_ds = dataset["test"].shuffle(seed=42).select(range(500))

def tokenize(batch):
    return tokenizer(batch["text"], truncation=True, padding="max_length", max_length=256)

train_ds = train_ds.map(tokenize, batched=True)
test_ds = test_ds.map(tokenize, batched=True)

model = AutoModelForSequenceClassification.from_pretrained(MODEL_NAME, num_labels=2)

def compute_metrics(eval_pred):
    logits, labels = eval_pred
    preds = np.argmax(logits, axis=-1)
    return {"accuracy": float((preds == labels).mean())}

training_args = TrainingArguments(
    output_dir="./results",
    num_train_epochs=2,
    per_device_train_batch_size=8,
    per_device_eval_batch_size=16,
    learning_rate=2e-5,
    eval_strategy="epoch",  # older transformers: evaluation_strategy
    save_strategy="no",
    logging_steps=25,
    seed=42,
    report_to=[],
)

trainer = Trainer(
    model=model,
    args=training_args,
    train_dataset=train_ds,
    eval_dataset=test_ds,
    compute_metrics=compute_metrics,
)

trainer.train()
metrics = trainer.evaluate()
print(f"Test accuracy: {metrics['eval_accuracy']:.4f}")
```

## Expected Output
- Training logs with decreasing loss every 25 steps
- An eval accuracy printed after each epoch
- Final test accuracy in the 0.80-0.90 range (random subset, so exact value varies slightly)
- Training takes roughly 15-35 minutes on a modern laptop CPU; a few minutes on a GPU

## Troubleshooting
- `eval_strategy` TypeError: transformers is too old; upgrade with `pip install -U transformers` or rename to `evaluation_strategy`
- Too slow on CPU: reduce to `range(1000)` train / `range(250)` test, `max_length=128`, or 1 epoch
- Out of memory: drop `per_device_train_batch_size` to 4 and `per_device_eval_batch_size` to 8
- Download stalls: set `HF_HUB_ENABLE_HF_TRANSFER=0` or retry; files are cached in `~/.cache/huggingface/`

## Cleanup
```bash
deactivate
rm -rf .training.mlt/labs/text-classification/.venv
rm -rf ./results
```
