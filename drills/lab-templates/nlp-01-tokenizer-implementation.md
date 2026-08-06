# Lab: Tokenizer Implementation

## Prerequisites
- Python 3.10+
- No third-party packages (pure Python stdlib)
- Any CPU, 4GB+ RAM

## Setup

```bash
python -m venv .work.mlt/labs/tokenizer-implementation/.venv
source .work.mlt/labs/tokenizer-implementation/.venv/bin/activate
```

## Objectives
- Implement byte-pair encoding (BPE) from scratch in pure Python
- Learn merges by iteratively counting adjacent pair frequencies
- Build a vocabulary from characters plus learned merge tokens
- Verify encode/decode round-trip on sample sentences

## Code

```python
import re
from collections import Counter

# Embedded training corpus (small, lowercase-friendly prose)
CORPUS = """
the cat sat on the mat. the dog sat on the log.
the cat chased the rat and the rat ran from the cat.
language models learn language from data and data shapes language models.
the quick brown fox jumps over the lazy dog and the dog keeps sleeping.
a tokenizer splits text into tokens and a model reads tokens not text.
the model learns from the tokens and the tokens come from the tokenizer.
"""

NUM_MERGES = 40
EOW = "</w>"  # end-of-word marker keeps word boundaries in tokens

def pre_tokenize(text):
    # Split into words and punctuation, lowercase for a compact vocab
    return re.findall(r"\w+|[^\w\s]", text.lower())

def word_to_symbols(word):
    # Initial representation: sequence of characters plus end-of-word marker
    return tuple(list(word) + [EOW])

def get_pair_counts(vocab_counts):
    # Count all adjacent symbol pairs across the (word, frequency) vocab
    pairs = Counter()
    for word, freq in vocab_counts.items():
        for i in range(len(word) - 1):
            pairs[(word[i], word[i + 1])] += freq
    return pairs

def merge_pair(pair, vocab_counts):
    # Replace every occurrence of the best pair with the merged symbol
    merged = pair[0] + pair[1]
    new_vocab = {}
    for word, freq in vocab_counts.items():
        new_word = []
        i = 0
        while i < len(word):
            if i < len(word) - 1 and (word[i], word[i + 1]) == pair:
                new_word.append(merged)
                i += 2
            else:
                new_word.append(word[i])
                i += 1
        new_vocab[tuple(new_word)] = freq
    return new_vocab

# Build initial vocab: one entry per unique pre-token, split into characters
vocab_counts = Counter(word_to_symbols(w) for w in pre_tokenize(CORPUS))

# Merge loop: repeatedly merge the most frequent adjacent pair
merges = []
for step in range(NUM_MERGES):
    pairs = get_pair_counts(vocab_counts)
    if not pairs:
        break
    best = max(pairs, key=pairs.get)
    vocab_counts = merge_pair(best, vocab_counts)
    merges.append(best)
    print(f"Merge {step + 1:2d}: {best} -> {''.join(best)}  (count={pairs[best]})")

# Final vocabulary: base characters, punctuation, EOW, plus merged tokens
base_symbols = sorted({c for w in pre_tokenize(CORPUS) for c in w} | {EOW})
merge_tokens = [a + b for a, b in merges]
vocab = base_symbols + merge_tokens
token_to_id = {tok: i for i, tok in enumerate(vocab)}
id_to_token = {i: tok for tok, i in token_to_id.items()}
print(f"\nVocab size: {len(vocab)} ({len(base_symbols)} base + {len(merge_tokens)} merged)")

def encode(sentence):
    # Greedy longest-match against the vocab, per pre-token
    ids = []
    for word in pre_tokenize(sentence):
        symbols = list(word) + [EOW]
        i = 0
        while i < len(symbols):
            for j in range(len(symbols), i, -1):
                piece = "".join(symbols[i:j])
                if piece in token_to_id:
                    ids.append(token_to_id[piece])
                    i = j
                    break
    return ids

def decode(ids):
    # Concatenate tokens, then turn the end-of-word markers back into spaces
    return "".join(id_to_token[i] for i in ids).replace(EOW, " ").strip()

# Round-trip check on sample sentences
samples = [
    "the cat sat on the mat.",
    "a tokenizer splits text into tokens.",
    "the model learns from tokens and data.",
]
for s in samples:
    ids = encode(s)
    tokens = [id_to_token[i] for i in ids]
    restored = decode(ids)
    print(f"\nInput : {s}")
    print(f"Tokens: {tokens}")
    print(f"IDs   : {ids}")
    print(f"Decode: {restored}")
    assert restored == " ".join(pre_tokenize(s)), "round-trip failed"
print("\nAll round-trips passed.")
```

## Expected Output
- 40 merge steps printed, most-frequent pairs first (e.g. `t h`, `th e`, `the </w>`)
- Vocab size around 68 tokens (28 base characters/punctuation plus 40 merges)
- Each sample sentence shown with its token list, integer IDs, and decoded text
- `All round-trips passed.` at the end

## Troubleshooting
- `AssertionError` on round-trip: the greedy encode must check all substrings; verify the inner loop falls back to single characters, which are always in the vocab
- Merges stop early: corpus too small or `NUM_MERGES` too large; reduce `NUM_MERGES` or add sentences to `CORPUS`
- Odd tokens like `mat.</w>`: punctuation was glued to a word; keep the regex `r"\w+|[^\w\s]"` so punctuation pre-tokenizes separately
- `ModuleNotFoundError`: none expected — this lab uses only the Python standard library

## Cleanup
```bash
deactivate
rm -rf .work.mlt/labs/tokenizer-implementation/.venv
```
