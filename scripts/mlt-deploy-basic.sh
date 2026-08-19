#!/usr/bin/env bash
# mlt-deploy-basic.sh — Thin-client bootstrap of pilo.trainer.mlt (MLT Training
# OS) into a target project.
#
# Copies ONLY the minimal scaffold into the target:
#   - .cursorrules (from templates/cursorrules.template, with TRAINER_MLT_SOURCE
#     substituted to the absolute path of THIS source framework)
#   - .work.mlt/ skeleton (PROFILE, HANDOFF, NEXT, UNKNOWNS, memory dirs)
#   - .quick/ operator cheat sheets
#
# Framework assets (skills/, curricula/, standards/, references/, drills/,
# templates/, scripts/) are NOT copied — the target's .cursorrules carries a
# TRAINER_MLT_SOURCE pointer so the agent resolves them from the source
# framework at runtime (thin-client mode).
#
# Default = NO-OVERWRITE: existing target files are preserved.
#   update: merge MLT into an existing .cursorrules (additive), re-sync the
#           source pointer via mlt-cursorrules-verify.sh --fix, re-sync skeleton.
#   force:  overwrite the target .cursorrules (requires explicit user intent).
#   status: read-only verification report (mlt-cursorrules-verify.sh).
#
# Every deploy/update run ends with mlt-cursorrules-verify.sh so a broken
# pointer or incomplete skeleton is reported immediately.
#
# Source resolution: FRAMEWORK_ROOT is derived from this script's location, so
# the script can be invoked from a TARGET using an external source:
#   bash /mnt/work/Projects/.ai.mlt/scripts/mlt-deploy-basic.sh /path/to/target update
# Override the source with MLT_SOURCE=/abs/path if needed.
#
# Usage:
#   bash scripts/mlt-deploy-basic.sh <target-path>              # no-overwrite deploy
#   bash scripts/mlt-deploy-basic.sh [status] [target-path]     # read-only verify report
#   bash scripts/mlt-deploy-basic.sh <target-path> [--update]   # merge + re-sync + verify
#   bash scripts/mlt-deploy-basic.sh <target-path> [--force]    # overwrite .cursorrules
#
# Argument forms are equivalent: verbs accept the '--' prefix or bare form
# (`update` ≡ `--update`, `status` ≡ `--status`, `force` ≡ `--force`), '-' and
# '--' separators are ignored, and the target path may appear in any position:
#   mlt-deploy-basic.sh /path update   ≡   mlt-deploy-basic.sh /path --update
set -euo pipefail

usage() {
    echo "Usage: bash scripts/mlt-deploy-basic.sh [status] <target-path> [--update|--force]"
    echo "  <target-path>  Target project root (created if missing); may appear in any position"
    echo "  status         Read-only verification of the target .cursorrules + .work.mlt skeleton"
    echo "  update         Merge MLT into existing .cursorrules, re-sync pointer + skeleton, verify"
    echo "  force          Overwrite an existing target .cursorrules"
    echo "  Verbs accept the '--' prefix or bare form; '-' / '--' are ignored separators."
    exit 2
}

# ── Argument normalization (bare verb ≡ --flag, path in any position) ──
MODE=""
RAW_TARGET=""
for arg in "$@"; do
  [[ "$arg" == "-" || "$arg" == "--" ]] && continue
  tok="${arg#--}"
  case "$tok" in
    status|update|force)
      if [[ -z "$MODE" ]]; then MODE="$tok"
      else echo "ERROR: conflicting modes: '$MODE' and '$tok'" >&2; usage; fi ;;
    /*|./*|../*|~*|*/*|.)
      if [[ -z "$RAW_TARGET" ]]; then RAW_TARGET="$arg"
      else echo "ERROR: multiple target paths: '$RAW_TARGET' and '$arg'" >&2; exit 2; fi ;;
    *) echo "ERROR: unknown argument: $arg" >&2; usage ;;
  esac
done
MODE="${MODE:-deploy}"
if [[ -z "$RAW_TARGET" ]]; then
  if [[ "$MODE" == "status" ]]; then
    RAW_TARGET="."
  else
    usage
  fi
fi

# Source framework root: explicit override wins, else derive from script location.
if [[ -n "${MLT_SOURCE:-}" ]]; then
  FRAMEWORK_ROOT="$(cd "$MLT_SOURCE" && pwd)"
else
  FRAMEWORK_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi
TEMPLATE="$FRAMEWORK_ROOT/templates/cursorrules.template"
VERIFY="$FRAMEWORK_ROOT/scripts/mlt-cursorrules-verify.sh"

# Shared sister-framework discovery (family naming `pilo.ai.<fw>.logicbison` + legacy `.ai.<fw>`).
source "$FRAMEWORK_ROOT/scripts/sister-discovery.sh"

if [ ! -f "$TEMPLATE" ]; then
    echo "ERROR: template not found: $TEMPLATE" >&2
    echo "       Source is not a valid pilo.trainer.mlt framework root." >&2
    exit 1
fi

# ── Status mode (read-only) ───────────────────────────────────────────
if [[ "$MODE" == "status" ]]; then
  exec bash "$VERIFY" "$RAW_TARGET"
fi

echo "=== MLT Deploy Basic ==="
echo "  Target: $RAW_TARGET"
echo "  Source: $FRAMEWORK_ROOT"
[ "$MODE" = "update" ] && echo "  Mode:   update (merge, re-sync skeleton, preserve memory)"
[ "$MODE" = "force" ]  && echo "  Mode:   force (overwrite .cursorrules)"
echo ""

