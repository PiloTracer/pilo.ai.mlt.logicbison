# Lab: CNN Image Classifier

## Prerequisites
- Python 3.10+
- 8GB+ RAM
- 1GB free disk space (CIFAR-10 auto-downloads ~170MB on first run)
- CPU is fine; a consumer GPU speeds up the optional full run

## Setup

```bash
python -m venv .work.mlt/labs/cnn-image-classifier/.venv
source .work.mlt/labs/cnn-image-classifier/.venv/bin/activate
pip install torch torchvision matplotlib
```

## Objectives
- Build a small CNN with `torch.nn`
- Train on a CIFAR-10 subset, CPU-feasible in a few minutes
- Track train and validation accuracy per epoch
- Plot the train/val accuracy curve

## Code

```python
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader, Subset, random_split
from torchvision import datasets, transforms
import matplotlib.pyplot as plt

# Reproducibility
torch.manual_seed(42)

# Device: use GPU if available, CPU otherwise
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
print(f"Using device: {device}")

# --- Data ---
# torchvision downloads CIFAR-10 to ./data on first run (~170MB, one-time).
transform = transforms.Compose([
    transforms.ToTensor(),
    transforms.Normalize((0.5, 0.5, 0.5), (0.5, 0.5, 0.5)),
])

full_train = datasets.CIFAR10(root="./data", train=True, download=True, transform=transform)

# Subset for a CPU-feasible timed drill. For a full run on GPU, set
# TRAIN_SIZE = len(full_train) and remove the random_split below.
TRAIN_SIZE = 5000
VAL_SIZE = 1000
subset, _ = random_split(full_train, [TRAIN_SIZE + VAL_SIZE, len(full_train) - TRAIN_SIZE - VAL_SIZE])
train_set, val_set = random_split(subset, [TRAIN_SIZE, VAL_SIZE])

train_loader = DataLoader(train_set, batch_size=64, shuffle=True, num_workers=2)
val_loader = DataLoader(val_set, batch_size=256, shuffle=False, num_workers=2)

CLASSES = full_train.classes  # 10 classes: airplane, automobile, ..., truck

# --- Model: small CNN, ~0.3M params ---
class SmallCNN(nn.Module):
    def __init__(self):
        super().__init__()
        self.features = nn.Sequential(
            nn.Conv2d(3, 32, kernel_size=3, padding=1),   # 32x32 -> 32x32
            nn.ReLU(),
            nn.MaxPool2d(2),                               # -> 16x16
            nn.Conv2d(32, 64, kernel_size=3, padding=1),
            nn.ReLU(),
            nn.MaxPool2d(2),                               # -> 8x8
        )
        self.classifier = nn.Sequential(
            nn.Flatten(),
            nn.Linear(64 * 8 * 8, 128),
            nn.ReLU(),
            nn.Linear(128, 10),
        )

    def forward(self, x):
        return self.classifier(self.features(x))

model = SmallCNN().to(device)
criterion = nn.CrossEntropyLoss()
optimizer = optim.Adam(model.parameters(), lr=1e-3)

def evaluate(loader):
    model.eval()
    correct, total = 0, 0
    with torch.no_grad():
        for images, labels in loader:
            images, labels = images.to(device), labels.to(device)
            preds = model(images).argmax(dim=1)
            correct += (preds == labels).sum().item()
            total += labels.size(0)
    return correct / total

# --- Train ---
EPOCHS = 3  # 2-3 epochs on the subset; raise to 10+ for a full GPU run
train_accs, val_accs = [], []

for epoch in range(1, EPOCHS + 1):
    model.train()
    correct, total = 0, 0
    for images, labels in train_loader:
        images, labels = images.to(device), labels.to(device)
        optimizer.zero_grad()
        outputs = model(images)
        loss = criterion(outputs, labels)
        loss.backward()
        optimizer.step()
        correct += (outputs.argmax(dim=1) == labels).sum().item()
        total += labels.size(0)

    train_acc = correct / total
    val_acc = evaluate(val_loader)
    train_accs.append(train_acc)
    val_accs.append(val_acc)
    print(f"Epoch {epoch}/{EPOCHS}  loss={loss.item():.4f}  "
          f"train_acc={train_acc:.3f}  val_acc={val_acc:.3f}")

# --- Plot train/val accuracy curve ---
plt.figure(figsize=(7, 4))
plt.plot(range(1, EPOCHS + 1), train_accs, marker="o", label="Train accuracy")
plt.plot(range(1, EPOCHS + 1), val_accs, marker="s", label="Val accuracy")
plt.xlabel("Epoch")
plt.ylabel("Accuracy")
plt.title("CIFAR-10 subset: train vs validation accuracy")
plt.legend()
plt.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig("cnn_accuracy_curve.png")
plt.show()
```

## Expected Output
- `Using device: cpu` (or `cuda` if a GPU is present)
- Per-epoch lines with train and validation accuracy
- On the 5000-image subset: train accuracy rising to roughly 0.35-0.45 over 3 epochs, val accuracy a few points below
- `cnn_accuracy_curve.png` showing both curves trending upward
- A full 10+ epoch GPU run on all 50k images should reach ~0.65-0.70 val accuracy

## Troubleshooting
- Download stalls or fails: CIFAR-10 comes from a public mirror; retry, or pre-download with `python -c "from torchvision import datasets; datasets.CIFAR10(root='./data', download=True)"`
- Training too slow on CPU: reduce `TRAIN_SIZE` to 2000 or `EPOCHS` to 2, and set `num_workers=0` if worker startup dominates
- `num_workers` errors (e.g. on Windows or restricted environments): set `num_workers=0` in both DataLoaders
- Out of memory on GPU: reduce `batch_size` in `train_loader` from 64 to 32
- Val accuracy flat at ~0.1 (random chance): check that the transform normalizes to [-1, 1] and that `labels` are on the same device as the model

## Cleanup
```bash
deactivate
rm -rf .work.mlt/labs/cnn-image-classifier/.venv
rm -rf ./data cnn_accuracy_curve.png
```
