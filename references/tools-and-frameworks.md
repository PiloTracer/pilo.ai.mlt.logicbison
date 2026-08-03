# pilo.trainer.mlt - Tools and Frameworks Quick Reference

Quick-start guide for the essential tools used in ML and LLM engineering. Each entry includes installation commands, basic usage examples, and links to documentation.

---

## PyTorch

**Description**: The dominant deep learning framework for research and production. Dynamic computation graphs, extensive ecosystem, and first-class GPU support.

**Install**:
```bash
# CPU only
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu

# CUDA 12.4
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124

# CUDA 12.1
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

# macOS with MPS (Apple Silicon)
pip install torch torchvision torchaudio
```

**Basic Usage**:
```python
import torch

# Check available device
device = "cuda" if torch.cuda.is_available() else "mps" if torch.backends.mps.is_available() else "cpu"

# Create tensors
x = torch.randn(3, 4, device=device)
y = torch.randn(3, 4, device=device)

# Basic operations
z = torch.matmul(x, y.T)
z = x @ y.T  # equivalent

# Autograd
w = torch.randn(4, 2, requires_grad=True)
loss = (torch.matmul(x, w) ** 2).sum()
loss.backward()
print(w.grad)

# Save and load
torch.save(model.state_dict(), "model.pt")
model.load_state_dict(torch.load("model.pt", weights_only=True))
```

**Docs**: https://pytorch.org/docs/stable/index.html

---

## Hugging Face Transformers

**Description**: Library providing thousands of pretrained models for NLP, vision, audio, and multimodal tasks. Unified API across PyTorch, TensorFlow, and JAX.

**Install**:
```bash
pip install transformers[torch]

# With accelerate for efficient training
pip install transformers[torch] accelerate

# For specific backends
pip install transformers[torch]  # PyTorch
pip install transformers[tf]     # TensorFlow
pip install transformers[flax]   # JAX
```

**Basic Usage**:
```python
# Pipeline API - simplest way to use models
from transformers import pipeline

classifier = pipeline("sentiment-analysis")
result = classifier("I love using transformers!")
# [{'label': 'POSITIVE', 'score': 0.9998}]

generator = pipeline("text-generation", model="mistralai/Mistral-7B-v0.1")
output = generator("Explain quantum computing:", max_new_tokens=100)

# Model and tokenizer loading
from transformers import AutoModelForCausalLM, AutoTokenizer

model_id = "meta-llama/Llama-3.2-1B"
tokenizer = AutoTokenizer.from_pretrained(model_id)
model = AutoModelForCausalLM.from_pretrained(model_id, torch_dtype="auto", device_map="auto")

messages = [{"role": "user", "content": "What is fine-tuning?"}]
text = tokenizer.apply_chat_template(messages, tokenize=False, add_generation_prompt=True)
inputs = tokenizer(text, return_tensors="pt").to(model.device)
outputs = model.generate(**inputs, max_new_tokens=100)
print(tokenizer.decode(outputs[0], skip_special_tokens=True))
```

**Docs**: https://huggingface.co/docs/transformers/index

---

## TRL (Transformer Reinforcement Learning)

**Description**: Hugging Face library for training language models with reinforcement learning and preference alignment. Includes SFTTrainer, DPOTrainer, GRPOTrainer, and reward modeling.

**Install**:
```bash
pip install trl

# With optional dependencies for efficient training
pip install trl peft accelerate bitsandbytes
```

**Basic Usage**:
```python
# SFTTrainer - Supervised Fine-Tuning
from trl import SFTConfig, SFTTrainer
from datasets import load_dataset
from transformers import AutoModelForCausalLM, AutoTokenizer

model = AutoModelForCausalLM.from_pretrained("meta-llama/Llama-3.2-1B")
tokenizer = AutoTokenizer.from_pretrained("meta-llama/Llama-3.2-1B")
dataset = load_dataset("HuggingFaceH4/ultrachat_200k", split="train_sft")

trainer = SFTTrainer(
    model=model,
    train_dataset=dataset,
    args=SFTConfig(
        output_dir="./output",
        num_train_epochs=1,
        per_device_train_batch_size=4,
        learning_rate=2e-5,
        logging_steps=10,
        max_seq_length=2048,
    ),
    tokenizer=tokenizer,
)
trainer.train()

# DPOTrainer - Direct Preference Optimization
from trl import DPOConfig, DPOTrainer

trainer = DPOTrainer(
    model=model,
    ref_model=ref_model,
    train_dataset=preference_dataset,
    args=DPOConfig(
        output_dir="./dpo_output",
        beta=0.1,
        learning_rate=5e-7,
        per_device_train_batch_size=2,
        max_length=2048,
        max_prompt_length=1024,
    ),
    tokenizer=tokenizer,
)
trainer.train()

# GRPOTrainer
from trl import GRPOConfig, GRPOTrainer

trainer = GRPOTrainer(
    model=model,
    reward_funcs=reward_fn,
    train_dataset=dataset,
    args=GRPOConfig(
        output_dir="./grpo_output",
        learning_rate=5e-7,
        per_device_train_batch_size=2,
    ),
    tokenizer=tokenizer,
)
trainer.train()
```

