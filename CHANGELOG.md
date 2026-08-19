# Changelog

## [0.6.2] - 2026-08-19

### Removed
- `mlt-deploy-repo` skill (`skills/mlt-deploy-repo/`) — no longer used; clone/archive of the framework is plain `git clone` / filesystem archive. All references stripped: `.cursorrules` skills table, `skills/README.md` registry + naming protocol + canonical verbs, `skills/SKILL_DEPENDENCIES.md` gate graph, `skills/mlt-director` routing, `PROCESS_ROUTER.md`, `scripts/mlt-cursorrules-verify.sh` self-hosted layout notes. Registry congruence preserved (verified by `scripts/framework-verify.sh`).

## [0.6.1] - 2026-08-19

### Added
- Sister-framework discovery for deploy/verify (homogenization with the Agent OS family): `scripts/sister-discovery.sh` — shared discovery lib, byte-identical to `pilo.ai.logicbison` (family naming `pilo.ai.<fw>.logicbison` + legacy `.ai.<fw>`, slot-replace rule); Frameworks registry in `.cursorrules` + `templates/cursorrules.template` (self + 5 sisters; `REPLACE:AI_*_PATH` cells filled at deploy time by `mlt-deploy-basic.sh`, unfilled tokens left for manual fill / runtime auto-discover); `mlt-cursorrules-verify.sh` six-slot checks — `--fix` fills open tokens and re-points stale baked paths, checks report reachable / STALE / not installed; `framework-verify.sh` sister section (lib presence + syntax, `sister_names` smoke, deploy/verify parity); `standards/PROTECTED_SURFACES.json` — machine-readable high-blast paths (resolves the dangling `agent.os.framework.md` citation)
- `mlt-session`: repo-context-aware commit scope — in the self-hosted framework source repo (detected via `.cursorrules` pilo.trainer.mlt identity + local `skills/` + unset `TRAINER_MLT_SOURCE`) `commit` / `close commit [push]` stage **all** modified/added/new files (`git add -A`); target repos (thin/fat-client) keep the strict `.work.mlt/`-only scope; ambiguous repos default to `.work.mlt/`-only. `scoped` still narrows to bookend files; framework-scope messages follow the `.cursorrules` `type: description` format. Synced: `.cursorrules` git exception, `PROCESS_ROUTER.md`, `skills/README.md`
- `mlt-session`: `context` mode — read-only full context load (PROFILE, HANDOFF, NEXT, UNKNOWNS, program progress) with uncommitted-aware git snapshot and secrets-flag pass; writes nothing. `scoped` commit modifier — `close commit scoped` / `commit scoped` stage bookend files only (HANDOFF + NEXT + session log + program ledger) instead of the full `.work.mlt/` default scope. Verb aliases (`begin`/`open` → start, `end`/`handoff` → close), goal text after `-` on `start` (equivalent to `--agenda`), natural-language trigger table, structured start/status/context/close/commit report templates, mode-comparison matrix, edge-case and wrong-prompt tables — aligned with the `session-control` skill contract
- HANDOFF templates (`templates/training/HANDOFF.md`, `.work.mlt/context/HANDOFF.md`): `**Session status:**` line — `mlt-session start` marks `Open - <date> - <agenda>`, `close` marks `Closed - <date> - <outcome>`
- `scripts/mlt-cursorrules-verify.sh` — verifies (and with `--fix` repairs) a deployed target's `.cursorrules` against the current framework source: `TRAINER_MLT_SOURCE` filled/reachable/valid root, fat-client `.ai.mlt/` asset completeness, self-hosted clone integrity, `.work.mlt/` skeleton, duplicate-section and alias-collision detection, remaining `REPLACE:` tokens; exit non-zero on FAIL
- `mlt-deploy-basic`: `status` mode (read-only verification report) and mandatory post-deploy verification — every deploy/update ends with `mlt-cursorrules-verify.sh`; `update` re-syncs a stale `TRAINER_MLT_SOURCE` via `--fix`
- `mlt-deploy-files` / `mlt-deploy-repo`: mandatory verification step (`--fat` / self-hosted layouts) in the skill contract

