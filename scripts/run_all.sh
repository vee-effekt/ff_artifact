#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "========================================"
echo "Running ALL Benchmarks (Fresh Data)"
echo "========================================"
echo ""

# Run OCaml benchmarks
"$SCRIPT_DIR/run_ocaml.sh"
echo ""

# Run Scala benchmarks
"$SCRIPT_DIR/run_scala.sh"
echo ""

# Run ETNA benchmarks
"$SCRIPT_DIR/run_etna.sh"
echo ""

echo "========================================"
echo "All benchmarks complete!"
echo "========================================"
echo ""
echo "Fresh data figures generated:"
echo "  - Figure 14: eval/figures/fresh/fig14.png (OCaml)"
echo "  - Figure 16: eval/figures/fresh/fig16.png (Scala)"
echo "  - Figure 17: eval/figures/fresh/fig17.png (ETNA geometric mean)"
echo "  - Figure 18: eval/figures/fresh/fig18.png (ETNA box plots)"
