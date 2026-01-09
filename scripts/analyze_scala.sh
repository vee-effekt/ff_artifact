#!/bin/bash
set -e

ARTIFACT_DIR="/ff_artifact/artifact"
EVAL_DIR="$ARTIFACT_DIR/eval"

echo "========================================"
echo "Scala Data Analysis (Precomputed)"
echo "========================================"
echo ""

cd "$EVAL_DIR"

# Step 1: Parse benchmark results
echo "Step 1: Parsing precomputed benchmark results..."
python3 parsers/parse_results_scala_csv.py --source precomputed
echo "  - Parsed data saved to: $EVAL_DIR/parsed_4.1_data_scala/precomputed/"
echo ""

# Step 2: Generate figures
echo "Step 2: Generating figures..."
python3 figure_scripts/f16.py --source precomputed
echo "  - Figure 16 saved to: $EVAL_DIR/figures/precomputed/fig16.png"
echo ""

echo "========================================"
echo "Scala analysis complete!"
echo "========================================"
echo ""
echo "Output files:"
echo "  - Parsed data:  $EVAL_DIR/parsed_4.1_data_scala/precomputed/"
echo "  - Figure 16:    $EVAL_DIR/figures/precomputed/fig16.png"
