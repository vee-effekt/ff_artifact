#!/bin/bash
# Run all Scala generator performance benchmarks for Figure 16
# Outputs: results/scala_benchmarks.csv

set -e

echo "=== Running Scala Performance Benchmarks (Figure 16) ==="
echo ""

cd /artifact/waffle-house/staged-scala

# Run JMH benchmarks
# This will benchmark ScalaCheck vs ScAllegro generators
# Benchmarks: BST (single-pass), STLC, BoolList
# Sizes: 10, 100, 1000, 10000

sbt "jmh:run -rf csv -rff /artifact/results/scala_benchmarks.csv"

echo ""
echo "Scala benchmarks complete. Results saved to: /artifact/results/scala_benchmarks.csv"
