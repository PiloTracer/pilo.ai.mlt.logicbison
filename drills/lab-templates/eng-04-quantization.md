# Lab: Quantization

## Prerequisites
- Python 3.10+
- cmake and a C++ compiler (path A)
- 8GB+ RAM, 6GB disk space
- Optional (path B): NVIDIA GPU with 2GB+ VRAM, CUDA, Linux

## Setup

```bash
python -m venv .training.mlt/labs/quantization/.venv
source .training.mlt/labs/quantization/.venv/bin/activate
pip install torch transformers sentencepiece gguf protobuf huggingface_hub

git clone https://github.com/ggml-org/llama.cpp .training.mlt/labs/quantization/llama.cpp
cmake -B .training.mlt/labs/quantization/llama.cpp/build -S .training.mlt/labs/quantization/llama.cpp
cmake --build .training.mlt/labs/quantization/llama.cpp/build --config Release -j --target llama-cli llama-quantize
```

## Objectives
- Convert an HF model to GGUF and quantize it to 4-bit with llama.cpp
- Load a model in 4-bit NF4 with bitsandbytes
- Measure size, memory, and generation speed before/after quantization
- Judge the quality/size tradeoff of 4-bit quantization

## Commands

Pick path A (no GPU) or path B (GPU). Both use Qwen2.5-0.5B (~1GB one-time download).

### Path A: GGUF + llama.cpp (CPU)

```bash
cd .training.mlt/labs/quantization

# Download the model (~1GB)
hf download Qwen/Qwen2.5-0.5B --local-dir models/Qwen2.5-0.5B

# Convert HF -> GGUF in f16
python llama.cpp/convert_hf_to_gguf.py models/Qwen2.5-0.5B \
  --outfile qwen2.5-0.5b-f16.gguf --outtype f16

# Quantize f16 -> 4-bit (Q4_K_M)
./llama.cpp/build/bin/llama-quantize qwen2.5-0.5b-f16.gguf qwen2.5-0.5b-q4_k_m.gguf Q4_K_M

# Compare file sizes
ls -lh qwen2.5-0.5b-*.gguf

# Same prompt on both files. Compare output quality and the tok/s
# timing that llama-cli prints at the end of each run.
./llama.cpp/build/bin/llama-cli -m qwen2.5-0.5b-f16.gguf \
  -p "Explain quantization in one paragraph." -n 128
./llama.cpp/build/bin/llama-cli -m qwen2.5-0.5b-q4_k_m.gguf \
  -p "Explain quantization in one paragraph." -n 128

cd ../../..
```

### Path B: bitsandbytes 4-bit (GPU)

```bash
pip install bitsandbytes accelerate datasets
```

```python
import time
import torch
from datasets import load_dataset
from transformers import AutoModelForCausalLM, AutoTokenizer, BitsAndBytesConfig

MODEL_ID = "Qwen/Qwen2.5-0.5B"  # ~1GB one-time download to the HF cache

tokenizer = AutoTokenizer.from_pretrained(MODEL_ID)

# Small public eval subset: wikitext-2 test split (~12MB download)
dataset = load_dataset("Salesforce/wikitext", "wikitext-2-raw-v1", split="test")
text = "\n\n".join(dataset.select(range(200))["text"])
encodings = tokenizer(text, return_tensors="pt")

def perplexity(model, max_length=512):
    model.eval()
    nll_sum, n_tokens = 0.0, 0
    seq_len = encodings.input_ids.size(1)
    for begin in range(0, seq_len, max_length):
        end = min(begin + max_length, seq_len)
        input_ids = encodings.input_ids[:, begin:end].to(model.device)
        with torch.no_grad():
            out = model(input_ids, labels=input_ids)  # loss = mean NLL over the chunk
        nll_sum += out.loss.item() * (end - begin)
        n_tokens += end - begin
        if end == seq_len:
            break
    return torch.exp(torch.tensor(nll_sum / n_tokens)).item()

def measure(model, name):
    torch.cuda.reset_peak_memory_stats()
    ppl = perplexity(model)
    vram = torch.cuda.max_memory_allocated() / 1024**3
    prompt = tokenizer("Quantization reduces model size by", return_tensors="pt").to(model.device)
    torch.cuda.synchronize()
    start = time.time()
    with torch.no_grad():
        out = model.generate(**prompt, max_new_tokens=64, do_sample=False)
    torch.cuda.synchronize()
    tok_s = (out.shape[1] - prompt.input_ids.shape[1]) / (time.time() - start)
    print(f"{name}: perplexity={ppl:.2f}, peak VRAM={vram:.2f} GB, {tok_s:.1f} tok/s")

# Baseline: fp16
model_fp16 = AutoModelForCausalLM.from_pretrained(
    MODEL_ID, torch_dtype=torch.float16, device_map="cuda")
measure(model_fp16, "fp16 baseline")
del model_fp16
torch.cuda.empty_cache()

# 4-bit NF4 via bitsandbytes
bnb_config = BitsAndBytesConfig(
    load_in_4bit=True,
    bnb_4bit_quant_type="nf4",
    bnb_4bit_compute_dtype=torch.float16,
)
model_4bit = AutoModelForCausalLM.from_pretrained(
    MODEL_ID, quantization_config=bnb_config, device_map="cuda")
measure(model_4bit, "4-bit NF4")
```

## Expected Output
- Path A: `qwen2.5-0.5b-f16.gguf` ~1GB, `qwen2.5-0.5b-q4_k_m.gguf` ~0.4GB
- Path A: the Q4_K_M run generates faster (higher tok/s) with output quality close to the f16 run on the same prompt
- Path B: 4-bit perplexity only slightly higher than fp16, peak VRAM roughly halved (~1.1GB -> ~0.5GB), similar or faster tok/s

## Troubleshooting
- `cmake` not found: install it (`apt install cmake` / `brew install cmake`) plus a C++ compiler
- `hf download` not found: upgrade with `pip install -U huggingface_hub` or use the legacy `huggingface-cli download`
- Convert script fails with `ModuleNotFoundError`: `pip install gguf sentencepiece protobuf transformers`
- bitsandbytes import or CUDA errors: it requires an NVIDIA GPU with CUDA; on CPU-only machines use path A
- Out of RAM during conversion: close other apps; f16 conversion of 0.5B needs ~2-3GB free

## Cleanup
```bash
deactivate
rm -rf .training.mlt/labs/quantization/.venv
rm -rf .training.mlt/labs/quantization/models
rm -rf .training.mlt/labs/quantization/llama.cpp
rm -f .training.mlt/labs/quantization/*.gguf
```
