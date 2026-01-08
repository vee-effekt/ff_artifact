#!/bin/bash
# Example: Generate figures using user-generated data
# This assumes you have already run experiments and parsed the results

cd /home/ubuntu/analysis

echo "=== Validating User-Generated Data ==="
echo ""

# Example paths (adjust these to match your actual data locations)
OCAML_DIR="/artifact/results/parsed_ocaml"
SCALA_DIR="/artifact/results/parsed_scala"
ETNA_DIR="/artifact/results/parsed_etna/speedups"

# Validate data before plotting
echo "Validating OCaml data..."
python analysis.py validate --figure ocaml --data-dir "$OCAML_DIR"
echo ""

echo "Validating Scala data..."
python analysis.py validate --figure scala --data-dir "$SCALA_DIR"
echo ""

echo "Validating Etna data..."
python analysis.py validate --figure etna --data-dir "$ETNA_DIR"
echo ""

echo "=== All Data Validated Successfully ==="
echo ""
echo "=== Generating Figures ==="
echo ""

# Generate figures
echo "[1/4] Generating Figure 14 (OCaml benchmarks)..."
python analysis.py plot-ocaml --data-dir "$OCAML_DIR"
echo ""

echo "[2/4] Generating Figure 16 (Scala benchmarks)..."
python analysis.py plot-scala --data-dir "$SCALA_DIR"
echo ""

echo "[3/4] Generating Figure 17 (OCaml speedups)..."
python analysis.py plot-ocaml-speedups
echo ""

echo "[4/4] Generating Figure 18 (Etna speedups)..."
python analysis.py plot-etna --data-dir "$ETNA_DIR"
echo ""

echo "=== All Figures Generated ==="
echo "Figures displayed interactively. Close plot windows to continue."
