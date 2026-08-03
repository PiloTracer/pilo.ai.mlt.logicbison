#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="${1:-.}"
MEMORY_DIR="$REPO_ROOT/.training.mlt"
CONTEXT_DIR="$MEMORY_DIR/context"
PLANS_DIR="$MEMORY_DIR/plans"
PROGRAMS_DIR="$MEMORY_DIR/programs"
SESSIONS_DIR="$MEMORY_DIR/sessions"
SOURCES_DIR="$MEMORY_DIR/sources"
LABS_DIR="$MEMORY_DIR/labs"
TUTORIALS_DIR="$MEMORY_DIR/tutorials"
DRILLS_DIR="$MEMORY_DIR/drills"
QUICK_DIR="$REPO_ROOT/.quick"

mkdir -p "$CONTEXT_DIR" "$PLANS_DIR" "$PROGRAMS_DIR" "$SESSIONS_DIR" "$SOURCES_DIR" "$LABS_DIR" "$TUTORIALS_DIR" "$DRILLS_DIR" "$QUICK_DIR"

TEMPLATE_DIR="$(cd "$(dirname "$0")/.." && pwd)/templates/training"

write_if_missing() {
    local target="$1"
    local source="$2"
    if [ ! -f "$target" ]; then
        if [ -f "$source" ]; then
            cp "$source" "$target"
        else
            echo "# $(basename "$target" .md)" > "$target"
            echo "" >> "$target"
            echo "(empty — fill in)" >> "$target"
        fi
        echo "  created: $target"
    else
        echo "  exists (skipped): $target"
    fi
}

write_if_missing "$CONTEXT_DIR/PROFILE.md" "$TEMPLATE_DIR/PROFILE.md"
write_if_missing "$CONTEXT_DIR/HANDOFF.md" "$TEMPLATE_DIR/HANDOFF.md"
write_if_missing "$PLANS_DIR/NEXT.md" "$TEMPLATE_DIR/NEXT.md"
write_if_missing "$PLANS_DIR/UNKNOWNS.md" "$TEMPLATE_DIR/UNKNOWNS.md"

# Operator cheat sheets (learner-facing starters shipped with the framework)
FRAMEWORK_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
write_if_missing "$QUICK_DIR/gates.md" "$FRAMEWORK_ROOT/.quick/gates.md"
write_if_missing "$QUICK_DIR/progress.md" "$FRAMEWORK_ROOT/.quick/progress.md"

CURSORRULES="$REPO_ROOT/.cursorrules"
if [ ! -f "$CURSORRULES" ]; then
    TEMPLATE="$FRAMEWORK_ROOT/templates/cursorrules.template"
    if [ ! -f "$TEMPLATE" ]; then
        echo "ERROR: template not found: $TEMPLATE" >&2
        echo "       Cannot create .cursorrules — deploy from a complete pilo.trainer.mlt checkout." >&2
        exit 1
    fi
    cp "$TEMPLATE" "$CURSORRULES"
    sed -i "s|REPLACE_BASICSOURCE|$FRAMEWORK_ROOT|g" "$CURSORRULES"
    echo "  created: $CURSORRULES (TRAINER_MLT_SOURCE=$FRAMEWORK_ROOT)"
else
    echo "  exists (skipped): $CURSORRULES"
fi

echo ""
echo "MLT scaffold complete."
echo "  Memory:     $MEMORY_DIR"
echo "  Next:       @mlt-bootstrap init → @mlt-assess run"
