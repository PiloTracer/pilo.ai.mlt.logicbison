# Lab: Small GPT Pre-training

## Prerequisites
- Python 3.10+
- 8GB+ RAM
- 1GB disk space
- CPU-only is fine; a small GPU (any VRAM) just makes it faster

## Setup

```bash
python -m venv .training.mlt/labs/small-gpt-pretraining/.venv
source .training.mlt/labs/small-gpt-pretraining/.venv/bin/activate
pip install torch matplotlib
```

## Objectives
- Implement a GPT (decoder-only transformer) from scratch in PyTorch
- Train a causal LM with lr warmup and cosine decay
- Plot the training/validation loss curve
- Generate text samples from the trained model

## Code

Save as `train_gpt.py` and run with `python train_gpt.py`.

```python
import math
import time
import urllib.request

import torch
import torch.nn as nn
import torch.nn.functional as F
import matplotlib.pyplot as plt

torch.manual_seed(1337)

# --- Hyperparameters (kept small so CPU training fits in the drill) ---
block_size = 128        # context length
batch_size = 64
n_embd = 128
n_head = 4
n_layer = 4
dropout = 0.1
max_steps = 2000
eval_interval = 250
eval_iters = 50
learning_rate = 3e-3
min_lr = 3e-4
warmup_steps = 100
device = "cuda" if torch.cuda.is_available() else "cpu"
print(f"device: {device}")

# --- Data: tiny-shakespeare (~1MB download, character-level tokenization) ---
url = "https://raw.githubusercontent.com/karpathy/char-rnn/master/data/tinyshakespeare/input.txt"
urllib.request.urlretrieve(url, "input.txt")
text = open("input.txt", encoding="utf-8").read()

chars = sorted(set(text))
vocab_size = len(chars)
stoi = {ch: i for i, ch in enumerate(chars)}
itos = {i: ch for ch, i in stoi.items()}
encode = lambda s: [stoi[c] for c in s]
decode = lambda l: "".join(itos[i] for i in l)
print(f"corpus: {len(text)} chars, vocab size: {vocab_size}")

data = torch.tensor(encode(text), dtype=torch.long)
n = int(0.9 * len(data))
train_data, val_data = data[:n], data[n:]

def get_batch(split):
    src = train_data if split == "train" else val_data
    ix = torch.randint(len(src) - block_size, (batch_size,))
    x = torch.stack([src[i:i + block_size] for i in ix])
    y = torch.stack([src[i + 1:i + block_size + 1] for i in ix])
    return x.to(device), y.to(device)

@torch.no_grad()
def estimate_loss(model):
    model.eval()
    out = {}
    for split in ("train", "val"):
        losses = torch.zeros(eval_iters)
        for k in range(eval_iters):
            x, y = get_batch(split)
            _, loss = model(x, y)
            losses[k] = loss.item()
        out[split] = losses.mean().item()
    model.train()
    return out

# --- Model ---
class Head(nn.Module):
    """One causal self-attention head."""
    def __init__(self, head_size):
        super().__init__()
        self.key = nn.Linear(n_embd, head_size, bias=False)
        self.query = nn.Linear(n_embd, head_size, bias=False)
        self.value = nn.Linear(n_embd, head_size, bias=False)
        self.dropout = nn.Dropout(dropout)

    def forward(self, x):
        k, q, v = self.key(x), self.query(x), self.value(x)
        out = F.scaled_dot_product_attention(
            q, k, v, is_causal=True,
            dropout_p=dropout if self.training else 0.0,
        )
        return self.dropout(out)

class MultiHeadAttention(nn.Module):
    def __init__(self, n_head, head_size):
        super().__init__()
        self.heads = nn.ModuleList([Head(head_size) for _ in range(n_head)])
        self.proj = nn.Linear(n_embd, n_embd)
        self.dropout = nn.Dropout(dropout)

    def forward(self, x):
        out = torch.cat([h(x) for h in self.heads], dim=-1)
        return self.dropout(self.proj(out))

class FeedForward(nn.Module):
    def __init__(self):
        super().__init__()
        self.net = nn.Sequential(
            nn.Linear(n_embd, 4 * n_embd),
            nn.GELU(),
            nn.Linear(4 * n_embd, n_embd),
            nn.Dropout(dropout),
        )

    def forward(self, x):
        return self.net(x)

class Block(nn.Module):
    """Pre-norm transformer block."""
    def __init__(self):
        super().__init__()
        head_size = n_embd // n_head
        self.sa = MultiHeadAttention(n_head, head_size)
        self.ffwd = FeedForward()
        self.ln1 = nn.LayerNorm(n_embd)
        self.ln2 = nn.LayerNorm(n_embd)

    def forward(self, x):
        x = x + self.sa(self.ln1(x))
        x = x + self.ffwd(self.ln2(x))
        return x

class GPT(nn.Module):
    def __init__(self):
        super().__init__()
        self.token_embedding = nn.Embedding(vocab_size, n_embd)
        self.position_embedding = nn.Embedding(block_size, n_embd)
        self.blocks = nn.Sequential(*[Block() for _ in range(n_layer)])
        self.ln_f = nn.LayerNorm(n_embd)
        self.lm_head = nn.Linear(n_embd, vocab_size)

    def forward(self, idx, targets=None):
        B, T = idx.shape
        tok = self.token_embedding(idx)                       # (B, T, C)
        pos = self.position_embedding(torch.arange(T, device=idx.device))
        x = self.blocks(tok + pos)
        x = self.ln_f(x)
        logits = self.lm_head(x)                              # (B, T, vocab)
        loss = None
        if targets is not None:
            loss = F.cross_entropy(logits.view(-1, vocab_size), targets.view(-1))
        return logits, loss

    @torch.no_grad()
    def generate(self, idx, max_new_tokens):
        for _ in range(max_new_tokens):
            idx_cond = idx[:, -block_size:]
            logits, _ = self(idx_cond)
            probs = F.softmax(logits[:, -1, :], dim=-1)
            idx_next = torch.multinomial(probs, num_samples=1)
            idx = torch.cat([idx, idx_next], dim=1)
        return idx

model = GPT().to(device)
n_params = sum(p.numel() for p in model.parameters())
print(f"model parameters: {n_params/1e6:.2f}M")
assert n_params < 100e6, "model must stay under 100M parameters"

# --- LR schedule: linear warmup then cosine decay to min_lr ---
def get_lr(step):
    if step < warmup_steps:
        return learning_rate * (step + 1) / warmup_steps
    t = (step - warmup_steps) / (max_steps - warmup_steps)
    return min_lr + 0.5 * (learning_rate - min_lr) * (1 + math.cos(math.pi * t))

optimizer = torch.optim.AdamW(model.parameters(), lr=learning_rate)

# --- Training loop ---
history = {"step": [], "train": [], "val": []}
t0 = time.time()
for step in range(max_steps):
    lr = get_lr(step)
    for g in optimizer.param_groups:
        g["lr"] = lr

    x, y = get_batch("train")
    _, loss = model(x, y)
    optimizer.zero_grad(set_to_none=True)
    loss.backward()
    torch.nn.utils.clip_grad_norm_(model.parameters(), 1.0)
    optimizer.step()

    if step % eval_interval == 0 or step == max_steps - 1:
        losses = estimate_loss(model)
        history["step"].append(step)
        history["train"].append(losses["train"])
        history["val"].append(losses["val"])
        print(f"step {step:4d} | train {losses['train']:.4f} | val {losses['val']:.4f} | lr {lr:.2e}")

print(f"training time: {time.time() - t0:.0f}s")
torch.save(model.state_dict(), "gpt_shakespeare.pt")

# --- Loss curve ---
plt.figure(figsize=(8, 4))
plt.plot(history["step"], history["train"], label="train")
plt.plot(history["step"], history["val"], label="val")
plt.xlabel("Step")
plt.ylabel("Loss")
plt.title("GPT pre-training loss (tiny-shakespeare)")
plt.legend()
plt.tight_layout()
plt.savefig("loss_curve.png")
print("saved loss_curve.png")

# --- Generate a sample ---
context = torch.zeros((1, 1), dtype=torch.long, device=device)
sample = decode(model.generate(context, max_new_tokens=500)[0].tolist())
print("--- sample ---")
print(sample)
```

