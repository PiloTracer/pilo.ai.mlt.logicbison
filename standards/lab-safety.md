# Lab safety standard

Binding for `@mlt-lab` and any hands-on exercise.

## Environment setup

### Minimum requirements

- **Python**: 3.10+ with virtual environment (venv, conda, or uv)
- **PyTorch**: Latest stable (CPU-only acceptable for fundamentals)
- **Disk**: At least 10GB free for models and datasets
- **RAM**: 8GB minimum, 16GB recommended

### Virtual environments (mandatory)

Every lab must run in an isolated environment, created inside the lab directory under `.training.mlt/labs/` (keeps learner artifacts inside the memory boundary):

```bash
python -m venv .training.mlt/labs/<topic>/.venv
source .training.mlt/labs/<topic>/.venv/bin/activate
```

Or with conda:
```bash
conda create -n mlt-<topic> python=3.10
conda activate mlt-<topic>
```

Or with uv (preferred for speed):
```bash
uv venv .training.mlt/labs/<topic>/.venv
source .training.mlt/labs/<topic>/.venv/bin/activate
```

## Resource limits

### Model size guidelines

| Available VRAM | Max model size | Recommended approach |
|----------------|----------------|---------------------|
| CPU only | <500M params | Quantized models, llama.cpp |
| 4-6 GB | 1-3B params | 4-bit quantization (QLoRA) |
| 8-12 GB | 7-13B params | 4-bit quantization |
| 16-24 GB | 13-30B params | 4-8 bit quantization |
| 24+ GB | 30B+ params (4-bit); ≤13B full precision | 4-8 bit quantization; full precision only ≤13B |

### Memory management

- Always check available VRAM before loading models
- Use `device_map="auto"` for multi-GPU setups
- Enable gradient checkpointing for training
- Use mixed precision (bf16 or fp16) when possible
- Clear CUDA cache between experiments: `torch.cuda.empty_cache()`

### Disk usage

- Warn before downloading models > 1GB
- Use Hugging Face cache: `~/.cache/huggingface/`
- Clean up unused models: `hf cache ls` and `hf cache rm` (legacy: `huggingface-cli scan-cache`)
- Prefer quantized versions (GGUF, AWQ, GPTQ) for storage efficiency

## Safety rules

### Model safety

- Only download from verified sources (Hugging Face verified publishers, official repos)
- Check model cards for licenses and usage restrictions
- Never execute untrusted model code without review
- Scan downloaded files for integrity (checksums when available)

### API key protection

- Never hardcode API keys in tutorials or labs
- Use environment variables: `os.environ["API_KEY"]`
- Provide `.env.example` templates
- Warn before any API calls that incur costs

### Data safety

- Use synthetic or public datasets for labs
- Never use production data without explicit permission
- Sanitize any real data before using in examples
- Document data sources and licenses

## Lab structure

Every lab must include:

1. **Prerequisites**: Python version, packages, hardware requirements
2. **Setup instructions**: Step-by-step environment setup
3. **Learning objectives**: What the learner will build/understand
4. **Code**: Runnable, tested, well-commented
5. **Expected output**: What success looks like
6. **Troubleshooting**: Common errors and fixes
7. **Cleanup**: How to remove the environment and free resources

## Forbidden in labs

- Requiring cloud GPUs without offering a local alternative
- Downloading >10GB without explicit user approval
- Running training without progress indicators or checkpoints
- Using deprecated APIs without noting the deprecation
- Ignoring error handling in example code
