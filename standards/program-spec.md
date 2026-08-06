# Program specification standard

Binding for program structure and organization.

## Program structure

Every program in `curricula/` must include:

### Metadata

```markdown
# Program Name

**Slug:** `program-slug`
**Duration:** X weeks · Y sessions/week
**Level:** Beginner / Intermediate / Advanced (bridging labels like "Intermediate-Advanced" are allowed)
**Prerequisites:** (list or "none")
```

### Audience / level assumptions

- Who this program is for
- What they should already know
- Common failure modes or misconceptions

### Duration & cadence

- Total duration in weeks
- Sessions per week
- Session length (typical)
- Async work (drills, labs, reading)

### Outcomes

List 3-5 specific, measurable outcomes:
- What the learner will be able to do
- What artifacts they will produce
- What concepts they will understand

### Modules

Each module includes:
- **Objectives**: What this module teaches
- **Content**: Topics covered
- **Lab/Drill**: Hands-on exercise
- **Sources**: Required reading and references
- **Exit check**: How to verify mastery

### Assessment

| Criterion | Pass condition |
|-----------|----------------|
| (criterion) | (measurable condition) |

### Exit criteria

All module exit checks met; artifacts stored under `.work.mlt/` and linked from the task ledger.

## Naming conventions

- Slug: kebab-case, descriptive (e.g., `llm-finetuning`)
- File: `<slug>.md` in `curricula/`
- No version numbers in slug (use git history)

## Program dependencies

If a program has prerequisites, specify:
- Required program slug(s)
- Required scope of the prerequisite (e.g. "all modules") and whether certification (`@mlt-review certify`) is required

## Customization

When installing a program to `.work.mlt/programs/<slug>/`:
1. Copy the curriculum file
2. Create `PROGRAM.md` with learner-specific notes
3. Create `progress.md` with task ledger
4. Create `notes.md` for retrieval queue

## Quality bar

A good program:
- Has clear, measurable outcomes
- Provides hands-on labs for every module
- Uses current tools and best practices
- Includes troubleshooting guidance
- References authoritative sources
- Can be completed on a local workstation
