# Lab: RNN Sequence Model

## Prerequisites
- Python 3.10+
- CPU only (no GPU needed)
- 2GB RAM, 1GB disk space

## Setup

```bash
python -m venv .work.mlt/labs/rnn-sequence-model/.venv
source .work.mlt/labs/rnn-sequence-model/.venv/bin/activate
pip install torch numpy matplotlib
```

## Objectives
- Build a synthetic sine-wave time series (no downloads)
- Convert a series into sliding-window supervised samples
- Train an LSTM in PyTorch for next-step prediction
- Plot predictions against ground truth

## Code

```python
import numpy as np
import torch
import torch.nn as nn
import matplotlib.pyplot as plt

torch.manual_seed(42)
np.random.seed(42)

# Synthetic sine wave with noise
t = np.linspace(0, 100, 1000)
series = np.sin(t) + 0.1 * np.random.randn(len(t))
series = series.astype(np.float32)

# Sliding windows: SEQ_LEN inputs -> next value
SEQ_LEN = 50

def make_windows(series, seq_len):
    X, y = [], []
    for i in range(len(series) - seq_len):
        X.append(series[i:i + seq_len])
        y.append(series[i + seq_len])
    return np.array(X), np.array(y)

X, y = make_windows(series, SEQ_LEN)

# Chronological split: first 80% train, last 20% test
split = int(0.8 * len(X))
X_train, X_test = X[:split], X[split:]
y_train, y_test = y[:split], y[split:]

X_train = torch.tensor(X_train).unsqueeze(-1)  # (N, seq_len, 1)
y_train = torch.tensor(y_train).unsqueeze(-1)  # (N, 1)
X_test = torch.tensor(X_test).unsqueeze(-1)
y_test = torch.tensor(y_test).unsqueeze(-1)

class LSTMForecaster(nn.Module):
    def __init__(self, hidden_size=32):
        super().__init__()
        self.lstm = nn.LSTM(input_size=1, hidden_size=hidden_size, batch_first=True)
        self.fc = nn.Linear(hidden_size, 1)

    def forward(self, x):
        out, _ = self.lstm(x)      # out: (N, seq_len, hidden)
        return self.fc(out[:, -1]) # predict from last timestep

model = LSTMForecaster()
criterion = nn.MSELoss()
optimizer = torch.optim.Adam(model.parameters(), lr=0.01)

EPOCHS = 30
losses = []
for epoch in range(EPOCHS):
    model.train()
    optimizer.zero_grad()
    preds = model(X_train)
    loss = criterion(preds, y_train)
    loss.backward()
    optimizer.step()
    losses.append(loss.item())
    if (epoch + 1) % 5 == 0:
        print(f"Epoch {epoch + 1}/{EPOCHS}  train MSE: {loss.item():.4f}")

model.eval()
with torch.no_grad():
    test_preds = model(X_test).squeeze(-1).numpy()
    test_mse = criterion(model(X_test), y_test).item()

print(f"Test MSE: {test_mse:.4f}")

plt.figure(figsize=(12, 4))
plt.subplot(1, 2, 1)
plt.plot(losses)
plt.xlabel('Epoch')
plt.ylabel('MSE')
plt.title('Training Loss')

plt.subplot(1, 2, 2)
plt.plot(y_test.squeeze(-1).numpy(), label='Ground truth')
plt.plot(test_preds, label='Prediction')
plt.xlabel('Test step')
plt.ylabel('Value')
plt.title('LSTM Predictions vs Ground Truth')
plt.legend()

plt.tight_layout()
plt.savefig('rnn_sequence_result.png')
plt.show()
```

## Expected Output
- Train MSE decreasing each printed epoch, below 0.05 by epoch 30
- Test MSE close to the noise floor (roughly 0.01-0.05)
- Plot where the prediction line closely tracks the sine-wave ground truth
- Runtime under 2 minutes on CPU

## Troubleshooting
- Loss not decreasing: raise `EPOCHS` or lower the learning rate to 0.005
- Predictions lag the ground truth: increase `hidden_size` to 64 or lengthen `SEQ_LEN`
- No plot window: check the saved `rnn_sequence_result.png` instead of relying on `plt.show()`
- `ModuleNotFoundError: torch`: activate the venv before running the script

## Cleanup
```bash
deactivate
rm -rf .work.mlt/labs/rnn-sequence-model/.venv
```
