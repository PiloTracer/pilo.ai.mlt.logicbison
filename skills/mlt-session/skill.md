---
name: mlt-session
description: >-
  Session lifecycle for MLT — start, status, context, close, plus optional
  git commit/push with repo-context-aware scope: in a target (learner) repo
  commits are strictly scoped to the .work.mlt working directory; in the
  self-hosted framework source repo commits cover ALL modified/added/new
  files in the repo. Modes: start, status, context, close. Modifiers:
  commit, push, scoped. Aliases: begin/open → start, end/handoff → close.
  Any combination of close / commit / push is valid; push implies commit.
  `context` loads all mandatory session context read-only (uncommitted-aware,
  no writes). Standalone commit / commit push are mid-session checkpoints
  that skip HANDOFF/NEXT updates. Never commits or pushes unless the
  invocation asks. On commit, MUST run git add + git commit in the shell —
  including new untracked files and directories.
---

# mlt-session — session open, context, close, and scoped commit/push

Bookend MLT training sessions so the next session (or human) resumes without guessing, and optionally persist session state to git — with **repo-context-aware scope** (see [Commit scope resolution](#commit-scope-resolution-binding)).

**Canonical path:** `skills/mlt-session/skill.md` · **Pairs with:** `.cursorrules`, `mlt-mentor`, `mlt-review`, `mlt-bootstrap`.

---

## Working directory (binding)

The working directory is **`.work.mlt/`** at the target repo root. It is the full domain of this framework in a target (learner) repo.

- **Reads (session context):** `context/PROFILE.md`, `context/HANDOFF.md`, `plans/NEXT.md`, `plans/UNKNOWNS.md`, `programs/<slug>/progress.md`, `sessions/`
- **Writes:** `sessions/<log>.md`, `context/HANDOFF.md`, `plans/NEXT.md`, `programs/<slug>/progress.md`
- **Git scope (commit/push):** repo-context-aware — see [Commit scope resolution](#commit-scope-resolution-binding).

**Boundary rules (mandatory):**

- **Session reads/writes** stay under `.work.mlt/` in every repo. Never create, edit, move, or delete files outside `.work.mlt/` as part of an `mlt-session` action. (Git staging is governed by the scope resolution below, not by this rule.)
- Files outside `.work.mlt/` (e.g. the learner's own project code) may be **read and referenced** only when the session context is already aware of them — i.e. the session log, HANDOFF, NEXT, or program ledger names them. Even then, `mlt-session` never **writes** outside `.work.mlt/`, and never pulls in unrelated files.
- `.quick/` views are owned by `mlt-review`, not `mlt-session`.
- If `.work.mlt/` is missing in the target repo, report it as not bootstrapped (`@mlt-bootstrap init`) and stop.

---

## Commit scope resolution (binding)

Resolve the commit scope from the **repo context** before any `git add`:

| Repo context | Detection | Default commit scope |
|--------------|-----------|----------------------|
| **Self-hosted framework source** | repo root has `.cursorrules` with the `pilo.trainer.mlt` identity **and** `skills/mlt-session/skill.md` at repo root (framework assets local, not under `.ai.mlt/`) **and** `TRAINER_MLT_SOURCE` unset (`REPLACE_BASICSOURCE`) | **Full repo** — stage ALL modified + new untracked files (`git add -A`; `.gitignore` still respected). Session work here is framework-dev; leaving `skills/`, `templates/`, docs, or `.cursorrules` behind is **fail**. |
| **Target repo — thin-client** | `TRAINER_MLT_SOURCE` set in `.cursorrules` | **`.work.mlt/` only** — `git add -- .work.mlt/`; never app code |
| **Target repo — fat-client** | framework vendored under `.ai.mlt/` | **`.work.mlt/` only** — `git add -- .work.mlt/`; never app code or the vendored `.ai.mlt/` |
| **Ambiguous / undetectable** | none of the above markers | **`.work.mlt/` only** (safe default) |

- The **`scoped`** modifier narrows either scope to the bookend files (HANDOFF + NEXT + session log + active program ledger).
- The resolved scope is stated in the C1 audit and in the commit report (`**Scope:** framework (full repo) | learner (.work.mlt/) | scoped (bookend)`).

---

## Hard rules

- **Default close / default commit:** never `git commit` or `git push` unless the invocation includes **`commit`** and/or **`push`**. Those words in the invocation are the user's explicit request (per `.cursorrules` git rule).
- **`close commit` / `close commit push` / `commit` / `commit push`:** **MUST** run `git add` + `git commit` in the shell. Dirty files within the resolved scope after `close commit` with only a drafted message is **fail**.
- **Commit scope (mandatory):** resolve per [Commit scope resolution](#commit-scope-resolution-binding) — self-hosted framework source → **full repo** (`git add -A`, all modified/added/new files); target repo → **`.work.mlt/` only** (`git add -- .work.mlt/`, never app code). The **`scoped`** modifier narrows either to bookend files only (see [Commit protocol](#commit-protocol)).
- **Untracked files included:** the staging step for the resolved scope stages every changed **and new** file in that scope, including new untracked files and directories. New artifacts (session logs, labs, tutorials, drill scores — and in framework scope, new skills/templates/docs) **must** be added, not skipped.
- **Always** show the commit message — drafted, used, or `none - working tree clean`.
- **Standalone `commit` / `commit push`:** run the same git steps as `close commit` / `close commit push` but **skip** HANDOFF and NEXT updates. Session stays open. Useful for mid-session checkpoints.
- **`context` writes nothing.** No HANDOFF/NEXT/session-log writes, no completion-gate changes — read-only full context load.
- **No `Co-authored-by:` trailers** (per `.cursorrules`). Commit subject: `type: description` (e.g. `chore: close MLT session — gradient descent`).
- **Secrets scan:** before any commit, scan staged paths for `.env`, keys, tokens, weights (`*.safetensors`, `*.gguf`, `*.bin`), datasets (`*.csv`, `*.jsonl`). On a match: stop, do not commit, report the flagged paths. `.gitignore` already excludes most of these — this is a belt-and-suspenders check.
- **Push requires commit:** an invocation containing `push` but not `commit` is treated as `commit push` — push never runs without committing the scoped changes first.
- Every non-read-only mode ends with a **completion checklist** — each item `pass` | `fail` | `skip` with evidence.

---

## Parse invocation

Normalize the invocation to **verb** + optional **modifiers**. Order does not matter (`close commit push` = `push close commit`). The word `session` is an optional legacy alias.

| User says | Verb | Git action |
|-----------|------|------------|
| `@mlt-session start [--agenda <text>]` / `start - <goal>` | start | — |
| `@mlt-session status` | status | — |
| `@mlt-session context` | context | — |
| `@mlt-session close [--note <text>]` | close | draft commit message only |
| `@mlt-session close commit` | close | commit `.work.mlt/` (incl. untracked) |
| `@mlt-session close commit scoped` | close | commit bookend files only (HANDOFF + NEXT + session log + ledger) |
| `@mlt-session close commit push` | close | commit then push |
| `@mlt-session close push` | close | treated as **commit push** (push requires commit) |
| `@mlt-session commit` | commit | commit `.work.mlt/` (incl. untracked), **no** close |
| `@mlt-session commit push` | commit | commit then push, **no** close |
| `@mlt-session push` | push | treated as **commit push** (push requires commit) |

**Aliases (same verb):** `begin`, `open` → start; `end`, `handoff` → close.

**Goal text:** anything after `-` or on a new line after `start` (not the words `commit`/`push`/`scoped`). Equivalent to `--agenda <text>`; if both are given, `--agenda` wins.

- `--agenda <text>`: optional agenda override on `start`.
- `--note <text>`: optional closing note appended to HANDOFF on `close`.
- **`scoped`**: narrows a `commit` to the session bookend files — HANDOFF, NEXT, the current session log, and the active program's task ledger — instead of the full `.work.mlt/` default scope.
- **Standalone `commit` / `commit push`** are mid-session checkpoints: run the same git steps as `close commit` / `close commit push` but **skip** HANDOFF and NEXT updates — the session stays open.

### Natural-language triggers

| Phrase | Maps to |
|--------|---------|
| `start` / `begin` / `open` | start |
| `close` / `end` / `handoff` / `wrap up` | close |
| `close commit` | close + commit |
| `close commit push` | close + commit + push |
| `commit` / `checkpoint` | commit only (no close) |
| `commit push` | commit + push, no close |
| `context` / `load context` / `orient` | context |
| `status` / am I loaded | status |

---

## Mode comparison

| | start | status | context | close | close commit | close commit push | commit | commit push |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| Read HANDOFF/NEXT | yes | yes | yes | yes | yes | yes | no | no |
| Write HANDOFF (Session status) | Open | no | no | Closed | Closed | Closed | no | no |
| Update NEXT | no | no | no | yes | yes | yes | no | no |
| Session log | create | read | read | finalize | finalize | finalize | no | no |
| `git commit` | no | no | no | no | yes | yes | yes | yes |
| `git push` | no | no | no | no | no | yes | no | yes |
| Commit message in output | no | no | no | **always** | **always** | **always** | **always** | **always** |
| Completion checklist | yes | no | no | yes | yes | yes | yes | yes |

---

## Steps — start mode

1. **S1 — Baseline reads (mandatory):** `.work.mlt/context/PROFILE.md` (learner identity and level), `.work.mlt/context/HANDOFF.md` (last session state), `.work.mlt/plans/NEXT.md` (planned next action), `.work.mlt/plans/UNKNOWNS.md` (open unknowns), and the active program's `progress.md` under `.work.mlt/programs/<slug>/` if present.
2. **S2 — Environment snapshot (evidence):** run `git status -sb` and `git log -1 --oneline` for branch + tree state. Note dirty `.work.mlt/` paths in the start report.
3. **S3 — Assemble session context:** learner level and program, last-session summary and open items, planned next action and whether it was completed.
4. **S4 — Set the agenda:** `--agenda` if provided, else goal text after `-`, else derive from NEXT.md and progress.md.
5. **S5 — Mark session open:** set `**Session status:** Open - <date> - <agenda>` in HANDOFF (update the line only; do not rewrite other sections).
6. **S6 — Create the session log** under `.work.mlt/sessions/` (naming convention below).
7. **S7 — Start report** (mandatory output, template below).

If prior HANDOFF says `Closed`, treat as a new session; do not assume prior chat memory. If HANDOFF is missing entirely, report it and offer `@mlt-bootstrap init` — do not invent session history.

### Session log naming convention (binding)

- Format: `YYYY-MM-DD_<topic-slug>.md` (local date, kebab-case topic), e.g. `2026-08-05_grad-descent-walkthrough.md`.
- If the topic is not known at `start`, use the agenda or module name; rename once at `close` if it sharpened.
- Exactly **one log file per session**: `mlt-session` creates it at `start`; every other skill that logs the session (`mlt-mentor`, `mlt-lab`, `mlt-drill`) writes into this same file — never a second one.
- The log records: date, agenda, modules/topics covered, retrieval results, artifacts produced (paths under `.work.mlt/`), commitments.

### Start report (mandatory output)

```markdown
## Session start — <learner/program>

**Date:** <ISO date> · **Branch:** <branch> · **Tree:** clean | dirty
**Program:** <slug or none> · **Module:** <current module or none>
**Agenda:** <agenda text>
**Session log:** .work.mlt/sessions/<log>.md

### Loaded
- HANDOFF: <one-line last-session summary>
- NEXT: <planned next action>
- Open unknowns: <count> · Blockers: <list or none>

### Checklist
- [pass|fail] S1 baseline reads (PROFILE, HANDOFF, NEXT, UNKNOWNS, progress)
- [pass|fail] S5 session marked Open in HANDOFF
- [pass|fail] S6 session log created at <path>
```

---

## Steps — status mode

Read-only snapshot. **No** writes, **no** completion checklist.

1. Read `.work.mlt/context/HANDOFF.md` and `.work.mlt/plans/NEXT.md`; read the current session log if one exists.
2. Read active program progress.
3. Run `git status -sb` and `git log -1 --oneline`.
4. Output:

```markdown
## Session status — <program/learner>

**Session:** Open | Closed - <date> - <agenda if Open>
**Branch:** <branch> · **Tree:** clean | dirty
**Pick up:** <one line from NEXT.md>
**Blockers:** <short list or none>
```

Optional: one line on dirty files (no full diff), session duration and items covered/remaining if a session log exists. For full context load without writes, use **context**; to open a session, use **start**.

---

## Steps — context mode

Read-only full context load. **No** HANDOFF/NEXT/session-log writes. Sits between `status` (one-line compact) and `start` (full load + marks HANDOFF Open + creates the log).

Use when: an operator (or agent) wants full session context for ad-hoc reasoning without opening/closing a session bookend — mid-session orientation, a second agent joining, debugging "what changed and what's next" without mutating HANDOFF.

1. **X1 — Mandatory context reads (read in full):** same set as S1 — PROFILE, HANDOFF, NEXT, UNKNOWNS, active program `progress.md`.
2. **X2 — Uncommitted-aware snapshot (evidence):** run:

   ```bash
   git status -sb
   git diff --stat
   git diff --cached --stat
   git log -1 --oneline
   ```

   Classify the working tree:
   - **clean:** state explicitly; report last commit only.
   - **dirty:** summarize by area (`context/`, `plans/`, `programs/<slug>/`, `sessions/`, `labs/`, …); list staged vs unstaged vs untracked counts. **Do not** paste full diffs — paths + per-area counts only. Flag any path matching secrets-scan patterns (see C2) without printing content.
3. **X3 — Context report** (mandatory output):

```markdown
## Session context — <learner/program>

**Date:** <ISO date> · **Branch:** <branch> · **Working tree:** clean | dirty (N files)
**Last commit:** <sha - subject>
**Session:** Open | Closed - <date>

### Context loaded
| File | Result | Note |
|------|--------|------|
| context/PROFILE.md | pass (or missing) | level, program |
| context/HANDOFF.md | pass (or missing) | session status, open questions |
| plans/NEXT.md | pass (or missing) | |
| plans/UNKNOWNS.md | pass (or missing) | N open |
| programs/<slug>/progress.md | pass / skip | |

### Uncommitted status (read-only)
- Staged: <N> · Unstaged: <N> · Untracked: <N>
- Areas touched: <dirs with counts>
- Secrets scan: clean | <flagged paths (not printed)>
- (Clean tree → omit this section; state "working tree clean".)

### Pick up here
<quote recommended next from NEXT.md, or "no NEXT.md">

### Open blockers
<from HANDOFF / NEXT / UNKNOWNS, or none>

### No files written
This mode is read-only: HANDOFF, NEXT, and the session log are **not** modified. To open a session bookend, run `@mlt-session start`.
```

### Anti-patterns (context)

- Treating `context` as `start` (writing the HANDOFF Open line or creating a session log) — `context` writes nothing.
- Pasting raw `git diff` output (use per-area counts).
- Skipping the secrets-flag pass on a dirty tree.
- Claiming "context loaded" without reading the full X1 set.

---

## Steps — close mode

Execution order: summarize → finalize log → HANDOFF → NEXT → ledger → draft message → (commit/push protocols if invoked).

1. Summarize what was accomplished this session.
2. Write the session summary to the session log (rename to the final `YYYY-MM-DD_<topic-slug>.md` if the placeholder topic changed).
3. **Update HANDOFF:** set `**Session status:** Closed - <date> - <one-line outcome>`; refresh what was done, what was learned, what was left incomplete, key decisions. Append `--note` if provided.
4. **Update NEXT.md:** concrete next action, recommended skill to run next, blockers/prerequisites.
5. Tick completed items in the program's task ledger.
6. Draft the commit message (shown in the report; used only if the invocation includes `commit`).
7. **Close report** (mandatory output, template below).

If the invocation also includes `commit` / `push`, run the [Commit protocol](#commit-protocol) (then [Push protocol](#push-protocol)) **after** the writes above.

### Close report (mandatory output)

```markdown
## Session close — <topic>

**Session log:** .work.mlt/sessions/<log>.md
**HANDOFF:** updated (Session status: Closed) · **NEXT:** <one-line next action>
**Ledger:** <N items ticked in programs/<slug>/progress.md, or none>

### Accomplished
- <items, with artifact paths under .work.mlt/>

### Left incomplete / risks
- <items or none>

### Commit message
<drafted block, used + SHA, or `none - working tree clean`>

### Checklist
- [pass|fail] session log finalized
- [pass|fail] HANDOFF updated (Closed)
- [pass|fail] NEXT.md set
- [pass|fail|skip] ledger ticked
- [pass|fail|skip] commit ran in shell, SHA shown, scope resolved and fully staged
- [pass|fail|skip] push ran after commit, branch/remote reported
```

---

## Commit protocol

Execution order: **C1 → C2 → C3 → C4 → C5-report**. Runs whenever the invocation includes `commit` — after `close` when present, standalone otherwise. If C2 (secrets) fails, **stop** — do not commit, do not update HANDOFF/NEXT on close.

### C1 — Working-tree audit (mandatory)

Run:

```bash
git status -sb
git diff --stat
git diff --cached --stat
git log -1 --oneline
```

Classify findings: staged vs unstaged vs untracked, by area. Resolve and state the commit scope ([Commit scope resolution](#commit-scope-resolution-binding)). In **learner scope**, confirm every dirty path relevant to this session is under `.work.mlt/` — paths outside it are left untouched, never staged. In **framework scope** (self-hosted source), every dirty/untracked path in the repo is in scope.

### C2 — Secrets scan (mandatory)

Scan the to-be-staged paths for secrets / large artifacts (`.env*`, keys, tokens, `*.safetensors`, `*.gguf`, `*.bin`, `*.csv`, `*.jsonl`, `models/`, `datasets/`, `.venv*`). In framework scope this covers the whole repo tree. **On match: stop and report; do not commit.** No match → proceed.

### C3 — Draft commit message (mandatory, always shown)

**Learner scope:** subject `chore: <verb> MLT session — <topic>` where `<verb>` is `close` (close mode) or `checkpoint` (standalone commit), `<topic>` from the session agenda/module. Body (optional): 1–3 bullets of what the session produced, referencing artifact paths under `.work.mlt/`.

**Framework scope:** subject per the `.cursorrules` commit format (`type: description`, ≤72 chars, imperative) with the `type` matching the staged work (`feat` / `fix` / `refactor` / `docs` / `chore` / `test`) — do not force the `chore: close MLT session` template onto framework changes. Body: why, not the file list.

Example (learner scope):

```text
chore: close MLT session — gradient descent

- derived update rules by hand; ran gd_linreg.py lab
- .work.mlt/sessions/2026-08-05_grad-descent-walkthrough.md
```

### C4 — Git actions (only when the invocation includes `commit`)

**Learner scope (target repos):**

1. `git add -- .work.mlt/` — stages modified **and new untracked files/directories** under `.work.mlt/`; `.gitignore` stays respected (venvs, weights, datasets excluded). **Never** add paths outside `.work.mlt/`.
2. `git commit` with the drafted message (HEREDOC for multi-line). No `Co-authored-by:` trailers.
3. Verify: `git log -1 --oneline` shows the new SHA; `git status -sb` shows `.work.mlt/` clean.

**Framework scope (self-hosted source repo):**

1. `git add -A` — stages **all** modified and new untracked files repo-wide (`.gitignore` still respected). This is the correct behavior in the framework source: session work spans `skills/`, `templates/`, `curricula/`, docs, `.cursorrules`, and `.work.mlt/` together. A commit that leaves framework files behind is **fail**.
2. `git commit` with the drafted message (HEREDOC for multi-line). No `Co-authored-by:` trailers.
3. Verify: `git log -1 --oneline` shows the new SHA; `git status -sb` shows the tree clean.

**`scoped` modifier** (`close commit scoped` / `commit scoped`): stage **only** the bookend files instead of the resolved scope:

1. `git add -- .work.mlt/context/HANDOFF.md .work.mlt/plans/NEXT.md .work.mlt/sessions/<log>.md` plus the active program's `progress.md` if changed.
2. Same commit + verification as above. Other changes stay uncommitted — list them in the report as follow-ups.

If the resolved scope is already clean, state `none - working tree clean` and skip the commit.

### C5 — Commit report (mandatory output)

```markdown
## Commit report

**Scope:** framework (full repo) | learner (.work.mlt/) | scoped (bookend files)
**Message:** <used, or `none - working tree clean`>
**Commit:** <SHA - subject>
**Staged:** <N paths (by area), incl. N new>
**Left uncommitted:** <paths outside learner scope (untouched), or other paths on scoped; "none" on framework scope>

### Checklist
- [pass|fail] scope resolved and stated (framework / learner / scoped)
- [pass|fail] git add + git commit ran in shell
- [pass|fail] new SHA shown via git log -1 --oneline
- [pass|fail] all changed + untracked files in the resolved scope included
- [pass|fail] nothing outside a learner scope staged (n/a on framework scope)
- [pass|fail] no Co-authored-by trailers
```

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
| `close commit scoped` | ✅ | ✅ (bookend only) | — |
| `close commit push` / `close push` | ✅ | ✅ | ✅ |
| `commit` / `commit scoped` | — | ✅ | — |
| `commit push` / `push` | — | ✅ | ✅ |

Any order is accepted; the flags above define the behavior. `push` always implies `commit` of the changes in the resolved scope.

---

## Edge cases

| Situation | Behavior |
|-----------|----------|
| Merge conflict markers in tree | close checklist **fail**; list files |
| Only paths outside `.work.mlt/` changed | Learner scope: outside scope — session commit stages nothing; list as follow-up for a separate, user-driven commit. Framework scope: in scope — staged by `git add -A` |
| Secrets scan fail | **Halt** — no HANDOFF/NEXT/commit until resolved |
| Learner closes mid-topic | HANDOFF notes "in-flight: …" under open questions |
| HANDOFF already Open, new `start` with new goal | Set Open line to new goal + today's date; note prior goal in start report |
| HANDOFF says Open, `start` again same goal | Refresh date only; do not duplicate the session log |
| No session log found at `close` | Create one from the summary (never fabricate content — record what the operator reports) |
| `.work.mlt/` missing | Report not bootstrapped (`@mlt-bootstrap init`); stop |
| Push with no upstream | Report branch/upstream state; do not invent a remote |

---

## Wrong prompts

| Prompt | Problem | Use instead |
|--------|---------|-------------|
| `close` expecting auto-commit | Default is draft only | `close commit` |
| `close commit` but tree still dirty | Agent staged HANDOFF-only or skipped shell git | Re-run; default scope is the resolved scope (full repo on framework source, all of `.work.mlt/` in target repos) |
| `close commit` for bookend files only | Default commits the resolved scope | `close commit scoped` |
| `close push` without `commit` | Skill maps to commit+push | `close commit push` |
| `commit` expecting HANDOFF update | Standalone commit skips HANDOFF/NEXT | `close commit` |
| `commit push` expecting session close | Standalone commit keeps session open | `close commit push` |
| `context` expecting a session to open | `context` writes nothing | `start` |
| `start` without reading files | Skill requires evidence | Full start protocol |

---

## Anti-patterns

- Claiming "context loaded" without reading HANDOFF and NEXT.
- Closing a session without updating HANDOFF and NEXT (on **close**).
- `close commit` without running `git commit` or without showing a new SHA.
- Staging outside the resolved scope — app code in a target repo, or (framework scope) leaving repo files behind.
- Omitting the commit message block from close/commit reports.
- Writing anything on `context` or `status`.
- Adding `Co-authored-by:` trailers.

---

## Completion checklist (every non-read-only mode)

Each item: `pass` | `fail` | `skip` with evidence.

- **start:** baseline reads done, HANDOFF marked Open, session log created under `.work.mlt/sessions/`, agenda announced
- **close:** session log finalized, HANDOFF updated (Closed), NEXT.md set, task ledger ticked
- **commit:** scope resolved and stated; `git add` + `git commit` ran in the shell; new SHA shown; all changed + untracked files in the resolved scope included; in learner scope nothing outside `.work.mlt/` staged
- **push:** `git push` ran after a commit, branch/remote state reported
- **always:** commit message block shown (drafted, used, or `none - working tree clean`); no `Co-authored-by:` trailers
- **status / context:** read-only — no checklist; end with the mode's report template
