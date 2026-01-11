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

# Step 2: Measure compilation times
echo "Step 3: Measuring compilation times..."
cd "$ARTIFACT_DIR/waffle-house/staged-ocaml"
COMPILE_OUTPUT_DIR="$EVAL_DIR/figures/fresh"
mkdir -p "$COMPILE_OUTPUT_DIR"
dune exec test_compile_time > "$COMPILE_OUTPUT_DIR/compilation_times.txt" 2>&1
echo "  - Compilation times saved to: $COMPILE_OUTPUT_DIR/compilation_times.txt"
echo ""

# Step 3: Run benchmarks
echo "Step 2: Running OCaml benchmarks..."
echo "  - Pinning to CPU core 0 for consistent timing"
mkdir -p "$OUTPUT_DIR"

echo "  - Running BST bespoke benchmark..."
taskset -c 0 dune exec /ff_artifact/artifact/waffle-house/staged-ocaml/_build/default/test/bst_benchmark.exe > "$OUTPUT_DIR/results_bst.txt" 2>&1

echo "  - Running BST type benchmark..."
taskset -c 0 dune exec /ff_artifact/artifact/waffle-house/staged-ocaml/_build/default/test/bst_type_benchmark.exe > "$OUTPUT_DIR/results_bsttype.txt" 2>&1

echo "  - Running BST single benchmark..."
taskset -c 0 dune exec /ff_artifact/artifact/waffle-house/staged-ocaml/_build/default/test/bst_single_benchmark.exe > "$OUTPUT_DIR/results_bstsingle.txt" 2>&1

echo "  - Running STLC benchmark..."
taskset -c 0 dune exec /ff_artifact/artifact/waffle-house/staged-ocaml/_build/default/test/stlc_benchmark.exe > "$OUTPUT_DIR/results_stlc.txt" 2>&1

echo "  - Running STLC type benchmark..."
taskset -c 0 dune exec /ff_artifact/artifact/waffle-house/staged-ocaml/_build/default/test/stlc_benchmark_type.exe > "$OUTPUT_DIR/results_stlctype.txt" 2>&1

echo "  - Running BoolList benchmark..."
taskset -c 0 dune exec /ff_artifact/artifact/waffle-house/staged-ocaml/_build/default/test/boollist_benchmark.exe > "$OUTPUT_DIR/results_boollist.txt" 2>&1

echo "  - All benchmarks complete. Results saved to: $OUTPUT_DIR/"
echo ""

# Step 4: Parse benchmark results
echo "Step 4: Parsing benchmark results..."
cd "$EVAL_DIR"
python3 parsers/parse_results_ocaml.py --source fresh
echo "  - Parsed data saved to: $EVAL_DIR/parsed_4.1_data_ocaml/fresh/"
echo ""

# Step 5: Generate figures
echo "Step 5: Generating figures..."
python3 figure_scripts/f14.py --source fresh
echo "  - Figure 14 saved to: $EVAL_DIR/figures/fresh/fig14.png"
python3 figure_scripts/f15.py --source fresh
echo "  - Figure 15 saved to: $EVAL_DIR/figures/fresh/fig15.png"
echo ""

echo "========================================"
echo "OCaml benchmark pipeline complete!"
echo "========================================"
echo ""
echo "Output files:"
echo "  - Raw results:       $OUTPUT_DIR/"
echo "  - Parsed data:       $EVAL_DIR/parsed_4.1_data_ocaml/fresh/"
echo "  - Compilation times: $EVAL_DIR/figures/fresh/compilation_times.txt"
echo "  - Figure 14:         $EVAL_DIR/figures/fresh/fig14.png"
echo "  - Figure 15:         $EVAL_DIR/figures/fresh/fig15.png"
