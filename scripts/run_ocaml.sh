#!/bin/bash
set -e

ARTIFACT_DIR="/ff_artifact/artifact"
EVAL_DIR="$ARTIFACT_DIR/eval"
OUTPUT_DIR="$EVAL_DIR/4.1_data_ocaml/fresh"

echo "========================================"
echo "OCaml Benchmark Pipeline"
echo "========================================"
echo ""

# Step 1: Build the project
echo "Step 1: Building staged-ocaml project..."
cd "$ARTIFACT_DIR/waffle-house/staged-ocaml"
dune build
echo "Build complete."
echo ""

# Step 2: Run benchmarks
echo "Step 2: Running OCaml benchmarks..."
echo "  - Pinning to CPU core 0 for consistent timing"
mkdir -p "$OUTPUT_DIR"
taskset -c 0 dune runtest --force > "$OUTPUT_DIR/results_ocaml.txt" 2>&1
echo "  - Raw results saved to: $OUTPUT_DIR/results_ocaml.txt"
echo ""

# Step 3: Parse benchmark results
echo "Step 3: Parsing benchmark results..."
cd "$EVAL_DIR"
python3 parsers/parse_results_ocaml.py --source fresh
echo "  - Parsed data saved to: $EVAL_DIR/parsed_4.1_data_ocaml/fresh/"
echo ""

# Step 4: Generate figures
echo "Step 4: Generating figures..."
python3 figure_scripts/f14.py --source fresh
echo "  - Figure 14 saved to: $EVAL_DIR/figures/fresh/fig14.png"
echo ""

echo "========================================"
echo "OCaml benchmark pipeline complete!"
echo "========================================"
echo ""
echo "Output files:"
echo "  - Raw results:  $OUTPUT_DIR/results_ocaml.txt"
echo "  - Parsed data:  $EVAL_DIR/parsed_4.1_data_ocaml/fresh/"
echo "  - Figure 14:    $EVAL_DIR/figures/fresh/fig14.png"
