#!/usr/bin/env python3
"""Main CLI entry point for analysis tool."""

import argparse
import sys
import os
from validators import validate_data, ValidationError
from figure_runners import (
    run_ocaml_plot,
    run_scala_plot,
    run_ocaml_speedups_plot,
    run_etna_plot
)
from config import PRECOMPUTED_PATHS


def generate_output_path(output_dir, figure_name, format='png'):
    """Generate output path for a figure."""
    if output_dir is None:
        return None

    os.makedirs(output_dir, exist_ok=True)
    return os.path.join(output_dir, f"{figure_name}.{format}")


def main():
    parser = argparse.ArgumentParser(
        description='Generate figures from eval scripts using precomputed or user-generated data',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog='''
Examples:
  # Plot OCaml benchmarks from precomputed data
  python analysis.py plot-ocaml --data-dir eval/parsed_4.1_data_ocaml

  # Save figure to file
  python analysis.py plot-ocaml \\
    --data-dir eval/parsed_4.1_data_ocaml \\
    --output /tmp/figure14.png

  # Plot all figures at once
  python analysis.py plot-all \\
    --ocaml-dir eval/parsed_4.1_data_ocaml \\
    --scala-dir eval/parsed_4.1_data_scala \\
    --etna-dir eval/parsed_4.2_data/speedups

  # Validate data before plotting
  python analysis.py validate --figure ocaml --data-dir /path/to/data
        '''
    )

    subparsers = parser.add_subparsers(dest='command', help='Command to run')

    # plot-ocaml command
    ocaml_parser = subparsers.add_parser('plot-ocaml', help='Generate Figure 14 (OCaml benchmarks)')
    ocaml_parser.add_argument('--data-dir', required=True, help='Directory containing OCaml JSON files')
    ocaml_parser.add_argument('--output', help='Output file path (if not specified, displays interactively)')
    ocaml_parser.add_argument('--format', choices=['png', 'pdf', 'svg'], default='png', help='Output format (default: png)')

    # plot-scala command
    scala_parser = subparsers.add_parser('plot-scala', help='Generate Figure 16 (Scala benchmarks)')
    scala_parser.add_argument('--data-dir', required=True, help='Directory containing Scala JSON files')
    scala_parser.add_argument('--output', help='Output file path (if not specified, displays interactively)')
    scala_parser.add_argument('--format', choices=['png', 'pdf', 'svg'], default='png', help='Output format (default: png)')

    # plot-ocaml-speedups command
    speedup_parser = subparsers.add_parser('plot-ocaml-speedups', help='Generate Figure 17 (OCaml speedups)')
    speedup_parser.add_argument('--output', help='Output file path (if not specified, displays interactively)')
    speedup_parser.add_argument('--format', choices=['png', 'pdf', 'svg'], default='png', help='Output format (default: png)')

    # plot-etna command
    etna_parser = subparsers.add_parser('plot-etna', help='Generate Figure 18 (Etna speedups)')
    etna_parser.add_argument('--data-dir', required=True, help='Directory containing Etna speedup JSON files')
    etna_parser.add_argument('--output', help='Output file path (if not specified, displays interactively)')
    etna_parser.add_argument('--format', choices=['png', 'pdf', 'svg'], default='png', help='Output format (default: png)')

    # plot-all command
    all_parser = subparsers.add_parser('plot-all', help='Generate all figures')
    all_parser.add_argument('--ocaml-dir', required=True, help='Directory containing OCaml JSON files')
    all_parser.add_argument('--scala-dir', required=True, help='Directory containing Scala JSON files')
    all_parser.add_argument('--etna-dir', required=True, help='Directory containing Etna speedup JSON files')
    all_parser.add_argument('--output-dir', help='Directory for output files (if not specified, displays interactively)')
    all_parser.add_argument('--format', choices=['png', 'pdf', 'svg'], default='png', help='Output format (default: png)')

    # validate command
    val_parser = subparsers.add_parser('validate', help='Validate data without plotting')
    val_parser.add_argument('--figure', choices=['ocaml', 'scala', 'etna'], required=True, help='Figure type to validate')
    val_parser.add_argument('--data-dir', required=True, help='Directory containing data files')

    # Global options
    parser.add_argument('--verbose', '-v', action='store_true', help='Enable verbose output')

    args = parser.parse_args()

    if args.command is None:
        parser.print_help()
        sys.exit(1)

    # Execute command
    try:
        if args.command == 'plot-ocaml':
            validate_data('ocaml', args.data_dir, args.verbose)
            run_ocaml_plot(args.data_dir, args.output, args.format)
            if not args.output:
                print("\n✓ Figure displayed. Close the plot window to exit.")

        elif args.command == 'plot-scala':
            validate_data('scala', args.data_dir, args.verbose)
            run_scala_plot(args.data_dir, args.output, args.format)
            if not args.output:
                print("\n✓ Figure displayed. Close the plot window to exit.")

        elif args.command == 'plot-ocaml-speedups':
            # No validation needed - uses hardcoded data
            run_ocaml_speedups_plot(args.output, args.format)
            if not args.output:
                print("\n✓ Figure displayed. Close the plot window to exit.")

        elif args.command == 'plot-etna':
            validate_data('etna', args.data_dir, args.verbose)
            run_etna_plot(args.data_dir, args.output, args.format)
            if not args.output:
                print("\n✓ Figure displayed. Close the plot window to exit.")

        elif args.command == 'plot-all':
            # Validate all data first
            print("Validating data...")
            validate_data('ocaml', args.ocaml_dir, args.verbose)
            validate_data('scala', args.scala_dir, args.verbose)
            validate_data('etna', args.etna_dir, args.verbose)
            print("✓ All data validated\n")

            # Generate all plots
            print("Generating figures...")

            print("[1/4] Generating Figure 14 (OCaml benchmarks)...")
            ocaml_output = generate_output_path(args.output_dir, 'figure14_ocaml', args.format)
            run_ocaml_plot(args.ocaml_dir, ocaml_output, args.format)

            print("[2/4] Generating Figure 16 (Scala benchmarks)...")
            scala_output = generate_output_path(args.output_dir, 'figure16_scala', args.format)
            run_scala_plot(args.scala_dir, scala_output, args.format)

            print("[3/4] Generating Figure 17 (OCaml speedups)...")
            speedup_output = generate_output_path(args.output_dir, 'figure17_speedups', args.format)
            run_ocaml_speedups_plot(speedup_output, args.format)

            print("[4/4] Generating Figure 18 (Etna speedups)...")
            etna_output = generate_output_path(args.output_dir, 'figure18_etna', args.format)
            run_etna_plot(args.etna_dir, etna_output, args.format)

            print("\n✓ All figures generated successfully!")
            if args.output_dir:
                print(f"   Saved to: {args.output_dir}")

        elif args.command == 'validate':
            validate_data(args.figure, args.data_dir, verbose=True)
            print(f"\n✓ All required files present and valid for {args.figure}")

    except ValidationError as e:
        print(f"\nERROR: Data validation failed\n{str(e)}", file=sys.stderr)
        print(f"\nRun with --verbose for more details.", file=sys.stderr)
        sys.exit(1)

    except KeyboardInterrupt:
        print("\n\nInterrupted by user.", file=sys.stderr)
        sys.exit(130)

    except Exception as e:
        print(f"\nERROR: {type(e).__name__}: {e}", file=sys.stderr)
        if args.verbose:
            import traceback
            traceback.print_exc()
        sys.exit(1)


if __name__ == '__main__':
    main()
