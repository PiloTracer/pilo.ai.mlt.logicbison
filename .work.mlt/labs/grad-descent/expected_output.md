# Expected output — grad-descent lab

Produced by `python gd_linreg.py` (verified 2026-08-04, NumPy 1.x, Python 3.10):

```text
final w=2.0147  b=0.9581  loss=0.000667
closed-form w=2.0000  b=1.0000
```

Plus `loss_curve.png`: MSE dropping steeply for ~10 steps, then flattening.

## How to read it

- `final w≈2.01, b≈0.96` — after only 30 steps, gradient descent recovered
  the true line `y = 2x + 1` to within ~1%.
- `loss=0.000667` — this is the loss measured at the start of the last
  iteration (after 29 updates); it is near zero because the fit is near-perfect.
- `closed-form w=2.0000, b=1.0000` — the exact least-squares answer. Any
  correct optimizer must approach it; raise `range(30)` to `range(1000)`
  and watch gradient descent converge onto it exactly.

If your numbers differ in the last decimal across NumPy versions, that is
floating-point rounding, not a bug. If `w` is far from 2 or the loss grows,
see `README.md` → Troubleshooting.
