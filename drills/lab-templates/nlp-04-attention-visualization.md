# Lab: Attention Visualization

## Prerequisites
- Python 3.10+
- 8GB RAM, CPU only
- ~270MB one-time model download (distilbert-base-uncased)

## Setup

```bash
python -m venv .work.mlt/labs/attention-visualization/.venv
source .work.mlt/labs/attention-visualization/.venv/bin/activate
pip install torch transformers matplotlib
```

## Objectives
- Extract self-attention weights from a pretrained DistilBERT
- Plot attention heatmaps per head and per layer with token labels
- Interpret what different attention heads focus on

## Code

```python
import torch
import matplotlib.pyplot as plt
from transformers import AutoTokenizer, AutoModel

torch.manual_seed(42)

# Load tokenizer and model with attention outputs enabled
# distilbert-base-uncased: 6 layers, 12 heads per layer, ~270MB download
model_name = "distilbert-base-uncased"
tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModel.from_pretrained(model_name, output_attentions=True)
model.eval()

sentence = "The cat sat on the mat because it was tired."

# Tokenize; include special tokens so the full attention pattern is visible
inputs = tokenizer(sentence, return_tensors="pt")
tokens = tokenizer.convert_ids_to_tokens(inputs["input_ids"][0])
print(f"Tokens ({len(tokens)}): {tokens}")

# Forward pass without gradients; inference is cheap on CPU
with torch.no_grad():
    outputs = model(**inputs)

# attentions: tuple of n_layers tensors, each (batch=1, n_heads, seq_len, seq_len)
attentions = outputs.attentions
n_layers = len(attentions)
n_heads = attentions[0].shape[1]
print(f"Layers: {n_layers}, heads per layer: {n_heads}")

# Grid of heatmaps: one row per layer, one column per head
fig, axes = plt.subplots(n_layers, n_heads, figsize=(3 * n_heads, 3 * n_layers))
for layer in range(n_layers):
    attn = attentions[layer][0]  # (n_heads, seq, seq)
    for head in range(n_heads):
        ax = axes[layer, head]
        ax.imshow(attn[head].numpy(), cmap="viridis", vmin=0, vmax=1)
        if layer == 0:
            ax.set_title(f"Head {head}", fontsize=8)
        if head == 0:
            ax.set_ylabel(f"Layer {layer}", fontsize=8)
        ax.set_xticks(range(len(tokens)), tokens, rotation=90, fontsize=6)
        ax.set_yticks(range(len(tokens)), tokens, fontsize=6)

plt.suptitle(f"Self-attention heatmaps: {sentence}")
plt.tight_layout()
plt.savefig("attention_heatmaps.png", dpi=150)
plt.show()

# Focus view: which tokens does the pronoun "it" attend to, per layer?
it_idx = tokens.index("it")
for layer in range(n_layers):
    scores = attentions[layer][0, :, it_idx, :].mean(dim=0)  # avg over heads
    top = scores.argsort(descending=True)[:3]
    ranked = ", ".join(f"{tokens[i]}({scores[i]:.2f})" for i in top)
    print(f"Layer {layer}: 'it' attends most to {ranked}")
```

## Expected Output
- Token list starts with `[CLS]` and ends with `[SEP]`
- "Layers: 6, heads per layer: 12" printed
- `attention_heatmaps.png`: a 6x12 grid of heatmaps, token labels on both axes
- Bright diagonals in many heads (tokens attend to themselves)
- The pronoun-resolution printout: "it" should rank "cat" or "was" among its top-attended tokens in middle/upper layers

## Discussion
Typical patterns to look for in the grid:
- Positional heads: strong attention to the previous/next token (off-diagonal stripes), common in lower layers.
- Delimiter heads: a vertical stripe on `[CLS]` or `[SEP]`; these heads act as a "no-op" or aggregation sink.
- Syntactic heads: verbs attending to their subjects/objects; e.g. "sat" attending to "cat".
- Coreference heads: in upper layers, "it" attending back to "cat" — the model resolves the pronoun without ever being told what a pronoun is.
Not every head is interpretable; some spread attention nearly uniformly.

## Troubleshooting
- `KeyError` / empty `outputs.attentions`: pass `output_attentions=True` to `from_pretrained`, not to the forward call on older transformers versions
- Token labels unreadable: increase figure size or reduce font; or plot a single layer with `plt.figure(figsize=(8, 8))`
- Download fails or is slow: the ~270MB model is fetched once into `~/.cache/huggingface/`; rerun and it resumes from cache
- `ValueError` on `tokens.index("it")`: pick a different sentence or token present after tokenization (check the printed token list)
- Blank heatmaps: ensure you index `attentions[layer][0]` (batch dim) before the head dim

## Cleanup
```bash
deactivate
rm -rf .work.mlt/labs/attention-visualization/.venv
rm -f attention_heatmaps.png
```
