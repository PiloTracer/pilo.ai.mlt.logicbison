# Citation standard

Binding for any external claim, source reference, or knowledge assertion.

## Rules

1. **Every non-trivial claim** needs a public source with:
   - Title or description
   - Author(s) or organization
   - URL (preferred) or publication venue
   - Date (if relevant to currency)

2. **Never invent citations.** If you don't have a verified source:
   - Mark as **Unverified**
   - State what you believe but note the uncertainty
   - Suggest the learner verify independently

3. **Acceptable sources** (in order of preference):
   - Official documentation (PyTorch, Hugging Face, etc.)
   - Published papers (arXiv, conferences)
   - Reputable courses (fast.ai, DeepLearning.AI, university courses)
   - Established blogs from practitioners (Sebastian Raschka, Chip Huyen, etc.)
   - GitHub repositories with documentation
   - Stack Overflow with high-voted answers

4. **Questionable sources** (use with caution):
   - Medium articles without author credentials
   - YouTube videos without code/examples
   - Reddit/forum posts without evidence
   - Marketing materials from vendors

5. **Forbidden sources**:
   - ChatGPT/Claude outputs without verification
   - Anonymous sources
   - Broken links
   - Sources you cannot access and verify

## Format

Inline citation:
```
According to the PyTorch documentation (https://pytorch.org/docs/stable/), 
torch.nn.Transformer requires input of shape (seq_len, batch, embed_dim).
```

Reference list:
```markdown
## References

1. **PyTorch Transformer Documentation**
   - Author: PyTorch Team
   - URL: https://pytorch.org/docs/stable/generated/torch.nn.Transformer.html
   - Accessed: 2026-01

2. **Attention Is All You Need**
   - Authors: Vaswani et al.
   - Published: NeurIPS 2017
   - URL: https://arxiv.org/abs/1706.03762
```

## Verification

- Check that URLs are accessible
- Verify author credentials when possible
- Cross-reference claims with multiple sources
- Note when information may be outdated (ML moves fast)

## Updating sources

- Flag sources older than 2 years for review
- Prefer recent sources for rapidly evolving topics (LLMs, tools)
- Note when a source has been superseded by newer work
