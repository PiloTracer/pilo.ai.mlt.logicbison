# Tutorial — Gradient Descent, Video-Only Entry

> **Example video-entry tutorial.** Shows the alternate format `@mlt-tutorial` produces when the learner's PROFILE prefers video: an ordered watch list of durable, reputable videos with "what to extract" cues and a synthesis-recall section — no code required.

**Summary.** A pure video path into the same conceptual ground as `gradient-descent-linear-regression.md`: what a gradient is, why "descent" means downhill, and how MSE + a linear model collapse into the universal update rule `θ ← θ − η·∇L`. No code, no reading. Three videos, watched in order with explicit "what to extract" cues. Total watch time ~50 minutes (17 + 24 + a ~10–28 min segment of the CS229 lecture). By the end you can answer: *what does gradient descent actually do, geometrically and arithmetically?*

**How to use this tutorial.** Watch each video once with the listed cue in mind. After the third video, do the **synthesis recall** at the end out loud or in writing — that is your retrieval practice for this session.

---

## Prerequisites

- None for content. Pen and paper help for jotting the update rule once you see it.

## Source policy

All cited channels below are durable, primary educational references ranked "Reputable courses" per `standards/citation.md` §3. If a link ever rots, the channel + series + title given will re-locate the video in one search.

---

## Watch order

### Video 1 — *The essential idea of a derivative as slope* (~17 min)

**Channel:** 3Blue1Brown
**Series:** *Essence of Calculus*
**Episode:** "The paradox of the derivative" (Chapter 2, 16:50)
**URL:** https://www.youtube.com/watch?v=9vKqVkMQHKk

**Why this first.** "Derivative as slope" is the founding idea of descent. Grant Sanderson visualises the derivative as the slope of a tangent line and explicitly addresses the "instantaneous rate of change" paradox that confuses everyone the first time.

**What to extract (write this down after watching):**
- A derivative is the slope of the tangent line at a single point.
- For `f(x)`, `f'(x)` tells you *which way is up* and *how steep*.
- That single fact is the entire foundation of "descent": walk opposite to `f'`.

---

### Video 2 — *Gradient descent, geometrically* (~24 min)

**Channel:** StatQuest with Josh Starmer
**Series:** StatQuest — Machine Learning
**Episode:** "Gradient Descent, Step-by-Step" (23:54; the single-variable case you need is the first ~10 minutes — the rest generalises to two parameters, worth finishing if you have the time)
**URL:** https://www.youtube.com/watch?v=sDv4f4s2SB8

**Why this second.** StatQuest takes the derivative-as-slope idea and immediately applies it to a loss function you can picture (a bowl). This is the conceptual bridge from "derivative" to "descent." Starmer draws the loss curve, the slope arrow, and the step — without code, without matrices.

**What to extract:**
- The loss curve is a hill; the gradient points uphill; you step downhill.
- The step size = `η × |gradient|`. When the slope is gentle you take small steps automatically; when near the minimum the slope flattens and you slow down — that's the magic of "stopping" without an explicit stop rule.
- "Learning rate" is the only knob you set; everything else is determined by the slope of the loss.

---

### Video 3 — *Gradient descent applied to a model* (segment, ~10–28 min)

**Channel:** Stanford (official upload)
**Course:** CS229 *Machine Learning*, Andrew Ng (Autumn 2018)
**Episode:** "Linear Regression and Gradient Descent | Lecture 2" (full lecture 1:17; you only need a segment)
**URL:** https://www.youtube.com/watch?v=4b4MUYve_U8
**Playlist (full course):** https://www.youtube.com/playlist?list=PLoROMvodv4rMiGQp3WXShtMGgzqpfVfbU

**Which segment.** Minimum path: start at **44:20** ("Gradient Descent") and watch through ~54:00 (batch vs stochastic descent) — ~10 min. Better path: start at **26:15** ("Linear Regression") so you see `hθ(x)` and `J(θ)` built before the update rule — ~28 min total. The normal-equations section after ~54:00 is optional (it's the written tutorial's Part 6 sanity check).

**Why third.** You've seen the slope idea (V1) and the bowl picture (V2). Ng closes the loop: a specific model (linear regression), a specific loss (MSE), and the explicit update equation — the same equation that appears, verbatim, in the written tutorial's Part 3. This video is the bridge from intuition to the actual formula you'd implement.

**What to extract:**
- The hypothesis `hθ(x) = θ₀ + θ₁x` (or in our notation `ŷ = b + w·x`).
- The cost `J(θ) = (1/2m) Σ (hθ(xⁱ) − yⁱ)²` — note the `(1/2m)` vs our `(1/n)`; the `1/2` is a convention that cancels the `2` from the derivative, cosmetic only.
- The update: `θⱼ ← θⱼ − α ∂J/∂θⱼ`. Ng uses `α` (alpha) for the learning rate where the written tutorial uses `η` (eta). Same symbol, same role.
- The merit of the closed-form normal equation as a sanity check on convergence.

