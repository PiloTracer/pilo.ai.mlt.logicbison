# pilo.trainer.mlt - Local Setup Guides

Step-by-step guides for setting up ML development environments on local workstations. Covers environment management, GPU setup, and model recommendations by hardware tier.

---

## Python Environment Setup

### venv (Built-in)

```bash
python3 -m venv ~/envs/ml-env
source ~/envs/ml-env/bin/activate
pip install --upgrade pip

# Freeze and restore
pip freeze > requirements.txt
pip install -r requirements.txt

# Deactivate
deactivate
```

### conda (Miniconda / Miniforge)

```bash
# Install Miniforge (recommended over Miniconda for conda-forge defaults)
curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
bash Miniforge3-$(uname)-$(uname -m).sh

# Create environment with specific Python version
conda create -n ml-env python=3.11 -y
conda activate ml-env

# Install packages from conda-forge (faster than defaults channel)
conda install pytorch torchvision torchaudio pytorch-cuda=12.4 -c pytorch -c nvidia -y
conda install -c conda-forge transformers datasets accelerate -y

# Export and recreate
conda env export > environment.yml
conda env create -f environment.yml

# List environments
conda env list

deactivate  # or: conda deactivate
```

### uv (Fast Python Package Manager)

```bash
# Install uv
curl -LsSf https://astral.sh/uv/install.sh | sh

# Create a project environment
uv venv .venv --python 3.11
source .venv/bin/activate

# Install packages (10-100x faster than pip)
uv pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124
uv pip install transformers datasets accelerate peft trl

# Lock and sync (like pip-tools)
uv pip compile requirements.in -o requirements.txt
uv pip sync requirements.txt

# Create and manage projects
uv init my-ml-project
uv add torch transformers
uv run python train.py
```

**Recommendation**: Use `uv` for speed and modern workflow, `conda` if you need non-Python dependencies (CUDA toolkit, cuDNN), `venv` for lightweight isolation.

---

## PyTorch Installation

### CPU Only

```bash
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
```

### CUDA 12.4 (Recommended for most NVIDIA GPUs)

```bash
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124
```

### CUDA 12.1

```bash
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
```

### macOS (Apple Silicon with MPS)

```bash
pip install torch torchvision torchaudio
# MPS backend is included automatically on macOS 12.3+
```

### Verify Installation

```python
import torch

print(f"PyTorch version: {torch.__version__}")
print(f"CUDA available: {torch.cuda.is_available()}")

if torch.cuda.is_available():
    print(f"CUDA version: {torch.version.cuda}")
    print(f"GPU: {torch.cuda.get_device_name(0)}")
    print(f"GPU count: {torch.cuda.device_count()}")
    print(f"VRAM: {torch.cuda.get_device_properties(0).total_mem / 1024**3:.1f} GB")

    x = torch.randn(1000, 1000, device="cuda")
    print(f"Tensor on GPU: {x.device}")

if torch.backends.mps.is_available():
    print("MPS available (Apple Silicon)")
    x = torch.randn(1000, 1000, device="mps")
    print(f"Tensor on MPS: {x.device}")
```

### Nightly Builds (for latest features)

```bash
pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu124
```

---

## Hugging Face Ecosystem Setup

```bash
# Core libraries
pip install transformers datasets evaluate accelerate

# Tokenizers and data processing
pip install tokenizers sentencepiece

# Efficient training
pip install peft          # Parameter-efficient fine-tuning (LoRA, etc.)
pip install trl            # RLHF, DPO, SFT trainers
pip install bitsandbytes   # 4-bit / 8-bit quantization

# Inference optimization
pip install auto-gptq      # GPTQ quantization
pip install autoawq        # AWQ quantization

# Experiment tracking
pip install wandb          # Weights & Biases
pip install tensorboard    # TensorBoard

# Authentication (for gated models like Llama)
pip install huggingface_hub
huggingface-cli login
# Or set environment variable:
export HF_TOKEN="hf_your_token_here"

# Download a model for offline use
huggingface-cli download meta-llama/Llama-3.2-1B --local-dir ./models/llama-3.2-1b

# Cache management
huggingface-cli scan-cache     # Show cache size and contents
huggingface-cli delete-cache   # Interactive cache cleanup
```

