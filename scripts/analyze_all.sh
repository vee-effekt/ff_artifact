#!/bin/bash
set -e

# Parse command-line argument for source (default: precomputed)
SOURCE="${1:-precomputed}"

# Validate source argument
if [[ "$SOURCE" != "precomputed" && "$SOURCE" != "fresh" ]]; then
    echo "Error: Invalid source '$SOURCE'. Must be 'precomputed' or 'fresh'."
    echo "Usage: $0 [precomputed|fresh]"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "========================================"
echo "Analyzing ALL $SOURCE Data"
echo "========================================"
echo ""

# Analyze OCaml data
"$SCRIPT_DIR/analyze_ocaml.sh" "$SOURCE"
echo ""

# Analyze Scala data
"$SCRIPT_DIR/analyze_scala.sh" "$SOURCE"
echo ""

# Analyze ETNA data
"$SCRIPT_DIR/analyze_etna.sh" "$SOURCE"
echo ""

echo "========================================"
echo "All analysis complete!"
echo "========================================"
echo ""
echo "$SOURCE data figures generated:"
echo "  - Figure 14: eval/figures/$SOURCE/fig14.png (OCaml)"
echo "  - Figure 16: eval/figures/$SOURCE/fig16.png (Scala)"
echo "  - Figure 17: eval/figures/$SOURCE/fig17.png (ETNA geometric mean)"
echo "  - Figure 18: eval/figures/$SOURCE/fig18.png (ETNA box plots)"
