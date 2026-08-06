# Skills registry — MLT Agent OS Framework

## Naming protocol

All MLT-specific skills use the `mlt-` prefix. Deployment skills and the session skill use unprefixed names for cross-framework reuse.

## Canonical verbs

| Verb | Meaning |
|------|---------|
| `init` | Scaffold or initialize from scratch |
| `start` | Open a lifecycle (session) |
| `run` | Execute the skill's primary action |
| `list` | Enumerate available options |
| `install` | Copy from catalog into learner memory |
| `status` | Report current state without mutation |
| `close` | Finalize and write handoff |
| `add` / `remove` | Modify a collection |
| `curate` | Review and improve existing entries |
| `generate` | Produce new content from a prompt |
| `setup` | Prepare an environment or resource |
| `design` | Create or refine structure |
| `refine` | Iterate on existing content |
| `certify` | Evaluate against gate criteria |
| `copy` / `clone` / `archive` | Deploy framework assets |
| `prepare` | Pre-session planning |
| `update` | Re-sync or refresh |

## Skill registry

| Skill | Folder | Verbs | Purpose |
|-------|--------|-------|---------|
| deploy-basic | `skills/deploy-basic/` | `- <path>`, `--update`, `--force` | Thin-client bootstrap |
| deploy-files | `skills/deploy-files/` | `copy - <path>` | Fat-client vendor |
| deploy-repo | `skills/deploy-repo/` | `clone`, `archive` | Full repo deploy |
| mlt-bootstrap | `skills/mlt-bootstrap/` | `init`, `status` | Scaffold `.training.mlt/`, PROFILE |
| session-mlt | `skills/session-mlt/` | `start`, `status`, `close` | Session lifecycle |
| mlt-director | `skills/mlt-director/` | `- <text>` | Free-text orchestrator |
| mlt-process-router | `skills/mlt-process-router/` | `- <question>` | Read-only signpost |
| mlt-assess | `skills/mlt-assess/` | `run` | Diagnostic assessment |
| mlt-program-standard | `skills/mlt-program-standard/` | `list`, `install - <slug>` | Install catalog program |
| mlt-program-custom | `skills/mlt-program-custom/` | `- <request>` | Design bespoke program |
| mlt-curriculum | `skills/mlt-curriculum/` | `design`, `refine` | Module design / sequencing |
| mlt-mentor | `skills/mlt-mentor/` | `run`, `prepare` | Mentoring sessions |
| mlt-lab | `skills/mlt-lab/` | `setup - <topic>` | Hands-on lab setup |
| mlt-tutorial | `skills/mlt-tutorial/` | `generate - <topic>` | Tutorial generation |
| mlt-drill | `skills/mlt-drill/` | `run - <type>`, `list` | Practical drills |
| mlt-sources | `skills/mlt-sources/` | `add`, `remove`, `list`, `curate` | Source curation |
| mlt-update | `skills/mlt-update/` | `run` | Continuous learning refresh |
| mlt-review | `skills/mlt-review/` | `status`, `certify` | Progress + gate certification |

## Typical greenfield sequence

1. `@deploy-basic - /path/to/new-project` (from source repo)
2. `@mlt-bootstrap init`
3. `@mlt-assess run`
4. `@mlt-program-standard install - <slug>` or `@mlt-program-custom - <request>`
5. `@session-mlt start` then `@mlt-mentor run`
6. `@session-mlt close`

## Framework assets table

| Asset | Path | Layer |
|-------|------|-------|
| Skills | `skills/` | Framework |
| Curricula | `curricula/` | Framework |
| Standards | `standards/` | Framework |
| References | `references/` | Framework |
| Drills | `drills/` | Framework |
| Templates | `templates/` | Framework |
| Scripts | `scripts/` | Framework |
| Learner memory | `.training.mlt/` | Learner |
| Agent contract | `.cursorrules` | Local |
