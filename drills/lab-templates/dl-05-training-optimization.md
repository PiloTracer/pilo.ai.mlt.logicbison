# Lab: Training Optimization

## Prerequisites
- Python 3.10+
- CPU only (no GPU needed)
- 2GB disk space, 4GB RAM

## Setup

```bash
python -m venv .work.mlt/labs/training-optimization/.venv
source .work.mlt/labs/training-optimization/.venv/bin/activate
pip install torch scikit-learn matplotlib
```

## Objectives
- Train the same MLP with SGD, SGD+momentum, Adam, and AdamW
- Compare convergence speed, final accuracy, and wall-clock time
- Understand how momentum and adaptive learning rates change optimization

## Code

```python
import time
import numpy as np
import torch
import torch.nn as nn
from sklearn.datasets import make_classification
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
import matplotlib.pyplot as plt

# --- Fixed seeds: every optimizer sees the same data and initialization ---
SEED = 42
np.random.seed(SEED)

# --- Synthetic dataset (no download required) ---
X, y = make_classification(
    n_samples=4000, n_features=20, n_informative=15,
    n_classes=2, random_state=SEED
)
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=SEED
)
scaler = StandardScaler()
X_train = torch.tensor(scaler.fit_transform(X_train), dtype=torch.float32)
X_test = torch.tensor(scaler.transform(X_test), dtype=torch.float32)
y_train = torch.tensor(y_train, dtype=torch.float32).unsqueeze(1)
y_test = torch.tensor(y_test, dtype=torch.float32).unsqueeze(1)

# --- Small MLP: 20 -> 64 -> 32 -> 1 ---
class MLP(nn.Module):
    def __init__(self):
        super().__init__()
        self.net = nn.Sequential(
            nn.Linear(20, 64), nn.ReLU(),
            nn.Linear(64, 32), nn.ReLU(),
            nn.Linear(32, 1),
        )

    def forward(self, x):
        return self.net(x)

def train(optimizer_name, lr=0.01, epochs=100, batch_size=128):
    # Re-seed inside the run so all optimizers start from identical weights
    torch.manual_seed(SEED)
    model = MLP()
    loss_fn = nn.BCEWithLogitsLoss()

    if optimizer_name == "SGD":
        optimizer = torch.optim.SGD(model.parameters(), lr=lr)
    elif optimizer_name == "SGD+momentum":
        optimizer = torch.optim.SGD(model.parameters(), lr=lr, momentum=0.9)
    elif optimizer_name == "Adam":
        optimizer = torch.optim.Adam(model.parameters(), lr=lr)
    elif optimizer_name == "AdamW":
        optimizer = torch.optim.AdamW(model.parameters(), lr=lr, weight_decay=0.01)
    else:
        raise ValueError(f"Unknown optimizer: {optimizer_name}")

    n = len(X_train)
    loss_history = []
    start = time.perf_counter()
    for epoch in range(epochs):
        # Re-seed shuffling so every optimizer sees batches in the same order
        torch.manual_seed(SEED + epoch)
        perm = torch.randperm(n)
        epoch_loss = 0.0
        for i in range(0, n, batch_size):
            idx = perm[i:i + batch_size]
            optimizer.zero_grad()
            loss = loss_fn(model(X_train[idx]), y_train[idx])
            loss.backward()
            optimizer.step()
            epoch_loss += loss.item() * len(idx)
        loss_history.append(epoch_loss / n)
    elapsed = time.perf_counter() - start

    # --- Final test accuracy ---
    model.eval()
    with torch.no_grad():
        preds = (torch.sigmoid(model(X_test)) > 0.5).float()
        accuracy = (preds == y_test).float().mean().item()

    return loss_history, accuracy, elapsed

# --- Run all four optimizers on identical data and initialization ---
results = {}
for name in ["SGD", "SGD+momentum", "Adam", "AdamW"]:
    losses, acc, elapsed = train(name)
    results[name] = (losses, acc, elapsed)
    print(f"{name:<15} final_loss={losses[-1]:.4f} acc={acc:.4f} time={elapsed:.2f}s")

# --- Loss curves ---
plt.figure(figsize=(8, 5))
for name, (losses, _, _) in results.items():
    plt.plot(losses, label=name)
plt.xlabel("Epoch")
plt.ylabel("Training loss")
plt.title("Optimizer Comparison: Loss Curves")
plt.legend()
plt.tight_layout()
plt.savefig("optimizer_comparison.png")
plt.show()

# --- Summary table ---
print(f"\n{'Optimizer':<15} {'Final Acc':>10} {'Time (s)':>10}")
print("-" * 37)
for name, (_, acc, elapsed) in results.items():
    print(f"{name:<15} {acc:>10.4f} {elapsed:>10.2f}")
```

## Expected Output
- SGD converges slowest; loss curve sits above the others for most epochs
- SGD+momentum converges noticeably faster than plain SGD
- Adam and AdamW converge fastest, typically within the first 20-30 epochs
- Final test accuracy around 0.88-0.95 for all optimizers, with momentum/Adam/AdamW above plain SGD
- Wall-clock time per run: a few seconds on a modern CPU; Adam/AdamW slightly slower per step than SGD
- `optimizer_comparison.png` shows four loss curves with distinct convergence rates
- Summary table printed with final accuracy and time for each optimizer

## Troubleshooting
- All optimizers reach the same loss: learning rate too low or too few epochs; try `lr=0.05` for SGD or increase `epochs`
- Loss is NaN or diverging: learning rate too high; reduce `lr` (especially for Adam, try `lr=0.001`)
- Different results between runs: verify `torch.manual_seed(SEED)` is called at the start of `train()`, not just once at the top
- Slow on CPU: reduce `n_samples` to 2000 or `epochs` to 50

## Cleanup
```bash
deactivate
rm -rf .work.mlt/labs/training-optimization/.venv
rm -f optimizer_comparison.png
```
