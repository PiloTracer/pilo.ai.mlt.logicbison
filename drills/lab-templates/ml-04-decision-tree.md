# Lab: Decision Tree Builder

## Prerequisites
- Python 3.10+
- NumPy
- scikit-learn (dataset loading only)
- 8GB RAM, CPU only

## Setup

```bash
python -m venv .training.mlt/labs/decision-tree/.venv
source .training.mlt/labs/decision-tree/.venv/bin/activate
pip install numpy scikit-learn
```

## Objectives
- Implement entropy and information gain from scratch
- Build a decision tree classifier recursively (NumPy only)
- Evaluate prediction accuracy on the iris dataset

## Code

```python
import numpy as np
from sklearn.datasets import load_iris

np.random.seed(42)

def entropy(y):
    """Shannon entropy of a label vector."""
    _, counts = np.unique(y, return_counts=True)
    probs = counts / len(y)
    return -np.sum(probs * np.log2(probs + 1e-12))

def information_gain(y, y_left, y_right):
    """Gain from splitting y into y_left and y_right."""
    n = len(y)
    return entropy(y) - (len(y_left) / n) * entropy(y_left) \
                      - (len(y_right) / n) * entropy(y_right)

def best_split(X, y):
    """Find the feature and threshold with the highest information gain."""
    best_gain, best_feature, best_threshold = 0.0, None, None
    for feature in range(X.shape[1]):
        thresholds = np.unique(X[:, feature])
        for threshold in thresholds:
            left_mask = X[:, feature] <= threshold
            if left_mask.sum() == 0 or left_mask.sum() == len(y):
                continue
            gain = information_gain(y, y[left_mask], y[~left_mask])
            if gain > best_gain:
                best_gain, best_feature, best_threshold = gain, feature, threshold
    return best_feature, best_threshold, best_gain

def majority_class(y):
    values, counts = np.unique(y, return_counts=True)
    return values[np.argmax(counts)]

def build_tree(X, y, depth=0, max_depth=5, min_samples=2):
    """Recursively build the tree as nested dicts."""
    # Leaf: pure node, max depth reached, or too few samples to split
    if len(np.unique(y)) == 1 or depth >= max_depth or len(y) < min_samples:
        return {"leaf": True, "class": majority_class(y), "samples": len(y)}

    feature, threshold, gain = best_split(X, y)
    if feature is None or gain <= 0:
        return {"leaf": True, "class": majority_class(y), "samples": len(y)}

    left_mask = X[:, feature] <= threshold
    return {
        "leaf": False,
        "feature": feature,
        "threshold": threshold,
        "left": build_tree(X[left_mask], y[left_mask], depth + 1, max_depth, min_samples),
        "right": build_tree(X[~left_mask], y[~left_mask], depth + 1, max_depth, min_samples),
    }

def predict_one(node, x):
    """Walk the tree for a single sample."""
    while not node["leaf"]:
        node = node["left"] if x[node["feature"]] <= node["threshold"] else node["right"]
    return node["class"]

def predict(node, X):
    return np.array([predict_one(node, x) for x in X])

# Load iris (150 samples, 4 features, 3 classes) and split 80/20
iris = load_iris()
X, y = iris.data, iris.target
indices = np.random.permutation(len(X))
split = int(0.8 * len(X))
train_idx, test_idx = indices[:split], indices[split:]
X_train, y_train = X[train_idx], y[train_idx]
X_test, y_test = X[test_idx], y[test_idx]

tree = build_tree(X_train, y_train, max_depth=5)
y_pred = predict(tree, X_test)
accuracy = np.mean(y_pred == y_test)
print(f"Test accuracy: {accuracy:.4f} ({int(np.sum(y_pred == y_test))}/{len(y_test)} correct)")

def print_tree(node, feature_names, depth=0):
    indent = "  " * depth
    if node["leaf"]:
        print(f"{indent}Predict class {node['class']} (n={node['samples']})")
        return
    print(f"{indent}if {feature_names[node['feature']]} <= {node['threshold']:.2f}:")
    print_tree(node["left"], feature_names, depth + 1)
    print(f"{indent}else:")
    print_tree(node["right"], feature_names, depth + 1)

print_tree(tree, iris.feature_names)
```

## Expected Output
- Test accuracy of 0.90 or higher (typically 0.93-1.00 with this seed and split)
- A printed tree with `petal length` or `petal width` at the root (the most informative features)
- Leaf nodes showing sample counts that sum to 120 (the training set size)

## Troubleshooting
- Accuracy near 0.33: the split likely produced an empty side — verify `best_split` skips degenerate splits where a side has 0 samples
- RecursionError: lower `max_depth` or ensure stopping conditions trigger (pure node, max depth, min samples)
- `np.log2(0)` warnings: the `+ 1e-12` epsilon in `entropy` guards against zero probabilities — do not remove it
- Slow splitting: thresholds are all unique values per feature, which is fine for iris; for larger data, subsample candidate thresholds with `np.percentile`

## Cleanup
```bash
deactivate
rm -rf .training.mlt/labs/decision-tree/.venv
```
