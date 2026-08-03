# Lab: Named Entity Recognition

## Prerequisites
- Python 3.10+
- 8GB+ RAM (CPU-only is fine)
- 2GB disk space (model ~250MB, dataset ~10MB, one-time downloads)

## Setup

```bash
python -m venv .training.mlt/labs/ner/.venv
source .training.mlt/labs/ner/.venv/bin/activate
pip install torch transformers datasets seqeval accelerate
```

## Objectives
- Fine-tune distilbert-base-uncased for token classification (NER)
- Align BIO labels with subword tokenization
- Evaluate with seqeval precision/recall/F1
- Run inference on new sentences

## Code

```python
import numpy as np
import torch
from datasets import load_dataset
from transformers import (
    AutoTokenizer,
    AutoModelForTokenClassification,
    DataCollatorForTokenClassification,
    TrainingArguments,
    Trainer,
    pipeline,
)
from seqeval.metrics import precision_score, recall_score, f1_score

SEED = 42
torch.manual_seed(SEED)
np.random.seed(SEED)

# CPU-feasible subset of conll2003 (news text, 4 entity types: PER, ORG, LOC, MISC)
dataset = load_dataset("conll2003")
train_ds = dataset["train"].select(range(2000))
eval_ds = dataset["validation"].select(range(500))
label_names = dataset["train"].features["ner_tags"].feature.names
id2label = {i: name for i, name in enumerate(label_names)}
label2id = {name: i for i, name in enumerate(label_names)}

model_name = "distilbert-base-uncased"  # 66M params, ~250MB download
tokenizer = AutoTokenizer.from_pretrained(model_name)

def tokenize_and_align_labels(examples):
    tokenized = tokenizer(
        examples["tokens"],
        truncation=True,
        is_split_into_words=True,  # input is already word-tokenized
    )
    aligned_labels = []
    for i, word_labels in enumerate(examples["ner_tags"]):
        word_ids = tokenized.word_ids(batch_index=i)
        label_ids = []
        prev_word_id = None
        for word_id in word_ids:
            if word_id is None:
                # special tokens ([CLS], [SEP], padding) get no label
                label_ids.append(-100)
            elif word_id != prev_word_id:
                # first subword of a word keeps the gold label
                label_ids.append(word_labels[word_id])
            else:
                # continuation subwords are ignored in the loss
                label_ids.append(-100)
            prev_word_id = word_id
        aligned_labels.append(label_ids)
    tokenized["labels"] = aligned_labels
    return tokenized

train_tok = train_ds.map(tokenize_and_align_labels, batched=True)
eval_tok = eval_ds.map(tokenize_and_align_labels, batched=True)

model = AutoModelForTokenClassification.from_pretrained(
    model_name,
    num_labels=len(label_names),
    id2label=id2label,
    label2id=label2id,
)

data_collator = DataCollatorForTokenClassification(tokenizer)

def compute_metrics(eval_pred):
    logits, labels = eval_pred
    predictions = np.argmax(logits, axis=-1)
    # drop ignored positions (-100), convert ids to label strings for seqeval
    true_labels = [
        [label_names[l] for l in label_row if l != -100]
        for label_row in labels
    ]
    true_preds = [
        [label_names[p] for (p, l) in zip(pred_row, label_row) if l != -100]
        for pred_row, label_row in zip(predictions, labels)
    ]
    return {
        "precision": precision_score(true_labels, true_preds),
        "recall": recall_score(true_labels, true_preds),
        "f1": f1_score(true_labels, true_preds),
    }

training_args = TrainingArguments(
    output_dir="./ner-checkpoints",
    eval_strategy="epoch",
    learning_rate=2e-5,
    per_device_train_batch_size=16,
    per_device_eval_batch_size=32,
    num_train_epochs=3,
    weight_decay=0.01,
    logging_steps=50,
    save_strategy="no",       # timed drill: skip checkpoint writes
    report_to="none",
    seed=SEED,
    fp16=torch.cuda.is_available(),  # mixed precision only if a GPU is present
)

trainer = Trainer(
    model=model,
    args=training_args,
    train_dataset=train_tok,
    eval_dataset=eval_tok,
    processing_class=tokenizer,
    data_collator=data_collator,
    compute_metrics=compute_metrics,
)

trainer.train()
metrics = trainer.evaluate()
print(f"eval precision: {metrics['eval_precision']:.3f}")
print(f"eval recall:    {metrics['eval_recall']:.3f}")
print(f"eval f1:        {metrics['eval_f1']:.3f}")

# Inference demo on new sentences
ner = pipeline(
    "token-classification",
    model=model,
    tokenizer=tokenizer,
    aggregation_strategy="simple",  # merge subwords back into whole entities
)
sentences = [
    "Angela Merkel met Tim Cook in Berlin to discuss Apple's new office.",
    "The Amazon rainforest spans Brazil, Peru, and Colombia.",
]
for sentence in sentences:
    print(f"\n{sentence}")
    for entity in ner(sentence):
        print(f"  {entity['word']:<20} {entity['entity_group']:<5} {entity['score']:.3f}")
```

## Expected Output
- Training loss decreasing over 3 epochs (starts ~0.3-0.5, ends below 0.1)
- Eval F1 around 0.75-0.85 on the 500-example validation subset (PER/ORG strong, MISC weaker)
- Inference demo prints detected entities with types and confidence scores, e.g. `Angela Merkel -> PER`, `Berlin -> LOC`, `Apple -> ORG`

## Troubleshooting
- `OutOfMemoryError` or swap thrashing on CPU: reduce `per_device_train_batch_size` to 8 and the subset to `range(1000)`
- Training too slow: cut epochs to 1-2 or shrink the subset; full conll2003 is not needed for this drill
- seqeval warns about invalid BIO sequences: expected with a small model/subset; it means the model emitted e.g. `I-PER` without a preceding `B-PER`
- Entities split into subwords in the demo (e.g. `Mer##kel`): ensure `aggregation_strategy="simple"` is set on the pipeline

## Cleanup
```bash
deactivate
rm -rf .training.mlt/labs/ner/.venv ner-checkpoints
```
