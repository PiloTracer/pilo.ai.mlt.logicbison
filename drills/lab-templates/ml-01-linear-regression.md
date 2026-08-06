# Lab: Linear Regression from Scratch

## Prerequisites
- Python 3.10+
- NumPy
- Matplotlib

## Setup

```bash
python -m venv .work.mlt/labs/linear-regression/.venv
source .work.mlt/labs/linear-regression/.venv/bin/activate
pip install numpy matplotlib
```

## Objectives
- Understand gradient descent
- Implement linear regression without any ML library
- Visualize the loss landscape and convergence

## Code

```python
import numpy as np
import matplotlib.pyplot as plt

np.random.seed(42)
X = 2 * np.random.rand(100, 1)
y = 4 + 3 * X + np.random.randn(100, 1)

def predict(X, theta):
    return X.dot(theta)

def compute_loss(X, y, theta):
    m = len(y)
    predictions = predict(X, theta)
    return (1 / (2 * m)) * np.sum((predictions - y) ** 2)

def gradient_descent(X, y, theta, lr, iterations):
    m = len(y)
    loss_history = []
    for i in range(iterations):
        gradients = (1 / m) * X.T.dot(predict(X, theta) - y)
        theta = theta - lr * gradients
        loss = compute_loss(X, y, theta)
        loss_history.append(loss)
    return theta, loss_history

X_b = np.c_[np.ones((100, 1)), X]
theta = np.random.randn(2, 1)
theta_final, losses = gradient_descent(X_b, y, theta, lr=0.1, iterations=1000)

print(f"Learned parameters: intercept={theta_final[0][0]:.2f}, slope={theta_final[1][0]:.2f}")
print(f"Final loss: {losses[-1]:.4f}")

plt.figure(figsize=(12, 4))
plt.subplot(1, 2, 1)
plt.scatter(X, y, alpha=0.5)
plt.plot(X, X_b.dot(theta_final), 'r-', linewidth=2)
plt.xlabel('X')
plt.ylabel('y')
plt.title('Linear Regression Fit')

plt.subplot(1, 2, 2)
plt.plot(losses)
plt.xlabel('Iteration')
plt.ylabel('Loss')
plt.title('Training Loss')
plt.tight_layout()
plt.savefig('linear_regression_result.png')
plt.show()
```

## Expected Output
- Learned parameters close to intercept=4.0, slope=3.0
- Loss curve showing smooth convergence
- A scatter plot with a good fit line

## Troubleshooting
- Loss diverging: reduce learning rate
- Slow convergence: increase iterations or check feature scaling
- No plot: install matplotlib with `pip install matplotlib`

## Cleanup
```bash
deactivate
rm -rf .work.mlt/labs/linear-regression/.venv
```
