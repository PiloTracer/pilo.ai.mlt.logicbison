# Contributing to pilo.trainer.mlt

## How to Contribute

### Adding a New Curriculum

1. Create `curricula/<slug>.md` following `standards/program-spec.md`
2. Include: metadata, audience, outcomes, modules, assessment, exit criteria
3. Add entry to `curricula/README.md`
4. Reference real sources with URLs
5. Ensure all labs run locally

### Adding a New Skill

1. Create `skills/mlt-<name>/skill.md` with YAML frontmatter
2. Follow naming convention: `mlt-` prefix, kebab-case
3. Register in `skills/README.md`
4. Add dependencies to `skills/SKILL_DEPENDENCIES.md`
5. Add entry to `.cursorrules` skills table

### Adding a New Standard

1. Create `standards/<name>.md`
2. Add reference in `PROCESS_ROUTER.md` binding standards table
3. Keep it specific and binding (not advisory)

### Adding Drills

1. Add entry to `drills/case-library.md` with ID, title, duration, program
2. Create `drills/lab-templates/<id>-<slug>.md` with full lab instructions
3. Include: prerequisites, setup, code, expected output, troubleshooting, cleanup

### Adding References

1. Add to `references/core-library.md` with title, author, URL, description
2. Verify URL is accessible
3. Prefer recent, authoritative sources

## Code of Conduct

- Evidence over vibes
- Local-first (no cloud-only solutions)
- Citation honesty (no invented references)
- Correct misconceptions, don't enable them
