---
name: mlt-session
description: >-
  Session lifecycle for MLT in a target repo — start, status, close, plus
  optional git commit/push strictly scoped to the .work.mlt working directory.
  Modes: start, status, close. Modifiers: commit, push. Any combination
  of close / commit / push is valid. Never commits or pushes unless the
  invocation asks. On commit, MUST run git add + git commit in the shell for
  all .work.mlt/ paths — including new untracked files and directories.
---

# mlt-session — session open, close, and scoped commit/push

Bookend MLT training sessions so the next session (or human) resumes without guessing, and optionally persist session state to git — **strictly scoped to the working directory** in the target repo.

**Canonical path:** `skills/mlt-session/skill.md` · **Pairs with:** `.cursorrules`, `mlt-mentor`, `mlt-review`, `mlt-bootstrap`.

---

## Working directory (binding)

The working directory is **`.work.mlt/`** at the target repo root. It is the full domain of this framework in the target repo.

- **Reads (session context):** `context/PROFILE.md`, `context/HANDOFF.md`, `plans/NEXT.md`, `programs/<slug>/progress.md`, `sessions/`
- **Writes:** `sessions/<log>.md`, `context/HANDOFF.md`, `plans/NEXT.md`, `programs/<slug>/progress.md`
- **Git scope (commit/push):** only paths under `.work.mlt/` — never stage or commit anything outside it.

**Boundary rules (mandatory):**

