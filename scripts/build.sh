#!/bin/bash
# Build script for ff_artifact
# Run this inside the Docker container to build all components

set -e

echo "=== Building ff_artifact components ==="
echo ""

# Ensure opam environment is set up
eval $(opam env --switch=4.14.1+BER)

# Install missing OCaml dependencies if needed
echo "[1/5] Installing ppx_show (missing dependency)..."
opam install -y ppx_show
echo ""

# Build waffle-house projects (etna depends on ppx_staged)
echo "[2/5] Building staged-ocaml..."
cd /ff_artifact/artifact/waffle-house/staged-ocaml
dune build @install
opam install . -y
echo ""

echo "[3/5] Building ppx_staged..."
cd /ff_artifact/artifact/waffle-house/ppx_staged
dune build @install
opam install . -y
echo ""

echo "[4/5] Building etna util library..."
cd /ff_artifact/artifact/etna/workloads/OCaml/util
opam install . -y
echo ""

echo "[5/5] Building etna OCaml workloads..."
cd /ff_artifact/artifact/etna/workloads/OCaml/BST && dune build
cd /ff_artifact/artifact/etna/workloads/OCaml/STLC && dune build
cd /ff_artifact/artifact/etna/workloads/OCaml/RBT && dune build
echo ""

echo "=== Build complete! ==="
echo ""
echo "Note: Skipped components:"
echo "  - unboxed-splitmix (requires OxCaml-specific features)"
echo "  - staged-scala (can be built separately with: cd /ff_artifact/artifact/waffle-house/staged-scala && sbt compile)"
