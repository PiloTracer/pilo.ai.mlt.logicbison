---
name: mlt-process-router
description: "Read-only signpost — answers 'how do I...' questions by mapping to existing skills without inventing new ones."
---

# mlt-process-router — read-only signpost

## Modes

| Mode | Invocation | Effect |
|------|-----------|--------|
| route | `@mlt-process-router - <question>` | Map question to skill |

## Parse

```text
@mlt-process-router - <how-do-I question>
```

## Rules

1. Never invent a new skill. If no existing skill matches, say so.
2. Return the exact skill invocation command, not a paraphrase.
3. If the question matches multiple skills, list all matches with brief context.
4. Reference `PROCESS_ROUTER.md` as the canonical mapping source.

## Steps

1. Read the user's question
2. Consult the mapping table in `PROCESS_ROUTER.md`
3. Match the question against the "You want to..." column:
   - Exact match → return the corresponding "Run" command
   - Close match → return the closest command with a note about the gap
   - No match → report "No skill matches this request" and suggest `@mlt-director - <description>` for orchestration
4. If the question is about understanding framework structure, point to:
   - `START_HERE.md` for the decision tree
   - `skills/README.md` for the full registry
   - `skills/SKILL_DEPENDENCIES.md` for prerequisites
5. If the question is about a binding standard, point to the relevant file in `standards/`

## Response format

```text
Q: <user question>
A: <skill invocation command>
   <one-line explanation>
   <link to skill or standard if relevant>
```

### Examples

```text
Q: How do I set up a hands-on lab for fine-tuning?
A: @mlt-lab setup - fine-tuning
   Prepares an isolated environment with guided steps for the topic.
   See skills/mlt-lab/skill.md

Q: How do I check if I'm ready for the next program?
A: @mlt-review status
   Checks task ledger, drill scores, and exit criteria.
   See skills/mlt-review/skill.md
```

## Completion criteria

- Every response maps to an existing skill or explicitly states no match
- No new skills are invented or implied
- Response includes the exact invocation command