- Every `mlt-session` action touches **only** files under `.work.mlt/`. Never create, edit, stage, move, or delete files outside `.work.mlt/` as part of an `mlt-session` action.
- Files outside `.work.mlt/` (e.g. the learner's own project code) may be **read and referenced** only when the session context is already aware of them — i.e. the session log, HANDOFF, NEXT, or program ledger names them. Even then, `mlt-session` never **writes** outside `.work.mlt/`, and never pulls in unrelated files.
- `.quick/` views are owned by `mlt-review`, not `mlt-session`.
- If `.work.mlt/` is missing in the target repo, report it as not bootstrapped (`@mlt-bootstrap init`) and stop.

---

## Hard rules

- **Default close / default commit:** never `git commit` or `git push` unless the invocation includes **`commit`** and/or **`push`**. Those words in the invocation are the user's explicit request (per `.cursorrules` git rule).
- **`close commit` / `close commit push` / `commit` / `commit push`:** **MUST** run `git add` + `git commit` in the shell. A dirty `.work.mlt/` after `close commit` with only a drafted message is **fail**.
- **Commit scope (mandatory):** stage **only** `.work.mlt/` paths — `git add -- .work.mlt/`. Never `git add -A`, `git add .`, or stage app code / files outside `.work.mlt/`.
- **Untracked files included:** `git add -- .work.mlt/` stages every changed **and new** file under `.work.mlt/`, including new untracked files and directories. New learner artifacts (session logs, labs, tutorials, drill scores) **must** be added, not skipped.
- **Always** show the commit message — drafted, used, or `none - working tree clean`.
- **No `Co-authored-by:` trailers** (per `.cursorrules`). Commit subject: `type: description` (e.g. `chore: close MLT session — gradient descent`).
- **Secrets scan:** before any commit, scan staged paths for `.env`, keys, tokens, weights (`*.safetensors`, `*.gguf`, `*.bin`), datasets (`*.csv`, `*.jsonl`). On a match: stop, do not commit, report the flagged paths. `.gitignore` already excludes most of these — this is a belt-and-suspenders check.
- **Push requires commit:** an invocation containing `push` but not `commit` is treated as `commit push` — push never runs without committing the scoped changes first.

---

## Parse invocation

Any **combination** of the parameters `close`, `commit`, `push` is valid; order does not matter (`close commit push` = `push close commit`).

| User says | Verb | Git action |
|-----------|------|------------|
| `@mlt-session start [--agenda <text>]` | start | — |
| `@mlt-session status` | status | — |
| `@mlt-session close [--note <text>]` | close | draft commit message only |
| `@mlt-session close commit` | close | commit `.work.mlt/` (incl. untracked) |
| `@mlt-session close commit push` | close | commit then push |
| `@mlt-session close push` | close | treated as **commit push** (push requires commit) |
| `@mlt-session commit` | commit | commit `.work.mlt/` (incl. untracked), **no** close |
| `@mlt-session commit push` | commit | commit then push, **no** close |
| `@mlt-session push` | push | treated as **commit push** (push requires commit) |

- `--agenda <text>`: optional agenda override on `start`.
- `--note <text>`: optional closing note appended to HANDOFF on `close`.
- **Standalone `commit` / `commit push`** are mid-session checkpoints: run the same git steps as `close commit` / `close commit push` but **skip** HANDOFF and NEXT updates — the session stays open.

---

## Steps — start mode

1. Read `.work.mlt/context/PROFILE.md` — confirm learner identity and level.
2. Read `.work.mlt/context/HANDOFF.md` — load last session state.
3. Read `.work.mlt/plans/NEXT.md` — load planned next action.
4. Read the active program's `progress.md` under `.work.mlt/programs/<slug>/` if present.
5. Assemble session context: learner level and program, last-session summary and open items, planned next action and whether it was completed.
6. Set the agenda: use `--agenda` if provided, otherwise derive from NEXT.md and progress.md.
7. Announce session open: learner name, program, module, agenda.
8. Create the session log under `.work.mlt/sessions/`.

### Session log naming convention (binding)

- Format: `YYYY-MM-DD_<topic-slug>.md` (local date, kebab-case topic), e.g. `2026-08-05_grad-descent-walkthrough.md`.
- If the topic is not known at `start`, use the agenda or module name; rename once at `close` if it sharpened.
- Exactly **one log file per session**: `mlt-session` creates it at `start`; every other skill that logs the session (`mlt-mentor`, `mlt-lab`, `mlt-drill`) writes into this same file — never a second one.
- The log records: date, agenda, modules/topics covered, retrieval results, artifacts produced (paths under `.work.mlt/`), commitments.

---

## Steps — status mode

1. Read the current session log.
2. Read active program progress.
3. Run `git status -sb` and `git log -1 --oneline` for a one-line tree snapshot.
4. Report: session duration, items covered, items remaining, open unknowns, branch + tree state (clean/dirty).

Read-only. No writes.

---

## Steps — close mode

1. Summarize what was accomplished this session.
2. Write the session summary to the session log (rename to the final `YYYY-MM-DD_<topic-slug>.md` if the placeholder topic changed).
3. Update `.work.mlt/context/HANDOFF.md`: what was done, what was learned, what was left incomplete, key decisions.
4. Update `.work.mlt/plans/NEXT.md`: concrete next action, recommended skill to run next, blockers/prerequisites.
5. Append `--note` to HANDOFF if provided.
6. Tick completed items in the program's task ledger.
7. Draft the commit message (shown in the report; used only if the invocation includes `commit`).

If the invocation also includes `commit` / `push`, run the [Commit protocol](#commit-protocol) (then [Push protocol](#push-protocol)) after the writes above.

---

## Commit protocol

Execution order: **C1 → C2 → C3 → C4 → C5**. Runs whenever the invocation includes `commit` — after `close` when present, standalone otherwise. If C2 (secrets) fails, **stop** — do not commit.

### C1 — Working-tree audit (mandatory)

Run:

```bash
git status -sb
git diff --stat
git diff --cached --stat
git log -1 --oneline
```

Classify findings: staged vs unstaged vs untracked, by area. Confirm every dirty path relevant to this session is under `.work.mlt/`. Paths outside `.work.mlt/` are left untouched — never staged.

### C2 — Secrets scan (mandatory)

Scan the to-be-staged paths for secrets / large artifacts (`.env*`, keys, tokens, `*.safetensors`, `*.gguf`, `*.bin`, `*.csv`, `*.jsonl`, `models/`, `datasets/`, `.venv*`). **On match: stop and report; do not commit.** No match → proceed.

### C3 — Draft commit message (mandatory, always shown)

Subject: `chore: <verb> MLT session — <topic>` where `<verb>` is `close` (close mode) or `checkpoint` (standalone commit), `<topic>` from the session agenda/module. Body (optional): 1–3 bullets of what the session produced, referencing artifact paths under `.work.mlt/`.

Example:

```text
chore: close MLT session — gradient descent

- derived update rules by hand; ran gd_linreg.py lab
- .work.mlt/sessions/2026-08-05_grad-descent-walkthrough.md
```

### C4 — Git actions (only when the invocation includes `commit`)

1. `git add -- .work.mlt/` — stages modified **and new untracked files/directories** under `.work.mlt/`; `.gitignore` stays respected (venvs, weights, datasets excluded). **Never** add paths outside `.work.mlt/`.
2. `git commit` with the drafted message (HEREDOC for multi-line). No `Co-authored-by:` trailers.
3. Verify: `git log -1 --oneline` shows the new SHA; `git status -sb` shows `.work.mlt/` clean (staged or clean).

If the tree under `.work.mlt/` is already clean, state `none - working tree clean` and skip the commit.

### C5 — Commit report (mandatory output)

Report: commit message used (or `none - working tree clean`), new commit SHA, paths staged, anything left uncommitted outside `.work.mlt/` (untouched).

---

## Push protocol

Runs only when the invocation includes `push` — and **only after** a commit (an invocation with `push` but no `commit` is treated as `commit push`).

1. Confirm a commit exists (`git log -1 --oneline`).
2. `git push` the current branch.
3. Verify: `git status -sb` shows `up to date` (or report the branch/upstream state if push fails or there is no upstream — do not invent a remote).
4. Report: pushed branch, remote, before/after SHAs, or the failure reason.

---

## Combination semantics

| Invocation | close writes | commit | push |
|------------|:---:|:---:|:---:|
| `close` | ✅ | — | — |
| `close commit` | ✅ | ✅ | — |
| `close commit push` / `close push` | ✅ | ✅ | ✅ |
| `commit` | — | ✅ | — |
| `commit push` / `push` | — | ✅ | ✅ |

Any order is accepted; the flags above define the behavior. `push` always implies `commit` of the scoped `.work.mlt/` changes.

---

## Completion checklist (every mode)

Each item: `pass` | `fail` | `skip` with evidence.

- **start:** session log created under `.work.mlt/sessions/`, context loaded, agenda announced
- **status:** progress + tree snapshot rendered, no writes
- **close:** HANDOFF.md updated, NEXT.md set, session log finalized, task ledger ticked
- **commit:** `git add -- .work.mlt/` + `git commit` ran in the shell, new SHA shown, untracked `.work.mlt/` files included, nothing outside `.work.mlt/` staged
- **push:** `git push` ran after a commit, branch/remote state reported
- **always:** commit message block shown (drafted, used, or `none - working tree clean`); no `Co-authored-by:` trailers
