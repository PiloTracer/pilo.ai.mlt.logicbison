# Lab: Data Augmentation

## Prerequisites
- Python 3.10+
- CPU-only is fine (small CNN on a CIFAR-10 subset)
- 8GB RAM, 2GB disk (CIFAR-10 download is ~170MB, one-time)

## Setup

```bash
python -m venv .work.mlt/labs/data-augmentation/.venv
source .work.mlt/labs/data-augmentation/.venv/bin/activate
pip install torch torchvision matplotlib
```

## Objectives
- Build three augmentation pipelines with torchvision transforms
- Visualize augmented samples side by side
- Train a small CNN under each strategy on a CIFAR-10 subset
- Compare validation accuracy: baseline vs flip/crop vs flip/crop+colorjitter+random-erasing

## Code

```python
import torch
import torch.nn as nn
import torch.optim as optim
import torchvision
import torchvision.transforms as T
import matplotlib.pyplot as plt
from torch.utils.data import DataLoader, Subset

# Reproducibility
torch.manual_seed(42)

# CIFAR-10 stats for normalization
MEAN, STD = (0.4914, 0.4822, 0.4465), (0.2470, 0.2435, 0.2616)

# --- Part 1: augmentation pipelines -----------------------------------------

# Strategy A: baseline (no augmentation, just tensor + normalize)
baseline = T.Compose([
    T.ToTensor(),
    T.Normalize(MEAN, STD),
])

# Strategy B: random horizontal flip + random crop with padding
flip_crop = T.Compose([
    T.RandomHorizontalFlip(p=0.5),
    T.RandomCrop(32, padding=4),
    T.ToTensor(),
    T.Normalize(MEAN, STD),
])

# Strategy C: B + color jitter + random erasing (erasing runs on the tensor)
full_aug = T.Compose([
    T.RandomHorizontalFlip(p=0.5),
    T.RandomCrop(32, padding=4),
    T.ColorJitter(brightness=0.3, contrast=0.3, saturation=0.3, hue=0.05),
    T.ToTensor(),
    T.Normalize(MEAN, STD),
    T.RandomErasing(p=0.5, scale=(0.02, 0.2)),
])

# Visualization pipelines (no normalization, so images stay displayable)
viz_pipelines = {
    "baseline": T.Compose([T.ToTensor()]),
    "flip/crop": T.Compose([
        T.RandomHorizontalFlip(p=0.5),
        T.RandomCrop(32, padding=4),
        T.ToTensor(),
    ]),
    "flip/crop+jitter+erase": T.Compose([
        T.RandomHorizontalFlip(p=0.5),
        T.RandomCrop(32, padding=4),
        T.ColorJitter(brightness=0.3, contrast=0.3, saturation=0.3, hue=0.05),
        T.ToTensor(),
        T.RandomErasing(p=0.5, scale=(0.02, 0.2), value=0),
    ]),
}

# Raw dataset (PIL images) for visualization; downloads CIFAR-10 once (~170MB)
raw_train = torchvision.datasets.CIFAR10(root="./data", train=True, download=True)

# --- Part 2: visualize augmented samples ------------------------------------

img, label = raw_train[0]  # one fixed sample image
fig, axes = plt.subplots(len(viz_pipelines), 8, figsize=(12, 5))
for row, (name, pipeline) in enumerate(viz_pipelines.items()):
    for col in range(8):
        torch.manual_seed(col)  # same seeds per column across rows for comparison
        aug = pipeline(img).permute(1, 2, 0).clamp(0, 1)
        axes[row, col].imshow(aug)
        axes[row, col].axis("off")
    axes[row, 0].set_ylabel(name, rotation=0, labelpad=80, va="center")
plt.suptitle(f"8 augmented variants of one sample (class: {raw_train.classes[label]})")
plt.tight_layout()
plt.savefig("augmented_samples.png", dpi=120)
plt.show()

# --- Part 3: data subsets ----------------------------------------------------

# Fixed subsets keep the comparison fair and CPU-feasible
g = torch.Generator().manual_seed(42)
train_idx = torch.randperm(len(raw_train), generator=g)[:2000].tolist()

raw_val = torchvision.datasets.CIFAR10(root="./data", train=False, download=True)
val_idx = torch.randperm(len(raw_val), generator=g)[:500].tolist()

# Validation transform is always plain (no augmentation at eval time)
eval_tf = T.Compose([T.ToTensor(), T.Normalize(MEAN, STD)])

# --- Part 4: a small CNN (~120k params) --------------------------------------

def make_model():
    return nn.Sequential(
        nn.Conv2d(3, 32, 3, padding=1), nn.ReLU(), nn.MaxPool2d(2),   # 32x32 -> 16x16
        nn.Conv2d(32, 64, 3, padding=1), nn.ReLU(), nn.MaxPool2d(2),  # 16x16 -> 8x8
        nn.Flatten(),
        nn.Linear(64 * 8 * 8, 128), nn.ReLU(),
        nn.Linear(128, 10),
    )

def evaluate(model, loader):
    model.eval()
    correct = total = 0
    with torch.no_grad():
        for x, y in loader:
            pred = model(x).argmax(dim=1)
            correct += (pred == y).sum().item()
            total += y.size(0)
    return correct / total

def train_with(transform, epochs=3):
    torch.manual_seed(42)  # same init for every strategy
    train_ds = torchvision.datasets.CIFAR10(root="./data", train=True, transform=transform)
    val_ds = torchvision.datasets.CIFAR10(root="./data", train=False, transform=eval_tf)
    train_loader = DataLoader(Subset(train_ds, train_idx), batch_size=64, shuffle=True)
    val_loader = DataLoader(Subset(val_ds, val_idx), batch_size=256)

    model = make_model()
    optimizer = optim.Adam(model.parameters(), lr=1e-3)
    criterion = nn.CrossEntropyLoss()

    history = []
    for epoch in range(epochs):
        model.train()
        running = 0.0
        for x, y in train_loader:
            optimizer.zero_grad()
            loss = criterion(model(x), y)
            loss.backward()
            optimizer.step()
            running += loss.item()
        acc = evaluate(model, val_loader)
        history.append(acc)
        print(f"  epoch {epoch + 1}/{epochs}  loss={running / len(train_loader):.4f}  val_acc={acc:.4f}")
    return history

# --- Part 5: benchmark the three strategies ----------------------------------

results = {}
for name, tf in [("baseline", baseline), ("flip/crop", flip_crop), ("full aug", full_aug)]:
    print(f"Training with: {name}")
    results[name] = train_with(tf)

print("\nFinal validation accuracy:")
for name, hist in results.items():
    print(f"  {name:12s}: {hist[-1]:.4f}")

# Plot val accuracy per epoch for each strategy
for name, hist in results.items():
    plt.plot(range(1, len(hist) + 1), hist, marker="o", label=name)
plt.xlabel("Epoch")
plt.ylabel("Validation accuracy")
plt.title("Augmentation strategy comparison (CIFAR-10 subset)")
plt.legend()
plt.tight_layout()
plt.savefig("augmentation_benchmark.png", dpi=120)
plt.show()
```

