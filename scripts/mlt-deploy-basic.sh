#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: bash scripts/mlt-deploy-basic.sh [-] <target-path> [--update|update] [--force|force]"
    echo "  <target-path>  Target project root (created if missing); a leading '-' separator is optional"
    echo "  --update       Merge MLT into existing .cursorrules, re-sync skeleton, preserve memory"
    echo "  --force        Overwrite an existing target .cursorrules"
    exit 2
}

TARGET="${1:-}"
if [ "$TARGET" = "-" ]; then
    shift
    TARGET="${1:-}"
fi
[ -z "$TARGET" ] && usage
shift

FORCE=0
UPDATE=0
for arg in "$@"; do
    case "$arg" in
        --force|force) FORCE=1 ;;
        --update|update) UPDATE=1 ;;
        -) ;;  # tolerated separator
        *) echo "Unknown option: $arg" >&2; usage ;;
    esac
done

FRAMEWORK_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEMPLATE="$FRAMEWORK_ROOT/templates/cursorrules.template"

if [ ! -f "$TEMPLATE" ]; then
    echo "ERROR: template not found: $TEMPLATE" >&2
    exit 1
fi

echo "=== MLT Deploy Basic ==="
echo "  Target: $TARGET"
echo "  Source: $FRAMEWORK_ROOT"
[ "$UPDATE" -eq 1 ] && echo "  Mode:   --update (re-sync skeleton, preserve memory)"
[ "$FORCE" -eq 1 ] && echo "  Mode:   --force (overwrite .cursorrules)"
echo ""

if [ ! -d "$TARGET" ]; then
    echo "  Creating target directory: $TARGET"
    mkdir -p "$TARGET"
fi

TARGET_ABS="$(cd "$TARGET" && pwd)"
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
}

CURSORRULES="$TARGET_ABS/.cursorrules"
SECTION_TEMPLATE="$FRAMEWORK_ROOT/templates/thin-client-section.md"
if [ -f "$CURSORRULES" ]; then
    if [ "$FORCE" -eq 1 ]; then
        cp "$TEMPLATE" "$CURSORRULES"
        substitute_tokens "$CURSORRULES"
        echo "  [OK] .cursorrules overwritten (--force)"
    elif [ "$UPDATE" -eq 1 ]; then
        if grep -q "TRAINER_MLT_SOURCE" "$CURSORRULES"; then
            echo "  [OK] .cursorrules already contains TRAINER_MLT_SOURCE — nothing to merge"
        else
            printf '\n---\n\n' >> "$CURSORRULES"
            sed "s|REPLACE_BASICSOURCE|$FRAMEWORK_ROOT|g" "$SECTION_TEMPLATE" >> "$CURSORRULES"
            echo "  [OK] MLT thin-client section appended to existing .cursorrules (additive merge)"
            echo "  [NOTE] If the target contract binds {HANDOFF}/{NEXT} to another framework or has"
            echo "         a skill-routing table, review the merge: namespace MLT aliases and register"
            echo "         mlt-* routing — see skills/mlt-deploy-basic/skill.md (Merge procedure)."
        fi
    else
        echo "  [SKIP] .cursorrules already exists (use --force to overwrite, --update to merge)"
    fi
else
    cp "$TEMPLATE" "$CURSORRULES"
    substitute_tokens "$CURSORRULES"
    echo "  [OK] .cursorrules deployed"
fi

bash "$FRAMEWORK_ROOT/templates/bootstrap.sh" "$TARGET_ABS"

echo ""
echo "=== Deploy Complete ==="
echo "  Next steps:"
echo "    cd $TARGET_ABS"
echo "    @mlt-bootstrap init"
