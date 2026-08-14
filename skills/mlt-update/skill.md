---
name: mlt-update
description: "Continuous learning refresh — scan for new tools, papers, and techniques in ML/LLM space and update sources."
---

# mlt-update — continuous learning refresh

> **Close:** operator-facing reports end per the **Operator handoff contract** (`skills/SKILL_DEPENDENCIES.md`) — Form A (`Next: nothing - …`) or Form B (`**Needs your approval:**` / `**Needs your answer:**` / `**Next step:**`).
> **Docs:** generated documents follow the **Document clarity contract** (`skills/SKILL_DEPENDENCIES.md`) — Status/Needs header, separate Decisions / Open questions lists, exactly one `## Next action`, no leftover scaffolding.

## Modes

| Mode | Invocation | Effect |
|------|-----------|--------|
| run | `@mlt-update run` | Scan and update source collection |

## Parse

```text
@mlt-update run [--topic <topic>] [--since <date>]
```

- `--topic`: focus on a specific area (e.g., `llm`, `training`, `inference`, `agents`)
- `--since`: only look for developments since this date (default: 3 months ago)

## Binding standard

Follow `standards/citation.md` for source verification.

## Steps

1. Read `.work.mlt/context/PROFILE.md` for learner interests and goals
2. Read `.work.mlt/sources/sources.md` for currently tracked sources
3. Read `references/core-library.md` for the canonical knowledge base
4. For each active topic area (or `--topic` if specified):
   - Identify key developments since `--since` date:
     - New framework releases or major version updates (PyTorch, Transformers, TRL, Unsloth)
     - Significant papers (new architectures, training methods, evaluation techniques)
     - New tools or libraries gaining adoption
     - Updated best practices or deprecations
   - For each development found:
     - Verify with a real, accessible source
     - Classify: new tool, paper, technique, deprecation, update
     - Assess relevance to the learner's profile and program
5. Generate an update report under `.work.mlt/sources/UPDATE-<date>.md`:

### Update report format

```markdown
# Learning Update — <date>

## New developments

### <Topic area>
- **<Development name>**: <one-line summary>
  - Source: <title, author, URL>
  - Relevance: <why this matters to the learner>
  - Action: <explore|read|install|ignore>

## Deprecations
- <What changed and what to use instead>

## Recommended source additions
| Title | Author | URL | Topic | Reason |
|-------|--------|-----|-------|--------|

## Sources to retire
| Source ID | Title | Reason |
|-----------|-------|--------|
```

6. Present the report to the learner
7. On learner approval, apply changes to `.work.mlt/sources/sources.md`
8. If the learner has an active program, flag any modules that should be updated

## Completion criteria

- Update report written to `.work.mlt/sources/UPDATE-<date>.md`
- Each development has a real, verified source
- Report includes additions, deprecations, and retirement recommendations
- sources.md updated on learner approval
- Active program modules flagged if content is outdated
