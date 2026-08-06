# Tutorial — Gradient Descent by Hand (Linear Regression, Pure NumPy)

> **Example tutorial.** Shows the output format of `@mlt-tutorial generate - <topic>` — prerequisites, setup, theory, derivation, runnable code, sanity check, experiments, troubleshooting, exercises, references.

**Summary.** In ~15 minutes you will *derive* the gradient descent update rule for a one-variable linear regression, implement it in 10 lines of pure NumPy, and watch the mean squared error drop on every step. No libraries beyond NumPy and Matplotlib. No training wheels. By the end you can answer: *given a loss function, how do I move the parameters in the direction that reduces loss?* That single question is the engine behind every neural network you will ever train.

**Why this one first.** It is the smallest example that touches the three founding concepts of ML math — dot product (the prediction), derivative as slope (the update), mean vs variance (the loss) — and it is the kernel of the `ml-foundations` M1 exit criterion ("derive gradient descent update rules by hand").

**Data.** 5 points approximating `y = 2x + 1`. We start the parameters *wrong* (w=0, b=0) and let gradient descent find the line.

---

## Prerequisites

- Python ≥ 3.9
- `numpy`, `matplotlib` (`pip install numpy matplotlib`)
- Prior knowledge: high-school algebra, what a derivative / slope is, the equation of a line `y = mx + b`. If "derivative" is hazy, the explanation below re-derives what you need.

## Setup (isolated venv, per lab-safety)

```bash
mkdir -p .training.mlt/labs/grad-descent
python3 -m venv .training.mlt/labs/grad-descent/.venv
source .training.mlt/labs/grad-descent/.venv/bin/activate
pip install numpy matplotlib
```

Save the script as `.training.mlt/labs/grad-descent/gd_linreg.py` and run it from that directory.

---

## Part 1 — The whole idea in one sentence

> Gradient descent: look at the slope of the loss with respect to each parameter, take a small step *downhill*.

That's it. No more, no less. The "magic" is the chain rule: how do we know how `w` affects the loss `L`? Because `w` affects the prediction `ŷ`, and the prediction affects the loss. Chain the two derivatives.

---

## Part 2 — Define the model and the loss

Model (one feature):
```
ŷ = w·x + b
```
- `w` (weight) = slope
- `x` is a single input value
- `b` = y-intercept
- the dot product `w·x` is the first concept: it collapses a multiplication into a scalar — the simplest possible "alignment" of one predictor with one input.

Loss (Mean Squared Error across `n` training points):
```
L = (1/n) · Σᵢ (ŷᵢ − yᵢ)²
```
- The squared error penalises being far from the truth, symmetrically
- We take the **mean** so the loss doesn't simply grow with dataset size: the magnitude of MSE is meaningful because it averages, not totals.

The `(1/n)` is the mean; the `(ŷᵢ − yᵢ)²` is the squared deviation — variance-shaped.

---

## Part 3 — Derive the update rules (by hand)

We need ∂L/∂w and ∂L/∂b. Apply the chain rule.

Loss for a single point `i`:
```
Lᵢ = (ŷᵢ − yᵢ)² = (w·xᵢ + b − yᵢ)²
```

### Derivative w.r.t. `w`
```
∂Lᵢ/∂w = 2 · (w·xᵢ + b − yᵢ) · ∂/∂w(w·xᵢ + b)
       = 2 · (ŷᵢ − yᵢ) · xᵢ
```
The factor `xᵢ` is the chain: `w` only touches the prediction through multiplication by `xᵢ`, so its sensitivity scales with `xᵢ`. Big-input points have louder opinions about `w`.

### Derivative w.r.t. `b`
```
∂Lᵢ/∂b = 2 · (ŷᵢ − yᵢ) · ∂/∂b(w·xᵢ + b)
       = 2 · (ŷᵢ − yᵢ)
```
`b` shifts all predictions equally, so its derivative is the raw error (times 2).

### Across the dataset (mean)
```
∂L/∂w = (1/n) · Σ 2(ŷᵢ − yᵢ) xᵢ      = (2/n) · Σ xᵢ (ŷᵢ − yᵢ)
∂L/∂b = (1/n) · Σ 2(ŷᵢ − yᵢ)         = (2/n) · Σ (ŷᵢ − yᵢ)
```

### The update — one step
```
w ← w − η · ∂L/∂w
b ← b − η · ∂L/∂b
```
- `η` = learning rate (how big each step is; `0.1` here)
- the **minus** sign is the whole point of "descent" — we move opposite to the gradient because the gradient points *uphill*. The derivative tells you which way is up; you walk the other way.

That is the entire algorithm. Memorize these four lines; everything else in deep learning is a generalisation or an acceleration of this pattern.

