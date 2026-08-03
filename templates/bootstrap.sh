#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="${1:-.}"
MEMORY_DIR="$REPO_ROOT/.training.mlt"
CONTEXT_DIR="$MEMORY_DIR/context"
PLANS_DIR="$MEMORY_DIR/plans"
PROGRAMS_DIR="$MEMORY_DIR/programs"
SESSIONS_DIR="$MEMORY_DIR/sessions"
SOURCES_DIR="$MEMORY_DIR/sources"
QUICK_DIR="$REPO_ROOT/.quick"

mkdir -p "$CONTEXT_DIR" "$PLANS_DIR" "$PROGRAMS_DIR" "$SESSIONS_DIR" "$SOURCES_DIR" "$QUICK_DIR"

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

CURSORRULES="$REPO_ROOT/.cursorrules"
if [ ! -f "$CURSORRULES" ]; then
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
    FRAMEWORK_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
    if [ -f "$FRAMEWORK_ROOT/templates/cursorrules.template" ]; then
        cp "$FRAMEWORK_ROOT/templates/cursorrules.template" "$CURSORRULES"
    elif [ -f "$FRAMEWORK_ROOT/.cursorrules" ]; then
        cp "$FRAMEWORK_ROOT/.cursorrules" "$CURSORRULES"
    fi
    echo "  created: $CURSORRULES"
else
    echo "  exists (skipped): $CURSORRULES"
fi

echo ""
echo "MLT scaffold complete."
echo "  Memory:     $MEMORY_DIR"
echo "  Next:       @mlt-bootstrap init → @mlt-assess run"
