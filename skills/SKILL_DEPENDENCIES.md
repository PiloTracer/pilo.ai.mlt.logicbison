# Skill dependencies — gate graph

## Prerequisites

Skills may require prior state before they can execute. The gate graph below defines which skills block others. Gate names (`profile-ready`, `assessed`, `program-active`, `session-open`, `module-complete`, `program-complete`, `certified`) are defined in `.quick/gates.md` and used identically there and in `@mlt-review` reports.

```text
mlt-deploy-basic / mlt-deploy-files
                │
                ▼
          mlt-bootstrap
                │
                ├──► mlt-assess ──► mlt-review
                │       │
                │       └──► mlt-program-custom ──┐
                ├──► mlt-program-standard ────────┤
                │                                 ▼
                │                         (active program) ──► mlt-curriculum
                │                                 │
                ├──► mlt-session ─────────────────┴──► mlt-mentor
                │       (mlt-mentor needs BOTH an open session and an active program)
                ├──► mlt-lab
                ├──► mlt-drill
                ├──► mlt-tutorial
                └──► mlt-sources ──► mlt-update
```

## Gate table

| Skill | Gate | Requires | Unlock condition |
|-------|------|----------|-----------------|
| mlt-bootstrap | — | mlt-deploy-basic OR mlt-deploy-files | Framework assets accessible |
| mlt-assess | profile-ready | mlt-bootstrap (PROFILE exists) | `.work.mlt/context/PROFILE.md` present |
| mlt-program-standard | profile-ready | mlt-bootstrap | `.work.mlt/programs/` directory exists |
| mlt-program-custom | assessed | mlt-bootstrap, mlt-assess | PROFILE and scorecard exist |
| mlt-curriculum | program-active | mlt-program-standard OR mlt-program-custom | Active program in `.work.mlt/programs/` |
| mlt-session | profile-ready | mlt-bootstrap | PROFILE present |
| mlt-mentor | session-open + program-active | mlt-session (active), active program | Session open AND program installed |
| mlt-lab | profile-ready | mlt-bootstrap | `.work.mlt/` scaffolded |
| mlt-drill | profile-ready | mlt-bootstrap | `.work.mlt/` scaffolded |
| mlt-tutorial | profile-ready | mlt-bootstrap | `.work.mlt/` scaffolded |
| mlt-sources | profile-ready | mlt-bootstrap | `.work.mlt/sources/` directory exists |
| mlt-review | assessed | mlt-assess (scorecard exists) | Assessment completed at least once |
| mlt-update | — | mlt-sources | Source list exists in `.work.mlt/sources/` |

`module-complete`, `program-complete`, and `certified` are progress gates evaluated by `@mlt-review status` / `certify`, not entry gates — see `.quick/gates.md` for their criteria.

Gate-free skills (`mlt-director`, `mlt-process-router`) are intentionally absent from the gate graph — they have no prerequisites.

## Operator handoff contract

Every operator-facing response that completes a task must close so the operator immediately knows what — if anything — is needed from them. Canonical rules:

- **Terse output.** Report only what changed and what's needed next. No restating the task, no filler.
- **Approvals** go under `**Needs your approval:**` as a numbered list, one decision per item, each citing the exact location: `path/to/file.md:L<n>`.
- **Questions** go under `**Needs your answer:**` as a numbered list, each self-contained. Never mix decisions and questions in one list.
- **Exactly one** `**Next step:**` — the immediate command or action, in the exact syntax to run. Later steps are mentioned only if asked.
- **Form A (nothing needed):** a single line, e.g. `Next: nothing - work complete`. No empty sections.
- **Form B (input needed):** summary, then the labeled sections above; omit any section that has nothing in it.
- Report-internal sections ("Follow-ups", "Remaining") never substitute for the close — any operator-required approval or question inside them must also appear in the labeled closing sections.

Full protocol: `.work.mlt/prompts/improve-clarity-of-responses.md`.

## Document clarity contract

Every generated document (program, module, tutorial, lab, drill result, scorecard, session log, review report, source list) must make its state and next step obvious:

- **Status/Needs header (≤4 lines):** what the document is (one sentence), **Status** (`Draft` | `In review` | `Approved` | `Superseded` + date), and what it **Needs** (the decision/review, or nothing).
- **Decisions / Open questions in separate lists** — numbered, each self-contained; never mixed, never buried in prose.
- **Exactly one `## Next action`** — the immediate command in exact syntax. If nothing is needed, one line instead: `Next action: none — <reason>`.
- **No leftover scaffolding** — `REPLACE:*` tokens and instructional placeholders must be filled or stripped before a document is presented as complete.
- Claims cite `path:L<n>` where they derive from files; quantitative claims are tagged `measured` | `estimated` | `assumption` | `unknown`.

Full protocol: `.work.mlt/prompts/improve-clarity-of-documentation.md`.

## BLOCKED report format

When a skill is blocked, emit this exact structure:

```text
BLOCKED: <skill-name> <verb>
  reason: <short reason>
  missing: <list of missing prerequisites>
  unlock: <command or action to resolve>
```

### Example

```text
BLOCKED: mlt-assess run
  reason: PROFILE.md not found
  missing: .work.mlt/context/PROFILE.md
  unlock: @mlt-bootstrap init
```

## Resolution

1. Read the BLOCKED report
2. Run the unlock command shown
3. Re-run the originally requested skill
4. If the unlock itself is blocked, recurse until a runnable skill is found
