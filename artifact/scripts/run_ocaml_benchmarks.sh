#!/bin/bash
# Run all OCaml generator performance benchmarks for Figure 14
# Outputs: results/ocaml_benchmarks.csv

set -e

echo "=== Running OCaml Performance Benchmarks (Figure 14) ==="
echo ""

cd /artifact/waffle-house/staged-ocaml

# Run benchmarks with Core_bench
# This will benchmark all generator variants across different sizes
# Strategies: bst_type, bst_insert, bst_single, stlc_type, stlc, boollist
# Treatments: base_quickcheck (bq), staged with SplittableRandom (staged_sr), staged with CSplitMix (staged_csr)
# Sizes: 10, 100, 1000, 10000

opam exec -- dune exec test/test_fast_gen.exe -- --benchmark \
  --sizes 10,100,1000,10000 \
  --strategies bst_type,bst_insert,bst_single,stlc_type,stlc,boollist \
  --treatments bq,staged_sr,staged_csr \
  --duration 5s \
  --output /artifact/results/ocaml_benchmarks.csv

echo ""
echo "OCaml benchmarks complete. Results saved to: /artifact/results/ocaml_benchmarks.csv"
