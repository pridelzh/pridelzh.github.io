---
layout: post
title: "Understanding Transformer"
date: 2026-07-31
categories:
  - Large Language Models
tags:
  - Transformer
  - Deep Learning
excerpt: "A concise research note on the Transformer architecture."
---

The Transformer replaces recurrence with attention, allowing every token to
compare its representation with every other token in parallel. Its core
operation projects an input sequence into queries, keys, and values.

For a key dimension of $d_k$, scaled dot-product attention is

$$
\operatorname{Attention}(Q,K,V)
= \operatorname{softmax}\left(\frac{QK^\top}{\sqrt{d_k}}\right)V
$$

The scale factor keeps large dot products from pushing the softmax into regions
with very small gradients. A compact NumPy version makes the data flow explicit:

```python
import numpy as np

def attention(query, key, value):
    scale = np.sqrt(key.shape[-1])
    scores = query @ key.T / scale
    weights = np.exp(scores - scores.max(axis=-1, keepdims=True))
    weights /= weights.sum(axis=-1, keepdims=True)
    return weights @ value
```

Multi-head attention repeats this operation in several learned representation
subspaces, then combines the results so the model can track different
relationships at once.
