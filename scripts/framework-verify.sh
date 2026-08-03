#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

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
for d in skills curricula standards references drills templates scripts docs; do
    check_dir "$d"
done
if [ -d docs ] && [ -z "$(ls -A docs)" ]; then
    echo "  [EMPTY] docs/ has no content"
    ERRORS=$((ERRORS + 1))
fi
echo ""

echo "--- Contract sanity ---"
if head -12 .cursorrules | grep -q "REPLACE"; then
    echo "  [ERROR] .cursorrules identity section contains unsubstituted REPLACE tokens"
    ERRORS=$((ERRORS + 1))
else
    echo "  [OK] .cursorrules identity substituted"
fi
echo ""

echo "--- Skills ---"
SKILL_COUNT=0
for skill_dir in skills/*/; do
    skill_name="$(basename "$skill_dir")"
    if [ ! -f "${skill_dir}skill.md" ]; then
        echo "  [ERROR] ${skill_dir} missing skill.md"
        ERRORS=$((ERRORS + 1))
        continue
    fi
    SKILL_COUNT=$((SKILL_COUNT + 1))
    if ! grep -q "skills/${skill_name}/" skills/README.md; then
        echo "  [ERROR] $skill_name not in skills/README.md registry"
        ERRORS=$((ERRORS + 1))
    fi
    if ! grep -q "skills/${skill_name}/" .cursorrules; then
        echo "  [ERROR] $skill_name not in .cursorrules skills table"
        ERRORS=$((ERRORS + 1))
    fi
done
echo "  Found $SKILL_COUNT skills with skill.md (registry + contract in sync if no errors above)"
echo ""

echo "--- Curricula ---"
CURR_COUNT=0
for curr_file in curricula/*.md; do
    [ "$curr_file" = "curricula/README.md" ] && continue
    CURR_COUNT=$((CURR_COUNT + 1))
    slug="$(basename "$curr_file" .md)"
    if ! grep -q "\`$slug\`" README.md; then
        echo "  [ERROR] $slug not in README.md program catalog"
        ERRORS=$((ERRORS + 1))
    fi
done
echo "  Found $CURR_COUNT curriculum programs"
echo ""

echo "--- Standards ---"
STD_COUNT=$(ls -1 standards/*.md 2>/dev/null | wc -l)
echo "  Found $STD_COUNT standards"
echo ""

echo "--- Template/skeleton parity ---"
for pair in \
    "templates/training/PROFILE.md:.training.mlt/context/PROFILE.md" \
    "templates/training/HANDOFF.md:.training.mlt/context/HANDOFF.md" \
    "templates/training/NEXT.md:.training.mlt/plans/NEXT.md" \
    "templates/training/UNKNOWNS.md:.training.mlt/plans/UNKNOWNS.md"; do
    src="${pair%%:*}"
    dst="${pair##*:}"
    if [ ! -f "$dst" ]; then
        echo "  [MISSING] $dst (skeleton)"
        ERRORS=$((ERRORS + 1))
    elif ! diff -q "$src" "$dst" >/dev/null; then
        echo "  [WARN] $dst diverges from $src (expected once sessions fill the skeleton)"
        WARNINGS=$((WARNINGS + 1))
    else
        echo "  [OK] $dst == $src"
    fi
done
echo ""

echo "--- Scripts ---"
for script in scripts/*.sh templates/*.sh; do
    if bash -n "$script" 2>/dev/null; then
        echo "  [OK] $script (syntax)"
    else
        echo "  [ERROR] $script fails bash -n"
        ERRORS=$((ERRORS + 1))
    fi
    if [ ! -x "$script" ]; then
        echo "  [WARN] $script not executable"
        WARNINGS=$((WARNINGS + 1))
    fi
done
echo ""

echo "--- Relative markdown links ---"
LINK_ERRORS=0
while IFS= read -r md; do
    md_dir="$(dirname "$md")"
    # extract ](target) where target is relative (not http(s), mailto, or #anchor)
    while read -r target; do
        case "$target" in
            http*|mailto:*|\`*) continue ;;
        esac
        target="${target%%#*}"
        [ -z "$target" ] && continue
        if [ ! -e "$md_dir/$target" ]; then
            echo "  [BROKEN] $md -> $target"
            LINK_ERRORS=$((LINK_ERRORS + 1))
        fi
    done < <(awk '/^```/{f=!f; next} !f' "$md" | grep -oE '\]\([^)#]+\)' | sed -E 's/^\]\(//; s/\)$//' || true)
done < <(find . -name '*.md' -not -path './.git/*' -not -path './tmp/*')
if [ "$LINK_ERRORS" -gt 0 ]; then
    echo "  $LINK_ERRORS broken relative link(s)"
    ERRORS=$((ERRORS + LINK_ERRORS))
else
    echo "  [OK] all relative links resolve"
fi
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
