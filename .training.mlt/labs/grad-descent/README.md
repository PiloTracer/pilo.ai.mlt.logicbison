# Lab — Gradient Descent for Linear Regression (Pure NumPy)

> **Example lab.** Shows the artifact layout every `@mlt-lab setup - <topic>` produces under `.training.mlt/labs/<topic>/`. This lab maps to Module 1 of the `ml-foundations` program; its completion is recorded in the program's `progress.md` (Lab cell) and in the session log.

## Learning objectives

1. Derive the gradient descent update rules for linear regression by hand
2. Implement them in ~10 lines of vectorized NumPy — no ML libraries
3. Verify the result against the closed-form least-squares solution
4. Build intuition for learning rate, feature scale, and loss behavior

## Prerequisites

- Python ≥ 3.9, high-school algebra, the equation of a line `y = mx + b`
- Packages: `numpy`, `matplotlib` only (no GPU needed)

## Setup

```bash
python3 -m venv .venv                 # isolated environment (per standards/lab-safety.md)
source .venv/bin/activate             # Windows: .venv\Scripts\activate
pip install numpy matplotlib
```

Or run `bash setup.sh` from the project root.

## Run

```bash
python .training.mlt/labs/grad-descent/gd_linreg.py
```

Success looks like `expected_output.md`. If it fails, see `troubleshooting.md` patterns below.

## Files

| File | Purpose |
|------|---------|
| `gd_linreg.py` | The lab — heavily commented so every line teaches |
| `setup.sh` | Environment creation (venv + pinned packages) |
| `expected_output.md` | What success looks like |
| `loss_curve.png` | Artifact produced by a successful run |

## Experiments (after the first successful run)

1. `eta = 1.5` → divergence (loss explodes): steps too big for the curvature
2. `eta = 0.001` → crawl: tiny learning rate wastes iterations
3. Scale inputs ×10 → `w` shrinks 10× and convergence slows: feature scale matters
4. Add outlier `y=50` at `x=5` → the line tilts toward it: MSE is outlier-sensitive

## Cleanup

```bash
rm -rf .training.mlt/labs/grad-descent/.venv   # keeps code + artifacts, frees disk
```

## Troubleshooting

1. **`loss` becomes `nan`** — learning rate too large; use `eta = 0.01`.
2. **Loss oscillates instead of dropping** — `eta` slightly too big; halve it.
3. **`w` drifts but `b` stays near 0** — inputs aren't centred; try `x = x - x.mean()`.
4. **`TypeError: unsupported operand` on `x * err`** — you passed Python lists; use `np.array(...)`.
