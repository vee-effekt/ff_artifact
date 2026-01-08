#!/bin/bash

seeds=(42 3141592 1729 8675309 12345 12121212 987654321 31415 271828 123581321 7777777 1618033 2718281828 31337 8008135 112358 777 1234567890 999999 54321 101010 666 123321 9876543210 6174 1984 2001 867530999 314159265359 1010101010)

# Create dedicated directory for this BST experiment run
EXPERIMENT_DIR="bst-experiments-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$EXPERIMENT_DIR"
echo "All results will be saved to: $EXPERIMENT_DIR"
echo ""

# Loop over the array of hardcoded seeds
for seed in "${seeds[@]}"; do
    echo "Running experiment with seed: $seed"

    # Run the Python script with the current seed
    python3 experiments/ocaml-experiments/Collect.py --data "oc3-bst-${seed}" --workload BST --seed "$seed"

    # Wait for the process to complete
    wait

    # Move it to the experiment directory
    mv "oc3-bst-${seed}" "$EXPERIMENT_DIR/"

    echo "Finished experiment with seed: $seed, results saved in $EXPERIMENT_DIR/oc3-bst-${seed}"
done

echo ""
echo "All experiments completed!"
echo "Results saved to: $EXPERIMENT_DIR"
echo "Total seeds processed: ${#seeds[@]}"