**Docs**: https://huggingface.co/docs/trl/index

---

## Unsloth

**Description**: Fine-tuning library that makes training 2x faster with 80% less VRAM through optimized kernels. Supports LoRA, QLoRA, and full fine-tuning for Llama, Mistral, Gemma, and more.

**Install**:
```bash
# CUDA 12.4 + PyTorch 2.5+
pip install unsloth

# For specific CUDA versions
pip install "unsloth[cu121-torch250]" --extra-index-url https://download.pytorch.org/whl/cu121
pip install "unsloth[cu124-torch250]" --extra-index-url https://download.pytorch.org/whl/cu124

# Nightly (for latest models)
pip install unsloth-nightly
```

**Basic Usage**:
```python
from unsloth import FastLanguageModel
from trl import SFTTrainer, SFTConfig
from datasets import load_dataset

max_seq_length = 2048

model, tokenizer = FastLanguageModel.from_pretrained(
    model_name="unsloth/Llama-3.2-1B",
    max_seq_length=max_seq_length,
    load_in_4bit=True,
)

model = FastLanguageModel.get_peft_model(
    model,
    r=16,
    target_modules=["q_proj", "k_proj", "v_proj", "o_proj", "gate_proj", "up_proj", "down_proj"],
    lora_alpha=16,
    lora_dropout=0,
    use_gradient_checkpointing="unsloth",
)

dataset = load_dataset("yahma/alpaca-cleaned", split="train")

trainer = SFTTrainer(
    model=model,
    train_dataset=dataset,
    args=SFTConfig(
        dataset_text_field="text",
        per_device_train_batch_size=2,
        gradient_accumulation_steps=4,
        max_steps=60,
        learning_rate=2e-4,
        max_seq_length=max_seq_length,
        output_dir="outputs",
    ),
)
trainer.train()

model.save_pretrained("lora_model")
model.save_pretrained_merged("merged_model", tokenizer, save_method="merged_16bit")
```

**Docs**: https://docs.unsloth.ai/

---

## Axolotl

**Description**: Config-driven LLM fine-tuning framework. Supports SFT, DPO, RLHF, LoRA, QLoRA across dozens of model architectures through YAML configuration files. No code required.

**Install**:
```bash
git clone https://github.com/axolotl-ai-cloud/axolotl
cd axolotl

pip install -e ".[flash-attn,deepspeed]"

# Docker
docker pull winglian/axolotl:main-latest
```

**Basic Usage**:
```yaml
# config.yml - example LoRA fine-tune configuration
base_model: meta-llama/Llama-3.2-1B
model_type: LlamaForCausalLM
tokenizer_type: AutoTokenizer

load_in_8bit: false
load_in_4bit: true
strict: false

datasets:
  - path: yahma/alpaca-cleaned
    type: alpaca

dataset_prepared_path: last_run_prepared
val_set_size: 0.05
output_dir: ./outputs/lora-out

adapter: lora
lora_model_dir:

sequence_len: 2048
sample_packing: true
pad_to_sequence_len: true

lora_r: 32
lora_alpha: 16
lora_dropout: 0.05
lora_target_modules:
  - q_proj
  - k_proj
  - v_proj
  - o_proj
  - gate_proj
  - up_proj
  - down_proj

gradient_accumulation_steps: 4
micro_batch_size: 2
num_epochs: 4
optimizer: adamw_bnb_8bit
lr_scheduler: cosine
learning_rate: 0.0002

bf16: true
tf32: false
gradient_checkpointing: true

flash_attention: true

wandb_project:
wandb_run_id:
```

```bash
# Run training
axolotl train config.yml

# Merge LoRA weights
axolotl merge_lora config.yml
```

**Docs**: https://axolotl-ai-cloud.github.io/axolotl/

---

## llama.cpp

**Description**: High-performance C/C++ inference engine for LLMs. Supports GGUF quantization formats (Q2_K through Q8_0). Runs on CPU, CUDA, Metal, and Vulkan.

