#!/bin/bash
# Build script for ff_artifact
# Run this inside the Docker container to build all components

set -e

echo "=== Building ff_artifact components ==="
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

echo "[5/6] Building etna util library..."
cd /ff_artifact/artifact/etna/workloads/OCaml/util
opam install . -y
echo ""

echo "[6/6] Building and installing etna OCaml workloads..."
cd /ff_artifact/artifact/etna/workloads/OCaml/BST && dune build && opam install . -y
cd /ff_artifact/artifact/etna/workloads/OCaml/STLC && dune build && opam install . -y
echo ""

echo "=== Build complete! ==="
echo ""

cd /ff_artifact/artifact
./build.sh