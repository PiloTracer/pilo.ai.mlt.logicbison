# Lab: K-Nearest Neighbors from Scratch

## Prerequisites
- Python 3.10+
- NumPy
- scikit-learn (data generation and splitting only)
- Matplotlib
- CPU-only; <1GB RAM and disk

## Setup

```bash
python -m venv .work.mlt/labs/knn/.venv
source .work.mlt/labs/knn/.venv/bin/activate
pip install numpy scikit-learn matplotlib
```

## Objectives
- Implement euclidean distance and majority vote without any ML library
- Select k via validation accuracy
- Evaluate the chosen k on a held-out test set

## Code

```python
import numpy as np
import matplotlib.pyplot as plt
from sklearn.datasets import make_classification
from sklearn.model_selection import train_test_split

np.random.seed(42)

# Synthetic 2D binary classification dataset
X, y = make_classification(n_samples=500, n_features=2, n_redundant=0,
                           n_informative=2, n_clusters_per_class=1,
                           random_state=42)

# 60% train / 20% validation / 20% test
X_train, X_temp, y_train, y_temp = train_test_split(X, y, test_size=0.4, random_state=42)
X_val, X_test, y_val, y_test = train_test_split(X_temp, y_temp, test_size=0.5, random_state=42)

def euclidean_distances(X_query, X_train):
    # Pairwise distances via broadcasting: shape (n_query, n_train)
    return np.sqrt(np.sum((X_query[:, None, :] - X_train[None, :, :]) ** 2, axis=2))

def knn_predict(X_train, y_train, X_query, k):
    dists = euclidean_distances(X_query, X_train)
    nn_idx = np.argsort(dists, axis=1)[:, :k]   # indices of k nearest neighbors
    nn_labels = y_train[nn_idx]
    preds = [np.argmax(np.bincount(labels)) for labels in nn_labels]  # majority vote
    return np.array(preds)

def accuracy(y_true, y_pred):
    return np.mean(y_true == y_pred)

# Select k by validation accuracy
k_values = [1, 3, 5, 7, 9, 11, 15, 21]
val_scores = []
for k in k_values:
    acc = accuracy(y_val, knn_predict(X_train, y_train, X_val, k))
    val_scores.append(acc)
    print(f"k={k:2d}  val accuracy={acc:.3f}")

best_k = k_values[int(np.argmax(val_scores))]
test_acc = accuracy(y_test, knn_predict(X_train, y_train, X_test, best_k))
print(f"Best k={best_k}, test accuracy={test_acc:.3f}")

plt.figure(figsize=(6, 4))
plt.plot(k_values, val_scores, marker='o')
plt.xlabel('k')
plt.ylabel('Validation accuracy')
plt.title('KNN: k selection')
plt.tight_layout()
plt.savefig('knn_k_selection.png')
plt.show()
```

## Expected Output
- Validation accuracy per k, 0.92-0.98 for this dataset
- A curve that peaks at a small k (k=1 with seed 42) and declines as k grows
- Test accuracy (~0.96) close to the best validation accuracy
- `knn_k_selection.png` showing validation accuracy vs k

## Troubleshooting
- Ties in majority vote with even k: use odd k values, or note that `np.argmax(np.bincount(...))` breaks ties toward the smaller class label
- Low accuracy for all k: KNN is distance-based; standardize features first if their scales differ (`(X - X.mean(0)) / X.std(0)`)
- `ValueError` from `np.bincount`: labels must be non-negative ints; cast with `y = y.astype(int)`
- Slow or high memory on larger datasets: the broadcast distance matrix is O(n_query * n_train); process queries in batches of 100

## Cleanup
```bash
deactivate
rm -rf .work.mlt/labs/knn/.venv
rm -f knn_k_selection.png
```
