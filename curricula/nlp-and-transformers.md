# NLP and Transformers

**Slug:** `nlp-and-transformers`
**Duration:** 6-8 weeks · 3-4 sessions/week
**Level:** Intermediate
**Prerequisites:** `deep-learning-essentials` (all modules)

## Audience
Learners comfortable with PyTorch ready to specialize in language models. Common misconception: "fine-tuning is just changing the last layer."

## Duration & Cadence
6-8 weeks, 3-4 sessions/week. Sessions: 90 min (paper reading + implementation). Async: HF tutorials, fine-tuning experiments.

## Outcomes
1. Implement self-attention and multi-head attention from scratch
2. Fine-tune transformers for classification, NER, and summarization
3. Navigate the Hugging Face ecosystem (Transformers, Datasets, Tokenizers)
4. Explain the transformer architecture and encoder/decoder variants

## Modules

### Module 1: NLP Fundamentals (Week 1-2)
**Objectives:** Understand text representation and classical NLP.
**Content:** Tokenization (word, subword BPE/WordPiece/SentencePiece, character). Text preprocessing and normalization. Word embeddings (Word2Vec CBOW/skip-gram, GloVe, FastText). Embedding evaluation (analogies, t-SNE).
**Lab:** Train Word2Vec on a corpus with Gensim. Visualize embeddings. Compare BPE vs WordPiece tokenization.
**Sources:** [HF NLP Course Ch.1](https://huggingface.co/learn/nlp-course/chapter1) · [Jay Alammar — Word2Vec](https://jalammar.github.io/illustrated-word2vec/) · [Jurafsky & Martin SLP3](https://web.stanford.edu/~jurafsky/slp3/)
**Exit check:** Explain why subword tokenization is preferred for transformers.

### Module 2: Transformer Architecture (Week 2-4)
**Objectives:** Deeply understand the transformer from the original paper.
**Content:** Self-attention (Q/K/V, scaled dot-product). Multi-head attention. Positional encoding (sinusoidal, RoPE, ALiBi). Encoder-decoder structure, masking. LayerNorm (pre-norm vs post-norm). Variants: encoder-only (BERT), decoder-only (GPT), encoder-decoder (T5).
**Lab:** Implement multi-head self-attention from scratch in PyTorch. Build a minimal 2-layer transformer block.
**Sources:** [Attention Is All You Need](https://arxiv.org/abs/1706.03762) · [Jay Alammar — Transformer](https://jalammar.github.io/illustrated-transformer/) · [Karpathy — Let's build GPT](https://www.youtube.com/watch?v=kCc8FmEb1nY) · [Annotated Transformer](https://nlp.seas.harvard.edu/annotated-transformer/)
**Exit check:** Implement scaled dot-product attention from memory; explain decoder masking.

### Module 3: Hugging Face Ecosystem (Week 4-5)
**Objectives:** Master Transformers, Datasets, Tokenizers, and Hub.
**Content:** Transformers (`AutoModel`, `AutoTokenizer`, `pipeline`). Datasets (loading, streaming, preprocessing). Tokenizers (training custom, fast vs slow). Hub (uploading, versioning, model cards). `Trainer` API (`TrainingArguments`, callbacks, logging).
**Lab:** Use `pipeline` for sentiment/NER/QA, then reimplement manually: tokenize, infer, post-process.
**Sources:** [HF NLP Course Ch.2-5](https://huggingface.co/learn/nlp-course/chapter2) · [Transformers Docs](https://huggingface.co/docs/transformers/) · [Datasets Docs](https://huggingface.co/docs/datasets/)
**Exit check:** Run inference without `pipeline` — manual tokenize, model call, decode.

### Module 4: NLP Tasks and Fine-tuning (Week 5-8)
**Objectives:** Fine-tune pre-trained models for real NLP tasks.
**Content:** Text classification (single/multi-label, imbalanced data). NER (BIO tagging, token classification). QA (extractive, SQuAD format). Summarization (extractive vs abstractive, ROUGE).
**Lab:** (1) Fine-tune DistilBERT for sentiment on IMDB. (2) Fine-tune BERT for NER on CoNLL-2003. (3) Fine-tune BART/T5 for summarization on CNN/DailyMail.
**Sources:** [HF NLP Course Ch.3-7](https://huggingface.co/learn/nlp-course/chapter3) · [Raschka — LLMs from Scratch](https://github.com/rasbt/LLMs-from-scratch) · [HF Task Guides](https://huggingface.co/docs/transformers/task_summary)
**Exit check:** Fine-tune for a new task not in labs; achieve competitive results.

## Assessment

| Criterion | Pass condition |
|-----------|----------------|
| Attention mechanics | Multi-head attention from scratch passes unit tests |
| HF fluency | Tokenize, fine-tune, evaluate without pipeline API |
| Fine-tuning | BERT variant >90% F1 on NER |
| Architecture | Explain encoder-only vs decoder-only with use cases |

## Exit Criteria
All exit checks met. Artifacts in `.training.mlt/`: text classifier, NER model, summarization pipeline.
