#!/bin/bash
set -e
set -o pipefail

echo "========================================"
echo "Fixing ETNA Type Workload Filenames"
echo "========================================"
echo ""

# Base directory for fresh data
FRESH_DATA_DIR="/ff_artifact/artifact/eval/4.2_data/fresh"

# Function to rename files in a directory
rename_files_in_dir() {
    local dir=$1
    local count=0

    echo "Processing: $dir"

    # Rename baseStaged -> baseTypestaged
    shopt -s nullglob
    for file in "$dir"/BST,baseStaged,* "$dir"/STLC,baseStaged,*; do
        if [ -f "$file" ]; then
            newfile=$(echo "$file" | sed 's/,baseStaged,/,baseTypestaged,/')
            mv "$file" "$newfile"
            count=$((count + 1))
        fi
    done

    # Rename baseStagedc -> baseTypestagedc
    for file in "$dir"/BST,baseStagedc,* "$dir"/STLC,baseStagedc,*; do
        if [ -f "$file" ]; then
            newfile=$(echo "$file" | sed 's/,baseStagedc,/,baseTypestagedc,/')
            mv "$file" "$newfile"
            count=$((count + 1))
        fi
    done

    # Rename baseStagedcsr -> baseTypestagedcsr
    for file in "$dir"/BST,baseStagedcsr,* "$dir"/STLC,baseStagedcsr,*; do
        if [ -f "$file" ]; then
            newfile=$(echo "$file" | sed 's/,baseStagedcsr,/,baseTypestagedcsr,/')
            mv "$file" "$newfile"
            count=$((count + 1))
        fi
    done
    shopt -u nullglob

    echo "  Renamed $count files"
}

# Process BST experiments
if [ -d "$FRESH_DATA_DIR/bst-experiments" ]; then
    echo ""
    echo "Processing BST experiments..."
    total_count=0
    for seed_dir in "$FRESH_DATA_DIR/bst-experiments"/oc3-bst-*; do
        if [ -d "$seed_dir" ]; then
            rename_files_in_dir "$seed_dir"
            total_count=$((total_count + 1))
        fi
    done
    echo "Processed $total_count BST seed directories"
fi

# Process STLC experiments
if [ -d "$FRESH_DATA_DIR/stlc-experiments" ]; then
    echo ""
    echo "Processing STLC experiments..."
    total_count=0
    for seed_dir in "$FRESH_DATA_DIR/stlc-experiments"/oc3-stlc-*; do
        if [ -d "$seed_dir" ]; then
            rename_files_in_dir "$seed_dir"
            total_count=$((total_count + 1))
        fi
    done
    echo "Processed $total_count STLC seed directories"
fi

echo ""
echo "========================================"
echo "Filename fixing complete!"
echo "========================================"
