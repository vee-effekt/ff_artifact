#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "========================================"
echo "Analyzing ALL Precomputed Data"
echo "========================================"
echo ""

# Analyze OCaml data
"$SCRIPT_DIR/analyze_ocaml.sh"
echo ""

# Analyze Scala data
"$SCRIPT_DIR/analyze_scala.sh"
echo ""

# Analyze ETNA data
"$SCRIPT_DIR/analyze_etna.sh"
echo ""

echo "========================================"
echo "All analysis complete!"
echo "========================================"
echo ""
echo "Precomputed data figures generated:"
echo "  - Figure 14: eval/figures/precomputed/fig14.png (OCaml)"
echo "  - Figure 16: eval/figures/precomputed/fig16.png (Scala)"
echo "  - Figure 17: eval/figures/precomputed/fig17.png (ETNA geometric mean)"
echo "  - Figure 18: eval/figures/precomputed/fig18.png (ETNA box plots)"
