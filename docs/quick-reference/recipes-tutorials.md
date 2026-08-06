# Recipe pack — Tutorials

Generate written tutorials, video-entry tutorials, or both. Every tutorial carries: title + summary, prerequisites, setup, theory (≤30% length), numbered step-by-step code with detailed explanatory comments, expected output, troubleshooting (≥5 errors), exercises, next steps, and real cited references.

---

## Written tutorials (medium length is the default)

```text
@mlt-tutorial generate - attention-mechanism
@mlt-tutorial generate - lora-finetuning --level advanced --length long
@mlt-tutorial generate - vector-databases --level beginner --length short

@mlt-director - give me a tutorial on how the Transformer decoder generates text, token by token
@mlt-director - explain batch normalization with a PyTorch example I can run
@mlt-director - tutorial about gradient descent — show the math first, then the code
```

## Video tutorials (watch list format)

When the learner's PROFILE says video-first, or with `--format video`:

```text
@mlt-tutorial generate - gradient-descent --format video
@mlt-tutorial generate - linear-algebra-intuition --format video
```

Produces an ordered watch list of durable, reputable YouTube videos (per `standards/citation.md`), each with "what to extract" cues and a synthesis-recall section — zero code, all intuition. Example shipped in the framework: `.training.mlt/tutorials/20260804-learn-today/gradient-descent-video-entry.md`.

## Multi-part bundles (written + video companion)

```text
@mlt-tutorial generate - gradient-descent --format both
```

Creates a `<YYYYMMDD>-<topic>/` bundle directory with both a written tutorial and a video entry that cross-reference each other.

## Level and length

| Flag | Options | Default |
|------|---------|---------|
| `--level` | `beginner`, `intermediate`, `advanced` | learner PROFILE level |
| `--length` | `short` (15 min read), `medium` (30 min), `long` (60 min) | `medium` |

## What gets produced

| Layout | Path |
|--------|------|
| Single | `.training.mlt/tutorials/<topic-slug>.md` |
| Bundle | `.training.mlt/tutorials/<YYYYMMDD>-<slug>/<part>.md` |

All code in tutorials carries detailed explanatory comments — the code itself is the teaching material (per `standards/code-quality.md` § Learner-facing code). Every non-trivial block explains the *concept*, not the syntax.