---

## Part 4 — Implement it (ten lines)

Save as `gd_linreg.py` (the shipped example at `.training.mlt/labs/grad-descent/gd_linreg.py` is the same code with detailed explanatory comments):

```python
import numpy as np
import matplotlib.pyplot as plt

np.random.seed(0)

x = np.array([0.0, 1.0, 2.0, 3.0, 4.0])
y = np.array([1.0, 3.0, 5.0, 7.0, 9.0])
n = x.shape[0]

w, b = 0.0, 0.0
eta = 0.1

losses = []
for step in range(30):
    y_hat = w * x + b
    err = y_hat - y
    loss = (err ** 2).mean()
    grad_w = (2.0 / n) * (x * err).sum()
    grad_b = (2.0 / n) * err.sum()
    w = w - eta * grad_w
    b = b - eta * grad_b
    losses.append(loss)

print(f"final w={w:.4f}  b={b:.4f}  loss={loss:.6f}")
plt.plot(losses)
plt.xlabel("step"); plt.ylabel("MSE loss"); plt.title("Gradient descent loss curve")
plt.savefig("loss_curve.png")
```

### Expected output
```
final w=2.0147  b=0.9581  loss=0.000667
```
(Verified by executing the script as written.) A `loss_curve.png` file is produced showing MSE dropping steeply then flattening. The true line is `w≈2.0, b≈1.0`; after 30 steps you're already there.

---

## Part 5 — Understand every line

1. `y_hat = w * x + b` — vectorised prediction in one NumPy expression. The same `w * x` that's a dot product for one point becomes elementwise multiplication across the whole vector; that's NumPy broadcasting, which later generalises to `np.dot(weights, inputs)` in deep learning.
2. `err = y_hat - y` — the residual; its squared mean is the loss, its sum drives both gradients.
3. `loss = (err ** 2).mean()` — MSE directly. `.mean()` is the mean-vs-variance idea in code: averaging, not summing, keeps the loss scale-invariant to dataset size.
4. `grad_w = (2.0 / n) * (x * err).sum()` — the formula derived in Part 3. `x * err` weights each point's contribution by its input — high-leverage points (large `|x|`) dominate the update.
5. `grad_b = (2.0 / n) * err.sum()` — `b`'s gradient ignores `x`; every point counts equally.
6. `w = w - eta * grad_w` — the gist. Negative direction is what makes it descent.

That's six conceptual lines, not ten. Everything else is plumbing.

---

## Part 6 — Sanity check: did gradient descent lie?

After convergence, your line ≈ `ŷ = 2.01x + 0.96`. Use the closed-form (one-variable least squares) to verify gradient descent isn't cheating you:

```
w_cf = Σ((x−x̄)(y−ȳ)) / Σ((x−x̄)²)
b_cf = ȳ − w_cf·x̄
```

Quick NumPy version, append:

```python
w_cf = ((x - x.mean()) * (y - y.mean())).sum() / ((x - x.mean()) ** 2).sum()
b_cf = y.mean() - w_cf * x.mean()
print(f"closed-form w={w_cf:.4f}  b={b_cf:.4f}")
```

Expected:
```
closed-form w=2.0000  b=1.0000
```

Your gradient descent converged slightly short because 30 steps at `η=0.1` isn't infinity. Bump `range(30)` to `range(1000)` and check — you'll see `w` and `b` converge to the closed-form values. **This is the test that should convince you the algorithm is correct**: any algorithm that claims to "fit" a line should reproduce the unique least-squares solution in the limit.

Quick proof of *why* the solution is unique here: MSE in `(w, b)` is a convex bowl (a paraboloid), so any minimum is the global minimum — there's no local minimum to get stuck in. In deep neural networks this guarantee disappears; keep that in the back pocket for later modules.

---

## Part 7 — Play with it (3-min experiments, no reading)

Try these one-at-a-time against the script. Each reveals a distinct mechanic:

1. Set `eta = 1.5`. Loss explodes (`nan` or worse). This is **divergence**: steps too big for the schedule; the gradient is multiplied by a learning rate larger than the curvature can absorb.
2. Set `eta = 0.001`. Loss moves slowly. **Underfitting / slow step**: tiny `η` prolongs training unnecessarily.
3. Replace `x = np.array([0,1,2,3,4])` with `x = np.array([0, 10, 20, 30, 40])` (scale inputs by 10). Watch how `w` shrinks by 10× and `b` takes many more steps. **Feature scale matters** — this hints at why feature normalisation becomes essential in real ML.
4. Add an outlier: append a sixth point `y[5] = 50` at `x=5`. Re-run. Notice the line tilts hard toward it even though it's clearly wrong. **MSE is outlier-sensitive** (squaring rewards big errors; this is also why you'll see MAE / Huber later).

