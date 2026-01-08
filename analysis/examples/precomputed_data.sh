#!/bin/bash
# Example: Generate all figures using precomputed data from eval2

cd /home/ubuntu/analysis

echo "=== Generating Figures from Precomputed Data ==="
echo ""

# Figure 14: OCaml benchmarks
echo "[1/4] Generating Figure 14 (OCaml benchmarks)..."
python analysis.py plot-ocaml \
  --data-dir /home/ubuntu/eval2/parsed_4.1_data_ocaml \
  --output /tmp/figure14_ocaml.png
echo ""

# Figure 16: Scala benchmarks
echo "[2/4] Generating Figure 16 (Scala benchmarks)..."
python analysis.py plot-scala \
  --data-dir /home/ubuntu/eval2/parsed_4.1_data_scala \
  --output /tmp/figure16_scala.png
echo ""

# Figure 17: OCaml speedups (hardcoded data)
echo "[3/4] Generating Figure 17 (OCaml speedups)..."
python analysis.py plot-ocaml-speedups \
  --output /tmp/figure17_speedups.png
echo ""

# Figure 18: Etna speedups
echo "[4/4] Generating Figure 18 (Etna speedups)..."
python analysis.py plot-etna \
  --data-dir /home/ubuntu/eval2/parsed_4.2_data/speedups \
  --output /tmp/figure18_etna.png
echo ""

echo "=== All Figures Generated ==="
echo "Saved to /tmp/"
ls -lh /tmp/figure*.png