## Expected Output
- `augmented_samples.png`: a 3x8 grid showing one CIFAR-10 image under each pipeline; the full-aug row shows color shifts and gray erased patches
- Each strategy trains 3 epochs on 2000 images in a few minutes on CPU
- Printed val accuracies; typically flip/crop and full aug beat baseline on held-out data, with the gap growing over epochs (baseline overfits faster)
- `augmentation_benchmark.png`: val accuracy curves per strategy
- With only 3 epochs and a small subset, differences can be modest (a few points); that is expected — the point is the method, not the final number

## Troubleshooting
- CIFAR-10 download fails or stalls: delete `./data` and rerun, or set a mirror via `CIFAR10(root="./data", ..., download=True)` retry; the archive is ~170MB
- Training too slow: reduce the subset to 1000/250 images or epochs to 2; keep the subset identical across strategies
- All strategies tie: increase epochs to 5-6; augmentation gains mostly show up once the baseline starts overfitting
- `RandomErasing` error: it must come after `ToTensor()` in the Compose — it operates on tensors, not PIL images
- Plot window does not open (headless/SSH): the script still writes both PNG files; open them directly

## Cleanup
```bash
deactivate
rm -rf .work.mlt/labs/data-augmentation/.venv
rm -rf ./data augmented_samples.png augmentation_benchmark.png
```
