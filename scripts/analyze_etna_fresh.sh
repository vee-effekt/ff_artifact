#!/bin/bash
set -e

ARTIFACT_DIR="/ff_artifact/artifact"
EVAL_DIR="$ARTIFACT_DIR/eval"

echo "========================================"
echo "ETNA Data Analysis (Fresh)"
echo "========================================"
echo ""

cd "$EVAL_DIR"

# Step 1: Parse benchmark results
echo "Step 1: Parsing fresh benchmark results..."
python3 parsers/parse_etna_data.py --source fresh --system BST
python3 parsers/parse_etna_data.py --source fresh --system STLC
echo "  - Parsed data saved to: $EVAL_DIR/parsed_4.2_data/fresh/parsed/"
echo ""

# Step 2: Clean data (remove <5ms and all-timeout entries)
echo "Step 2: Cleaning data (removing outliers)..."
python3 etna_data_processing/clean_under5ms_or_timeout.py --source fresh --system BST
python3 etna_data_processing/clean_under5ms_or_timeout.py --source fresh --system STLC
echo "  - Cleaned data saved to: $EVAL_DIR/parsed_4.2_data/fresh/cleaned/"
echo ""

# Step 3: Calculate speedups
echo "Step 3: Calculating speedups..."
python3 etna_data_processing/calculate_speedups.py --source fresh --system BST --workload type
python3 etna_data_processing/calculate_speedups.py --source fresh --system BST --workload bespoke
python3 etna_data_processing/calculate_speedups.py --source fresh --system BST --workload bespokesingle
python3 etna_data_processing/calculate_speedups.py --source fresh --system STLC --workload type
python3 etna_data_processing/calculate_speedups.py --source fresh --system STLC --workload bespoke
echo "  - Speedup data saved to: $EVAL_DIR/parsed_4.2_data/fresh/speedups/"
echo ""

# Step 4: Generate figures
echo "Step 4: Generating figures..."
python3 figure_scripts/f17.py --source fresh
echo "  - Figure 17 (geometric mean speedups) saved"
python3 figure_scripts/f18.py --source fresh
echo "  - Figure 18 (speedup box plots) saved"
echo ""

echo "========================================"
echo "ETNA analysis complete!"
echo "========================================"
echo ""
echo "Output files:"
echo "  - Parsed data:  $EVAL_DIR/parsed_4.2_data/fresh/"
echo "  - Figure 17:    $EVAL_DIR/figures/fresh/fig17.png"
echo "  - Figure 18:    $EVAL_DIR/figures/fresh/fig18.png"