## Expected Output
- `model parameters: ~0.8M` (well under the 100M cap), vocab size 65
- Initial loss near `ln(65) ~= 4.17`, falling to train/val loss ~1.4-1.8 by step 2000
- Runtime: roughly 10-25 min on a modern laptop CPU, 1-3 min on a small GPU
- `loss_curve.png` showing both curves decreasing smoothly and leveling off
- Generated sample that is gibberish words but visibly Shakespeare-like: plausible character names, line breaks, and stage-direction formatting

## Troubleshooting
- Loss stuck near 4.17: check `y` is shifted by one token in `get_batch`, and that the optimizer lr is actually updated each step
- Loss goes NaN: lower `learning_rate` to `1e-3`; gradient clipping is already on
- Too slow on CPU: reduce `max_steps` to 1000, `batch_size` to 32, or `n_layer`/`n_embd`; expect slightly higher final loss
- Download fails: fetch `input.txt` manually with `curl -O https://raw.githubusercontent.com/karpathy/char-rnn/master/data/tinyshakespeare/input.txt`
- `CUDA out of memory`: reduce `batch_size` to 16-32

## Cleanup
```bash
deactivate
rm -rf .training.mlt/labs/small-gpt-pretraining/.venv
rm -f input.txt gpt_shakespeare.pt loss_curve.png train_gpt.py
```
