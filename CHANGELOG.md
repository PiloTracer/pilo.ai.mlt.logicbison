# Changelog

## [Unreleased]

### Fixed
- `deploy-basic.sh`: thin-client deploy was functionally broken — now substitutes `REPLACE_BASICSOURCE`/`REPLACE:*` tokens, implements working `--force` and `--update` modes
- `bootstrap.sh`: removed dangerous fallback that copied the source repo's own `.cursorrules` into targets; now fails loudly and sets `TRAINER_MLT_SOURCE` when run standalone
- `.cursorrules`: removed phantom `@x-director` reference; fixed fat-client path resolution rule (`.ai.mlt/<path>`); renamed leftover "MLT Professor OS" branding to pilo.trainer.mlt; documented `REPLACE_BASICSOURCE`, `REPLACE:LEARNER_NAME`, `REPLACE:LEARNER_ROLE` in the placeholder map
- `SKILL_DEPENDENCIES.md`: gate graph redrawn to match the gate table; added missing `mlt-sources` row
- Skills registry: added `start` verb; `list` verb recorded for mlt-drill and mlt-sources; mlt-assess can now recommend `ai-agents-and-apps`
- Scaffold contracts: `labs/`, `tutorials/`, `drills/` added to mlt-bootstrap/deploy-basic/bootstrap.sh; scaffold files now copied from `templates/training/`
- Lab virtualenvs anchored inside `.training.mlt/` (memory boundary) across lab-safety, mlt-lab, mlt-drill, and lab templates
- `lab-safety.md`: corrected VRAM table (24+ GB row), replaced nonexistent `huggingface-cli cache-info` with `hf cache ls`/`hf cache rm`
- Local-first alignment: <3B/single-GPU fallbacks added to llm-finetuning, llm-training, llm-engineering; HF Spaces made opt-in in ai-agents-and-apps
- Dead/stale links: replaced retired Open LLM Leaderboard and redirected Anthropic docs URLs; flagged >2-year-old sources per citation.md
- `program-spec.md`: Level enum allows bridging labels; prerequisite section matches actual program files
- `.gitignore`: `.training.mlt/` skeleton now tracked (it silently vanished on fresh clones); `.env.*` covered with `!.env.example`; lab venvs ignored
- `framework-verify.sh`: now checks skills↔registry↔contract sync, curricula↔README catalog, template/skeleton parity, script syntax, docs content, and broken relative links

### Added
- 30 drill lab templates (`drills/lab-templates/`) — every case in `drills/case-library.md` now has a full lab; all local-first (CPU or consumer GPU, <3B models), with setup, runnable code, expected output, troubleshooting, cleanup
- `docs/README.md` (docs/ was empty and failed verification on fresh clones)
- Thin-client `cursorrules.template` now points to the full ruleset at `$TRAINER_MLT_SOURCE/.cursorrules`

## [0.1.0] - 2026-08-03

### Added
- Initial framework structure (pilo.trainer.mlt v0.1.0)
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
