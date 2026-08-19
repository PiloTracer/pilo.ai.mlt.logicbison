---
name: mlt-director
description: "Free-text orchestrator — takes a natural language description, parses intent, checks prerequisites, and dispatches to the right skill."
---

# mlt-director — free-text orchestrator

> **Close:** operator-facing reports end per the **Operator handoff contract** (`skills/SKILL_DEPENDENCIES.md`) — Form A (`Next: nothing - …`) or Form B (`**Needs your approval:**` / `**Needs your answer:**` / `**Next step:**`).

## Modes

| Mode | Invocation | Effect |
|------|-----------|--------|
| dispatch | `@mlt-director - <description>` | Parse intent and route to skill |

## Parse

```text
@mlt-director - <natural language description>
```

Accepts any free-text description of what the learner wants to do. No strict syntax required.

## Steps

1. Read the user's free-text description
2. Parse intent by matching against known skill capabilities:
   - "set up", "initialize", "start fresh" → mlt-bootstrap
   - "what's my level", "assess", "diagnose" → mlt-assess
   - "install program", "use standard program" → mlt-program-standard
   - "custom program", "design a program for" → mlt-program-custom
   - "module order", "reorder modules", "refine the curriculum" → mlt-curriculum
   - "which skill", "how do I", "what should I run" → mlt-process-router
   - "start session", "begin training" → mlt-session start
   - "context", "orient me", "where am I" → mlt-session context / status
   - "checkpoint", "commit session work", "push" → mlt-session commit / commit push
   - "teach me", "mentor", "learn about" → mlt-mentor
   - "tutorial", "explain how to" → mlt-tutorial
   - "lab", "hands-on", "build" → mlt-lab
   - "drill", "practice", "exercise" → mlt-drill
   - "progress", "how am I doing", "certify" → mlt-review
   - "sources", "references", "reading" → mlt-sources
   - "update", "new tools", "trends" → mlt-update
   - "close session", "wrap up" → mlt-session close
   - "deploy", "copy to project" → mlt-deploy-basic / mlt-deploy-files
3. If intent is ambiguous, list the top 2-3 candidate skills and ask the user to clarify
4. Check prerequisites using the gate graph in `skills/SKILL_DEPENDENCIES.md`
5. If a prerequisite is missing, emit a BLOCKED report with the unlock command
6. If prerequisites are met, dispatch by reading the target skill's `skill.md` and following its steps
7. If the description spans multiple skills, propose a sequence and ask for confirmation before executing

## Completion criteria

- User's intent is mapped to exactly one skill (or a confirmed sequence)
- Prerequisites are verified
- Dispatched skill is either executing or a BLOCKED report is shown with the unlock path
- If ambiguous, the user was asked to clarify with specific options
