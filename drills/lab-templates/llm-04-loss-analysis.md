# Lab: Loss Analysis

## Prerequisites
- Python 3.10+
- NumPy
- Matplotlib

## Setup

```bash
python -m venv .work.mlt/labs/loss-analysis/.venv
source .work.mlt/labs/loss-analysis/.venv/bin/activate
pip install numpy matplotlib
```

## Objectives
- Recognize the five classic training loss pathologies
- Classify synthetic loss curves by their shape
- Implement spike detection on a loss curve
- Map each diagnosis to a concrete fix

## Code

```python
import numpy as np
import matplotlib.pyplot as plt

np.random.seed(42)
steps = np.arange(200)


def healthy():
    # Smooth exponential decay toward a plateau, small noise
    return 2.5 * np.exp(-steps / 40) + 0.35 + np.random.randn(len(steps)) * 0.03


def lr_too_high():
    # Oscillates and never settles; may diverge
    return 2.0 + 0.6 * np.sin(steps / 3) * np.exp(steps / 300) + np.random.randn(len(steps)) * 0.15


def lr_too_low():
    # Decreases almost linearly, far from converged after 200 steps
    return 2.5 - steps * 0.004 + np.random.randn(len(steps)) * 0.02


def overfitting():
    # Train loss keeps dropping while val loss turns up after step ~80
    train = 2.5 * np.exp(-steps / 30) + 0.1 + np.random.randn(len(steps)) * 0.02
    val = 2.5 * np.exp(-steps / 30) + 0.3 + np.where(steps > 80, (steps - 80) * 0.008, 0)
    return train, val + np.random.randn(len(steps)) * 0.03


def gradient_spikes():
    # Healthy decay with occasional large spikes that recover
    loss = 2.5 * np.exp(-steps / 40) + 0.35 + np.random.randn(len(steps)) * 0.03
    spike_idx = np.random.choice(len(steps), size=8, replace=False)
    loss[spike_idx] += np.random.uniform(1.0, 3.0, size=8)
    return loss


curves = {
    "curve_A": healthy(),
    "curve_B": lr_too_high(),
    "curve_C": lr_too_low(),
    "curve_D": gradient_spikes(),
}
train_d, val_d = overfitting()

# --- Task 1: plot every curve, classify each by eye before reading the answers ---
fig, axes = plt.subplots(2, 3, figsize=(15, 8))
for ax, (name, loss) in zip(axes.flat, curves.items()):
    ax.plot(steps, loss)
    ax.set_title(name)
    ax.set_xlabel("Step")
    ax.set_ylabel("Loss")
ax = axes.flat[4]
ax.plot(steps, train_d, label="train")
ax.plot(steps, val_d, label="val")
ax.set_title("curve_E")
ax.legend()
axes.flat[5].axis("off")
plt.tight_layout()
plt.savefig("loss_curves.png")
plt.show()

# --- Task 2: spike detection ---
def detect_spikes(loss, window=10, threshold=5.0):
    """Flag steps where loss exceeds the rolling median by threshold * robust std.

    Robust std comes from the median absolute deviation (MAD), so a spike
    inside the window cannot inflate the estimate and mask itself.
    """
    spikes = []
    for i in range(window, len(loss)):
        w = loss[i - window:i]
        med = np.median(w)
        robust_std = 1.4826 * np.median(np.abs(w - med))
        if loss[i] > med + threshold * robust_std:
            spikes.append(i)
    return np.array(spikes)


loss_d = curves["curve_D"]
spikes = detect_spikes(loss_d)
print(f"Detected {len(spikes)} spikes at steps: {spikes}")

plt.figure(figsize=(10, 4))
plt.plot(steps, loss_d)
plt.scatter(steps[spikes], loss_d[spikes], color="red", zorder=5, label="spike")
plt.title("curve_D with detected spikes")
plt.legend()
plt.savefig("spike_detection.png")
plt.show()

# --- Task 3: diagnose a curve from simple statistics and suggest a fix ---
def diagnose(loss, val_loss=None):
    tail_std = np.std(loss[-50:])
    tail_slope = np.polyfit(np.arange(50), loss[-50:], 1)[0]
    n_spikes = len(detect_spikes(loss))

    # Order matters: check the most specific signatures first
    if val_loss is not None and val_loss[-1] > np.min(val_loss) + 0.2:
        return "overfitting: early stopping, more data, weight decay, or dropout"
    if tail_std > 0.3 and loss[-1] > 1.0:
        return "LR too high: reduce learning rate 2-10x, add warmup or LR decay"
    if n_spikes >= 3:
        return "gradient spikes: lower LR, add gradient clipping, check for bad batches"
    if tail_slope < -0.001 and loss[-1] > 1.0:
        return "LR too low: increase learning rate or train longer"
    if tail_std < 0.1 and abs(tail_slope) < 0.002:
        return "healthy: no action needed"
    return "unclear: plot the curve and inspect manually"


for name, loss in curves.items():
    print(f"{name}: {diagnose(loss)}")
print(f"curve_E: {diagnose(train_d, val_d)}")
```

## Expected Output
- `loss_curves.png`: grid of 5 curves. Correct classification: A=healthy, B=LR too high (oscillating/diverging), C=LR too low (slow near-linear descent), D=gradient spikes, E=overfitting (train down, val up after step ~80)
- `detect_spikes` finds ~8 spikes in curve_D; `spike_detection.png` marks them in red with no obvious false positives
- `diagnose` prints the matching diagnosis and fix for each of the 5 curves
- Classify all 5 curves yourself before scrolling to the answer key in the first bullet

## Troubleshooting
- Plots don't open: run with `MPLBACKEND=Agg python lab.py` and open the saved PNGs instead
- Spike detection flags everything: increase `threshold` or `window`; the rolling window must exclude the current point
- `diagnose` returns "unclear" for curve_C: check thresholds against `tail_slope` and `loss[-1]`; the order of the `if` branches matters
- Different curves after edits: keep `np.random.seed(42)` at the top before any `randn` call

## Cleanup
```bash
deactivate
rm -rf .work.mlt/labs/loss-analysis/.venv
rm -f loss_curves.png spike_detection.png
```
