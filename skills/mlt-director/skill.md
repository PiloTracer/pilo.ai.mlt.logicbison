---
name: mlt-director
description: "Free-text orchestrator — takes a natural language description, parses intent, checks prerequisites, and dispatches to the right skill."
---

# mlt-director — free-text orchestrator

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
   - "start session", "begin training" → session-mlt start
   - "teach me", "mentor", "learn about" → mlt-mentor
   - "tutorial", "explain how to" → mlt-tutorial
   - "lab", "hands-on", "build" → mlt-lab
   - "drill", "practice", "exercise" → mlt-drill
   - "progress", "how am I doing", "certify" → mlt-review
   - "sources", "references", "reading" → mlt-sources
   - "update", "new tools", "trends" → mlt-update
   - "close session", "wrap up" → session-mlt close
   - "deploy", "copy to project" → deploy-basic / deploy-files
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