### Changed
- Frameworks registry carries **no parent row**: the Agent OS orchestrator (`pilo.ai.logicbison` / `.ai`) routes INTO this framework; this framework never routes back, so no `.ai` contact path is kept (owner decision)
- `scripts/mlt-deploy-basic.sh`: full argument normalization — verbs accept the `--` prefix or bare form (`update` ≡ `--update`, `status` ≡ `--status`, `force` ≡ `--force`), `-` / `--` separators ignored, target path accepted in any position; `MLT_SOURCE` env override for the source root
- Deploy skill docs (`mlt-deploy-basic`, `mlt-deploy-files`, `mlt-deploy-repo`): explicit argument-equivalence contracts so `@mlt-deploy-basic "/path" update` is identical to `@mlt-deploy-basic /path --update`

### Fixed
- `agent.os.framework.md`: detection line now cites `mlt-session` (was the Agent OS `session-control` name, copied verbatim from the family text)

## [0.2.0] - 2026-08-06

### Changed
- Working directory renamed `.training.mlt` → `.work.mlt` framework-wide (folders, `.cursorrules` placeholder map `{TRAINING_ROOT}` → `{WORK_ROOT}`, templates, scripts, docs, curricula, standards, lab templates, example memory) — the session skill and all learner artifacts now scope to `.work.mlt/` in the target repo
- `mlt-session` extended: `close` / `commit` / `push` parameters in any combination (`close commit`, `close commit push`, `close push`, `commit`, `commit push`, `push`); git ops are strictly scoped to `.work.mlt/` (never app code), `commit` stages new untracked files/dirs under `.work.mlt/`, `push` requires commit; `.cursorrules` git rule documents the `@mlt-session` exception
- Skill names standardized under the `mlt-` prefix: `deploy-basic` → `mlt-deploy-basic`, `deploy-files` → `mlt-deploy-files`, `deploy-repo` → `mlt-deploy-repo`, `session-mlt` → `mlt-session`. Updated everywhere: skill folders + `name:` frontmatter, `@`-invocations, `skills/README.md` registry + naming protocol, `skills/SKILL_DEPENDENCIES.md` gate graph, `.cursorrules` / `cursorrules.template` skills table + routing notes, `START_HERE.md`, `PROCESS_ROUTER.md`, `README.md`, docs, templates, and the script `scripts/deploy-basic.sh` → `scripts/mlt-deploy-basic.sh`

### Added
- `mlt-session`: explicit binding file-boundary section — in a target (client) repo, `start` / `status` / `close` touch only files under `.work.mlt/`; exception: outside files may be read/referenced when the session context (log, HANDOFF, NEXT, ledger) is already aware of related changes — never written; `.quick/` views remain owned by `mlt-review`

## [0.1.0] - 2026-08-05

First public release.

### Added (release hardening)
- `scripts/install.sh` — one-command Linux setup: environment check, framework verification, optional deploy to a target project
- Canonical session & lab tracking contract: session logs named `YYYY-MM-DD_<topic-slug>.md` (one log per session, shared by mlt-session/mlt-mentor/mlt-lab/mlt-drill); lab artifacts under `.work.mlt/labs/<topic>/`; `mlt-review` now cross-verifies lab ledger entries against actual artifact directories
- `mlt-lab` and `mlt-drill` now consume `drills/lab-templates/` (33 ready-made labs) before generating from scratch
- Learner-facing code standard (`standards/code-quality.md`): all educational programs, labs, tutorials, drills, and model solutions must carry detailed explanatory comments
- Gate unification: named gates in `skills/SKILL_DEPENDENCIES.md`, single canonical BLOCKED format, `mlt-mentor` enforces the program-active gate, `mlt-program-standard install` validates prerequisites
- Memory scaffold completed everywhere: `.work.mlt/exports/` + `.quick/` added to bootstrap.sh, mlt-bootstrap, mlt-deploy-basic
- Full tutorial (`docs/tutorial-getting-started.md`) and quick-reference recipe pack (`docs/quick-reference/`) for programs, tutorials, and quick lessons
- Example learner content under `.work.mlt/` (marked as examples): installed `ml-foundations` program, gradient-descent tutorial bundle (written + video entry), `grad-descent` lab with commented code, sample session log
- README quick start: root → deploy → target workflow, AI-agent usage note, Windows compatibility section