**Build**:
```bash
git clone https://github.com/ggerganov/llama.cpp
cd llama.cpp

# Build with CMake
cmake -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --config Release -j$(nproc)

# Build with CUDA support
cmake -B build -DCMAKE_BUILD_TYPE=Release -DGGML_CUDA=ON
cmake --build build --config Release -j$(nproc)

# Build with Metal (macOS)
cmake -B build -DCMAKE_BUILD_TYPE=Release -DGGML_METAL=ON
cmake --build build --config Release -j$(nproc)
```

**Basic Usage**:
```bash
# Run inference (chat mode)
./build/bin/llama-cli -m models/llama-3.2-1b-q4_k_m.gguf \
  -p "You are a helpful assistant." \
  -cnv

# Start an OpenAI-compatible server
./build/bin/llama-server -m models/llama-3.2-1b-q4_k_m.gguf \
  --host 0.0.0.0 --port 8080 \
  -ngl 99

# Quantize a model
./build/bin/llama-quantize models/model.gguf models/model-q4_k_m.gguf Q4_K_M

# Convert a Hugging Face model to GGUF
python convert_hf_to_gguf.py /path/to/model --outfile model.gguf --outtype f16
```

**Docs**: https://github.com/ggerganov/llama.cpp

---

## ollama

**Description**: CLI and runtime for running LLMs locally. One-command model download and inference with a REST API. Supports model customization via Modelfiles.

**Install**:
```bash
# Linux
curl -fsSL https://ollama.com/install.sh | sh

# macOS
brew install ollama

# Windows
# Download from https://ollama.com/download
```

**Basic Usage**:
```bash
# Pull and run a model
ollama pull llama3.2:1b
ollama run llama3.2:1b "What is a transformer?"

# Run with system prompt
ollama run llama3.2:1b --system "You are a senior ML engineer."

# List installed models
ollama list

# Show model info
ollama show llama3.2:1b

# Create a custom model with Modelfile
cat > Modelfile << 'EOF'
FROM llama3.2:1b
SYSTEM You are a helpful coding assistant.
PARAMETER temperature 0.7
PARAMETER top_p 0.9
EOF
ollama create my-model -f Modelfile

# Use the REST API
curl http://localhost:11434/api/chat -d '{
  "model": "llama3.2:1b",
  "messages": [{"role": "user", "content": "Explain backpropagation"}],
  "stream": false
}'

# Serve OpenAI-compatible API (port 11434)
# Compatible with most LLM client libraries
```

**Docs**: https://github.com/ollama/ollama

---

## vLLM

**Description**: High-throughput, memory-efficient LLM serving engine. Features PagedAttention, continuous batching, tensor parallelism, and an OpenAI-compatible API server.

**Install**:
```bash
pip install vllm

# From source (for latest features)
pip install vllm --pre --extra-index-url https://wheels.vllm.ai/nightly

# Docker
docker run --gpus all -it vllm/vllm-openai:latest \
  --model meta-llama/Llama-3.2-1B
```

**Basic Usage**:
```bash
# Start an OpenAI-compatible server
vllm serve meta-llama/Llama-3.1-8B-Instruct \
  --host 0.0.0.0 \
  --port 8000 \
  --tensor-parallel-size 1 \
  --max-model-len 8192 \
  --gpu-memory-utilization 0.9

# Query the server
curl http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "meta-llama/Llama-3.1-8B-Instruct",
    "messages": [{"role": "user", "content": "What is PagedAttention?"}],
    "temperature": 0.7
  }'
```

```python
# Offline inference (batch processing)
from vllm import LLM, SamplingParams

llm = LLM(model="meta-llama/Llama-3.1-8B-Instruct", tensor_parallel_size=1)
params = SamplingParams(temperature=0.7, max_tokens=256)

prompts = [
    "Explain quantum entanglement simply.",
    "Write a haiku about programming.",
    "What is the difference between TCP and UDP?",
]
outputs = llm.chat(
    [{"role": "user", "content": p} for p in prompts],
    params,
)
for output in outputs:
    print(output.outputs[0].text)
```

**Docs**: https://docs.vllm.ai/en/latest/

---

## LangChain

**Description**: Framework for building applications powered by LLMs. Provides abstractions for chains, agents, retrieval (RAG), memory, tool calling, and orchestration via LangGraph.

**Install**:
```bash
pip install langchain langchain-core langchain-community

# For specific integrations
pip install langchain-openai       # OpenAI models
pip install langchain-anthropic    # Anthropic models
pip install langchain-huggingface  # Hugging Face models
pip install langchain-chroma       # ChromaDB vector store
pip install langgraph              # Stateful agent framework
```

