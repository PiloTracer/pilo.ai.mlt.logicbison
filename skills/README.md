# Skills registry — MLT Agent OS Framework

## Naming protocol

All MLT skills use the `mlt-` prefix. Deployment skills are `mlt-deploy-basic`, `mlt-deploy-files`, `mlt-deploy-repo`; the session lifecycle skill is `mlt-session`.

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
| mlt-deploy-basic | `skills/mlt-deploy-basic/` | `- <path>`, `--update`, `--force`, `status` | Thin-client bootstrap + target `.cursorrules` verification |
| mlt-deploy-files | `skills/mlt-deploy-files/` | `copy - <path>` | Fat-client vendor |
| mlt-deploy-repo | `skills/mlt-deploy-repo/` | `clone`, `archive` | Full repo deploy |
| mlt-bootstrap | `skills/mlt-bootstrap/` | `init`, `status` | Scaffold `.work.mlt/`, PROFILE |
| mlt-session | `skills/mlt-session/` | `start`, `status`, `close`, `commit`, `push` | Session lifecycle + scoped commit/push |
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

1. `@mlt-deploy-basic - /path/to/new-project` (from source repo)
2. `@mlt-bootstrap init`
3. `@mlt-assess run`
4. `@mlt-program-standard install - <slug>` or `@mlt-program-custom - <request>`
5. `@mlt-session start` then `@mlt-mentor run`
6. `@mlt-session close`

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
| Learner memory | `.work.mlt/` | Learner |
| Agent contract | `.cursorrules` | Local |
