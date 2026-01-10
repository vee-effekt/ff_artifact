#!/bin/bash
set -e

ARTIFACT_DIR="/ff_artifact/artifact"
EVAL_DIR="$ARTIFACT_DIR/eval"
OUTPUT_DIR="$EVAL_DIR/4.2_data/fresh"

echo "========================================"
echo "ETNA Benchmark Pipeline"
echo "========================================"
echo ""

# Step 1: Run BST experiments
echo "Step 1: Running BST mutation testing experiments..."
echo "  - This runs 30 seeds with multiple strategies"
cd "$ARTIFACT_DIR/etna"
./bash-bst.sh
echo "  - BST results saved to: $OUTPUT_DIR/bst-experiments/"
echo ""

# Step 2: Run STLC experiments
echo "Step 2: Running STLC mutation testing experiments..."
echo "  - This runs 30 seeds with multiple strategies"
./bash-stlc.sh
echo "  - STLC results saved to: $OUTPUT_DIR/stlc-experiments/"
echo ""

# Step 3: Fix type workload filenames
echo "Step 3: Fixing type workload filenames..."
echo "  - Renaming baseStaged* to baseTypestaged* for parser compatibility"
bash "$ARTIFACT_DIR/scripts/fix_etna_filenames.sh"
echo ""

# Step 4: Parse benchmark results
echo "Step 4: Parsing benchmark results..."
cd "$EVAL_DIR"
python3 parsers/parse_etna_data.py --source fresh --system BST
python3 parsers/parse_etna_data.py --source fresh --system STLC
echo "  - Parsed data saved to: $EVAL_DIR/parsed_4.2_data/fresh/parsed/"
echo ""

# Step 5: Clean data (remove <5ms and all-timeout entries)
echo "Step 5: Cleaning data (removing outliers)..."
python3 etna_data_processing/clean_under5ms_or_timeout.py --source fresh --system BST
python3 etna_data_processing/clean_under5ms_or_timeout.py --source fresh --system STLC
echo "  - Cleaned data saved to: $EVAL_DIR/parsed_4.2_data/fresh/cleaned/"
echo ""

# Step 6: Calculate speedups
echo "Step 6: Calculating speedups..."
python3 etna_data_processing/calculate_speedups.py --source fresh --system BST --workload type
python3 etna_data_processing/calculate_speedups.py --source fresh --system BST --workload bespoke
python3 etna_data_processing/calculate_speedups.py --source fresh --system BST --workload bespokesingle
python3 etna_data_processing/calculate_speedups.py --source fresh --system STLC --workload type
python3 etna_data_processing/calculate_speedups.py --source fresh --system STLC --workload bespoke
echo "  - Speedup data saved to: $EVAL_DIR/parsed_4.2_data/fresh/speedups/"
echo ""

# Step 7: Generate figures
echo "Step 7: Generating figures..."
python3 figure_scripts/f17.py --source fresh
echo "  - Figure 17 (geometric mean speedups) saved"
python3 figure_scripts/f18.py --source fresh
echo "  - Figure 18 (speedup box plots) saved"
echo ""

echo "========================================"
echo "ETNA benchmark pipeline complete!"
echo "========================================"
echo ""
echo "Output files:"
echo "  - Raw BST data:   $OUTPUT_DIR/bst-experiments/"
echo "  - Raw STLC data:  $OUTPUT_DIR/stlc-experiments/"
echo "  - Parsed data:    $EVAL_DIR/parsed_4.2_data/fresh/"
echo "  - Figure 17:      $EVAL_DIR/figures/fresh/fig17.png"
echo "  - Figure 18:      $EVAL_DIR/figures/fresh/fig18.png"
