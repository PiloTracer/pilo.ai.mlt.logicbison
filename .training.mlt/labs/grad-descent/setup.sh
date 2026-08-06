#!/usr/bin/env bash
# Lab environment setup — grad-descent (per standards/lab-safety.md)
# Creates an isolated virtualenv INSIDE the lab directory so cleanup is
# one rm -rf and nothing leaks into system Python.
set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"

python3 -m venv "$LAB_DIR/.venv"
# shellcheck disable=SC1091
source "$LAB_DIR/.venv/bin/activate"
pip install --upgrade pip
pip install "numpy>=1.26,<3" "matplotlib>=3.8,<4"

echo ""
echo "Lab environment ready. Run:"
echo "  python $LAB_DIR/gd_linreg.py"