if [ ! -d "$RAW_TARGET" ]; then
    echo "  Creating target directory: $RAW_TARGET"
    mkdir -p "$RAW_TARGET"
fi

TARGET_ABS="$(cd "$RAW_TARGET" && pwd)"
PROJECT_NAME="$(basename "$TARGET_ABS")"

# Substitute the deploy-time tokens in a freshly copied .cursorrules.
substitute_tokens() {
    local file="$1"
    sed -i \
        -e "s|REPLACE_BASICSOURCE|$FRAMEWORK_ROOT|g" \
        -e "s|REPLACE:PROJECT_NAME|$PROJECT_NAME|g" \
        -e "s|REPLACE:LEARNER_LEVEL|beginner|g" \
        -e "s|REPLACE:PRIMARY_GOAL|(set the learner's primary training goal)|g" \
        "$file"
    echo "  [OK] tokens substituted (TRAINER_MLT_SOURCE=$FRAMEWORK_ROOT)"
    # Sister-framework cells: fill REPLACE:AI_*_PATH tokens at deploy time when
    # the sister is installed as a sibling (family naming `pilo.ai.<fw>.logicbison`
    # or legacy `.ai.<fw>` — see scripts/sister-discovery.sh). Tokens absent from
    # the template are skipped; tokens left unfilled stay for manual cell fill /
    # runtime auto-discover (see .cursorrules § Frameworks registry path resolution).
    local SIBLING_PARENT fw token_upper token fw_dir fw_esc checked
    SIBLING_PARENT="$(cd "$FRAMEWORK_ROOT/.." && pwd)"
    for fw in $FRAMEWORK_SLOTS; do
        token_upper="$(echo "$fw" | tr '[:lower:]' '[:upper:]')"
        token="REPLACE:AI_${token_upper}_PATH"
        grep -q "$token" "$file" || continue   # no cell in this template → skip
        fw_dir="$(find_sister_dir "$FRAMEWORK_ROOT" "$fw" "$SIBLING_PARENT" || true)"
        if [[ -n "$fw_dir" ]]; then
            fw_esc="${fw_dir//\//\\/}"
            perl -i -pe "s{${token} \\(default:? \\\`[^)]*\\)}{${fw_esc} (discovered at deploy time)}" "$file"
            if grep -q "$token" "$file"; then
                echo "  frameworks: WARN ${token} cell did not match expected template shape — left for runtime auto-discover" >&2
            else
                echo "  frameworks: resolved ${token} → ${fw_dir}" >&2
            fi
        else
            checked="$(sister_names "$fw" "$FRAMEWORK_ROOT" | paste -sd' ' -)"
            echo "  frameworks: ${token} not found (checked ${checked} in $SIBLING_PARENT) — fill manually if the sister exists under another dir name" >&2
        fi
    done
}

CURSORRULES="$TARGET_ABS/.cursorrules"
SECTION_TEMPLATE="$FRAMEWORK_ROOT/templates/thin-client-section.md"
if [ -f "$CURSORRULES" ]; then
    if [ "$MODE" = "force" ]; then
        cp "$TEMPLATE" "$CURSORRULES"
        substitute_tokens "$CURSORRULES"
        echo "  [OK] .cursorrules overwritten (force)"
    elif [ "$MODE" = "update" ]; then
        if grep -q "TRAINER_MLT_SOURCE" "$CURSORRULES"; then
            echo "  [OK] .cursorrules already contains TRAINER_MLT_SOURCE — re-syncing pointer (no duplicate section)"
        else
            printf '\n---\n\n' >> "$CURSORRULES"
            sed "s|REPLACE_BASICSOURCE|$FRAMEWORK_ROOT|g" "$SECTION_TEMPLATE" >> "$CURSORRULES"
            echo "  [OK] MLT thin-client section appended to existing .cursorrules (additive merge)"
            echo "  [NOTE] If the target contract binds {HANDOFF}/{NEXT} to another framework or has"
            echo "         a skill-routing table, review the merge: namespace MLT aliases and register"
            echo "         mlt-* routing — see skills/mlt-deploy-basic/skill.md (Merge procedure)."
        fi
    else
        echo "  [SKIP] .cursorrules already exists (use 'force' to overwrite, 'update' to merge)"
    fi
else
    cp "$TEMPLATE" "$CURSORRULES"
    substitute_tokens "$CURSORRULES"
    echo "  [OK] .cursorrules deployed"
fi

bash "$FRAMEWORK_ROOT/templates/bootstrap.sh" "$TARGET_ABS"

# update: re-sync the source pointer (repairs stale values, idempotent).
if [ "$MODE" = "update" ]; then
    echo ""
    echo "=== Pointer re-sync (update) ==="
    bash "$VERIFY" "$TARGET_ABS" --fix || true
fi

# Post-deploy verification — a deploy is not complete until the target's
# .cursorrules resolves against the current source and the skeleton is intact.
echo ""
echo "=== Post-deploy verification ==="
if bash "$VERIFY" "$TARGET_ABS"; then
    VERIFY_RC=0
else
    VERIFY_RC=$?
fi

echo ""
echo "=== Deploy Complete ==="
echo "  Next steps:"
echo "    cd $TARGET_ABS"
echo "    @mlt-bootstrap init"
[ "$VERIFY_RC" -ne 0 ] && exit "$VERIFY_RC"
exit 0
