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
if ! grep -q "## Operator handoff contract" skills/SKILL_DEPENDENCIES.md; then
    echo "  [ERROR] skills/SKILL_DEPENDENCIES.md missing Operator handoff contract section"
    ERRORS=$((ERRORS + 1))
fi
if ! grep -q "## Document clarity contract" skills/SKILL_DEPENDENCIES.md; then
    echo "  [ERROR] skills/SKILL_DEPENDENCIES.md missing Document clarity contract section"
    ERRORS=$((ERRORS + 1))
fi
DOC_SKILLS="mlt-assess mlt-bootstrap mlt-curriculum mlt-drill mlt-lab mlt-mentor mlt-program-custom mlt-program-standard mlt-review mlt-session mlt-sources mlt-tutorial mlt-update"
for skill_dir in skills/*/; do
    skill_name="$(basename "$skill_dir")"
    if [ ! -f "${skill_dir}skill.md" ]; then
        echo "  [ERROR] ${skill_dir} missing skill.md"
        ERRORS=$((ERRORS + 1))
        continue
    fi
    SKILL_COUNT=$((SKILL_COUNT + 1))
    if ! grep -q "Operator handoff contract" "${skill_dir}skill.md"; then
        echo "  [ERROR] $skill_name missing Operator handoff contract reference"
        ERRORS=$((ERRORS + 1))
    fi
    case " $DOC_SKILLS " in
        *" $skill_name "*)
            if ! grep -q "Document clarity contract" "${skill_dir}skill.md"; then
                echo "  [ERROR] $skill_name (doc-generating) missing Document clarity contract reference"
                ERRORS=$((ERRORS + 1))
            fi
            ;;
    esac
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
    "templates/training/PROFILE.md:.work.mlt/context/PROFILE.md" \
    "templates/training/HANDOFF.md:.work.mlt/context/HANDOFF.md" \
    "templates/training/NEXT.md:.work.mlt/plans/NEXT.md" \
    "templates/training/UNKNOWNS.md:.work.mlt/plans/UNKNOWNS.md"; do
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

echo "--- Memory layout (.work.mlt skeleton) ---"
for d in context plans programs sessions sources labs tutorials drills exports; do
    if [ -d ".work.mlt/$d" ]; then
        echo "  [OK] .work.mlt/$d/"
    else
        echo "  [MISSING] .work.mlt/$d/ (fresh clones lose empty dirs — add a .gitkeep)"
        ERRORS=$((ERRORS + 1))
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

echo "--- Sister framework discovery ---"
check_file "scripts/sister-discovery.sh"
if [ -f scripts/sister-discovery.sh ] && bash -n scripts/sister-discovery.sh; then
    # shellcheck disable=SC1091
    source scripts/sister-discovery.sh
    DISCOVERED="$(sister_names ui "$PWD" | head -1)"
    if [ "$DISCOVERED" = ".ai.ui" ]; then
        echo "  [OK] sister discovery: sister_names ui → $DISCOVERED"
    else
        echo "  [ERROR] sister discovery: sister_names ui → '$DISCOVERED' (expected .ai.ui)"
        ERRORS=$((ERRORS + 1))
    fi
    for script in scripts/mlt-deploy-basic.sh scripts/mlt-cursorrules-verify.sh; do
        if [ -f "$script" ] && grep -q "sister-discovery.sh" "$script"; then
            echo "  [OK] $script sources sister-discovery.sh (deploy/verify parity)"
        else
            echo "  [ERROR] $script does not source sister-discovery.sh (deploy/verify parity broken)"
            ERRORS=$((ERRORS + 1))
        fi
    done
else
    echo "  [ERROR] scripts/sister-discovery.sh missing or fails bash -n"
    ERRORS=$((ERRORS + 1))
fi
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
