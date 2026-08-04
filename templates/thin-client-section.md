# MLT Training OS (thin-client)

MLT (Machine Learning and AI Training) skills are available from the source framework. Use them for ML/LLM training programs, tutorials, labs, drills, and mentoring.

TRAINER_MLT_SOURCE=REPLACE_BASICSOURCE

- **Full ruleset (mandatory before non-trivial MLT work):** `$TRAINER_MLT_SOURCE/.cursorrules` — change-safety gates, skills table, protected files, workflow rules.
- **Entry points:** `$TRAINER_MLT_SOURCE/START_HERE.md` (decision tree) · `$TRAINER_MLT_SOURCE/PROCESS_ROUTER.md` (how-to → skill map).
- **Skills:** `$TRAINER_MLT_SOURCE/skills/` — invoke as `@mlt-bootstrap init`, `@mlt-assess run`, `@mlt-program-standard install - <slug>`, `@session-mlt start`, `@mlt-mentor run`, etc.
- **Learner memory (local):** `.training.mlt/` in this repo — profile, programs, sessions, labs, tutorials, drills. Never write MLT learner artifacts outside it.
- **Alias collisions:** if this contract already binds `{HANDOFF}` / `{NEXT}` to another framework, do not rebind them — use namespaced aliases instead: `{MLT_HANDOFF}` = `.training.mlt/context/HANDOFF.md` · `{MLT_NEXT}` = `.training.mlt/plans/NEXT.md`.
- If `$TRAINER_MLT_SOURCE` is unreachable: stop and report `pilo.trainer.mlt source unreachable: $TRAINER_MLT_SOURCE`.
