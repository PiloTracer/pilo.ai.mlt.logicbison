# MLT Training OS (thin-client)

MLT (Machine Learning and AI Training) skills are available from the source framework. Use them for ML/LLM training programs, tutorials, labs, drills, and mentoring.

TRAINER_MLT_SOURCE=REPLACE_BASICSOURCE

- **Full ruleset (mandatory before non-trivial MLT work):** `$TRAINER_MLT_SOURCE/.cursorrules` — change-safety gates, skills table, protected files, workflow rules.
- **Entry points:** `$TRAINER_MLT_SOURCE/START_HERE.md` (decision tree) · `$TRAINER_MLT_SOURCE/PROCESS_ROUTER.md` (how-to → skill map).
- **Skills:** `$TRAINER_MLT_SOURCE/skills/` — invoke as `@mlt-bootstrap init`, `@mlt-assess run`, `@mlt-program-standard install - <slug>`, `@mlt-session start`, `@mlt-mentor run`, etc.
- **Learner memory (local):** `.work.mlt/` in this repo — context (profile, handoff), plans, programs, sessions, sources, labs, tutorials, drills, exports. Never write MLT learner artifacts outside it. Session logs follow `YYYY-MM-DD_<topic-slug>.md` naming; labs live under `labs/<topic>/`.
- **Alias collisions:** if this contract already binds `{HANDOFF}` / `{NEXT}` to another framework, do not rebind them — use namespaced aliases instead: `{MLT_HANDOFF}` = `.work.mlt/context/HANDOFF.md` · `{MLT_NEXT}` = `.work.mlt/plans/NEXT.md`.
- **Clarity contracts:** operator-facing replies close per the **Operator handoff contract** and generated documents follow the **Document clarity contract** — both in `$TRAINER_MLT_SOURCE/skills/SKILL_DEPENDENCIES.md`.
- If `$TRAINER_MLT_SOURCE` is unreachable: stop and report `pilo.trainer.mlt source unreachable: $TRAINER_MLT_SOURCE`.
