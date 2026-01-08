#!/bin/bash
# Build script for etna tarball
# Extracts and builds OCaml workloads (BST, STLC, RBT)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARTIFACT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "=== Building ETNA ==="
echo ""

# Find the most recent etna tarball
ETNA_TARBALL=$(ls -t "$ARTIFACT_ROOT"/releases/etna-*.tar.gz 2>/dev/null | head -1)

if [ -z "$ETNA_TARBALL" ]; then
    echo "Error: No etna tarball found in releases/"
    echo "Please run package-artifact.sh first"
    exit 1
fi

echo "Found tarball: $(basename "$ETNA_TARBALL")"
echo ""

# Extract to a build directory
BUILD_DIR="$ARTIFACT_ROOT/build"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

echo "Extracting etna..."
tar -xzf "$ETNA_TARBALL"
echo "✓ Extracted"
echo ""

# Build the OCaml workloads
cd etna

echo "Checking OCaml dependencies..."
echo ""

# Check if required opam packages are installed
REQUIRED_PACKAGES="core ppx_jane ppxlib qcheck crowbar base_quickcheck splittable_random"
MISSING_PACKAGES=""

for pkg in $REQUIRED_PACKAGES; do
    if ! opam list --installed "$pkg" &> /dev/null; then
        MISSING_PACKAGES="$MISSING_PACKAGES $pkg"
    fi
done

if [ -n "$MISSING_PACKAGES" ]; then
    echo "Installing missing OCaml packages:$MISSING_PACKAGES"
    opam install -y $MISSING_PACKAGES
    echo "✓ Dependencies installed"
    echo ""
else
    echo "✓ All dependencies already installed"
    echo ""
fi

# Ensure opam environment is set up
eval $(opam env)

echo "Building OCaml workloads..."
echo ""

# Install util library first
echo "[0/2] Installing util library..."
cd workloads/OCaml/util
opam install . -y
cd - > /dev/null
echo "✓ util library installed"
echo ""

# Build BST
echo "[1/2] Building BST workload..."
cd workloads/OCaml/BST
dune build
cd - > /dev/null
echo "✓ BST built"
echo ""

# Build STLC
echo "[2/2] Building STLC workload..."
cd workloads/OCaml/STLC
dune build
cd - > /dev/null
echo "✓ STLC built"
echo ""

echo "=== ETNA build complete! ==="
echo ""
echo "Built in: $BUILD_DIR/etna"
echo ""
echo "To run experiments:"
echo "  cd $BUILD_DIR/etna"
echo "  ./bash-bst.sh"
echo "  ./bash-stlc.sh"