After playing, you can articulate: *the learning rate governs stability; feature scale governs how wide the bowl is; the loss function governs which points get respect.* Three of the most important instincts in all of ML, earned in three minutes on a 5-row dataset.

---

## Part 8 — Connection to the program

The `ml-foundations` M1 exit lab is "gradient descent for linear regression in pure NumPy, with loss-landscape visualization." This tutorial is 70% of it. The remaining 30% is: (a) switch to multiple features (`ŷ = w·x` where both are vectors — generalising the dot product to the dot product of two vectors), and (b) draw a 2D contour of the loss surface with the parameter trajectory overlaid (`plt.contour` of `(w, b)` vs `L`). Both are mechanical extensions of what's above.

This tutorial seeds M1's three founding intuitions:
- **Dot product**: scaled, summed. Predictions, attention scores, layer pre-activations are all dot products.
- **Derivative as slope → update direction**: the chain rule is how you get gradients anywhere in a computation graph; backprop is exactly this, repeated.
- **Mean vs variance**: MSE, gradient norms, batch normalisation statistics, KL divergence — all live on the mean/variance axis.

---

## Troubleshooting (5 common issues)

1. **`loss becomes nan` after a few iterations.** Learning rate too large; try `eta = 0.01`. If still `nan`, you may have accidentally pasted `loss = ...` inside the loop without recomputing `y_hat` first — gradient is using a stale prediction.
2. **Loss not down-only — it oscillates.** `η` slightly too big; halve it. With convex MSE, oscillation always means step size relative to curvature.
3. **`w` keeps drifting but `b` stays near 0.** Inputs aren't centred. Cheap fix: `x = x - x.mean()` so `b`'s job becomes pure bias, not absorbing the offset of `x`.
4. **Closed-form `w_cf` doesn't match final `w`.** Reduce `range` limit — 30 steps is illustrative, not converged. Use `range(5000)` to confirm you reach the unique least-squares answer.
5. **`TypeError: unsupported operand` on `x * err`.** You passed Python lists, not NumPy arrays. Ensure `x = np.array(...)`, not `x = [...]`.

---

## Exercises (pick any one)

1. **Vectorise across multiple features.** Generalise to `ŷ = w₁x₁ + w₂x₂ + w₃x₃ + b` with a random X of shape `(n, 3)` and `y = X @ [1,−2,0.5] + 4 + noise`. Track the 4-parameter update rule — only the dot products get bigger.
2. **Animate the line fitting.** Plot the line at steps 1, 5, 15, 30. You'll see the line "tumble" into place. It's motivational and verifies the trajectory.
3. **Replace MSE with Mean Absolute Error.** Derive `∂|err|/∂w = sign(err)·x`, implement, and note MAE is non-differentiable at zero but more robust to outliers. Tie back to Experiment 4 above.

---

## Next steps

- **Within M1**: extend this script to plot the loss landscape as a 2D contour (`plt.contourf` over a grid of `w`, `b`) with the parameter path overlaid — that satisfies the "loss-landscape visualisation" clause of the M1 exit lab.
- **Adjacent concept (M3 preview)**: stochastic gradient descent — same update on mini-batches, the bridge to training real models on data too big to fit a single `.mean()`.
- **Sources to read next** — see References below; all are free, canonical, and the derivatives above match the notation in Goodfellow's Deep Learning §4.3.

---

## References

All sources are real, primary, and freely accessible.

1. **NumPy — Broadcasting.** NumPy official documentation, SciPy. `https://numpy.org/doc/stable/user/basics.broadcasting.html`
2. **NumPy — Linear algebra (`np.dot`, `np.linalg`).** SciPy docs. `https://numpy.org/doc/stable/reference/routines.linalg.html`
3. **Goodfellow, Bengio, Courville.** *Deep Learning* (2016), §4.3 "Gradient-Based Optimization" and §5.1.4 "Gradient-Based Optimization as Learning." MIT Press, free online: `https://www.deeplearningbook.org/contents/numerical.html`
4. **3Blue1Brown.** *Essence of Calculus*, episode "The paradox of the derivative" — gives the geometric intuition behind "derivative as slope." `https://www.youtube.com/playlist?list=PLZHQObOWTQDMsr9C-r2HZ9WfK5v5YB5Rz`
5. **Wikipedia.** "Gradient descent" — explicit derivation for linear regression in §Examples. `https://en.wikipedia.org/wiki/Gradient_descent`
6. **Stanford CS229 Lecture Notes (Andrew Ng).** `https://cs229.stanford.edu/notes2022fall/main_notes.pdf` — §Linear Regression contains the exact closed form and gradient descent formulas used here.
