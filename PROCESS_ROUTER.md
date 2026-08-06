# Process router — how-to → skill

**Read-only signpost.** Prefer `@mlt-process-router - <question>` so the agent follows this map without inventing new skills.

| You want to… | Run |
|--------------|-----|
| Scaffold learner memory | `@mlt-bootstrap init` |
| Open / close a training day | `@session-mlt start` / `close` |
| Describe a goal in plain language | `@mlt-director - <text>` |
| Diagnose level and gaps | `@mlt-assess run` |
| List catalog programs | `@mlt-program-standard list` |
| Install a catalog program | `@mlt-program-standard install - <slug>` |
| Design a bespoke program | `@mlt-program-custom - <request>` |
| Refine modules / sequencing | `@mlt-curriculum design` / `refine` |
| Run a mentoring session | `@mlt-mentor run` |
| Prep tomorrow's session | `@mlt-mentor prepare` |
| Generate a tutorial | `@mlt-tutorial generate - <topic>` |
| Set up a hands-on lab | `@mlt-lab setup - <topic>` |
| Practical drill | `@mlt-drill run - <type>` — cases in [`drills/case-library.md`](drills/case-library.md) |
| See what's done vs pending | `@mlt-review status` (short) · `status --full` (detail) |
| Add or curate sources | `@mlt-sources add` / `curate` — start from [`references/core-library.md`](references/core-library.md) |
| Refresh continuous learning | `@mlt-update run` |
| Check gates / progress | `@mlt-review status` / `certify` |
| Deploy into another project | `@deploy-basic - /path` |
| Re-sync an existing deploy | `@deploy-basic - /path --update` |
| Vendor framework into project | `@deploy-files copy - /path` |
| Standalone copy or backup of the framework | `@deploy-repo clone - <url> <target>` / `archive - <dir>` |

**Blocked on a gate?** Read [`skills/SKILL_DEPENDENCIES.md`](skills/SKILL_DEPENDENCIES.md) and run the unlock command shown in the BLOCKED report.

**Binding standards** — read the one that matches the work, not all of them:

| Standard | Binds |
|----------|-------|
| [`mentoring.md`](standards/mentoring.md) | Session structure, retrieval opening |
| [`assessment.md`](standards/assessment.md) | Scoring anchors, drill rubric, gate criteria |
| [`lab-safety.md`](standards/lab-safety.md) | Lab environment setup, safety, resource limits |
| [`code-quality.md`](standards/code-quality.md) | Code standards for ML/LLM projects |
| [`citation.md`](standards/citation.md) | Any external claim |
| [`program-spec.md`](standards/program-spec.md) | Program structure |
