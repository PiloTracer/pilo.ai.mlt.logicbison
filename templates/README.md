# MLT Templates

Reusable templates for bootstrapping and deployment.

## Contents

| File | Purpose |
|------|---------|
| `bootstrap.sh` | Scaffolds `.training.mlt/` directories and learner memory |
| `cursorrules.template` | `.cursorrules` template with `REPLACE:` tokens for thin-client deploy |
| `thin-client-section.md` | Additive MLT section merged into a target's existing `.cursorrules` on `--update` |
| `training/` | Learner memory templates (PROFILE, HANDOFF, NEXT, UNKNOWNS) |

## Usage

Templates are consumed by skills:

- `@deploy-basic` copies `cursorrules.template` + runs `bootstrap.sh` (via `scripts/deploy-basic.sh`)
- `@mlt-bootstrap init` scaffolds the same layout (mechanically via `bootstrap.sh` when available) + drives the PROFILE interview
- `@deploy-files` copies the entire framework tree

## Adding templates

Place new templates under `training/` and reference them from `bootstrap.sh`.
