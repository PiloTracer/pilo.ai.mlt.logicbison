# Lab: Cross-Validation Pipeline

## Prerequisites
- Python 3.10+
- CPU only, 8GB RAM
- 1GB disk space

## Setup

```bash
python -m venv .work.mlt/labs/cross-validation/.venv
source .work.mlt/labs/cross-validation/.venv/bin/activate
pip install scikit-learn numpy
```

## Objectives
- Implement a k-fold split by hand (shuffle, partition, iterate)
- Train and score a model on each fold
- Reproduce the same result with sklearn `cross_val_score`
- Report per-fold and mean±std scores

## Code

```python
import numpy as np
from sklearn.datasets import load_wine
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import cross_val_score
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler

K = 5
SEED = 42

X, y = load_wine(return_X_y=True)  # 178 samples, 13 features, 3 classes

def kfold_split(n_samples, k, seed):
    """Hand-written k-fold splitter. Yields (train_idx, test_idx) per fold."""
    rng = np.random.default_rng(seed)
    indices = rng.permutation(n_samples)
    folds = np.array_split(indices, k)  # near-equal folds; first folds get the remainder
    for i in range(k):
        test_idx = folds[i]
        train_idx = np.concatenate([folds[j] for j in range(k) if j != i])
        yield train_idx, test_idx

def make_model():
    # Pipeline so the scaler is fit on each training fold only (no leakage)
    return make_pipeline(
        StandardScaler(),
        LogisticRegression(max_iter=2000, random_state=SEED),
    )

# --- Manual cross-validation ---
splits = list(kfold_split(len(X), K, SEED))
manual_scores = []
for fold, (train_idx, test_idx) in enumerate(splits):
    model = make_model()
    model.fit(X[train_idx], y[train_idx])
    score = model.score(X[test_idx], y[test_idx])
    manual_scores.append(score)
    print(f"Fold {fold + 1}: accuracy = {score:.4f} (train={len(train_idx)}, test={len(test_idx)})")

manual_scores = np.array(manual_scores)
print(f"Manual CV: mean = {manual_scores.mean():.4f} +- {manual_scores.std():.4f}")

# --- sklearn cross_val_score on the exact same splits ---
# cv accepts an iterable of (train, test) index pairs, so this is apples-to-apples
sk_scores = cross_val_score(make_model(), X, y, cv=splits, scoring="accuracy")
for fold, score in enumerate(sk_scores):
    print(f"Fold {fold + 1}: accuracy = {score:.4f}")
print(f"sklearn CV: mean = {sk_scores.mean():.4f} +- {sk_scores.std():.4f}")

# --- Sanity check: both pipelines must agree fold by fold ---
assert np.allclose(manual_scores, sk_scores), "manual and sklearn scores diverged"
print("OK: manual splitter matches cross_val_score on identical splits")
```

## Expected Output
- 5 per-fold accuracies around 0.97-1.00, identical between manual and sklearn runs
- Mean accuracy around 0.99 ± 0.01 for both pipelines
- Final line: `OK: manual splitter matches cross_val_score on identical splits`

## Troubleshooting
- `ConvergenceWarning` from LogisticRegression: raise `max_iter` or confirm `StandardScaler` is in the pipeline
- Manual and sklearn scores differ: check that the same `splits` list is passed to `cross_val_score` and that the seed matches
- Scores suspiciously high (1.0 on every fold): verify the scaler is fit inside the fold loop, not on the full dataset beforehand
- `array_split` folds have unequal sizes: expected when `n_samples % k != 0`; harmless

## Cleanup
```bash
deactivate
rm -rf .work.mlt/labs/cross-validation/.venv
```
