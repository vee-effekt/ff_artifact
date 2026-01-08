"""Configuration constants for the analysis tool."""

import os

# Path to eval2 figure scripts
EVAL2_FIGURES_DIR = '/home/ubuntu/eval2/figure_scripts'

# Required files for each figure type
REQUIRED_FILES = {
    'ocaml': [
        'boollist_bespoke.json',
        'bst_bespoke.json',
        'bst_single.json',
        'bst_type.json',
        'stlc_bespoke.json',
        'stlc_type.json'
    ],
    'scala': [
        'boollist.json',
        'bst.json',
        'stlc.json'
    ],
    'etna': [
        'bst_type.json',
        'bst_bespoke.json',
        'bst_bespokesingle.json',
        'stlc_type.json',
        'stlc_bespoke.json'
    ]
}

# Expected data structure sizes
EXPECTED_SIZES = [10, 100, 1000, 10000]

# Output format settings
OUTPUT_FORMATS = {
    'png': {'dpi': 300, 'bbox_inches': 'tight'},
    'pdf': {'bbox_inches': 'tight'},
    'svg': {'bbox_inches': 'tight'}
}

# Precomputed data paths (for documentation and examples)
PRECOMPUTED_PATHS = {
    'ocaml': '/home/ubuntu/eval2/parsed_4.1_data_ocaml',
    'scala': '/home/ubuntu/eval2/parsed_4.1_data_scala',
    'etna': '/home/ubuntu/eval2/parsed_4.2_data/speedups'
}
