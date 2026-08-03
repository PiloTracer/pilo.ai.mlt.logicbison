# Lab: Tokenizer Training

## Prerequisites
- Python 3.10+
- 8GB RAM (CPU only)
- 2GB disk space

## Setup

```bash
python -m venv .training.mlt/labs/tokenizer-training/.venv
source .training.mlt/labs/tokenizer-training/.venv/bin/activate
pip install tokenizers datasets transformers
```

## Objectives
- Train a custom BPE tokenizer on a small text corpus
- Choose a vocab size and define special tokens
- Save and reload a tokenizer from disk
- Measure fertility (tokens/word) against a pretrained tokenizer on domain text

## Code

```python
from datasets import load_dataset
from tokenizers import Tokenizer
from tokenizers.models import BPE
from tokenizers.trainers import BpeTrainer
from tokenizers.pre_tokenizers import Metaspace
from tokenizers.decoders import Metaspace as MetaspaceDecoder
from transformers import AutoTokenizer

# Corpus: wikitext-2 subset (one-time download ~12MB, cached in ~/.cache/huggingface)
dataset = load_dataset("Salesforce/wikitext", "wikitext-2-raw-v1", split="train")
texts = [t for t in dataset.select(range(5000))["text"] if t.strip()]
eval_texts = [t for t in dataset.select(range(5000, 6000))["text"] if t.strip()]

def batch_iterator(batch_size=1000):
    for i in range(0, len(texts), batch_size):
        yield texts[i:i + batch_size]

# Special tokens the tokenizer must always reserve
SPECIAL_TOKENS = ["[PAD]", "[UNK]", "[BOS]", "[EOS]"]

def train_bpe(vocab_size):
    tok = Tokenizer(BPE(unk_token="[UNK]"))
    # Metaspace marks word starts with ▁ so decode() can reconstruct whitespace
    tok.pre_tokenizer = Metaspace()
    tok.decoder = MetaspaceDecoder()
    trainer = BpeTrainer(
        vocab_size=vocab_size,
        special_tokens=SPECIAL_TOKENS,
        show_progress=False,
    )
    tok.train_from_iterator(batch_iterator(), trainer=trainer)
    return tok

# Vocab size choice: 2k is too small, 8k is reasonable for a small corpus;
# production LMs use 32k-256k trained on much more data
tok_small = train_bpe(2000)
tok_main = train_bpe(8000)
print(f"Small vocab: {tok_small.get_vocab_size()}, main vocab: {tok_main.get_vocab_size()}")

def fertility(tokens_per_text, texts):
    """Average tokens per word; lower is better compression."""
    total_tokens = sum(len(tokens_per_text(t)) for t in texts)
    total_words = sum(len(t.split()) for t in texts)
    return total_tokens / total_words

f_small = fertility(lambda t: tok_small.encode(t).ids, eval_texts)
f_main = fertility(lambda t: tok_main.encode(t).ids, eval_texts)
print(f"Fertility on held-out wikitext: vocab=2k {f_small:.2f}, vocab=8k {f_main:.2f} tokens/word")

# Save and reload
tok_main.save("custom-tokenizer.json")
loaded = Tokenizer.from_file("custom-tokenizer.json")

# Round-trip check
sample = "Tokenizers break text into subword units."
encoded = loaded.encode(sample)
print("Tokens:", encoded.tokens)
print("IDs:", encoded.ids)
assert loaded.decode(encoded.ids) == sample

# Fertility on out-of-domain text: ML jargon and code
domain_texts = [
    "The transformer architecture uses multi-head self-attention mechanisms.",
    "Backpropagation computes gradients via the chain rule of calculus.",
    "def tokenize(text): return tokenizer.encode(text).ids",
    "Hyperparameters like learning_rate=2e-4 and batch_size=32 affect convergence.",
]

# GPT-2 tokenizer as pretrained baseline (~1MB download)
gpt2 = AutoTokenizer.from_pretrained("gpt2")

f_custom = fertility(lambda t: loaded.encode(t).ids, domain_texts)
f_gpt2 = fertility(lambda t: gpt2(t)["input_ids"], domain_texts)
print(f"Domain text fertility: custom {f_custom:.2f} vs gpt2 {f_gpt2:.2f} tokens/word")
```

## Expected Output
- Vocab sizes exactly 2000 and 8000
- vocab=8k fertility lower than vocab=2k on held-out wikitext (~1.4 vs ~1.8 tokens/word)
- Round-trip assert passes; subword tokens printed with `▁` marking word starts
- Custom tokenizer fertility higher than GPT-2 on the domain texts (~3.4 vs ~2.4): domain mismatch makes the wikitext-trained tokenizer split code and jargon into more pieces

## Troubleshooting
- `load_dataset` fails on wikitext: ensure `datasets` is current (`pip install -U datasets`); the `Salesforce/wikitext` parquet mirror works without a loading script
- Decode mismatch on round trip: pre-tokenizer and decoder must match (both Metaspace here); also check `unk_token` is set, since `[UNK]` destroys information
- `PyTorch was not found` warning from transformers: harmless; tokenizers run without torch
- Fertility identical for both vocab sizes: corpus too small for the larger vocab to fill; increase `range(5000)` or lower vocab size
- Slow training: BPE training on 5k texts should take seconds; if it hangs, check the iterator yields strings, not dicts

## Cleanup
```bash
rm -f custom-tokenizer.json
deactivate
rm -rf .training.mlt/labs/tokenizer-training/.venv
```
