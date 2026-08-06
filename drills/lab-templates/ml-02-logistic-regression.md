# Lab: Logistic Regression Classifier

## Prerequisites
- Python 3.10+
- NumPy
- Matplotlib

## Setup

```bash
python -m venv .work.mlt/labs/logistic-regression/.venv
source .work.mlt/labs/logistic-regression/.venv/bin/activate
pip install numpy matplotlib
```

## Objectives
- Implement sigmoid and binary cross-entropy loss from scratch
- Derive and compute gradients for logistic regression
- Train with gradient descent and measure accuracy
- Plot the decision boundary on a 2D dataset

## Code

```python
import numpy as np
import matplotlib.pyplot as plt

# Synthetic 2D dataset: two Gaussian clusters, one per class
np.random.seed(42)
n = 200
X0 = np.random.randn(n, 2) + np.array([-1.5, -1.5])
X1 = np.random.randn(n, 2) + np.array([1.5, 1.5])
X = np.vstack([X0, X1])
y = np.concatenate([np.zeros(n), np.ones(n)]).reshape(-1, 1)

# Shuffle so train/test split is fair
idx = np.random.permutation(2 * n)
X, y = X[idx], y[idx]

# 80/20 train/test split
split = int(0.8 * len(X))
X_train, X_test = X[:split], X[split:]
y_train, y_test = y[:split], y[split:]

# Add bias column (intercept) to features
X_train_b = np.c_[np.ones((len(X_train), 1)), X_train]
X_test_b = np.c_[np.ones((len(X_test), 1)), X_test]

def sigmoid(z):
    return 1 / (1 + np.exp(-z))

def compute_loss(X, y, theta):
    # Binary cross-entropy, clipped for numerical stability
    m = len(y)
    p = np.clip(sigmoid(X.dot(theta)), 1e-12, 1 - 1e-12)
    return -(1 / m) * np.sum(y * np.log(p) + (1 - y) * np.log(1 - p))

def gradient_descent(X, y, theta, lr, iterations):
    m = len(y)
    loss_history = []
    for i in range(iterations):
        # Gradient of cross-entropy: (1/m) X^T (sigmoid(X theta) - y)
        gradients = (1 / m) * X.T.dot(sigmoid(X.dot(theta)) - y)
        theta = theta - lr * gradients
        loss_history.append(compute_loss(X, y, theta))
    return theta, loss_history

def accuracy(X, y, theta):
    preds = (sigmoid(X.dot(theta)) >= 0.5).astype(float)
    return np.mean(preds == y)

theta = np.zeros((3, 1))
theta_final, losses = gradient_descent(X_train_b, y_train, theta, lr=0.5, iterations=1000)

print(f"Train accuracy: {accuracy(X_train_b, y_train, theta_final):.4f}")
print(f"Test accuracy: {accuracy(X_test_b, y_test, theta_final):.4f}")
print(f"Final loss: {losses[-1]:.4f}")

plt.figure(figsize=(12, 4))
plt.subplot(1, 2, 1)
plt.scatter(X_train[y_train.ravel() == 0][:, 0], X_train[y_train.ravel() == 0][:, 1], label='class 0', alpha=0.6)
plt.scatter(X_train[y_train.ravel() == 1][:, 0], X_train[y_train.ravel() == 1][:, 1], label='class 1', alpha=0.6)

# Decision boundary: sigmoid(X theta) = 0.5  =>  theta0 + theta1*x1 + theta2*x2 = 0
x1_line = np.linspace(X[:, 0].min() - 1, X[:, 0].max() + 1, 100)
x2_line = -(theta_final[0] + theta_final[1] * x1_line) / theta_final[2]
plt.plot(x1_line, x2_line, 'k-', linewidth=2, label='decision boundary')
plt.xlabel('x1')
plt.ylabel('x2')
plt.title('Decision Boundary')
plt.legend()

plt.subplot(1, 2, 2)
plt.plot(losses)
plt.xlabel('Iteration')
plt.ylabel('Loss')
plt.title('Training Loss')
plt.tight_layout()
plt.savefig('logistic_regression_result.png')
plt.show()
```

## Expected Output
- Train and test accuracy above 0.95
- Loss curve decreasing smoothly toward a low value
- A scatter plot with a clean linear boundary separating the two clusters

## Troubleshooting
- Loss is NaN: sigmoid outputs hit exact 0 or 1 — keep the `np.clip` in `compute_loss` or lower the learning rate
- Poor accuracy: clusters may overlap — increase iterations, raise the learning rate, or spread the cluster centers further apart
- Boundary line off the plot: `theta_final[2]` near zero makes the slope explode — retrain with more iterations
- No plot: install matplotlib with `pip install matplotlib`

## Cleanup
```bash
deactivate
rm -rf .work.mlt/labs/logistic-regression/.venv
```