```python
# Set cache directory (avoid filling home partition)
import os
os.environ["HF_HOME"] = "/mnt/data/huggingface"
os.environ["TRANSFORMERS_CACHE"] = "/mnt/data/huggingface/hub"

# Or in ~/.bashrc
# export HF_HOME=/mnt/data/huggingface
```

---

## GPU Setup (NVIDIA)

### Check Current GPU Status

```bash
# Quick check
nvidia-smi

# Continuous monitoring
watch -n 1 nvidia-smi

# Detailed info
nvidia-smi -q

# Check CUDA version
nvcc --version
```

### Install NVIDIA Drivers (Ubuntu/Debian)

```bash
# Check current driver
nvidia-smi --query-gpu=driver_version --format=csv

# Update package list
sudo apt update

# List available drivers
ubuntu-drivers devices

# Install recommended driver
sudo ubuntu-drivers autoinstall

# Or install specific version
sudo apt install nvidia-driver-560

# Reboot required
sudo reboot
```

### Install CUDA Toolkit

```bash
# Method 1: NVIDIA's runfile (standalone, doesn't affect system CUDA)
wget https://developer.download.nvidia.com/compute/cuda/12.4.1/local_installers/cuda_12.4.1_550.54.15_linux.run
sudo sh cuda_12.4.1_550.54.15_linux.run --toolkit --silent --override

# Add to ~/.bashrc
export PATH=/usr/local/cuda-12.4/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda-12.4/lib64:$LD_LIBRARY_PATH

# Method 2: Ubuntu package manager
sudo apt install nvidia-cuda-toolkit

# Verify
nvcc --version
```

### Install cuDNN

```bash
# Download from NVIDIA (requires developer account)
# https://developer.nvidia.com/cudnn

# Or via conda (simpler)
conda install -c nvidia cudnn

# Verify cuDNN
python -c "import torch; print(torch.backends.cudnn.version())"
```

### Multiple CUDA Versions

```bash
# Install multiple versions side by side
# /usr/local/cuda-12.1/
# /usr/local/cuda-12.4/

# Switch via symlinks or environment variables
export CUDA_HOME=/usr/local/cuda-12.4
export PATH=$CUDA_HOME/bin:$PATH
export LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PATH
```

---

## Model Recommendations by Hardware

### CPU Only (No GPU)

| Model | Size | Quantization | RAM Needed | Use Case |
|-------|------|-------------|------------|----------|
| SmolLM2-135M | 135M | Q4_K_M | 1 GB | Learning, quick tests |
| Qwen2.5-0.5B | 500M | Q4_K_M | 2 GB | General chat, simple tasks |
| Phi-3.5-mini | 3.8B | Q4_K_M | 4 GB | Reasoning, code |
| Llama-3.2-1B | 1B | Q4_K_M | 2 GB | General purpose |

```bash
# Run with llama.cpp (CPU optimized)
./build/bin/llama-cli -m models/smolm2-135m-q4_k_m.gguf -t 8 -cnv
# -t 8 = use 8 CPU threads (adjust to your core count)

# Run with ollama
ollama run smollm2:135m
```

### 4 GB VRAM (GTX 1650, RTX 3050 Laptop)

| Model | Size | Quantization | VRAM Needed | Use Case |
|-------|------|-------------|-------------|----------|
| Llama-3.2-1B | 1B | Q8_0 | 2 GB | Best quality at this size |
| Llama-3.2-3B | 3B | Q4_K_M | 3 GB | Stronger reasoning |
| Qwen2.5-3B | 3B | Q4_K_M | 3 GB | Multilingual, code |
| Gemma-2-2B | 2B | Q4_K_M | 2.5 GB | Good general model |
| Phi-3.5-mini | 3.8B | Q4_K_M | 4 GB | Best small reasoning model |

```bash
# Fine-tune with LoRA using 4-bit quantization
from unsloth import FastLanguageModel

model, tokenizer = FastLanguageModel.from_pretrained(
    model_name="unsloth/Llama-3.2-1B",
    max_seq_length=1024,
    load_in_4bit=True,
)

# Keep batch size small, use gradient accumulation
# micro_batch_size=1, gradient_accumulation_steps=8
```

### 8 GB VRAM (RTX 3060, RTX 4060)

