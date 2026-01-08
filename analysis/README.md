# Analysis CLI Tool

A unified CLI tool to generate figures from eval scripts using either precomputed or user-generated experimental data.

## Quick Start

```bash
cd /home/ubuntu/ff_artifact/analysis

# Generate a single figure from precomputed data
python analysis.py plot-ocaml --data-dir ../eval/parsed_4.1_data_ocaml

# Save to file instead of displaying
python analysis.py plot-ocaml \
  --data-dir ../eval/parsed_4.1_data_ocaml \
  --output figures/figure14.png

# Generate all figures at once
python3 analysis.py plot-all \
  --ocaml-dir ../eval/parsed_4.1_data_ocaml \
  --scala-dir ../eval/parsed_4.1_data_scala \
  --etna-dir ../eval/parsed_4.2_data/speedups \
  --output-dir figures/
```

## Commands

### `plot-ocaml` - Figure 14: OCaml Benchmark Performance

Generate OCaml benchmark scaling plots (6 subplots).

```bash
python analysis.py plot-ocaml --data-dir <path> [--output <path>] [--format png|pdf|svg]
```

**Required data files:**
- `boollist_bespoke.json`
- `bst_bespoke.json`
- `bst_single.json`
- `bst_type.json`
- `stlc_bespoke.json`
- `stlc_type.json`

### `plot-scala` - Figure 16: Scala Benchmark Performance

Generate Scala benchmark scaling plots (3 subplots).

```bash
python analysis.py plot-scala --data-dir <path> [--output <path>] [--format png|pdf|svg]
```

**Required data files:**
- `boollist.json`
- `bst.json`
- `stlc.json`

### `plot-ocaml-speedups` - Figure 17: OCaml Speedup Bar Chart

Generate OCaml speedup bar chart (uses hardcoded reference data).

```bash
python analysis.py plot-ocaml-speedups [--output <path>] [--format png|pdf|svg]
```

**Note:** This command uses hardcoded speedup values and does not require a data directory.

### `plot-etna` - Figure 18: Etna Bug-Finding Speedup Distribution

Generate Etna bug-finding speedup distribution plots (5 subplots).

```bash
python analysis.py plot-etna --data-dir <path> [--output <path>] [--format png|pdf|svg]
```

**Required data files:**
- `bst_type.json`
- `bst_bespoke.json`
- `bst_bespokesingle.json`
- `stlc_type.json`
- `stlc_bespoke.json`

### `plot-all` - Generate All Figures

Generate all four figures in one command.

```bash
python analysis.py plot-all \
  --ocaml-dir <path> \
  --scala-dir <path> \
  --etna-dir <path> \
  [--output-dir <path>] \
  [--format png|pdf|svg]
```

### `validate` - Validate Data Files

Check that all required files exist and are valid JSON before plotting.

```bash
python analysis.py validate --figure {ocaml|scala|etna} --data-dir <path>
```

## Output Formats

- **PNG** (default): Raster image at 300 DPI
- **PDF**: Vector format, suitable for papers
- **SVG**: Vector format, editable in Inkscape/Illustrator

## Data Requirements

### JSON File Structure

All data files must be valid JSON with the following structure:

**OCaml/Scala benchmark data:**
```json
{
  "benchmark_name": {
    "variant_label": {
      "10": 1234.56,
      "100": 12345.67,
      "1000": 123456.78,
      "10000": 1234567.89
    }
  }
}
```

**Etna speedup data:**
```json
{
  "mutant_id": {
    "property_name": {
      "seed": {
        "strategy_name": speedup_value
      }
    }
  }
}
```

## Using Precomputed Data

The precomputed data from eval is located at:

- **OCaml:** `/home/ubuntu/ff_artifact/eval/parsed_4.1_data_ocaml/`
- **Scala:** `/home/ubuntu/ff_artifact/eval/parsed_4.1_data_scala/`
- **Etna:** `/home/ubuntu/ff_artifact/eval/parsed_4.2_data/speedups/`

When running from the `analysis/` directory, use relative paths:
- **OCaml:** `../eval/parsed_4.1_data_ocaml/`
- **Scala:** `../eval/parsed_4.1_data_scala/`
- **Etna:** `../eval/parsed_4.2_data/speedups/`

See `examples/precomputed_data.sh` for a complete example.

## Using User-Generated Data

1. Run your experiments using the artifact scripts
2. Parse the raw output using eval parsers
3. Point the analysis tool at your parsed data directory

See `examples/user_data.sh` for a complete example.

## Validation

Always validate your data before plotting:

```bash
# Validate OCaml data
python analysis.py validate --figure ocaml --data-dir /path/to/data

# Validate with verbose output
python analysis.py validate --figure scala --data-dir /path/to/data --verbose
```

## Troubleshooting

### Missing Files

```
ERROR: Data validation failed
Missing files:
  - bst_single.json not found in /path/to/data
```

**Solution:** Ensure all required JSON files are in the data directory.

### Invalid JSON

```
ERROR: Data validation failed
Invalid JSON files:
  - bst_type.json (Expecting value: line 5 column 10)
```

**Solution:** Check the JSON file for syntax errors. Use `python -m json.tool <file>` to validate.

### Import Errors

```
ModuleNotFoundError: No module named 'matplotlib'
```

**Solution:** The required Python packages (matplotlib, numpy, seaborn) should already be installed in this environment. If not, install with `pip install matplotlib numpy seaborn`.

### Display Issues

If plots don't display interactively, ensure you have a display server available or use the `--output` flag to save to a file instead.

## Examples Directory

The `examples/` directory contains complete usage examples:

- `precomputed_data.sh` - Generate all figures from precomputed eval data
- `user_data.sh` - Generate figures from user-generated data (requires parsed data)

## Dependencies

- Python 3.6+
- matplotlib
- numpy
- seaborn
- json (stdlib)
- argparse (stdlib)

All dependencies are already present in the environment.

## Architecture

The tool is organized into separate modules:

- `config.py` - Configuration constants and file mappings
- `validators.py` - Data validation logic
- `utils.py` - Helper utilities (plt.show interception)
- `figure_runners.py` - Wrapper functions for each figure script
- `analysis.py` - Main CLI entry point

The tool reuses the original eval figure scripts (`f14.py`, `f16.py`, `f17.py`, `f18.py`) by importing them as modules and intercepting `plt.show()` to support file output.
