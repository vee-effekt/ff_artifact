#!/bin/bash
# Master script for one-click reproduction of all "Fail Faster" experiments
# This will take approximately 4-6 hours to complete.

set -e

echo "================================================================================"
echo "  Fail Faster: Staging and Fast Randomness for High-Performance PBT"
echo "  Artifact Evaluation - Complete Reproduction"
echo "================================================================================"
echo ""
echo "This script will reproduce all experiments from the paper:"
echo "  - Figure 14: OCaml generator performance microbenchmarks (~1 hour)"
echo "  - Figure 16: Scala generator performance microbenchmarks (~30 minutes)"
echo "  - Figures 17-18: Etna bug-finding speed experiments (~3-4 hours)"
echo ""
echo "Total estimated time: 4-6 hours"
echo ""
read -p "Press Enter to continue or Ctrl+C to cancel..."
echo ""

# Create output directory
echo "Creating results directory..."
mkdir -p /artifact/results
echo ""

# Phase 1: OCaml Benchmarks
echo "================================================================================"
echo "[1/3] Running OCaml Generator Performance Benchmarks (Figure 14)"
echo "================================================================================"
echo "This compares Base_quickcheck vs AllegrOCaml vs AllegrOCaml+CSplitMix"
echo "Benchmarks: BST (3 strategies), STLC (2 strategies), BoolList"
echo "Sizes: 10, 100, 1000, 10000"
echo ""

START_TIME=$(date +%s)
bash /artifact/scripts/run_ocaml_benchmarks.sh
END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))
echo "Phase 1 completed in $((ELAPSED / 60)) minutes $((ELAPSED % 60)) seconds"
echo ""

# Phase 2: Scala Benchmarks
echo "================================================================================"
echo "[2/3] Running Scala Generator Performance Benchmarks (Figure 16)"
echo "================================================================================"
echo "This compares ScalaCheck vs ScAllegro"
echo "Benchmarks: BST, STLC, BoolList"
echo "Sizes: 10, 100, 1000, 10000"
echo ""

START_TIME=$(date +%s)
bash /artifact/scripts/run_scala_benchmarks.sh
END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))
echo "Phase 2 completed in $((ELAPSED / 60)) minutes $((ELAPSED % 60)) seconds"
echo ""

# Phase 3: Etna Experiments
echo "================================================================================"
echo "[3/3] Running Etna Bug-Finding Speed Experiments (Figures 17-18)"
echo "================================================================================"
echo "This evaluates bug-finding performance across different generator strategies"
echo "BST: 37 tasks × 30 seeds"
echo "STLC: 20 tasks × 30 seeds"
echo ""
echo "WARNING: This phase is the most time-consuming (~3-4 hours)"
echo ""

START_TIME=$(date +%s)
bash /artifact/scripts/run_etna_experiments.sh
END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))
echo "Phase 3 completed in $((ELAPSED / 60)) minutes $((ELAPSED % 60)) seconds"
echo ""

# Summary
echo "================================================================================"
echo "  Reproduction Complete!"
echo "================================================================================"
echo ""
echo "Results have been saved to: /artifact/results/"
echo ""
echo "Output files:"
echo "  - ocaml_benchmarks.csv    (Figure 14 data)"
echo "  - scala_benchmarks.csv    (Figure 16 data)"
echo "  - etna_bst.csv            (Figures 17-18 BST data)"
echo "  - etna_stlc.csv           (Figures 17-18 STLC data)"
echo ""
echo "You can now:"
echo "  1. Inspect the CSV files to verify the data"
echo "  2. Use your plotting infrastructure to generate the figures"
echo "  3. Compare the results with the claims in the paper"
echo ""
echo "Expected results:"
echo "  - Figure 14: AllegrOCaml speedups of 1.3-7× over Base_quickcheck"
echo "               AllegrOCaml+CSplitMix speedups of 2.1-9.8× over Base_quickcheck"
echo "  - Figure 16: ScAllegro speedups of 4.9-13.4× over ScalaCheck"
echo "  - Figures 17-18: Bug-finding speedups of 1.2-3.9× (AllegrOCaml)"
echo "                   Bug-finding speedups of 2.4-3.9× (AllegrOCaml+CSplitMix)"
echo ""
echo "================================================================================"
