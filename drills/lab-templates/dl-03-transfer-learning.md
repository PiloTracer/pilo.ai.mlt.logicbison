# Lab: Transfer Learning

## Prerequisites
- Python 3.10+
- 8GB+ RAM, CPU-only is fine
- 1GB disk space (ResNet-18 weights ~45MB, CIFAR-10 ~170MB, both auto-downloaded once)

## Setup

```bash
python -m venv .training.mlt/labs/transfer-learning/.venv
source .training.mlt/labs/transfer-learning/.venv/bin/activate
pip install torch torchvision
```

## Objectives
- Load a pretrained ResNet-18 and adapt it to a new 2-class task
- Freeze the backbone and train only the classifier head
- Unfreeze and fine-tune the full network with a lower learning rate
- Compare frozen-head vs full fine-tuning accuracy

## Code

```python
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader, Subset
from torchvision import datasets, transforms, models

torch.manual_seed(42)

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
print(f"Using device: {device}")

# 2-class subset of CIFAR-10: cats (3) vs dogs (5). No extra dataset download
# beyond CIFAR-10 itself (~170MB, downloaded once by torchvision).
# Keep images at 32x32: pretrained ResNet-18 accepts any spatial size, and
# upscaling to 224x224 would make CPU training too slow for a timed drill.
CLASSES = {3: 0, 5: 1}  # cat -> 0, dog -> 1
transform = transforms.Compose([
    transforms.ToTensor(),
    transforms.Normalize((0.485, 0.456, 0.406), (0.229, 0.224, 0.225)),
])

train_full = datasets.CIFAR10(root="./data", train=True, download=True, transform=transform)
test_full = datasets.CIFAR10(root="./data", train=False, download=True, transform=transform)

def make_subset(dataset, per_class):
    idx = []
    counts = {c: 0 for c in CLASSES}
    for i, (_, label) in enumerate(dataset):
        if label in CLASSES and counts[label] < per_class:
            idx.append(i)
            counts[label] += 1
    return Subset(dataset, idx)

train_set = make_subset(train_full, per_class=1000)  # 2000 images total
test_set = make_subset(test_full, per_class=200)     # 400 images total

# Relabel targets: a wrapper so the loaders emit 0/1 instead of 3/5
class Relabeled(torch.utils.data.Dataset):
    def __init__(self, subset):
        self.subset = subset
    def __len__(self):
        return len(self.subset)
    def __getitem__(self, i):
        x, y = self.subset[i]
        return x, CLASSES[y]

train_loader = DataLoader(Relabeled(train_set), batch_size=64, shuffle=True, num_workers=2)
test_loader = DataLoader(Relabeled(test_set), batch_size=256, shuffle=False)

# Pretrained ResNet-18 (~45MB one-time download to ~/.cache/torch)
model = models.resnet18(weights=models.ResNet18_Weights.DEFAULT)
model.fc = nn.Linear(model.fc.in_features, 2)  # replace 1000-class head
model = model.to(device)

criterion = nn.CrossEntropyLoss()

def evaluate(model):
    model.eval()
    correct, total = 0, 0
    with torch.no_grad():
        for x, y in test_loader:
            x, y = x.to(device), y.to(device)
            correct += (model(x).argmax(1) == y).sum().item()
            total += y.size(0)
    return correct / total

def train_epochs(model, epochs, optimizer):
    model.train()
    for epoch in range(epochs):
        running = 0.0
        for x, y in train_loader:
            x, y = x.to(device), y.to(device)
            optimizer.zero_grad()
            loss = criterion(model(x), y)
            loss.backward()
            optimizer.step()
            running += loss.item()
        print(f"  epoch {epoch + 1}/{epochs}  loss={running / len(train_loader):.4f}")

# Phase 1: freeze backbone, train only the new classifier head
for param in model.parameters():
    param.requires_grad = False
for param in model.fc.parameters():
    param.requires_grad = True

print("Phase 1: frozen backbone, training head only")
optimizer = optim.Adam(model.fc.parameters(), lr=1e-3)
train_epochs(model, epochs=3, optimizer=optimizer)
acc_frozen = evaluate(model)
print(f"Frozen-backbone test accuracy: {acc_frozen:.3f}")

# Phase 2: unfreeze everything, fine-tune with a lower learning rate
for param in model.parameters():
    param.requires_grad = True

print("Phase 2: full fine-tuning")
optimizer = optim.Adam(model.parameters(), lr=1e-4)
train_epochs(model, epochs=2, optimizer=optimizer)
acc_finetuned = evaluate(model)
print(f"Fine-tuned test accuracy: {acc_finetuned:.3f}")

print(f"\nComparison: frozen={acc_frozen:.3f}  fine-tuned={acc_finetuned:.3f}")
```

## Expected Output
- Phase 1 loss decreasing over 3 epochs; frozen-backbone test accuracy around 0.85-0.95
- Phase 2 fine-tuned accuracy equal to or a few points above the frozen result
- Total runtime roughly 10-25 minutes on CPU, under 5 minutes on a consumer GPU

## Troubleshooting
- Too slow on CPU: reduce `per_class=1000` to `500` and Phase 1 to 2 epochs; keep images at 32x32 (do not upscale to 224x224 on CPU)
- `TypeError: resnet18() got an unexpected keyword argument 'weights'`: old torchvision, upgrade with `pip install -U torchvision` (the legacy form is `pretrained=True`)
- CIFAR-10 download fails or stalls: delete `./data/cifar-10-batches-py` and rerun; the download is ~170MB
- `RuntimeError: CUDA out of memory`: lower `batch_size` to 32, or force CPU with `CUDA_VISIBLE_DEVICES=""`

## Cleanup
```bash
deactivate
rm -rf .training.mlt/labs/transfer-learning/.venv ./data
```
