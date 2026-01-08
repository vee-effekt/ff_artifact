#!/bin/bash
# Run Etna bug-finding speed experiments for Figures 17-18
# Outputs: results/etna_bst.csv, results/etna_stlc.csv

set -e

echo "=== Running Etna Bug-Finding Experiments (Figures 17-18) ==="
echo ""

# Use the run_etna.py script for self-contained execution
cd /artifact/scripts

python3 run_etna.py

echo ""
echo "Etna experiments complete!"
echo "Results saved to:"
echo "  - /artifact/results/etna_bst.csv"
echo "  - /artifact/results/etna_stlc.csv"
