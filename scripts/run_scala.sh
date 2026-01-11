#!/bin/bash
set -e

ARTIFACT_DIR="/ff_artifact/artifact"
EVAL_DIR="$ARTIFACT_DIR/eval"
OUTPUT_DIR="$EVAL_DIR/4.1_data_scala/fresh"

echo "========================================"
echo "Scala Benchmark Pipeline"
echo "========================================"
echo ""

# Step 1: Run benchmarks in groups to avoid OOM
echo "Step 1: Running Scala/JMH benchmarks (in fine-grained groups to manage memory)..."
cd "$ARTIFACT_DIR/waffle-house/staged-scala"
mkdir -p "$OUTPUT_DIR"

# Run BoolList benchmarks (small sizes)
echo "  - Running BoolList benchmarks (10, 100, 1000)..."
sbt "jmh:run -rf csv -rff $OUTPUT_DIR/results_boollist_small.csv generateBoolListBespoke10|generateBoolListBespoke100|generateBoolListBespoke1000|generateBoolListBespokeStaged10|generateBoolListBespokeStaged100|generateBoolListBespokeStaged1000"
sync && sleep 2

# Run BoolList benchmarks (10000) - individually to avoid OOM
echo "  - Running BoolList benchmarks (10000)..."
sbt "jmh:run -rf csv -rff $OUTPUT_DIR/results_boollist_10k_1.csv generateBoolListBespoke10000"
sync && sleep 2
sbt "jmh:run -rf csv -rff $OUTPUT_DIR/results_boollist_10k_2.csv generateBoolListBespokeStaged10000"
sync && sleep 2

# Run BST Bespoke benchmarks (small sizes)
echo "  - Running BST Bespoke benchmarks (10, 100, 1000)..."
sbt "jmh:run -rf csv -rff $OUTPUT_DIR/results_bst_bespoke_small.csv generateBstBespoke10|generateBstBespoke100|generateBstBespoke1000|generateBstBespokeStaged10|generateBstBespokeStaged100|generateBstBespokeStaged1000"
sync && sleep 2

# Run BST Bespoke benchmarks (10000) - individually to avoid OOM
echo "  - Running BST Bespoke benchmarks (10000)..."
sbt "jmh:run -rf csv -rff $OUTPUT_DIR/results_bst_bespoke_10k_1.csv generateBstBespoke10000"
sync && sleep 2
sbt "jmh:run -rf csv -rff $OUTPUT_DIR/results_bst_bespoke_10k_2.csv generateBstBespokeStaged10000"
sync && sleep 2

# Run STLC Term benchmarks (small sizes)
echo "  - Running STLC Term benchmarks (10, 100, 1000)..."
sbt "jmh:run -rf csv -rff $OUTPUT_DIR/results_stlc_small.csv generateTerm10|generateTerm100|generateTerm1000|generateTermStaged10|generateTermStaged100|generateTermStaged1000"
sync && sleep 2

# Run STLC Term benchmarks (10000) - individually to avoid OOM
echo "  - Running STLC Term benchmarks (10000)..."
sbt "jmh:run -rf csv -rff $OUTPUT_DIR/results_stlc_10k_1.csv generateTerm10000"
sync && sleep 2
sbt "jmh:run -rf csv -rff $OUTPUT_DIR/results_stlc_10k_2.csv generateTermStaged10000"
sync && sleep 2

# Combine all CSV files
echo "  - Combining results..."
cat "$OUTPUT_DIR/results_boollist_small.csv" > "$OUTPUT_DIR/results_scala.csv"
tail -n +2 "$OUTPUT_DIR/results_boollist_10k_1.csv" >> "$OUTPUT_DIR/results_scala.csv"
tail -n +2 "$OUTPUT_DIR/results_boollist_10k_2.csv" >> "$OUTPUT_DIR/results_scala.csv"
tail -n +2 "$OUTPUT_DIR/results_bst_bespoke_small.csv" >> "$OUTPUT_DIR/results_scala.csv"
tail -n +2 "$OUTPUT_DIR/results_bst_bespoke_10k_1.csv" >> "$OUTPUT_DIR/results_scala.csv"
tail -n +2 "$OUTPUT_DIR/results_bst_bespoke_10k_2.csv" >> "$OUTPUT_DIR/results_scala.csv"
tail -n +2 "$OUTPUT_DIR/results_stlc_small.csv" >> "$OUTPUT_DIR/results_scala.csv"
tail -n +2 "$OUTPUT_DIR/results_stlc_10k_1.csv" >> "$OUTPUT_DIR/results_scala.csv"
tail -n +2 "$OUTPUT_DIR/results_stlc_10k_2.csv" >> "$OUTPUT_DIR/results_scala.csv"

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
