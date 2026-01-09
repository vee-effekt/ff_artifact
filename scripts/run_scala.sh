#!/bin/bash
set -e

ARTIFACT_DIR="/ff_artifact/artifact"
EVAL_DIR="$ARTIFACT_DIR/eval"
OUTPUT_DIR="$EVAL_DIR/4.1_data_scala/fresh"

echo "========================================"
echo "Scala Benchmark Pipeline"
echo "========================================"
echo ""

# Step 1: Run benchmarks
echo "Step 1: Running Scala/JMH benchmarks..."
cd "$ARTIFACT_DIR/waffle-house/staged-scala"
mkdir -p "$OUTPUT_DIR"
sbt "jmh:run -rf csv -rff $OUTPUT_DIR/results_scala.csv"
echo "  - Raw results saved to: $OUTPUT_DIR/results_scala.csv"
echo ""

# Step 2: Parse benchmark results
echo "Step 2: Parsing benchmark results..."
cd "$EVAL_DIR"
python3 parsers/parse_results_scala_csv.py --source fresh
echo "  - Parsed data saved to: $EVAL_DIR/parsed_4.1_data_scala/fresh/"
echo ""

# Step 3: Generate figures
echo "Step 3: Generating figures..."
python3 figure_scripts/f16.py --source fresh
echo "  - Figure 16 saved to: $EVAL_DIR/figures/fresh/fig16.png"
echo ""

echo "========================================"
echo "Scala benchmark pipeline complete!"
echo "========================================"
echo ""
echo "Output files:"
echo "  - Raw results:  $OUTPUT_DIR/results_scala.csv"
echo "  - Parsed data:  $EVAL_DIR/parsed_4.1_data_scala/fresh/"
echo "  - Figure 16:    $EVAL_DIR/figures/fresh/fig16.png"