---

## Synthesis recall (do this after the three videos)

Close the videos. Without looking, answer on paper or out loud:

1. Why does gradient descent step **opposite** to the gradient? (one sentence — the word "downhill" should be in it)
2. What does the **learning rate** multiply, and why does the step shrink automatically near the minimum?
3. Why does the squared error loss `(ŷ − y)²` produce a convex bowl (and therefore a unique minimum) for linear regression?
4. Write the update rule for `w` and `b` from memory. Compare with the written tutorial's Part 3 — same four lines.
5. Translated to your own words: what changes between Ng's `(1/2m)` notation and the tutorial's `(1/n)`?

If you trip on #4, rewatch Video 3 from 44:20. If you trip on #1, rewatch Video 2's first 10 minutes.

---

## Why these three, and not five

Each picks up exactly where the previous ends and only adds one new idea:
- V1: derivative = slope.
- V2: sloped loss → step opposite → "descent."
- V3: dressed onto a real model and loss function → the actual update equation.

That is the spine of M1's math content with zero fluff. Adding more videos here would dilute retrieval; the written tutorial is the parallel track for verification, not another video.

---

## How this slots back into the program

- This is the **video half** of M1's first concept block. The written tutorial `gradient-descent-linear-regression.md` (same directory) is the **reading/code half**. Either path alone gets you to the M1 exit criterion ("derive the gradient descent update rules by hand"); doing both is reinforcement.
- Next in M1, still video-friendly: linear algebra intuition — 3Blue1Brown *Essence of Linear Algebra*, episodes "Vectors, what even are they?" and "Linear combinations, span, and basis." Those extend the dot-product idea into the full vector/matrix picture needed for `ŷ = X·w + b` in the multi-feature version.
- After M1's video spine, M2 (Python for ML) is mostly a refresher for anyone already comfortable with Python.

---

## Troubleshooting (5 issues with the video format specifically)

1. **"I watched all three but can't reproduce the update rule."** Watch-then-recall is harder than it looks. Slow down: pause V3 at the moment Ng writes `∂J/∂θⱼ` (~47:00), copy it onto paper, then resume. Recall fails when recognition felt like understanding.
2. **"Two videos used different letters (`α` vs `η`, `θ` vs `w`)."** This is a feature, not a bug. Each time you mentally translate notation you rehearse the concept. Keep a one-line notation map: `α = η = learning rate`, `θ = w (and θ₀ = b)`, `J = L = loss`, `m = n = #samples`.
3. **"StatQuest feels too slow / 3Blue1Brown feels too abstract."** Switch their order. Some learners need the bowl picture before the derivative definition; both videos still cover the same content.
4. **"Ng's lecture is from 2018 — should I find a newer one?"** No. Gradient descent for linear regression has not changed. Older lectures are often better because they predate fashionable frameworks and force the raw derivation.
5. **"I want a single video instead of three."** Use StatQuest's "Gradient Descent, Step-by-Step" alone — it covers the most ground in the least time. You lose Ng's closed-form cross-check and 3Blue1Brown's slope intuition, but for a 25-minute floor, that's the one to keep.

---

## References (per `standards/citation.md`)

All sources are real, canonical, public, and rank "Reputable courses" per §3.

1. **3Blue1Brown — "The paradox of the derivative | Chapter 2, Essence of calculus"**
   - Author: Grant Sanderson
   - Channel: `https://www.youtube.com/@3blue1brown`
   - URL: `https://www.youtube.com/watch?v=9vKqVkMQHKk` (16:50)

2. **StatQuest with Josh Starmer — "Gradient Descent, Step-by-Step"**
   - Author: Josh Starmer
   - Channel: `https://www.youtube.com/@statquest`
   - URL: `https://www.youtube.com/watch?v=sDv4f4s2SB8` (23:54)

3. **Stanford CS229 — "Linear Regression and Gradient Descent | Lecture 2 (Autumn 2018)"**
   - Author: Andrew Ng, Stanford University
   - Course home: `https://cs229.stanford.edu/`
   - URL: `https://www.youtube.com/watch?v=4b4MUYve_U8` (1:17; relevant segment 26:15–54:00, core 44:20–54:00)
   - Course playlist: `https://www.youtube.com/playlist?list=PLoROMvodv4rMiGQp3WXShtMGgzqpfVfbU`

4. **Written tutorial (companion)**
   - File: `gradient-descent-linear-regression.md` (same directory)
   - Same conceptual material in reading + code form; Part 3 derivation matches Video 3's update rule exactly.
