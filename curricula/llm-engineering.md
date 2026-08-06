# LLM Engineering

**Slug:** `llm-engineering`
**Duration:** 6-8 weeks · 3-4 sessions/week
**Level:** Advanced
**Prerequisites:** `llm-finetuning` (all modules)

## Audience
Learners who can fine-tune LLMs and want to build production systems. Common misconception: "RAG is always better than fine-tuning."

## Duration & Cadence
6-8 weeks, 3-4 sessions/week. Sessions: 90 min (concept + live building). Async: RAG pipelines, agent experiments, quantization benchmarks.

## Outcomes
1. Run LLMs locally with llama.cpp and ollama, understanding GGUF and quantization
2. Design prompts using CoT, few-shot, and ReAct patterns
3. Build a RAG system with vector search, chunking, and reranking
4. Implement a tool-using ReAct agent
5. Quantize and optimize models for efficient inference

## Modules

### Module 1: Running LLMs Locally (Week 1-2)
**Objectives:** Master local inference with llama.cpp, ollama, LM Studio.
**Content:** llama.cpp (GGUF format, quant types Q4_K_M/Q5_K_M/Q8_0, perf tuning). ollama (model management, Modelfiles, API). LM Studio (GUI, local server). Hardware (CPU/GPU offloading, RAM, KV cache sizing).
**Lab:** Install ollama, pull Llama 3.1 8B and Mistral 7B (scale down to 1-3B GGUF models such as Llama-3.2-1B or Qwen2.5-1.5B on machines with <16GB RAM). Benchmark speed across quants. Set up llama.cpp OpenAI-compatible server. Compare GGUF quality via perplexity.
**Sources:** [llama.cpp](https://github.com/ggerganov/llama.cpp) · [ollama](https://ollama.com/) · [LM Studio](https://lmstudio.ai/)
**Exit check:** Running local server with benchmarked throughput; explain quantization tradeoffs.

### Module 2: Prompt Engineering (Week 2-3)
**Objectives:** Design systematic, reliable prompts.
**Content:** Zero-shot and few-shot (instruction clarity, example selection). CoT (step-by-step, self-consistency). ReAct (reasoning + acting loops). Structured output (JSON mode, XML, schema enforcement, grammar-constrained decoding). Prompt optimization (testing, versioning, failure analysis).
**Lab:** Build prompt library for 5 tasks (summarize, extract, classify, QA, code gen). Benchmark across 3 models. Implement ReAct for multi-step research.
**Sources:** [Prompt Engineering Guide](https://www.promptingguide.ai/) · [Anthropic Prompt Docs](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/overview) · [OpenAI Best Practices](https://platform.openai.com/docs/guides/prompt-engineering)
**Exit check:** Benchmarked prompt library >80% accuracy on target tasks.

### Module 3: RAG (Week 3-5)
**Objectives:** Build production-quality retrieval-augmented generation.
**Content:** Embeddings (sentence-transformers, MTEB). Vector DBs (Chroma, FAISS, Qdrant, HNSW/IVF). Chunking (fixed, recursive, semantic, document-aware). Retrieval (hybrid dense+sparse, reranking, query transform). RAG patterns (naive, advanced, self-RAG, corrective). Evaluation (RAGAS: faithfulness, relevance, precision).
**Lab:** Full RAG system: ingest docs, multi-strategy chunking, embed with sentence-transformers, store in Chroma, hybrid retrieval + reranking, evaluate with RAGAS.
**Sources:** [LangChain RAG](https://python.langchain.com/docs/tutorials/rag/) · [LlamaIndex](https://docs.llamaindex.ai/) · [RAGAS](https://github.com/explodinggradients/ragas) · [Sentence Transformers](https://www.sbert.net/)
**Exit check:** RAG system >0.7 faithfulness on RAGAS; handles multi-doc queries.

### Module 4: Agents (Week 5-7)
**Objectives:** Build tool-using agents with ReAct.
**Content:** Tool use (function calling, JSON schemas, error handling). ReAct (thought-action-observation, stopping criteria). Frameworks (smolagents, LangChain agents). Multi-agent (supervisor, swarm, debate). Memory (buffers, summarization, vector-backed). Safety (sandboxing, validation, loop detection).
**Lab:** Build a research agent (web search, doc reading, synthesis). Then multi-agent: planner delegates to specialist agents (coder, researcher, reviewer).
**Sources:** [smolagents](https://github.com/huggingface/smolagents) · [LangChain Agents](https://python.langchain.com/docs/concepts/agents/) · [Anthropic — Effective Agents](https://www.anthropic.com/engineering/building-effective-agents)
**Exit check:** Working agent completing multi-step task with 3+ tools.

### Module 5: Inference Optimization (Week 7-8)
**Objectives:** Optimize inference for speed and memory.
**Content:** Quantization (GPTQ, AWQ, GGUF, bitsandbytes). vLLM (PagedAttention, continuous batching, tensor parallel). SGLang (RadixAttention, prefix caching). Speculative decoding (draft models, Medusa). KV cache optimization (sliding window, eviction).
**Lab:** Quantize Llama 3.1 8B with AWQ and GPTQ (or a 1-3B model on smaller GPUs). Benchmark vs FP16. Deploy with vLLM, measure concurrent throughput.
**Sources:** [vLLM](https://docs.vllm.ai/) · [SGLang](https://sgl-project.github.io/) · [AutoGPTQ](https://github.com/AutoGPTQ/AutoGPTQ) · [AutoAWQ](https://github.com/casper-hansen/AutoAWQ)
**Exit check:** Benchmark comparing FP16/AWQ/GPTQ on latency, throughput, quality.

## Assessment

| Criterion | Pass condition |
|-----------|----------------|
| Local inference | llama.cpp and ollama with benchmarked throughput |
| Prompting | Library >80% accuracy across models |
| RAG | Faithfulness >0.7 on RAGAS |
| Agents | Multi-step agent with 3+ tools |
| Optimization | Quantization benchmark with clear tradeoff analysis |

## Exit Criteria
All exit checks met. Artifacts in `.work.mlt/`: server config, prompt library, RAG pipeline, agent, quant benchmark.
