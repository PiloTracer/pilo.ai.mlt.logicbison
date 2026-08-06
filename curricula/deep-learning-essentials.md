# Deep Learning Essentials

**Slug:** `deep-learning-essentials`
**Duration:** 6-8 weeks · 3-4 sessions/week
**Level:** Intermediate
**Prerequisites:** `ml-foundations` (all modules)

## Audience
Learners comfortable with Python and basic ML. Ready to build neural networks. Common misconception: "deeper is always better."

## Duration & Cadence
6-8 weeks, 3-4 sessions/week. Sessions: 90 min (concept + live coding). Async: labs, paper reading.

## Outcomes
1. Build and train neural networks in PyTorch from scratch
2. Apply transfer learning for image classification
3. Design training pipelines with proper optimization and regularization
4. Choose between MLPs, CNNs, RNNs for different problems

## Modules

### Module 1: Neural Networks (Week 1-2)
**Objectives:** Understand feedforward networks and backpropagation.
**Content:** MLPs, activation functions (ReLU, GELU, sigmoid), backpropagation via chain rule, loss functions (cross-entropy, MSE), initialization (Xavier, He).
**Lab:** Build a 3-layer MLP from scratch in NumPy for MNIST. Reimplement in PyTorch and compare.
**Sources:** [3Blue1Brown — Neural Networks](https://www.3blue1brown.com/topics/neural-networks) · [Karpathy — Zero to Hero](https://karpathy.ai/zero-to-hero.html) · [fast.ai Lessons 1-3](https://course.fast.ai/)
**Exit check:** Trace backprop through a 2-layer net by hand; explain vanishing gradients.

### Module 2: PyTorch Fundamentals (Week 2-3)
**Objectives:** Master tensors, autograd, nn.Module, DataLoader.
**Content:** Tensor ops and GPU transfers. Autograd computation graphs. Custom nn.Module layers. Dataset/DataLoader with transforms and augmentation. Training loops (optimizer step, zero_grad).
**Lab:** CIFAR-10 pipeline: custom Dataset, DataLoader with augmentation, training loop, checkpointing.
**Sources:** [PyTorch Tutorials](https://pytorch.org/tutorials/) · [PyTorch Basics](https://pytorch.org/tutorials/beginner/basics/intro.html)
**Exit check:** Write a complete training loop from memory; explain autograd.

### Module 3: CNNs and Transfer Learning (Week 3-5)
**Objectives:** Build image classifiers with convolutions and pre-trained models.
**Content:** Convolutions (filters, stride, padding). Architectures (ResNet, EfficientNet). Transfer learning (feature extraction vs fine-tuning). Data augmentation (RandomCrop, MixUp).
**Lab:** Fine-tune ResNet-18 on Caltech-101. Compare from-scratch vs transfer learning.
**Sources:** [PyTorch Transfer Learning](https://pytorch.org/tutorials/beginner/transfer_learning_tutorial.html) · [CS231n Stanford](http://cs231n.stanford.edu/) · [fast.ai](https://course.fast.ai/)
**Exit check:** Explain fine-tune vs feature extract; >85% accuracy on CIFAR-10.

### Module 4: RNNs and Sequences (Week 5-6)
**Objectives:** Handle sequential data with recurrent architectures.
**Content:** Vanilla RNNs, BPTT, vanishing gradients. LSTM/GRU gating. Time series forecasting, text generation. Attention preview.
**Lab:** LSTM for time series forecasting on weather/stock data. Compare with MLP baseline.
**Sources:** [Karpathy — RNN Effectiveness](http://karpathy.github.io/2015/05/21/rnn-effectiveness/) · [Colah — LSTMs](https://colah.github.io/posts/2015-08-Understanding-LSTMs/)
**Exit check:** Explain LSTM gating; sequence model outperforms naive baseline.

### Module 5: Training Techniques (Week 6-8)
**Objectives:** Master optimization, scheduling, regularization, batch norm.
**Content:** Optimizers (SGD, Adam, AdamW). Schedulers (cosine, warmup, OneCycleLR). Regularization (dropout, weight decay, label smoothing). Normalization (BatchNorm, LayerNorm). Mixed precision (FP16, BF16).
**Lab:** Systematic ablation on a CNN: compare optimizers, schedulers, regularization. Document best combo.
**Sources:** [PyTorch Optimizers](https://pytorch.org/docs/stable/optim.html) · [Raschka — DL Fundamentals (2023 — foundational, flagged for currency review per citation.md)](https://sebastianraschka.com/blog/2023/dlfundamentals.html)
**Exit check:** Justify optimizer/scheduler choices; demonstrate mixed precision training.

## Assessment

| Criterion | Pass condition |
|-----------|----------------|
| Backprop | Derive gradients for 2-layer network by hand |
| PyTorch | Training pipeline from scratch in <2 hours |
| Transfer learning | Fine-tuned model >85% accuracy on unseen data |
| Training mastery | Ablation shows clear hyperparameter understanding |

## Exit Criteria
All exit checks met. Artifacts in `.work.mlt/`: MLP impl, transfer learning classifier, sequence model.
