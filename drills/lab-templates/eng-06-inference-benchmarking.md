# Lab: Inference Benchmarking

## Prerequisites
- Linux or macOS
- 8GB+ RAM
- 4GB disk space
- Python 3.10+ (stdlib only, no pip installs)
- ollama (skip install if present from [eng-01-local-llm.md](eng-01-local-llm.md))

## Setup

```bash
# ollama (skip if already installed)
curl -fsSL https://ollama.com/install.sh | sh
ollama pull llama3.2:1b   # one-time download, ~1.3GB

# llama.cpp via Homebrew (macOS or Linux)
brew install llama.cpp

# llama.cpp alternative: build from source
git clone https://github.com/ggml-org/llama.cpp.git
cmake llama.cpp -B llama.cpp/build
cmake --build llama.cpp/build --config Release -j
export PATH="$PWD/llama.cpp/build/bin:$PATH"
```

The GGUF for llama.cpp (~0.8GB, one-time) downloads automatically on first run via the `-hf` flag.

## Objectives
- Measure tokens/sec and time-to-first-token (TTFT) on two local backends
- Compare memory footprint of ollama vs llama.cpp on the same 1B-class model
- Build a reproducible benchmark: fixed prompts, fixed seed, warmup runs
- Tabulate results and write a short analysis

## Commands

Save as `benchmark.py` and run with `python benchmark.py`:

```python
#!/usr/bin/env python3
"""Benchmark ollama vs llama.cpp on the same 1B-class model (llama3.2:1b).

Measures tokens/sec, time-to-first-token (TTFT), and peak memory for
3 fixed prompts per backend, then prints a results table.
Stdlib only: no pip installs required.
"""
import json
import re
import resource
import subprocess
import sys
import time
import urllib.request

OLLAMA_URL = "http://localhost:11434"
OLLAMA_MODEL = "llama3.2:1b"                              # ollama pull llama3.2:1b (~1.3GB)
LLAMA_HF = "bartowski/Llama-3.2-1B-Instruct-GGUF:Q4_K_M"  # ~0.8GB, one-time download
MAX_TOKENS = 128

PROMPTS = [
    "Explain what a neural network is in one paragraph.",
    "Write a Python function that checks whether a string is a palindrome.",
    "List five real-world applications of machine learning.",
]


def bench_ollama(prompt):
    """Stream one generation from the ollama API; return TTFT and tokens/sec."""
    payload = json.dumps({
        "model": OLLAMA_MODEL,
        "prompt": prompt,
        "stream": True,                # stream so we can time the first token
        "keep_alive": "10m",           # keep model loaded between prompts
        "options": {"num_predict": MAX_TOKENS, "temperature": 0.0, "seed": 42},
    }).encode()
    req = urllib.request.Request(f"{OLLAMA_URL}/api/generate", data=payload)
    t0 = time.perf_counter()
    ttft, final = None, {}
    with urllib.request.urlopen(req) as resp:
        for line in resp:
            chunk = json.loads(line)
            if ttft is None and chunk.get("response"):
                ttft = time.perf_counter() - t0
            if chunk.get("done"):
                final = chunk          # last chunk carries server-side timing
    tok_s = final["eval_count"] / (final["eval_duration"] / 1e9)  # duration is ns
    return ttft, tok_s


def ollama_mem_gb():
    """Resident model size reported by ollama (call while the model is loaded)."""
    with urllib.request.urlopen(f"{OLLAMA_URL}/api/ps") as resp:
        data = json.load(resp)
    return sum(m["size"] for m in data.get("models", [])) / 1e9


def bench_llamacpp(prompt):
    """Run llama-cli once; parse TTFT and tokens/sec from its perf summary on stderr."""
    cmd = [
        "llama-cli", "-hf", LLAMA_HF,  # fallback: -m /path/to/model.gguf
        "-p", prompt, "-n", str(MAX_TOKENS),
        "-no-cnv", "--no-display-prompt",  # single batch generation, no chat mode
        "--temp", "0", "--seed", "42",
    ]
    proc = subprocess.run(cmd, capture_output=True, text=True)
    if proc.returncode != 0:
        sys.exit(f"llama-cli failed:\n{proc.stderr[-2000:]}")
    ttft = tok_s = None
    for line in proc.stderr.splitlines():
        if "prompt eval time" in line:    # prompt processing time ~ TTFT
            ttft = float(re.search(r"=\s*([\d.]+)\s*ms", line).group(1)) / 1000
        elif "eval time" in line:         # generation speed
            tok_s = float(re.search(r"([\d.]+)\s*tokens per second", line).group(1))
    # Peak RSS of the llama-cli child process (KB on Linux, bytes on macOS)
    peak = resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss
    mem_gb = peak / 1e9 if sys.platform == "darwin" else peak / 1e6
    return ttft, tok_s, mem_gb


def main():
    rows = []

    bench_ollama("Say hi.")               # warmup, untimed (loads weights, page cache)
    for p in PROMPTS:
        ttft, tok_s = bench_ollama(p)
        rows.append(["ollama", p, ttft, tok_s, ollama_mem_gb()])

    bench_llamacpp("Say hi.")             # warmup, untimed
    for p in PROMPTS:
        ttft, tok_s, mem = bench_llamacpp(p)
        rows.append(["llama.cpp", p, ttft, tok_s, mem])

    print("\n| Backend | Prompt | TTFT (s) | Tokens/sec | Memory (GB) |")
    print("|---------|--------|----------|------------|-------------|")
    for backend, p, ttft, tok_s, mem in rows:
        print(f"| {backend} | {p[:37]}... | {ttft:.2f} | {tok_s:.1f} | {mem:.2f} |")

    for backend in ("ollama", "llama.cpp"):
        sub = [r for r in rows if r[0] == backend]
        avg_ttft = sum(r[2] for r in sub) / len(sub)
        avg_tok = sum(r[3] for r in sub) / len(sub)
        print(f"{backend}: avg TTFT {avg_ttft:.2f}s, avg {avg_tok:.1f} tokens/sec")


if __name__ == "__main__":
    main()
```

