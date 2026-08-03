# Lab: RAG System

## Prerequisites
- Python 3.10+
- 8GB+ RAM, CPU-only is fine
- ~2GB free disk (models + packages)
- ollama installed and running (see [eng-01-local-llm.md](eng-01-local-llm.md))
- One-time downloads: `all-MiniLM-L6-v2` embedding model (~90MB) and `llama3.2:1b` (~1.3GB)

## Setup

```bash
# Skip if ollama is already installed from eng-01
curl -fsSL https://ollama.com/install.sh | sh

# Pull the generation model (~1.3GB one-time download)
ollama pull llama3.2:1b

# Start the ollama server in a separate terminal if it is not already running
ollama serve

python -m venv .training.mlt/labs/rag-system/.venv
source .training.mlt/labs/rag-system/.venv/bin/activate
pip install sentence-transformers chromadb ollama
```

## Objectives
- Embed a small document collection with sentence-transformers
- Store and query embeddings in a local vector database (Chroma)
- Build a retrieve-then-generate pipeline with a local LLM
- Measure retrieval hit-rate on hand-written questions

## Code

```python
import random

import chromadb
import numpy as np
import ollama
from sentence_transformers import SentenceTransformer

random.seed(42)
np.random.seed(42)

# 30 small embedded documents: no external dataset needed
DOCS = [
    ("d01", "Gradient descent is an optimization algorithm that updates model parameters in the direction opposite to the gradient of the loss function."),
    ("d02", "The learning rate controls the step size of each gradient descent update; too large diverges, too small is slow."),
    ("d03", "Overfitting happens when a model memorizes training data and fails to generalize to unseen examples."),
    ("d04", "Regularization techniques like L1 and L2 penalties reduce overfitting by constraining model weights."),
    ("d05", "A transformer is a neural network architecture based on self-attention, introduced in the paper Attention Is All You Need in 2017."),
    ("d06", "Self-attention lets each token in a sequence weigh the relevance of every other token when building its representation."),
    ("d07", "Tokenization splits raw text into smaller units called tokens, such as words, subwords, or characters, before feeding them to a model."),
    ("d08", "An embedding is a dense vector representation of text where semantically similar texts are close together in vector space."),
    ("d09", "Sentence-BERT models like all-MiniLM-L6-v2 produce sentence embeddings suitable for semantic search and clustering."),
    ("d10", "A vector database stores embedding vectors and supports fast nearest-neighbor search over them."),
    ("d11", "Cosine similarity measures the angle between two vectors and is a common metric for comparing embeddings."),
    ("d12", "Retrieval-Augmented Generation (RAG) combines a retriever that fetches relevant documents with a generator that produces an answer grounded in them."),
    ("d13", "Chunking splits long documents into smaller passages so each chunk can be embedded and retrieved independently."),
    ("d14", "Top-k retrieval returns the k most similar documents to a query from the vector store."),
    ("d15", "Hit-rate measures how often the correct document appears in the retrieved top-k results."),
    ("d16", "Fine-tuning adapts a pre-trained model to a specific task by continuing training on task-specific data."),
    ("d17", "LoRA is a parameter-efficient fine-tuning method that trains small low-rank adapter matrices instead of all model weights."),
    ("d18", "Quantization reduces model size and memory usage by representing weights with fewer bits, such as 8-bit or 4-bit integers."),
    ("d19", "Ollama is a tool for running open-source large language models locally on your own machine."),
    ("d20", "Llama 3.2 1B is a small instruction-tuned language model from Meta with about 1.3 billion parameters that runs on consumer hardware."),
    ("d21", "Chroma is an open-source embedding database that can run in-memory or persist vectors to disk."),
    ("d22", "FAISS is a library from Meta for efficient similarity search over dense vectors."),
    ("d23", "A cross-encoder re-ranks retrieved passages by scoring each query-document pair jointly, improving precision at the cost of speed."),
    ("d24", "Hallucination is when a language model generates plausible-sounding but factually incorrect text."),
    ("d25", "Grounding an LLM answer in retrieved documents reduces hallucination by constraining the model to the provided context."),
    ("d26", "Batch size is the number of training examples processed before the model updates its weights."),
    ("d27", "Cross-entropy loss is the standard loss function for classification and next-token prediction tasks."),
    ("d28", "A validation set is held-out data used during training to monitor generalization and tune hyperparameters."),
    ("d29", "Temperature is a sampling parameter that controls randomness in LLM output; lower values make output more deterministic."),
    ("d30", "A context window is the maximum number of tokens a language model can consider at once."),
]

# 10 hand-written questions with the id of the document that answers them
QUESTIONS = [
    ("What is retrieval-augmented generation?", "d12"),
    ("Which model produces sentence embeddings for semantic search?", "d09"),
    ("What does the learning rate control in gradient descent?", "d02"),
    ("How can I run large language models locally on my own machine?", "d19"),
    ("What metric checks whether the correct document is in the top-k results?", "d15"),
    ("What is LoRA used for?", "d17"),
    ("How do I reduce hallucinations in generated answers?", "d25"),
    ("Which open-source embedding database can persist vectors to disk?", "d21"),
    ("What architecture is based on self-attention?", "d05"),
    ("What does the temperature parameter control in LLM sampling?", "d29"),
]

TOP_K = 3

# Load the embedding model (~90MB one-time download into the HF cache)
embedder = SentenceTransformer("sentence-transformers/all-MiniLM-L6-v2")

ids = [doc_id for doc_id, _ in DOCS]
texts = [text for _, text in DOCS]

# Embed all documents in one batch
doc_embeddings = embedder.encode(texts, convert_to_numpy=True)

# In-memory Chroma collection with cosine distance
client = chromadb.Client()
collection = client.create_collection(name="mlt_docs", metadata={"hnsw:space": "cosine"})
collection.add(ids=ids, documents=texts, embeddings=doc_embeddings.tolist())


def retrieve(query, k=TOP_K):
    """Embed the query and return the ids and texts of the top-k documents."""
    query_embedding = embedder.encode([query], convert_to_numpy=True)
    results = collection.query(query_embeddings=query_embedding.tolist(), n_results=k)
    return results["ids"][0], results["documents"][0]


def generate_answer(query, context_docs):
    """Answer the query with a local LLM grounded in the retrieved context."""
    context = "\n\n".join(context_docs)
    prompt = (
        "Answer the question using only the context below. "
        "If the context does not contain the answer, say you do not know.\n\n"
        f"Context:\n{context}\n\nQuestion: {query}\nAnswer:"
    )
    response = ollama.generate(
        model="llama3.2:1b",
        prompt=prompt,
        options={"seed": 42, "temperature": 0},
    )
    return response["response"].strip()


# 1. Evaluate retrieval hit-rate on the 10 questions
hits = 0
for question, expected_id in QUESTIONS:
    retrieved_ids, _ = retrieve(question, k=TOP_K)
    hit = expected_id in retrieved_ids
    hits += hit
    print(f"[{'HIT' if hit else 'MISS'}] {question} -> {retrieved_ids} (expected {expected_id})")

print(f"\nRetrieval hit-rate: {hits}/{len(QUESTIONS)} = {hits / len(QUESTIONS):.0%}")

# 2. Run the full RAG pipeline on the first 3 questions
print("\n--- RAG answers ---")
for question, _ in QUESTIONS[:3]:
    _, context_docs = retrieve(question, k=2)
    answer = generate_answer(question, context_docs)
    print(f"\nQ: {question}\nA: {answer}")
```

## Expected Output
- First run downloads `all-MiniLM-L6-v2` (~90MB); later runs start in seconds
- 10 retrieval lines marked HIT/MISS; hit-rate of 9/10 or 10/10 is normal for this small, clean collection
- 3 short answers that correctly reflect the retrieved documents (e.g. RAG defined as retrieval plus grounded generation)
- Each generated answer completes in a few seconds on CPU

## Troubleshooting
- `Connection refused` on ollama: the server is not running; start `ollama serve` in a separate terminal
- `model 'llama3.2:1b' not found`: run `ollama pull llama3.2:1b` first
- Low hit-rate: raise `TOP_K`, or check that the question wording overlaps with the target document; embedding models rely on semantic similarity, not exact keywords
- Slow embedding on first call: the model is downloading (~90MB); wait for it to finish once
- `chromadb` import or telemetry errors: upgrade with `pip install -U chromadb`; telemetry noise is harmless

## Cleanup
```bash
deactivate
rm -rf .training.mlt/labs/rag-system/.venv
ollama rm llama3.2:1b   # optional, frees ~1.3GB
```

The embedding model stays in the HF cache at `~/.cache/huggingface/` (~90MB); remove it manually if not needed for other labs.
