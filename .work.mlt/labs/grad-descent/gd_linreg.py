"""
Lab — Gradient Descent for Linear Regression (pure NumPy)

WHAT YOU WILL SEE
    A linear regression trained from scratch with gradient descent:
    starting from deliberately wrong parameters (w=0, b=0), the loop
    below walks the parameters downhill on the loss surface until the
    fitted line matches the data.

THE ONE IDEA
    Gradient descent: look at the slope of the loss with respect to
    each parameter, take a small step downhill:

        w <- w - eta * dL/dw
        b <- b - eta * dL/db

    The minus sign is the whole algorithm: the gradient points uphill,
    so we walk the opposite way.

KEYS TO THE NOTATION
    w    weight (slope of the fitted line)
    b    bias (y-intercept of the fitted line)
    eta  learning rate — the size of each downhill step
    L    loss, here Mean Squared Error: L = (1/n) * sum((y_hat - y)^2)

EXPECTED OUTPUT (verified)
    final w=2.0147  b=0.9581  loss=0.000667
    closed-form w=2.0000  b=1.0000
    plus a file `loss_curve.png` showing the loss dropping.

Run:  python gd_linreg.py   (inside the lab's .venv — see setup.sh)
"""

import numpy as np
import matplotlib.pyplot as plt

# Fix the random seed so every run of this lab produces identical numbers.
# Reproducibility is a habit: if a result cannot be reproduced, it cannot
# be trusted (see standards/code-quality.md).
np.random.seed(0)

# ---------------------------------------------------------------------------
# 1. THE DATA
# Five points that lie almost exactly on the line y = 2x + 1.
# The training task: recover w=2, b=1 starting from w=0, b=0.
# ---------------------------------------------------------------------------
x = np.array([0.0, 1.0, 2.0, 3.0, 4.0])   # input values (single feature)
y = np.array([1.0, 3.0, 5.0, 7.0, 9.0])   # target values (ground truth)
n = x.shape[0]                             # number of training points (5)

# ---------------------------------------------------------------------------
# 2. PARAMETERS — START DELIBERATELY WRONG
# w (weight) is the slope, b (bias) the intercept. Starting at zero proves
# that the algorithm finds the line; we did not hardcode the answer.
# ---------------------------------------------------------------------------
w, b = 0.0, 0.0

# eta = learning rate: how far we step downhill each iteration.
# Why 0.1? Big enough to converge in ~30 steps, small enough to stay stable
# for this data scale. Try 1.5 (diverges) and 0.001 (crawls) — see README.
eta = 0.1

# losses records L at every step so we can plot the descent afterwards.
losses = []

# ---------------------------------------------------------------------------
# 3. THE TRAINING LOOP — gradient descent itself
# ---------------------------------------------------------------------------
for step in range(30):
    # Prediction for every point at once: y_hat = w*x + b (vectorized).
    # For one point, w*x is a dot product (weight times input); NumPy
    # applies it elementwise across the whole array in one expression.
    y_hat = w * x + b

    # Residuals: how far each prediction is from the truth.
    err = y_hat - y

    # Loss = Mean Squared Error = average of the squared residuals.
    # Squaring penalizes large errors harder; dividing by n (the MEAN,
    # not the sum) keeps the loss scale independent of dataset size.
    loss = (err ** 2).mean()

    # Gradient of L with respect to w:  dL/dw = (2/n) * sum(x_i * err_i)
    # Each point's opinion about w is weighted by its input x_i — points
    # with large |x| pull harder on the slope.
    grad_w = (2.0 / n) * (x * err).sum()

    # Gradient of L with respect to b:  dL/db = (2/n) * sum(err_i)
    # b shifts every prediction equally, so x does not appear here.
    grad_b = (2.0 / n) * err.sum()

    # KEY IDEA: the update step. The gradient points uphill on the loss
    # surface, so we step in the NEGATIVE gradient direction — that single
    # line is the engine of every neural network you will ever train.
    w = w - eta * grad_w
    b = b - eta * grad_b

    losses.append(loss)

# Report the learned parameters. Compare with the true line y = 2x + 1:
# after only 30 steps we are already within ~1% of the exact answer.
print(f"final w={w:.4f}  b={b:.4f}  loss={loss:.6f}")

# Plot the loss curve: steep drop first (far from the minimum), then a
# flattening tail (near the minimum the slope — and therefore the step —
# shrinks automatically). Saved as loss_curve.png next to this script.
plt.plot(losses)
plt.xlabel("step")
plt.ylabel("MSE loss")
plt.title("Gradient descent loss curve")
plt.savefig("loss_curve.png")

# ---------------------------------------------------------------------------
# 4. SANITY CHECK — the closed-form solution
# For linear regression with MSE there is an exact answer (the least
# squares solution), so we can verify that gradient descent is not
# cheating us. Any correct optimizer must approach these values as the
# number of steps grows.
# ---------------------------------------------------------------------------
w_cf = ((x - x.mean()) * (y - y.mean())).sum() / ((x - x.mean()) ** 2).sum()
b_cf = y.mean() - w_cf * x.mean()
print(f"closed-form w={w_cf:.4f}  b={b_cf:.4f}")
