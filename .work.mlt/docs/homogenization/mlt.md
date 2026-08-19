# `.ai.mlt` (MLT Agent OS) — upgrade directions for the deploy skills

**Status:** Applied + verified (2026-08-19) · **Needs:** none · **Repo:** `/mnt/work/Projects/.ai.mlt`

Goal: make the deploy skills produce targets whose `.cursorrules` discover all six sisters under both namings — same as the current framework. **Achieved.**

## Current state (measured 2026-08-19, before this change)

- `scripts/mlt-deploy-basic.sh` (176 L): thin bootstrap; substitutes `REPLACE_BASICSOURCE` → `TRAINER_MLT_SOURCE` (the source env var) + project tokens; template = `templates/cursorrules.template`. **No sister logic anywhere** (zero hits for `sister`/`.ai.ui`/`AI_UI_PATH` in `scripts/`).
- `scripts/mlt-cursorrules-verify.sh` (219 L): checks MLT layouts + a single grep heuristic (`:191-197`); **no sister cells**.
- **No `mlt-deploy-files.sh` / `mlt-deploy-repo.sh` scripts** — those skills exist in `skills/` but have no backing script (deploy-files/deploy-repo are skill-only).
- `.cursorrules`: **no Frameworks registry** (natural insertion point: after the `**Free-text:**` line, `:30`).
- `templates/cursorrules.template`: tiny (~31 L) placeholder-style; **no registry, no `AI_*_PATH` tokens**.
- `scripts/framework-verify.sh` (200 L): structural checks; no sister checks.

## What was applied (2026-08-19)

1. ✅ **`scripts/sister-discovery.sh` copied** from `pilo.ai.logicbison/scripts/sister-discovery.sh` (byte-identical; `bash -n` clean).
2. ✅ **`.cursorrules` Frameworks registry** (Layer 1) inserted after the `**Free-text:**` line — 6-row table (`.ai.mlt` self + 5 sisters), path-resolution rules, degraded-routing rule. **Owner decision (2026-08-19):** no parent row — the Agent OS orchestrator routes INTO this framework; this framework never routes back, so it carries no `.ai` contact path.
3. ✅ **`scripts/mlt-deploy-basic.sh` wired** — sources `sister-discovery.sh`; `substitute_tokens()` fills `REPLACE:AI_*_PATH` cells at deploy time (guarded: tokens absent from the template are skipped; unfilled tokens stay for manual fill / runtime auto-discover).
4. ✅ **`templates/cursorrules.template` registry with tokens** — 6 rows: `.ai.mlt` self = `*this directory*` (no token), 5 token cells (`AI_UI/BIZ/SOC/CTO/FLUTTER_PATH`, defaults `../.ai.<fw>`), + consumer-side resolution text (thin/fat/self).
   - **Design note (deviation from doc draft):** no `REPLACE:AI_MLT_PATH` cell — the self row needs no token (thin resolves via `TRAINER_MLT_SOURCE`, fat via local `.ai.mlt/`). The fill loop skips tokens that don't exist, so the family loop stays safe.
5. ✅ **`scripts/mlt-cursorrules-verify.sh` six-slot checks** — sources the lib; `SELF_SLOT` derived from source basename (`.ai.mlt` → `mlt`, skipped in fill/check loops — also prevents the target's own `TRAINER_MLT_SOURCE` path from false-flagging as a stale sister cell); `find_sister()`/`baked_sister_paths()` helpers; `--fix` fills open tokens + re-points stale baked paths; checks report `reachable` / `STALE` / `not installed` / `custom cell value`.
6. ✅ **`scripts/framework-verify.sh` sister section** — verifies `sister-discovery.sh` presence + syntax, `sister_names ui` smoke, and deploy/verify parity (both scripts source the lib).
7. ✅ **Gap fixes:**
   - `standards/PROTECTED_SURFACES.json` **created** (adapted from family; lists the real MLT high-blast paths incl. the new `sister-discovery.sh`) — resolves the dangling citation from `agent.os.framework.md`.
   - `agent.os.framework.md:5` **corrected**: `session-control` → `mlt-session` (the vendored skill; family text was copied verbatim). **Owner-approved** edit.
   - **Decision (owner-approved):** `mlt-deploy-files` / `mlt-deploy-repo` stay **skill-only** — no scripts restored. Both deploy paths were smoke-verified instead (see below).

## Verification (all run 2026-08-19)

```bash
source scripts/sister-discovery.sh
sister_names ui "$PWD"     # → .ai.ui ✓
find_sister_dir ui → /mnt/work/Projects/.ai.ui   # 5 sisters installed on disk ✓
bash scripts/mlt-deploy-basic.sh /tmp/smoke-mlt   # thin deploy: 5 tokens filled at deploy time
                                                  # post-deploy verify: PASS
bash scripts/mlt-deploy-basic.sh /tmp/smoke-mlt update   # idempotent, PASS
bash scripts/mlt-cursorrules-verify.sh /tmp/smoke-stale  # stale path → FAIL STALE
bash scripts/mlt-cursorrules-verify.sh /tmp/smoke-stale --fix  # re-pointed → PASS
bash scripts/mlt-cursorrules-verify.sh /tmp/smoke-fat --fat    # fat-client vendor → PASS
bash scripts/mlt-cursorrules-verify.sh . --self                # self-hosted → PASS
bash scripts/framework-verify.sh    # 0 errors, 2 expected warnings → PASSED
bash -n scripts/*.sh templates/*.sh # all clean
python3 -c "import json; json.load(open('standards/PROTECTED_SURFACES.json'))"  # valid
```

## Decisions

1. **Deploy scripts stay skill-only** (owner-approved): `mlt-deploy-files` (fat) and `mlt-deploy-repo` (clone/archive) remain agent-driven; `mlt-deploy-basic` (thin) is script-backed. Both deploy paths verified working end-to-end.
2. **OS marker repaired** (owner-approved): `standards/PROTECTED_SURFACES.json` created; `agent.os.framework.md` detection line now cites `mlt-session`.
3. **Template self row has no token** — `*this directory*` + resolution rules cover thin/fat; the family fill loop skips absent tokens.

## Open questions

- ~~`.ai` (Agent OS) registry row~~ — **resolved 2026-08-19 (owner decision):** the child framework never routes to the parent orchestrator, so the registry carries no `.ai` row at all (removed from `.cursorrules` + template). Big brother confirmed on disk at `../pilo.ai.logicbison` (`../.ai` absent) — informational only; no contact machinery was added (an `agent_os_names`/`find_agent_os_root` draft was reverted; `sister-discovery.sh` stays byte-identical to the family lib).
- Sibling `cursorrules-verify.sh` in `pilo.ai.logicbison` is the family source of truth for the sister lib + checks; `mlt-*` scripts mirror it — keep in sync on future family changes.

## Checklist

- [x] `scripts/sister-discovery.sh` copied
- [x] `.cursorrules` registry + resolution (Layer 1)
- [x] Deploy fill (step 3) + template registry (step 4) as a pair
- [x] Verify commands pass (thin / update / fix / fat / self / framework-verify)
- [x] Both deploy paths proven: `mlt-deploy-basic` (script) and `mlt-deploy-files` (skill, fat layout verified)
- [x] Change set committed full-scope and released as **v0.6.1** (2026-08-19)

## Next action

None — smoke-test queue complete (`context` + `status` verified live 2026-08-19). Resume the training pipeline (`@mlt-bootstrap init`) only on explicit training-project intent.
