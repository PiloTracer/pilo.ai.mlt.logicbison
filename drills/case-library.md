# Drill Case Library

Practical coding exercises for ML and LLM training. Each drill is a timed, hands-on exercise.

## ML Foundations Drills

| ID | Title | Duration | Program | Description |
|----|-------|----------|---------|-------------|
| ML-01 | Linear Regression from Scratch | 45 min | ml-foundations | Implement gradient descent for linear regression using only NumPy |
| ML-02 | Logistic Regression Classifier | 45 min | ml-foundations | Build binary classifier with sigmoid + cross-entropy loss |
| ML-03 | K-Nearest Neighbors | 30 min | ml-foundations | Implement KNN for classification from scratch |
| ML-04 | Decision Tree Builder | 60 min | ml-foundations | Build a basic decision tree with information gain splitting |
| ML-05 | Cross-Validation Pipeline | 30 min | ml-foundations | Implement k-fold cross-validation with scikit-learn |
| ML-06 | EDA Challenge | 45 min | ml-foundations | Exploratory data analysis on a real dataset with Pandas + Matplotlib |

## Deep Learning Drills

| ID | Title | Duration | Program | Description |
|----|-------|----------|---------|-------------|
| DL-01 | MLP from Scratch | 60 min | deep-learning-essentials | Build a multi-layer perceptron in PyTorch with custom forward/backward |
| DL-02 | CNN Image Classifier | 60 min | deep-learning-essentials | Build and train a CNN on CIFAR-10 |
| DL-03 | Transfer Learning | 45 min | deep-learning-essentials | Fine-tune ResNet on a custom dataset |
| DL-04 | RNN Sequence Model | 60 min | deep-learning-essentials | Build an LSTM for time series prediction |
| DL-05 | Training Optimization | 30 min | deep-learning-essentials | Compare optimizers (SGD, Adam, AdamW) on the same model |
| DL-06 | Data Augmentation | 30 min | deep-learning-essentials | Implement and benchmark augmentation strategies |

## NLP and Transformer Drills

| ID | Title | Duration | Program | Description |
|----|-------|----------|---------|-------------|
| NLP-01 | Tokenizer Implementation | 45 min | nlp-and-transformers | Build a BPE tokenizer from scratch |
| NLP-02 | Text Classification | 45 min | nlp-and-transformers | Fine-tune BERT for sentiment analysis with Transformers |
| NLP-03 | Named Entity Recognition | 60 min | nlp-and-transformers | Fine-tune a model for NER task |
| NLP-04 | Attention Visualization | 30 min | nlp-and-transformers | Visualize self-attention weights in a Transformer |
| NLP-05 | Custom Transformer | 90 min | nlp-and-transformers | Implement a small Transformer from scratch in PyTorch |

## LLM Training Drills

| ID | Title | Duration | Program | Description |
|----|-------|----------|---------|-------------|
| LLM-01 | Dataset Curation | 60 min | llm-training | Clean, deduplicate, and filter a web dataset |
| LLM-02 | Tokenizer Training | 45 min | llm-training | Train a custom SentencePiece/BPE tokenizer |
| LLM-03 | Small GPT Pre-training | 90 min | llm-training | Pre-train a <100M parameter GPT model |
| LLM-04 | Loss Analysis | 30 min | llm-training | Analyze training loss curves and diagnose issues |

## LLM Fine-tuning Drills

| ID | Title | Duration | Program | Description |
|----|-------|----------|---------|-------------|
| FT-01 | SFT with TRL | 60 min | llm-finetuning | Fine-tune a model with SFTTrainer on instruction data |
| FT-02 | LoRA Fine-tuning | 45 min | llm-finetuning | Apply LoRA to fine-tune with minimal VRAM |
| FT-03 | QLoRA Fine-tuning | 45 min | llm-finetuning | Fine-tune a 7B model in 4-bit with QLoRA |
| FT-04 | DPO Alignment | 60 min | llm-finetuning | Train a model with Direct Preference Optimization |
| FT-05 | Model Evaluation | 45 min | llm-finetuning | Evaluate fine-tuned model with lighteval |
| FT-06 | Model Merging | 30 min | llm-finetuning | Merge two models with mergekit |

## LLM Engineering Drills

| ID | Title | Duration | Program | Description |
|----|-------|----------|---------|-------------|
| ENG-01 | Local LLM Setup | 30 min | llm-engineering | Run Llama 3 locally with ollama |
| ENG-02 | Prompt Engineering | 45 min | llm-engineering | Implement and compare prompting strategies |
| ENG-03 | RAG System | 90 min | llm-engineering | Build a complete RAG pipeline with local embeddings |
| ENG-04 | Quantization | 45 min | llm-engineering | Quantize a model to 4-bit with GPTQ/GGUF |
| ENG-05 | Tool-Using Agent | 60 min | llm-engineering | Build an agent that uses external tools |
| ENG-06 | Inference Benchmarking | 30 min | llm-engineering | Benchmark inference speed across backends |

## Scoring

Each drill is scored on 4 dimensions (1-4 scale):
- **Correctness**: Does the code run and produce correct output?
- **Understanding**: Can the learner explain what the code does?
- **Efficiency**: Is the approach reasonably efficient?
- **Best practices**: Does the code follow ML/Python conventions?

Average >= 3 with no dimension at 1 = drill passed.
