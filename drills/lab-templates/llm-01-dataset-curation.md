# Lab: Dataset Curation

## Prerequisites
- Python 3.10+
- 8GB+ RAM
- 1GB free disk (HF streaming cache)

## Setup

```bash
python -m venv .training.mlt/labs/dataset-curation/.venv
source .training.mlt/labs/dataset-curation/.venv/bin/activate
pip install datasets
```

## Objectives
- Pull a bounded streaming slice of a large web-text corpus (wikitext-103)
- Clean HTML entities, tags, and whitespace artifacts
- Filter documents with language and length heuristics
- Remove exact duplicates and near-duplicates with hand-rolled MinHash + LSH
- Produce a before/after quality report and a curated JSONL artifact

## Code

```python
import hashlib
import html
import json
import random
import re
import statistics
from itertools import combinations

from datasets import load_dataset

random.seed(42)

N_DOCS = 3000          # streaming slice size
MIN_WORDS = 20         # length heuristics
MAX_WORDS = 2000
MIN_ASCII = 0.95       # crude encoding/language heuristic
MIN_STOPWORD = 0.05    # fraction of common English words required
SHINGLE_K = 5          # word shingles for MinHash
NUM_PERM = 64
BANDS = 16             # LSH: ROWS = NUM_PERM // BANDS
JACCARD_THRESH = 0.8
PRIME = (1 << 61) - 1  # Mersenne prime for hashing
OUT_PATH = ".training.mlt/labs/dataset-curation/curated.jsonl"

EN_STOPWORDS = set(
    "the of and a in to is was for on with as at by an be this that it from "
    "or are were has have had not but his her he she they their its".split()
)

# --- 1. Stream a bounded slice (no full download; only what we read) ---
ds = load_dataset(
    "Salesforce/wikitext", "wikitext-103-v1", split="train", streaming=True
)
docs = []
for i, example in enumerate(ds):
    if i >= N_DOCS:
        break
    docs.append(example["text"])

# --- 2. Cleaning: HTML entities, tags, whitespace ---
TAG_RE = re.compile(r"<[^>]+>")
WS_RE = re.compile(r"\s+")

def clean_text(text):
    text = html.unescape(text)      # &amp; -> &, &lt; -> <
    text = TAG_RE.sub(" ", text)    # strip HTML tags
    text = WS_RE.sub(" ", text)     # collapse whitespace/newlines
    return text.strip()

# --- 3. Language and length heuristics ---
def passes_filters(text):
    words = text.split()
    if not (MIN_WORDS <= len(words) <= MAX_WORDS):
        return False
    ascii_ratio = sum(c.isascii() for c in text) / max(len(text), 1)
    if ascii_ratio < MIN_ASCII:
        return False
    stopword_ratio = sum(w.lower() in EN_STOPWORDS for w in words) / len(words)
    return stopword_ratio >= MIN_STOPWORD

# --- 4. Exact dedup: hash of normalized text ---
def exact_key(text):
    return hashlib.md5(WS_RE.sub(" ", text.lower()).strip().encode()).hexdigest()

# --- 5. Near-dedup: hand-rolled MinHash + LSH banding ---
A = [random.randrange(1, PRIME) for _ in range(NUM_PERM)]
B = [random.randrange(0, PRIME) for _ in range(NUM_PERM)]

def shingles(text, k=SHINGLE_K):
    words = text.lower().split()
    return {
        int.from_bytes(
            hashlib.md5(" ".join(words[i:i + k]).encode()).digest()[:8], "little"
        ) % PRIME
        for i in range(len(words) - k + 1)
    }

def minhash_signature(shingle_ids):
    return [
        min((a * x + b) % PRIME for x in shingle_ids)
        for a, b in zip(A, B)
    ]

def find_near_dupes(signatures):
    rows = NUM_PERM // BANDS
    buckets = {}
    for idx, sig in enumerate(signatures):
        for band in range(BANDS):
            key = (band, tuple(sig[band * rows:(band + 1) * rows]))
            buckets.setdefault(key, []).append(idx)
    dupes = set()
    for group in buckets.values():
        if len(group) < 2:
            continue
        for i, j in combinations(group, 2):
            est = sum(x == y for x, y in zip(signatures[i], signatures[j])) / NUM_PERM
            if est >= JACCARD_THRESH:
                dupes.add(max(i, j))  # keep the earlier document
    return dupes

# --- Quality report ---
def report(name, docs):
    if not docs:
        print(f"[{name}] 0 docs")
        return
    word_counts = [len(d.split()) for d in docs]
    print(f"[{name}]")
    print(f"  docs:        {len(docs)}")
    print(f"  total words: {sum(word_counts):,}")
    print(f"  mean words:  {statistics.mean(word_counts):.1f}")
    print(f"  median words:{statistics.median(word_counts):.1f}")
    print(f"  total chars: {sum(len(d) for d in docs):,}")

report("raw", docs)

# Pipeline
cleaned = [clean_text(d) for d in docs]
report("cleaned", cleaned)

filtered = [d for d in cleaned if passes_filters(d)]
print(f"length/language filter: {len(cleaned)} -> {len(filtered)} docs")

seen, deduped_exact = set(), []
for d in filtered:
    k = exact_key(d)
    if k not in seen:
        seen.add(k)
        deduped_exact.append(d)
print(f"exact dedup: {len(filtered)} -> {len(deduped_exact)} docs")

sigs = [minhash_signature(shingles(d)) for d in deduped_exact]
near_dupes = find_near_dupes(sigs)
curated = [d for i, d in enumerate(deduped_exact) if i not in near_dupes]
print(f"near dedup (MinHash): {len(deduped_exact)} -> {len(curated)} docs")

report("curated", curated)

with open(OUT_PATH, "w") as f:
    for d in curated:
        f.write(json.dumps({"text": d}) + "\n")
print(f"wrote {len(curated)} docs to {OUT_PATH}")
```

## Expected Output
- Raw report: 3000 docs pulled from the stream (wikitext-103 rows include many headings and blank-ish lines)
- Cleaning leaves doc count unchanged but reduces total characters
- Length/language filter drops a large share of docs (section headings, short fragments); expect roughly 30-60% retention
- Exact dedup removes few to no docs; MinHash near-dedup removes a small number of near-duplicates
- Curated report shows higher mean/median word counts than raw
- `curated.jsonl` written under `.training.mlt/labs/dataset-curation/`

## Troubleshooting
- `load_dataset` hangs or is slow: streaming still downloads chunks on demand; check your connection. The slice read is a few tens of MB. Lower `N_DOCS` if needed.
- `DatasetNotFoundError` or config error: ensure a recent `datasets` version (`pip install -U datasets`); the config name is `wikitext-103-v1` under `Salesforce/wikitext`.
- MinHash step is slow: pure-Python MinHash on thousands of docs takes tens of seconds; reduce `N_DOCS` or `NUM_PERM`, or install `datasketch` and swap in its `MinHash`/`MinHashLSH`.
- Zero docs pass the filter: check that `MIN_STOPWORD` is not too strict for the corpus, and print a few filtered-out samples to tune `MIN_WORDS`.
- `FileNotFoundError` on write: create the directory first with `mkdir -p .training.mlt/labs/dataset-curation` or run the script from the repo root.

## Cleanup
```bash
deactivate
rm -rf .training.mlt/labs/dataset-curation/.venv
rm -f .training.mlt/labs/dataset-curation/curated.jsonl
```