After the run, copy the table into your notes and add 3-5 sentences of analysis: which backend is faster, where TTFT differs, and why.

## Expected Output
- A results table with 6 timed rows (3 prompts x 2 backends) plus per-backend averages, e.g.:

| Backend | TTFT (s) | Tokens/sec | Memory (GB) |
|---------|----------|------------|-------------|
| ollama | 0.05-0.20 | 20-50 | ~1.5-2.5 |
| llama.cpp | 0.10-0.40 | 15-45 | ~1.0-2.0 |

- Numbers vary by hardware; on a modern laptop CPU both backends should exceed 10 tokens/sec.
- Typical finding: throughput is similar (ollama uses llama.cpp under the hood); llama.cpp pays model-load cost per invocation unless kept warm, while ollama keeps the model resident.

## Troubleshooting
- `Connection refused` on localhost:11434: ollama server not running; start it with `ollama serve` and verify with `ollama list`
- `llama-cli: command not found`: llama.cpp not installed or not on PATH; use the brew install or add `llama.cpp/build/bin` to PATH
- `-hf` download fails (build without curl support, or blocked network): download the GGUF manually with `curl -L -o Llama-3.2-1B-Q4_K_M.gguf https://huggingface.co/bartowski/Llama-3.2-1B-Instruct-GGUF/resolve/main/Llama-3.2-1B-Instruct-Q4_K_M.gguf` and replace `-hf ...` with `-m Llama-3.2-1B-Q4_K_M.gguf`
- Tokens/sec far below expectations: close other heavy processes, check for thermal throttling, rerun; numbers should be stable within ~10% across runs
- ollama memory reads 0.00: model was unloaded before `/api/ps`; the `keep_alive` option prevents this, re-run and query immediately after generation

## Cleanup
```bash
ollama rm llama3.2:1b
rm -f benchmark.py
# optional: remove the GGUF from the HF cache and uninstall llama.cpp
rm -rf ~/.cache/huggingface/hub/models--bartowski--Llama-3.2-1B-Instruct-GGUF
brew uninstall llama.cpp
```
