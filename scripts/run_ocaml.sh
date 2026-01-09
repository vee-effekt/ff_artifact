#!/bin/bash

# Navigate to artifact directory
cd /ff_artifact/artifact

# Navigate to staged-ocaml directory
cd waffle-house/staged-ocaml

# Build the project
dune build

# Run benchmarks with CPU pinning and high priority
# - taskset -c 0: pin to CPU core 0
# - nice -n -20: highest priority (requires root)
echo "Running benchmarks pinned to CPU 0 with high priority..."
nice -n -20 taskset -c 0 dune runtest > /ff_artifact/artifact/results/ocaml_results.txt 2>&1

echo "Results saved to /ff_artifact/artifact/results/ocaml_results.txt"