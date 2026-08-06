---
name: mlt-sources
description: "Source curation — add, remove, or curate learning sources with references to references/core-library.md."
---

# mlt-sources — source curation

## Modes

| Mode | Invocation | Effect |
|------|-----------|--------|
| add | `@mlt-sources add - <source>` | Add a learning source |
| remove | `@mlt-sources remove - <source-id>` | Remove a source |
| curate | `@mlt-sources curate` | Review and improve the source collection |
| list | `@mlt-sources list` | Show all tracked sources |

## Parse

```text
@mlt-sources add - <title> [--author <name>] [--url <link>] [--topic <topic>] [--type <book|course|paper|tutorial|video|repo>]
@mlt-sources remove - <source-id>
@mlt-sources curate [--topic <topic>]
@mlt-sources list [--topic <topic>]
```

## Binding standard

Follow `standards/citation.md` for source verification and format.

## Steps — add mode

1. Verify the source exists and is accessible:
   - If URL provided, confirm it resolves
   - Confirm author/organization is credible
   - Check it is not already in `.work.mlt/sources/sources.md`
2. Classify the source:
   - Type: book, course, paper, tutorial, video, repo
   - Topic: which dimension(s) it covers (Math, Python, ML, DL, LLMs, Tools, Deployment)
   - Level: beginner, intermediate, advanced
   - Quality rating: acceptable, good, excellent
3. Append to `.work.mlt/sources/sources.md` with:
   - ID (auto-incrementing)
   - Title, author, URL, date accessed
   - Type, topic, level, quality rating
   - One-line summary of what it covers
4. Cross-reference with `references/core-library.md` — note if it fills a gap

## Steps — remove mode

1. Find the source by ID in `.work.mlt/sources/sources.md`
2. Confirm with user before removing
3. Remove the entry, preserve numbering for other entries

## Steps — curate mode

1. Read `.work.mlt/sources/sources.md`
2. Read `references/core-library.md` for the canonical library
3. For each tracked source:
   - Check if URL still resolves
   - Check if content is outdated (>2 years for rapidly evolving topics)
   - Identify duplicates or near-duplicates
   - Flag sources that should be replaced by newer alternatives
4. Propose additions from `references/core-library.md` not yet tracked
5. Generate a curation report:
   - Sources to keep, update, remove, add
   - Coverage gaps by topic

## Steps — list mode

1. Read `.work.mlt/sources/sources.md`
2. Render table filtered by `--topic` if specified

## Completion criteria

- add: source verified, appended to sources.md with full metadata
- remove: source deleted after confirmation
- curate: curation report generated with keep/update/remove/add recommendations
- list: table rendered with current sources
