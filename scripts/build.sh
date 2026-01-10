#!/bin/bash
# Build script for ff_artifact
# Run this inside the Docker container to build all components

set -e

echo "=== Building ff_artifact components ==="
echo ""

# Make all scripts executable
echo "[0/6] Making scripts executable..."
chmod +x /ff_artifact/artifact/scripts/*.sh
chmod +x /ff_artifact/artifact/etna/*.sh
echo ""

# Ensure opam environment is set up
eval $(opam env --switch=4.14.1+BER)

# Install missing OCaml dependencies if needed
echo "[1/6] Installing ppx_show (missing dependency)..."
opam install -y ppx_show
echo ""

# Install benchtool Python package
echo "[2/6] Installing benchtool Python package..."
cd /ff_artifact/artifact/etna/tool
pip3 install --break-system-packages -e .
echo ""

# Build waffle-house projects (etna depends on ppx_staged)
echo "[3/6] Building staged-ocaml..."
cd /ff_artifact/artifact/waffle-house/staged-ocaml
dune build @install
opam install . -y
echo ""

echo "[4/6] Building ppx_staged..."
cd /ff_artifact/artifact/waffle-house/ppx_staged
dune build @install
opam install . -y
echo ""

echo "[5/6] Building Etna util library..."
cd /ff_artifact/artifact/etna/workloads/OCaml/util
opam install . -y
echo ""

echo "[6/6] Building and installing etna OCaml workloads..."
cd /ff_artifact/artifact/etna/workloads/OCaml/BST && dune build && opam install . -y
cd /ff_artifact/artifact/etna/workloads/OCaml/STLC && dune build && opam install . -y
echo ""

echo "=== Build complete! ==="
echo ""
echo "Available commands (run from /ff_artifact/artifact):"
echo ""
echo "Run all benchmarks and generate all figures:"
echo "  ./scripts/run_all.sh       - Run (and analyze) ALL benchmarks (OCaml, Scala, Etna)"
echo "  ./scripts/analyze_all.sh   - Analyze ALL precomputed data"
echo ""
echo "Run individual benchmarks (fresh data):"
echo "  ./scripts/run_ocaml.sh     - Run OCaml benchmarks"
echo "  ./scripts/run_scala.sh     - Run Scala benchmarks"
echo "  ./scripts/run_etna.sh      - Run Etna benchmarks"
echo ""
echo "Analyze individual datasets (precomputed data):"
echo "  ./scripts/analyze_ocaml.sh - Generate figures from precomputed OCaml data"
echo "  ./scripts/analyze_scala.sh - Generate figures from precomputed Scala data"
echo "  ./scripts/analyze_etna.sh  - Generate figures from precomputed Etna data"