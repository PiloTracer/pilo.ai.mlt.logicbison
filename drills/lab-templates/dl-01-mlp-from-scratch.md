# Lab: MLP from Scratch

## Prerequisites
- Python 3.10+
- CPU only (no GPU needed)
- 4GB RAM, 3GB disk (PyTorch wheel)

## Setup

```bash
python -m venv .work.mlt/labs/mlp-from-scratch/.venv
source .work.mlt/labs/mlp-from-scratch/.venv/bin/activate
pip install numpy matplotlib scikit-learn torch
```

## Objectives
- Implement forward and backward propagation by hand in NumPy (no autograd)
- Train a 2-layer MLP (ReLU hidden, sigmoid output, cross-entropy loss) on `make_moons`
- Verify gradients against a numerically computed gradient
- Re-implement the same network with PyTorch `nn.Module` and compare

## Code

```python
import numpy as np
import matplotlib.pyplot as plt
from sklearn.datasets import make_moons

np.random.seed(42)

# ---------- Data ----------
X, y = make_moons(n_samples=300, noise=0.2, random_state=42)
y = y.reshape(-1, 1)  # (m, 1) for binary cross-entropy
m, n_features = X.shape
n_hidden = 16

# ---------- Model: 2 -> 16 (ReLU) -> 1 (sigmoid) ----------
def init_params():
    W1 = np.random.randn(n_features, n_hidden) * 0.1
    b1 = np.zeros((1, n_hidden))
    W2 = np.random.randn(n_hidden, 1) * 0.1
    b2 = np.zeros((1, 1))
    return W1, b1, W2, b2

def sigmoid(z):
    return 1 / (1 + np.exp(-z))

def forward(X, W1, b1, W2, b2):
    Z1 = X @ W1 + b1
    A1 = np.maximum(0, Z1)        # ReLU
    Z2 = A1 @ W2 + b2
    A2 = sigmoid(Z2)              # probability of class 1
    cache = (X, Z1, A1, A2)
    return A2, cache

def compute_loss(y, A2):
    # Binary cross-entropy, clipped for numerical stability
    eps = 1e-12
    A2 = np.clip(A2, eps, 1 - eps)
    return -np.mean(y * np.log(A2) + (1 - y) * np.log(1 - A2))

def backward(y, W1, b1, W2, b2, cache):
    X, Z1, A1, A2 = cache
    m = len(y)
    dZ2 = (A2 - y) / m            # dL/dZ2 for sigmoid + BCE
    dW2 = A1.T @ dZ2
    db2 = np.sum(dZ2, axis=0, keepdims=True)
    dA1 = dZ2 @ W2.T
    dZ1 = dA1 * (Z1 > 0)          # ReLU derivative
    dW1 = X.T @ dZ1
    db1 = np.sum(dZ1, axis=0, keepdims=True)
    return dW1, db1, dW2, db2

# ---------- Gradient check (one mini step, before training) ----------
def grad_check():
    W1, b1, W2, b2 = init_params()
    Xc, yc = X[:20], y[:20]
    A2, cache = forward(Xc, W1, b1, W2, b2)
    dW1, db1, dW2, db2 = backward(yc, W1, b1, W2, b2, cache)
    eps = 1e-5
    # Check one entry of W2 numerically
    W2[0, 0] += eps
    loss_plus = compute_loss(yc, forward(Xc, W1, b1, W2, b2)[0])
    W2[0, 0] -= 2 * eps
    loss_minus = compute_loss(yc, forward(Xc, W1, b1, W2, b2)[0])
    num_grad = (loss_plus - loss_minus) / (2 * eps)
    print(f"dW2[0,0] analytic={dW2[0,0]:.6f} numeric={num_grad:.6f}")

grad_check()  # analytic and numeric gradients must match to ~4 decimals

# ---------- Training (full-batch gradient descent) ----------
W1, b1, W2, b2 = init_params()
lr, epochs = 1.0, 2000
losses = []
for epoch in range(epochs):
    A2, cache = forward(X, W1, b1, W2, b2)
    losses.append(compute_loss(y, A2))
    dW1, db1, dW2, db2 = backward(y, W1, b1, W2, b2, cache)
    W1 -= lr * dW1
    b1 -= lr * db1
    W2 -= lr * dW2
    b2 -= lr * db2
    if epoch % 400 == 0:
        print(f"epoch {epoch:4d}  loss {losses[-1]:.4f}")

preds = (forward(X, W1, b1, W2, b2)[0] > 0.5).astype(int)
acc_numpy = np.mean(preds == y)
print(f"NumPy MLP accuracy: {acc_numpy:.3f}")

# ---------- Plots ----------
plt.figure(figsize=(12, 4))
plt.subplot(1, 2, 1)
plt.plot(losses)
plt.xlabel('Epoch')
plt.ylabel('Loss')
plt.title('Training Loss (NumPy)')

plt.subplot(1, 2, 2)
xx, yy = np.meshgrid(np.linspace(X[:, 0].min() - 0.5, X[:, 0].max() + 0.5, 200),
                     np.linspace(X[:, 1].min() - 0.5, X[:, 1].max() + 0.5, 200))
grid = np.c_[xx.ravel(), yy.ravel()]
zz = forward(grid, W1, b1, W2, b2)[0].reshape(xx.shape)
plt.contourf(xx, yy, zz, levels=20, alpha=0.6, cmap='RdBu')
plt.scatter(X[:, 0], X[:, 1], c=y.ravel(), cmap='RdBu', edgecolors='k')
plt.title('Decision Boundary (NumPy)')
plt.tight_layout()
plt.savefig('mlp_numpy_result.png')
plt.show()

# ---------- PyTorch comparison ----------
import torch
import torch.nn as nn

torch.manual_seed(42)

class MLP(nn.Module):
    def __init__(self):
        super().__init__()
        self.net = nn.Sequential(
            nn.Linear(2, 16),
            nn.ReLU(),
            nn.Linear(16, 1),
            nn.Sigmoid(),
        )

    def forward(self, x):
        return self.net(x)

model = MLP()
criterion = nn.BCELoss()
optimizer = torch.optim.Adam(model.parameters(), lr=0.01)

Xt = torch.tensor(X, dtype=torch.float32)
yt = torch.tensor(y, dtype=torch.float32)

for epoch in range(500):
    optimizer.zero_grad()
    out = model(Xt)
    loss = criterion(out, yt)
    loss.backward()
    optimizer.step()

with torch.no_grad():
    acc_torch = ((model(Xt) > 0.5).float() == yt).float().mean().item()
print(f"PyTorch MLP accuracy: {acc_torch:.3f}")
print(f"Final losses: NumPy={losses[-1]:.4f}  PyTorch={loss.item():.4f}")
```

## Expected Output
- Gradient check prints analytic and numeric gradients matching to ~4 decimals
- Loss decreasing smoothly from ~0.69 toward ~0.2 or lower
- NumPy MLP accuracy above 0.85 on `make_moons`; PyTorch version similar (typically 0.90+)
- `mlp_numpy_result.png`: loss curve plus a curved decision boundary separating the two moons

## Troubleshooting
- Gradient check mismatch: check the ReLU derivative (`Z1 > 0`) and the `/m` factor in `dZ2`; a wrong BCE derivative is the usual cause
- Loss stuck near 0.69: weights initialized too large or learning rate too small; keep init scale `* 0.1` and try `lr=1.0`
- Loss is NaN: sigmoid overflow or `log(0)`; ensure the `np.clip` in `compute_loss` is present and inputs are standardized-ish (make_moons already is)
- `pip install torch` too large or slow: use the CPU-only wheel with `pip install torch --index-url https://download.pytorch.org/whl/cpu`

## Cleanup
```bash
deactivate
rm -rf .work.mlt/labs/mlp-from-scratch/.venv mlp_numpy_result.png
```