**Basic Usage**:
```python
# Simple chain with prompt template
from langchain_huggingface import HuggingFaceEndpoint
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser

llm = HuggingFaceEndpoint(repo_id="meta-llama/Llama-3.1-8B-Instruct")
prompt = ChatPromptTemplate.from_messages([
    ("system", "You are a helpful assistant."),
    ("user", "{question}")
])

chain = prompt | llm | StrOutputParser()
result = chain.invoke({"question": "What is RAG?"})

# RAG with retriever
from langchain_community.vectorstores import Chroma
from langchain_huggingface import HuggingFaceEmbeddings
from langchain_core.runnables import RunnablePassthrough

embeddings = HuggingFaceEmbeddings(model_name="sentence-transformers/all-MiniLM-L6-v2")
vectorstore = Chroma.from_documents(documents, embeddings)
retriever = vectorstore.as_retriever(search_kwargs={"k": 3})

rag_prompt = ChatPromptTemplate.from_messages([
    ("system", "Answer using this context:\n{context}"),
    ("user", "{question}")
])

rag_chain = (
    {"context": retriever, "question": RunnablePassthrough()}
    | rag_prompt
    | llm
    | StrOutputParser()
)
result = rag_chain.invoke("What are the main components of a transformer?")
```

**Docs**: https://python.langchain.com/docs/introduction/

---

## Gradio

**Description**: Python library for building interactive web demos for ML models. Create shareable UIs with minimal code. Integrates directly with Hugging Face Spaces.

**Install**:
```bash
pip install gradio

# With optional dependencies
pip install gradio[flagging]  # For data flagging features
```

**Basic Usage**:
```python
# Simple chat interface
import gradio as gr
from transformers import pipeline

generator = pipeline("text-generation", model="mistralai/Mistral-7B-v0.1")

def respond(message, history):
    prompt = ""
    for user, assistant in history:
        prompt += f"User: {user}\nAssistant: {assistant}\n"
    prompt += f"User: {message}\nAssistant:"
    output = generator(prompt, max_new_tokens=200, do_sample=True, temperature=0.7)
    return output[0]["generated_text"][len(prompt):]

demo = gr.ChatInterface(fn=respond, title="Chat with Mistral")
demo.launch(share=True)

# Model comparison interface
import gradio as gr

def predict(model_name, prompt, temperature, max_tokens):
    # Load and run the specified model
    pass

with gr.Blocks() as demo:
    with gr.Row():
        model = gr.Dropdown(["llama-3.2-1b", "mistral-7b", "gemma-2-2b"], label="Model")
        temperature = gr.Slider(0, 2, value=0.7, label="Temperature")
        max_tokens = gr.Slider(16, 512, value=128, step=16, label="Max Tokens")
    prompt = gr.Textbox(label="Prompt", lines=3)
    output = gr.Textbox(label="Output", lines=10)
    btn = gr.Button("Generate")
    btn.click(predict, inputs=[model, prompt, temperature, max_tokens], outputs=output)

demo.launch()
```

**Docs**: https://www.gradio.app/docs/

---

## MLflow

**Description**: Open-source platform for managing the end-to-end ML lifecycle. Experiment tracking, model registry, packaging, and deployment. Framework-agnostic and works with any ML library.

**Install**:
```bash
pip install mlflow

# Start the tracking server
mlflow server --host 0.0.0.0 --port 5000
```

**Basic Usage**:
```python
import mlflow
import mlflow.pytorch
import torch

mlflow.set_tracking_uri("http://localhost:5000")
mlflow.set_experiment("llm-fine-tuning")

with mlflow.start_run(run_name="lora-r16-lr2e-4"):
    # Log parameters
    mlflow.log_params({
        "base_model": "meta-llama/Llama-3.2-1B",
        "lora_r": 16,
        "lora_alpha": 16,
        "learning_rate": 2e-4,
        "num_epochs": 3,
        "batch_size": 4,
    })

    # Log metrics during training
    for epoch in range(num_epochs):
        for step, batch in enumerate(dataloader):
            loss = train_step(batch)
            mlflow.log_metric("train_loss", loss, step=epoch * len(dataloader) + step)

    # Log the model
    mlflow.pytorch.log_model(model, "model", registered_model_name="llama-lora")

    # Log artifacts (configs, eval results)
    mlflow.log_artifact("config.yml")
    mlflow.log_artifact("eval_results.json")
```

```bash
# CLI commands
mlflow ui                                    # Start UI (local)
mlflow server --host 0.0.0.0 --port 5000    # Start remote server
mlflow models serve -m "models:/llama-lora/1" --port 8080  # Serve a registered model
mlflow experiments list                      # List experiments
mlflow runs list --experiment-name "llm-fine-tuning"
```

**Docs**: https://mlflow.org/docs/latest/index.html
