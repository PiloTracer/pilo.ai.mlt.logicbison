#!/usr/bin/env bash
set -euo pipefail

FRAMEWORK_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

usage() {
    cat <<'EOF'
MLT (Machine Learning and AI Training) — installer

Usage:
  bash scripts/install.sh check              Verify this framework checkout (default)
  bash scripts/install.sh deploy <target>    Verify, then deploy MLT into <target> project
  bash scripts/install.sh help               Show this help

Typical flow on Linux:
  git clone https://github.com/PiloTracer/pilo.trainer.mlt.git
  cd pilo.trainer.mlt
  bash scripts/install.sh deploy /path/to/my-learning-project
  cd /path/to/my-learning-project
  # open the target with your AI agent (Cursor, etc.) — it reads .cursorrules —
  # then ask:  @mlt-bootstrap init

Windows: run inside WSL2 (recommended) or Git Bash. See README.md § Windows.
EOF
}

check_tool() {
    if command -v "$1" >/dev/null 2>&1; then
        echo "  [OK] $1"
    else
        echo "  [MISSING] $1"
        return 1
    fi
}

echo "=== MLT install — environment check ==="
FAIL=0
for tool in bash sed grep awk find git; do
    check_tool "$tool" || FAIL=1
done
if command -v python3 >/dev/null 2>&1; then
    echo "  [OK] python3 ($(python3 --version 2>&1))"
else
    echo "  [WARN] python3 not found — needed for labs, not for framework setup"
fi
[ "$FAIL" -eq 1 ] && { echo "Install prerequisites missing. Aborting." >&2; exit 1; }
echo ""

echo "=== MLT install — framework verification ==="
bash "$FRAMEWORK_ROOT/scripts/framework-verify.sh"
echo ""

MODE="${1:-check}"
case "$MODE" in
    check|help|-h|--help)
        [ "$MODE" = "help" ] || [ "$MODE" = "-h" ] || [ "$MODE" = "--help" ] && { usage; exit 0; }
        echo "Framework checkout is healthy."
        echo ""
        usage
        ;;
    deploy)
        TARGET="${2:-}"
        if [ -z "$TARGET" ]; then
            echo "deploy requires a target path: bash scripts/install.sh deploy /path/to/project" >&2
            exit 2
        fi
        echo "=== MLT install — deploying to $TARGET ==="
        bash "$FRAMEWORK_ROOT/scripts/mlt-deploy-basic.sh" - "$TARGET"
        ;;
    *)
        echo "Unknown mode: $MODE" >&2
        usage
        exit 2
        ;;
esac
