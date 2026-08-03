# Lab: Run LLM Locally with ollama

## Prerequisites
- Linux, macOS, or Windows
- 8GB+ RAM
- 4GB disk space

## Setup

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

## Objectives
- Install and run ollama
- Download and run open-source LLMs
- Compare models by size and capability

## Commands

```bash
ollama run llama3.2:1b
```

Then interact:
```
>>> What is machine learning?
>>> Explain transformers in simple terms
>>> /bye
```

Run a larger model (requires 8GB+ RAM):
```bash
ollama run llama3.2:3b
```

Run a coding model:
```bash
ollama run qwen2.5-coder:1.5b
```

Use the API:
```bash
curl http://localhost:11434/api/generate -d '{
  "model": "llama3.2:1b",
  "prompt": "Explain what a neural network is in one sentence."
}'
```

## Model Recommendations

| Model | Size | RAM needed | Best for |
|-------|------|-----------|----------|
| llama3.2:1b | 1.3GB | 4GB | Quick experiments |
| llama3.2:3b | 2.0GB | 8GB | General tasks |
| qwen2.5-coder:1.5b | 0.9GB | 4GB | Code generation |
| phi3:mini | 2.3GB | 8GB | Reasoning |
| mistral:7b | 4.1GB | 16GB | General purpose |

## Troubleshooting
- ollama not found: add to PATH or restart terminal
- Slow inference: use smaller model or enable GPU acceleration
- Out of memory: kill other processes or use smaller model

## Cleanup
```bash
ollama rm <model-name>
```