| Model | Size | Quantization | VRAM Needed | Use Case |
|-------|------|-------------|-------------|----------|
| Llama-3.1-8B | 8B | Q4_K_M | 6 GB | Best 8B class model |
| Mistral-7B | 7B | Q4_K_M | 5.5 GB | Strong general model |
| Qwen2.5-7B | 7B | Q4_K_M | 5.5 GB | Excellent multilingual |
| Gemma-2-9B | 9B | Q4_K_M | 7 GB | Strong reasoning |
| Llama-3.1-8B | 8B | Q8_0 | 9 GB | Higher quality, tight fit |

```bash
# Fine-tune 7-8B model with QLoRA (4-bit base + LoRA)
# Works well with batch_size=2, gradient_accumulation_steps=4
# Use max_seq_length=2048, may need to reduce to 1024 for longer training

# Run unquantized for inference
from transformers import AutoModelForCausalLM
model = AutoModelForCausalLM.from_pretrained(
    "meta-llama/Llama-3.1-8B-Instruct",
    torch_dtype="auto",
    device_map="auto",
)
```

### 16 GB+ VRAM (RTX 4070 Ti, RTX 4080, RTX 4090, A6000)

| Model | Size | Quantization | VRAM Needed | Use Case |
|-------|------|-------------|-------------|----------|
| Llama-3.1-8B | 8B | FP16/BF16 | 16 GB | Full precision fine-tuning |
| Llama-3.1-70B | 70B | Q4_K_M | 40 GB | Needs multi-GPU |
| Mistral-Large | 123B | Q3_K_M | 48 GB | Needs multi-GPU |
| Qwen2.5-72B | 72B | Q4_K_M | 42 GB | Needs multi-GPU |
| DeepSeek-R1-Distill-32B | 32B | Q4_K_M | 20 GB | Strong reasoning |

```bash
# Fine-tune 8B model in full BF16 precision on 16GB card
# Use batch_size=1, gradient_accumulation_steps=8, max_seq_length=2048

# For 24GB+ VRAM (RTX 3090/4090), full fine-tune 7-8B models
# Use DeepSpeed ZeRO-2 or FSDP for larger models

# Multi-GPU with accelerate
accelerate launch --multi_gpu --num_processes=2 train.py

# With DeepSpeed
accelerate launch --multi_gpu --use_deepspeed --deepspeed_config ds_config.json train.py
```

---

## Common Troubleshooting

### CUDA Out of Memory

```bash
# Check current GPU memory usage
nvidia-smi

# Kill processes using GPU
nvidia-smi --query-compute-apps=pid --format=csv,noheader | xargs -r kill

# Clear PyTorch CUDA cache
python -c "import torch; torch.cuda.empty_cache()"
```

**Reduction strategies**:
```python
# 1. Reduce batch size
per_device_train_batch_size = 1  # minimum

# 2. Use gradient accumulation (maintains effective batch size)
gradient_accumulation_steps = 16  # effective batch = 1 * 16

# 3. Reduce sequence length
max_seq_length = 512  # instead of 2048 or 4096

# 4. Enable gradient checkpointing (trades compute for memory)
model.gradient_checkpointing_enable()
# Or in TrainingArguments: gradient_checkpointing=True

# 5. Use 4-bit quantization with bitsandbytes
model = AutoModelForCausalLM.from_pretrained(
    model_name,
    load_in_4bit=True,
    bnb_4bit_compute_dtype=torch.bfloat16,
    bnb_4bit_quant_type="nf4",
)

# 6. Use DeepSpeed ZeRO Stage 2 or 3
# ds_config.json: {"zero_optimization": {"stage": 2, "offload_optimizer": {"device": "cpu"}}}

# 7. Disable caching during generation (saves memory, slower generation)
model.config.use_cache = False  # during training
```

### Slow Training

