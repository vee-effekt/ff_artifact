#!/bin/bash
set -e

ARTIFACT_DIR="/ff_artifact/artifact"
EVAL_DIR="$ARTIFACT_DIR/eval"

echo "========================================"
echo "OCaml Data Analysis (Precomputed)"
echo "========================================"
echo ""

cd "$EVAL_DIR"

# Step 1: Parse benchmark results
echo "Step 1: Parsing precomputed benchmark results..."
python3 parsers/parse_results_ocaml.py --source precomputed
echo "  - Parsed data saved to: $EVAL_DIR/parsed_4.1_data_ocaml/precomputed/"
echo ""

# Step 2: Generate figures
echo "Step 2: Generating figures..."
python3 figure_scripts/f14.py --source precomputed
echo "  - Figure 14 saved to: $EVAL_DIR/figures/precomputed/fig14.png"
echo ""

echo "========================================"
echo "OCaml analysis complete!"
echo "========================================"
echo ""
echo "Output files:"
echo "  - Parsed data:  $EVAL_DIR/parsed_4.1_data_ocaml/precomputed/"
echo "  - Figure 14:    $EVAL_DIR/figures/precomputed/fig14.png"
