#!/usr/bin/env bash
set -euo pipefail

echo "=== pilo.trainer.mlt Framework Verification ==="
echo ""

ERRORS=0
WARNINGS=0

check_dir() {
    if [ -d "$1" ]; then
        echo "  [OK] $1/"
    else
        echo "  [MISSING] $1/"
        ERRORS=$((ERRORS + 1))
    fi
}

check_file() {
    if [ -f "$1" ]; then
        echo "  [OK] $1"
    else
        echo "  [MISSING] $1"
        ERRORS=$((ERRORS + 1))
    fi
}

echo "--- Core Files ---"
check_file ".cursorrules"
check_file "START_HERE.md"
check_file "PROCESS_ROUTER.md"
check_file "README.md"
echo ""

echo "--- Directories ---"
check_dir "skills"
check_dir "curricula"
check_dir "standards"
check_dir "references"
check_dir "drills"
check_dir "templates"
check_dir "scripts"
check_dir "docs"
echo ""

echo "--- Skills ---"
SKILL_COUNT=0
for skill_dir in skills/*/; do
    if [ -f "${skill_dir}skill.md" ]; then
        SKILL_COUNT=$((SKILL_COUNT + 1))
    else
        echo "  [WARN] ${skill_dir} missing skill.md"
        WARNINGS=$((WARNINGS + 1))
    fi
done
echo "  Found $SKILL_COUNT skills with skill.md"
echo ""

echo "--- Curricula ---"
CURR_COUNT=0
for curr_file in curricula/*.md; do
    if [ "$curr_file" != "curricula/README.md" ]; then
        CURR_COUNT=$((CURR_COUNT + 1))
    fi
done
echo "  Found $CURR_COUNT curriculum programs"
echo ""

echo "--- Standards ---"
STD_COUNT=$(ls -1 standards/*.md 2>/dev/null | wc -l)
echo "  Found $STD_COUNT standards"
echo ""

echo "=== Results ==="
echo "  Errors:   $ERRORS"
echo "  Warnings: $WARNINGS"
echo ""

if [ $ERRORS -eq 0 ]; then
    echo "  Framework verification: PASSED"
    exit 0
else
    echo "  Framework verification: FAILED ($ERRORS errors)"
    exit 1
fi
