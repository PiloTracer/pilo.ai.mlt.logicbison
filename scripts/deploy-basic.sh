#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-.}"
FRAMEWORK_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "=== MLT Deploy Basic ==="
echo "  Target: $TARGET"
echo "  Source: $FRAMEWORK_ROOT"
echo ""

if [ ! -d "$TARGET" ]; then
    echo "  Creating target directory: $TARGET"
    mkdir -p "$TARGET"
fi

if [ -f "$TARGET/.cursorrules" ]; then
    echo "  [SKIP] .cursorrules already exists (use --force to overwrite)"
    if [ "${2:-}" != "--force" ]; then
        echo "  Use: bash scripts/deploy-basic.sh $TARGET --force"
    fi
else
    cp "$FRAMEWORK_ROOT/templates/cursorrules.template" "$TARGET/.cursorrules"
    echo "  [OK] .cursorrules deployed"
fi

bash "$FRAMEWORK_ROOT/templates/bootstrap.sh" "$TARGET"

echo ""
echo "=== Deploy Complete ==="
echo "  Next steps:"
echo "    cd $TARGET"
echo "    @mlt-bootstrap init"
