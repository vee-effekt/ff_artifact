#!/bin/bash
# Cleans all generated fresh data so benchmarks can be rerun

EVAL_DIR="/ff_artifact/artifact/eval"

echo "========================================"
echo "Cleaning Fresh Data"
echo "========================================"
echo ""

# Raw benchmark data
echo "Removing raw benchmark data..."
rm -rf "$EVAL_DIR/4.1_data_ocaml/fresh"/*
rm -rf "$EVAL_DIR/4.1_data_scala/fresh"/*
rm -rf "$EVAL_DIR/4.2_data/fresh"/*

# Parsed data
echo "Removing parsed data..."
rm -rf "$EVAL_DIR/parsed_4.1_data_ocaml/fresh"/*
rm -rf "$EVAL_DIR/parsed_4.1_data_scala/fresh"/*
rm -rf "$EVAL_DIR/parsed_4.2_data/fresh"/*

# Generated figures
echo "Removing generated figures..."
rm -rf "$EVAL_DIR/figures/fresh"/*

echo ""
echo "========================================"
echo "Clean complete!"
echo "========================================"
echo ""
echo "Cleared directories:"
echo "  - $EVAL_DIR/4.1_data_ocaml/fresh/"
echo "  - $EVAL_DIR/4.1_data_scala/fresh/"
echo "  - $EVAL_DIR/4.2_data/fresh/"
echo "  - $EVAL_DIR/parsed_4.1_data_ocaml/fresh/"
echo "  - $EVAL_DIR/parsed_4.1_data_scala/fresh/"
echo "  - $EVAL_DIR/parsed_4.2_data/fresh/"
echo "  - $EVAL_DIR/figures/fresh/"
