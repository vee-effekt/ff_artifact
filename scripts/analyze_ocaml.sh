#!/bin/bash
set -e

# Parse command-line argument for source (default: precomputed)
SOURCE="${1:-precomputed}"

# Validate source argument
if [[ "$SOURCE" != "precomputed" && "$SOURCE" != "fresh" ]]; then
    echo "Error: Invalid source '$SOURCE'. Must be 'precomputed' or 'fresh'."
    echo "Usage: $0 [precomputed|fresh]"
    exit 1
fi

ARTIFACT_DIR="/ff_artifact/artifact"
EVAL_DIR="$ARTIFACT_DIR/eval"

echo "========================================"
echo "OCaml Data Analysis ($SOURCE)"
echo "========================================"
echo ""

cd "$EVAL_DIR"

# Step 1: Parse benchmark results
echo "Step 1: Parsing $SOURCE benchmark results..."
python3 parsers/parse_results_ocaml.py --source "$SOURCE"
echo "  - Parsed data saved to: $EVAL_DIR/parsed_4.1_data_ocaml/$SOURCE/"
echo ""

# Step 2: Generate figures
echo "Step 2: Generating figures..."
python3 figure_scripts/f14.py --source "$SOURCE"
echo "  - Figure 14 saved to: $EVAL_DIR/figures/$SOURCE/fig14.png"
echo ""

echo "========================================"
echo "OCaml analysis complete!"
echo "========================================"
echo ""
echo "Output files:"
echo "  - Parsed data:  $EVAL_DIR/parsed_4.1_data_ocaml/$SOURCE/"
echo "  - Figure 14:    $EVAL_DIR/figures/$SOURCE/fig14.png"
