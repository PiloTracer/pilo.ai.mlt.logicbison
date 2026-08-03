# Lab: Custom Transformer from Scratch

## Prerequisites
- Python 3.10+
- CPU only (no GPU required)
- 2GB free RAM
- 2GB disk space

## Setup

```bash
python -m venv .training.mlt/labs/custom-transformer/.venv
source .training.mlt/labs/custom-transformer/.venv/bin/activate
pip install torch
```

## Objectives
- Implement multi-head causal self-attention from scratch
- Build a decoder-only Transformer with positional embeddings, layer norm, and residuals
- Train character-level on a tiny embedded corpus
- Generate text with temperature sampling

## Code

```python
import torch
import torch.nn as nn
import torch.nn.functional as F

torch.manual_seed(42)

# Embedded tiny corpus (Shakespeare-style, public domain). No downloads needed.
CORPUS = """
To be, or not to be, that is the question:
Whether 'tis nobler in the mind to suffer
The slings and arrows of outrageous fortune,
Or to take arms against a sea of troubles
And by opposing end them. To die, to sleep;
No more; and by a sleep to say we end
The heart-ache and the thousand natural shocks
That flesh is heir to: 'tis a consummation
Devoutly to be wish'd. To die, to sleep;
To sleep, perchance to dream. Ay, there's the rub;
For in that sleep of death what dreams may come,
When we have shuffled off this mortal coil,
Must give us pause. There's the respect
That makes calamity of so long life.
All the world's a stage, and all the men and women merely players;
They have their exits and their entrances,
And one man in his time plays many parts.
What's past is prologue. We are such stuff
As dreams are made on, and our little life
Is rounded with a sleep. The course of true love never did run smooth.
"""
text = CORPUS * 5  # repeat to give the model more training signal

# Character-level tokenizer
chars = sorted(set(text))
vocab_size = len(chars)
stoi = {ch: i for i, ch in enumerate(chars)}
itos = {i: ch for ch, i in stoi.items()}
encode = lambda s: [stoi[c] for c in s]
decode = lambda ids: ''.join(itos[i] for i in ids)

data = torch.tensor(encode(text), dtype=torch.long)

# Hyperparameters (~5M params, CPU-friendly)
d_model = 256
n_heads = 4
n_layers = 6
d_ff = 1024
block_size = 128
batch_size = 32
max_steps = 500
lr = 3e-4
device = 'cuda' if torch.cuda.is_available() else 'cpu'
print(f"device: {device} | vocab_size: {vocab_size} | corpus tokens: {len(data)}")


class CausalSelfAttention(nn.Module):
    def __init__(self):
        super().__init__()
        self.qkv = nn.Linear(d_model, 3 * d_model)
        self.proj = nn.Linear(d_model, d_model)
        # lower-triangular mask so each token only attends to the past
        self.register_buffer('mask', torch.tril(torch.ones(block_size, block_size))
                             .view(1, 1, block_size, block_size))

    def forward(self, x):
        B, T, C = x.shape
        q, k, v = self.qkv(x).split(d_model, dim=2)
        q = q.view(B, T, n_heads, C // n_heads).transpose(1, 2)
        k = k.view(B, T, n_heads, C // n_heads).transpose(1, 2)
        v = v.view(B, T, n_heads, C // n_heads).transpose(1, 2)
        att = (q @ k.transpose(-2, -1)) / (k.size(-1) ** 0.5)
        att = att.masked_fill(self.mask[:, :, :T, :T] == 0, float('-inf'))
        att = F.softmax(att, dim=-1)
        y = att @ v
        y = y.transpose(1, 2).contiguous().view(B, T, C)
        return self.proj(y)


class Block(nn.Module):
    """One decoder block: pre-norm attention + pre-norm FFN, both with residuals."""

    def __init__(self):
        super().__init__()
        self.ln1 = nn.LayerNorm(d_model)
        self.attn = CausalSelfAttention()
        self.ln2 = nn.LayerNorm(d_model)
        self.ffn = nn.Sequential(
            nn.Linear(d_model, d_ff),
            nn.GELU(),
            nn.Linear(d_ff, d_model),
        )

    def forward(self, x):
        x = x + self.attn(self.ln1(x))  # residual around attention
        x = x + self.ffn(self.ln2(x))   # residual around feed-forward
        return x


class TinyTransformer(nn.Module):
    def __init__(self):
        super().__init__()
        self.token_emb = nn.Embedding(vocab_size, d_model)
        self.pos_emb = nn.Embedding(block_size, d_model)  # learned positional embeddings
        self.blocks = nn.Sequential(*[Block() for _ in range(n_layers)])
        self.ln_f = nn.LayerNorm(d_model)
        self.head = nn.Linear(d_model, vocab_size)

    def forward(self, idx, targets=None):
        B, T = idx.shape
        tok = self.token_emb(idx)
        pos = self.pos_emb(torch.arange(T, device=idx.device))
        x = tok + pos
        x = self.blocks(x)
        x = self.ln_f(x)
        logits = self.head(x)
        loss = None
        if targets is not None:
            loss = F.cross_entropy(logits.view(-1, vocab_size), targets.view(-1))
        return logits, loss

    @torch.no_grad()
    def generate(self, idx, max_new_tokens, temperature=1.0):
        for _ in range(max_new_tokens):
            idx_cond = idx[:, -block_size:]  # crop context to block_size
            logits, _ = self(idx_cond)
            logits = logits[:, -1, :] / temperature
            probs = F.softmax(logits, dim=-1)
            next_id = torch.multinomial(probs, num_samples=1)
            idx = torch.cat([idx, next_id], dim=1)
        return idx


def get_batch():
    ix = torch.randint(len(data) - block_size, (batch_size,))
    x = torch.stack([data[i:i + block_size] for i in ix])
    y = torch.stack([data[i + 1:i + block_size + 1] for i in ix])
    return x.to(device), y.to(device)


model = TinyTransformer().to(device)
print(f"Parameters: {sum(p.numel() for p in model.parameters()):,}")

optimizer = torch.optim.AdamW(model.parameters(), lr=lr)

# Training loop: predict the next character at every position
for step in range(max_steps):
    x, y = get_batch()
    logits, loss = model(x, y)
    optimizer.zero_grad()
    loss.backward()
    optimizer.step()
    if step % 50 == 0 or step == max_steps - 1:
        print(f"step {step:4d} | loss {loss.item():.4f}")

# Generate from a prompt
prompt = "To be, or not to be"
idx = torch.tensor([encode(prompt)], dtype=torch.long, device=device)
out = model.generate(idx, max_new_tokens=200, temperature=0.8)
print("\n--- generated ---")
print(decode(out[0].tolist()))
```

## Expected Output
- Parameter count around 4.8M
- Loss starting near ln(vocab_size) ~ 4.3 and dropping below ~1.5 by step 500
- Generated text: locally coherent character sequences resembling the corpus (words, line breaks, phrases like "to sleep" or "the question"), not grammatically perfect

## Troubleshooting
- Loss stuck near 4.3: check the causal mask is applied (masked_fill before softmax) and that targets are shifted by one in get_batch
- Training too slow on CPU: reduce `max_steps` to 300, `n_layers` to 4, or `batch_size` to 16
- Generation repeats one character: raise `max_steps`, or sample with temperature 0.8-1.0 instead of argmax
- IndexError in encode at generation time: the prompt must only contain characters present in the corpus
- Loss is NaN: lower the learning rate to 1e-4 or add gradient clipping with `torch.nn.utils.clip_grad_norm_(model.parameters(), 1.0)`

## Cleanup
```bash
deactivate
rm -rf .training.mlt/labs/custom-transformer/.venv
```