### Fixed
- `mlt-deploy-basic.sh`: thin-client deploy was functionally broken — now substitutes `REPLACE_BASICSOURCE`/`REPLACE:*` tokens, implements working `--force` and `--update` modes
- `bootstrap.sh`: removed dangerous fallback that copied the source repo's own `.cursorrules` into targets; now fails loudly and sets `TRAINER_MLT_SOURCE` when run standalone
- `.cursorrules`: removed phantom `@x-director` reference; fixed fat-client path resolution rule (`.ai.mlt/<path>`); renamed leftover "MLT Professor OS" branding to pilo.trainer.mlt; documented `REPLACE_BASICSOURCE`, `REPLACE:LEARNER_NAME`, `REPLACE:LEARNER_ROLE` in the placeholder map
- `SKILL_DEPENDENCIES.md`: gate graph redrawn to match the gate table; added missing `mlt-sources` row
- Skills registry: added `start` verb; `list` verb recorded for mlt-drill and mlt-sources; mlt-assess can now recommend `ai-agents-and-apps`
- Scaffold contracts: `labs/`, `tutorials/`, `drills/` added to mlt-bootstrap/mlt-deploy-basic/bootstrap.sh; scaffold files now copied from `templates/training/`
- Lab virtualenvs anchored inside `.work.mlt/` (memory boundary) across lab-safety, mlt-lab, mlt-drill, and lab templates
- `lab-safety.md`: corrected VRAM table (24+ GB row), replaced nonexistent `huggingface-cli cache-info` with `hf cache ls`/`hf cache rm`
- Local-first alignment: <3B/single-GPU fallbacks added to llm-finetuning, llm-training, llm-engineering; HF Spaces made opt-in in ai-agents-and-apps
- Dead/stale links: replaced retired Open LLM Leaderboard and redirected Anthropic docs URLs; flagged >2-year-old sources per citation.md
- `program-spec.md`: Level enum allows bridging labels; prerequisite section matches actual program files
- `.gitignore`: `.work.mlt/` skeleton now tracked (it silently vanished on fresh clones); `.env.*` covered with `!.env.example`; lab venvs ignored
- `framework-verify.sh`: now checks skills↔registry↔contract sync, curricula↔README catalog, template/skeleton parity, script syntax, docs content, and broken relative links
- `mlt-deploy-basic` invocation: `-` separator and dashed flags are now optional — `@mlt-deploy-basic - /path --update` and `@mlt-deploy-basic /path update` are equivalent (skill parse + script arg handling)
- `mlt-review status` now includes the next action (from NEXT.md) in every report, refreshes `.quick/progress.md` and `.quick/gates.md` on each run (they were static placeholders no skill ever updated), and emits a BLOCKED report when no program is installed; `.quick/` files marked as generated views

### Added
- 30 drill lab templates (`drills/lab-templates/`) — every case in `drills/case-library.md` now has a full lab; all local-first (CPU or consumer GPU, <3B models), with setup, runnable code, expected output, troubleshooting, cleanup
- `docs/README.md` (docs/ was empty and failed verification on fresh clones)
- Thin-client `cursorrules.template` now points to the full ruleset at `$TRAINER_MLT_SOURCE/.cursorrules`
- `templates/thin-client-section.md` + additive `--update` merge in `mlt-deploy-basic.sh` (idempotent append into existing target contracts; learned from the future-strategy deploy)
- Merge procedure in `skills/mlt-deploy-basic/skill.md`: subsection integration, alias namespacing (`{MLT_HANDOFF}`/`{MLT_NEXT}`) on placeholder collision, skill-routing registration, separation note
- Target-repo coexistence rules in `.cursorrules` and multi-framework guidance in `cursorrules.template`

## [0.0.1] - 2026-08-03

### Added
- Initial framework structure (pilo.trainer.mlt v0.0.1)
- Core agent contract (.cursorrules)
- 8 training programs in curricula catalog
- 6 binding standards (mentoring, assessment, lab-safety, code-quality, citation, program-spec)
- 18 agent skills (deploy, bootstrap, session, director, router, assess, program, curriculum, mentor, lab, tutorial, drill, sources, update, review)
- Knowledge base with 80+ verified references
- Tools and frameworks reference guide
- Local setup guides for ML environments
- 3 sample lab templates
- Drill case library with 30+ exercises
- Bootstrap and deployment scripts
- Framework verification script
- Learner memory templates
- Progress tracking and gates system
- START_HERE decision tree
- PROCESS_ROUTER how-to mapping
