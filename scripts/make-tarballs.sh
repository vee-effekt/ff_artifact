#!/bin/bash
# Package ff_artifact repositories into distributable tarballs
# Run this from /home/ubuntu/ff_artifact/repos

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARTIFACT_ROOT="$(dirname "$SCRIPT_DIR")"
REPOS_DIR="$ARTIFACT_ROOT/repos"
OUTPUT_DIR="$ARTIFACT_ROOT/releases"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

# Change to repos directory
cd "$REPOS_DIR"

mkdir -p "$OUTPUT_DIR"

echo "=== Packaging ff_artifact for distribution ==="
echo "Output directory: $OUTPUT_DIR"
echo ""

# Package etna
echo "[1/3] Packaging etna..."
tar -czf "$OUTPUT_DIR/etna-${TIMESTAMP}.tar.gz" \
    --exclude='etna/.git' \
    --exclude='etna/data' \
    --exclude='etna/*-experiments-*' \
    --exclude='etna/oc3-*' \
    --exclude='*/_build' \
    --exclude='*/__pycache__' \
    --exclude='*/dist-newstyle' \
    etna/
echo "✓ Created: etna-${TIMESTAMP}.tar.gz"
echo ""

# Package eval
echo "[2/3] Packaging eval..."
tar -czf "$OUTPUT_DIR/eval-${TIMESTAMP}.tar.gz" \
    --exclude='eval/**/__pycache__' \
    eval/
echo "✓ Created: eval-${TIMESTAMP}.tar.gz"
echo ""

# Package waffle-house
echo "[3/4] Packaging waffle-house..."
tar -czf "$OUTPUT_DIR/waffle-house-${TIMESTAMP}.tar.gz" \
    --exclude='waffle-house/.git' \
    --exclude='waffle-house/**/_build' \
    --exclude='waffle-house/**/dist-newstyle' \
    --exclude='waffle-house/**/.stack-work' \
    --exclude='waffle-house/**/target' \
    waffle-house/
echo "✓ Created: waffle-house-${TIMESTAMP}.tar.gz"
echo ""

echo "=== Packaging complete! ==="
echo ""
echo "Archives created in: $OUTPUT_DIR"
ls -lh "$OUTPUT_DIR"/*.tar.gz