```python
# 1. Enable mixed precision (BF16 on Ampere+, FP16 on older GPUs)
training_args = TrainingArguments(
    bf16=True,   # Ampere and newer (RTX 30xx, 40xx, A100)
    # fp16=True, # Pre-Ampere (RTX 20xx, V100, T4)
)

# 2. Enable TF32 (Ampere+ only, faster matmuls with slight precision loss)
torch.backends.cuda.matmul.allow_tf32 = True
torch.backends.cudnn.allow_tf32 = True

# 3. Use Flash Attention 2
pip install flash-attn --no-build-isolation
# Then load model with:
model = AutoModelForCausalLM.from_pretrained(
    model_name,
    attn_implementation="flash_attention_2",
)

# 4. Use sample packing (fit more examples per sequence)
# Supported by Axolotl and TRL:
# axolotl config: sample_packing: true
# TRL: SFTConfig(packing=True)

# 5. Increase dataloader workers
dataloader_num_workers = 4  # in TrainingArguments

# 6. Use Unsloth for 2x faster training
# pip install unsloth
# model = FastLanguageModel.get_peft_model(model, ...)
```

### Model Download Issues

```bash
# 1. Use huggingface-cli for resumable downloads
huggingface-cli download meta-llama/Llama-3.2-1B --local-dir ./models/llama-3.2-1b

# 2. Set a custom cache directory (avoid home partition limits)
export HF_HOME=/mnt/data/huggingface

# 3. Resume interrupted downloads
HF_HUB_ENABLE_HF_TRANSFER=1 huggingface-cli download meta-llama/Llama-3.1-8B

# 4. Use hf_transfer for faster downloads (requires pip install hf_transfer)
pip install hf_transfer
HF_HUB_ENABLE_HF_TRANSFER=1 huggingface-cli download meta-llama/Llama-3.1-8B

# 5. Download specific files only
huggingface-cli download meta-llama/Llama-3.2-1B \
  config.json tokenizer.json tokenizer_config.json \
  model.safetensors \
  --local-dir ./models/llama-3.2-1b

# 6. Mirror / proxy (if in restricted network)
export HF_ENDPOINT=https://hf-mirror.com
```

### Bitsandbytes / 4-bit Quantization Errors

```bash
# Check bitsandbytes installation
python -c "import bitsandbytes; print(bitsandbytes.__version__)"

# Reinstall with CUDA support
pip uninstall bitsandbytes -y
pip install bitsandbytes

# Verify CUDA is found
python -c "import bitsandbytes as bnb; print(bnb.cuda_setup.main())"

# If CUDA not found, ensure CUDA toolkit is installed and LD_LIBRARY_PATH is set
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH
```

### Tokenizer Warnings and Errors

```python
# Fix: "Using pad_token but not set" warnings
tokenizer = AutoTokenizer.from_pretrained(model_name)
if tokenizer.pad_token is None:
    tokenizer.pad_token = tokenizer.eos_token

# Fix: Special token handling
tokenizer = AutoTokenizer.from_pretrained(
    model_name,
    padding_side="right",
    use_fast=True,
)

# Fix: Chat template issues
# Check if model has a chat template
print(tokenizer.chat_template)

# Apply chat template correctly
messages = [{"role": "user", "content": "Hello"}]
text = tokenizer.apply_chat_template(messages, tokenize=False, add_generation_prompt=True)
```

### Weights & Biases Connection Issues

```bash
# Offline mode (no internet required)
wandb offline
wandb sync wandb/latest-run  # sync later

# Self-hosted W&B server
wandb login --host https://your-wandb-server.com

# Disable W&B entirely
export WANDB_DISABLED=true

# Or in code
import os
os.environ["WANDB_DISABLED"] = "true"
```

### Conda Environment Conflicts

```bash
# Clean conda cache
conda clean --all

# Create fresh environment instead of fixing broken one
conda create -n ml-env-fresh python=3.11 -y
conda activate ml-env-fresh

# Check for conflicts
conda list | grep -i conflict

# Use mamba for faster and more reliable solving
conda install mamba -c conda-forge
mamba create -n ml-env python=3.11 pytorch -c pytorch -c nvidia
```

### Disk Space Management

```bash
# Check Hugging Face cache size
du -sh ~/.cache/huggingface/

# Clean unused model cache
huggingface-cli delete-cache

# Move cache to larger drive
mv ~/.cache/huggingface /mnt/data/huggingface
ln -s /mnt/data/huggingface ~/.cache/huggingface
export HF_HOME=/mnt/data/huggingface

# Check PyTorch cache
du -sh ~/.cache/torch/

# Clean pip cache
pip cache purge
```
