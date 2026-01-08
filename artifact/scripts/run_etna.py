#!/usr/bin/env python3
"""
Self-contained script to run Etna bug-finding experiments for Figures 17-18.
This script directly calls Etna workloads and collects results in CSV format.
"""

import subprocess
import os
import csv
import json
import sys
from pathlib import Path
from typing import List, Dict, Tuple

# Configuration
ETNA_PATH = Path("/artifact/etna2")
RESULTS_PATH = Path("/artifact/results")
WORKLOADS_PATH = ETNA_PATH / "workloads" / "OCaml"

# Paper configuration - Figures 17-18
BST_STRATEGIES = [
    ('base', 'bespoke'),           # Base_quickcheck bespoke
    ('base', 'bespokeSingle'),     # Base_quickcheck single-pass
    ('base', 'type'),              # Base_quickcheck type-based
    ('base', 'bespokeStaged'),     # AllegrOCaml bespoke + SR
    ('base', 'bespokeSingleStaged'), # AllegrOCaml single-pass + SR
    ('base', 'staged'),            # AllegrOCaml type + SR
    ('base', 'bespokeStagedC'),    # AllegrOCaml bespoke + CSplitMix
    ('base', 'bespokeSingleStagedC'), # AllegrOCaml single-pass + CSplitMix
    ('base', 'stagedC'),           # AllegrOCaml type + CSplitMix
]

STLC_STRATEGIES = [
    ('base', 'bespoke'),           # Base_quickcheck bespoke
    ('base', 'type'),              # Base_quickcheck type-based
    ('base', 'bespokeStaged'),     # AllegrOCaml bespoke + SR
    ('base', 'staged'),            # AllegrOCaml type + SR
    ('base', 'bespokeStagedC'),    # AllegrOCaml bespoke + CSplitMix
    ('base', 'stagedC'),           # AllegrOCaml type + CSplitMix
]

NUM_SEEDS = 30
TIMEOUT = 60  # seconds

def get_workload_properties(workload: str) -> List[str]:
    """Get all properties for a workload by reading its main.ml"""
    # This is a simplified version - in practice you'd parse the OCaml file
    # or maintain a configuration
    if workload == 'BST':
        # BST has many properties - this is an example subset
        return [
            'prop_InsertValid',
            'prop_DeleteValid',
            'prop_UnionValid',
            # Add all 37 properties here
        ]
    elif workload == 'STLC':
        return [
            'prop_SubstPreserves',
            'prop_EvalPreserves',
            # Add all 20 properties here
        ]
    return []

def run_etna_trial(workload: str, framework: str, strategy: str,
                   property: str, seed: int, timeout: int = 60) -> Dict:
    """Run a single Etna trial and return results"""
    workload_path = WORKLOADS_PATH / workload
    output_file = f"/tmp/etna_{workload}_{framework}_{strategy}_{property}_{seed}.out"

    cmd = [
        'opam', 'exec', '--',
        'dune', 'exec', workload,
        '--',
        framework,
        property,
        strategy,
        output_file
    ]

    try:
        result = subprocess.run(
            cmd,
            cwd=str(workload_path),
            timeout=timeout,
            capture_output=True,
            text=True
        )

        # Parse output file to extract timing information
        time_to_bug = None
        tests_run = 0
        found_bug = False

        if os.path.exists(output_file):
            with open(output_file, 'r') as f:
                # Parse Etna output format
                # This is simplified - actual parsing depends on output format
                content = f.read()
                if 'Bug found' in content or 'Failed' in content:
                    found_bug = True
                    # Extract timing info
                    # time_to_bug = parse_time(content)

        return {
            'workload': workload,
            'framework': framework,
            'strategy': strategy,
            'property': property,
            'seed': seed,
            'found_bug': found_bug,
            'time_to_bug': time_to_bug,
            'tests_run': tests_run,
            'timed_out': result.returncode != 0
        }

    except subprocess.TimeoutExpired:
        return {
            'workload': workload,
            'framework': framework,
            'strategy': strategy,
            'property': property,
            'seed': seed,
            'found_bug': False,
            'time_to_bug': None,
            'tests_run': 0,
            'timed_out': True
        }
    except Exception as e:
        print(f"Error running trial: {e}", file=sys.stderr)
        return None

def run_workload_experiments(workload: str, strategies: List[Tuple[str, str]],
                             output_file: Path):
    """Run all experiments for a workload and save to CSV"""
    properties = get_workload_properties(workload)
    results = []

    total_trials = len(properties) * len(strategies) * NUM_SEEDS
    current_trial = 0

    print(f"Running {workload} experiments: {len(properties)} properties × "
          f"{len(strategies)} strategies × {NUM_SEEDS} seeds = {total_trials} trials")

    for property in properties:
        for framework, strategy in strategies:
            for seed in range(NUM_SEEDS):
                current_trial += 1
                print(f"[{current_trial}/{total_trials}] "
                      f"{workload} / {framework}:{strategy} / {property} / seed {seed}")

                result = run_etna_trial(workload, framework, strategy, property,
                                       seed, TIMEOUT)
                if result:
                    results.append(result)

    # Write to CSV
    if results:
        with open(output_file, 'w', newline='') as f:
            writer = csv.DictWriter(f, fieldnames=results[0].keys())
            writer.writeheader()
            writer.writerows(results)

        print(f"Results saved to {output_file}")

def main():
    """Main entry point"""
    RESULTS_PATH.mkdir(parents=True, exist_ok=True)

    # Run BST experiments
    print("=" * 60)
    print("Running BST experiments (Figure 17-18)")
    print("=" * 60)
    run_workload_experiments('BST', BST_STRATEGIES,
                            RESULTS_PATH / 'etna_bst.csv')

    # Run STLC experiments
    print("\n" + "=" * 60)
    print("Running STLC experiments (Figure 17-18)")
    print("=" * 60)
    run_workload_experiments('STLC', STLC_STRATEGIES,
                            RESULTS_PATH / 'etna_stlc.csv')

    print("\nAll Etna experiments complete!")

if __name__ == '__main__':
    main()
