"""Wrapper functions for running figure scripts."""

import sys
import os

# Add eval2 figure scripts to path
sys.path.insert(0, '/home/ubuntu/eval2/figure_scripts')

from utils import intercept_plot_show


def run_ocaml_plot(data_dir, output_path=None, format='png'):
    """Run f14.py for OCaml benchmarks (Figure 14).

    Args:
        data_dir: Directory containing OCaml JSON files
        output_path: Path to save figure (if None, displays interactively)
        format: Output format ('png', 'pdf', or 'svg')
    """
    def plot():
        import f14

        # Modify sys.argv to pass directory argument to f14
        old_argv = sys.argv
        try:
            sys.argv = ['f14.py', data_dir]
            f14.main()
        finally:
            sys.argv = old_argv

    intercept_plot_show(plot, output_path, format)


def run_scala_plot(data_dir, output_path=None, format='png'):
    """Run f16.py for Scala benchmarks (Figure 16).

    Args:
        data_dir: Directory containing Scala JSON files
        output_path: Path to save figure (if None, displays interactively)
        format: Output format ('png', 'pdf', or 'svg')
    """
    def plot():
        import f16

        # Load data and plot (working around f16 bug)
        parsed_data = f16.load_data_from_directory(data_dir)
        f16.plot(parsed_data)

    intercept_plot_show(plot, output_path, format)


def run_ocaml_speedups_plot(output_path=None, format='png'):
    """Run f17.py for OCaml speedups (Figure 17).

    This uses hardcoded data, so no data directory is needed.

    Args:
        output_path: Path to save figure (if None, displays interactively)
        format: Output format ('png', 'pdf', or 'svg')
    """
    def plot():
        # f17 has all code at module level, execute as script
        with open('/home/ubuntu/eval2/figure_scripts/f17.py') as f:
            code = f.read()
        exec(code, {'__name__': '__main__'})

    intercept_plot_show(plot, output_path, format)


def run_etna_plot(data_dir, output_path=None, format='png'):
    """Run f18.py for Etna speedups (Figure 18).

    Args:
        data_dir: Directory containing Etna speedup JSON files
        output_path: Path to save figure (if None, displays interactively)
        format: Output format ('png', 'pdf', or 'svg')
    """
    def plot():
        # f18 executes on import - use exec with modified sys.argv
        old_argv = sys.argv
        try:
            sys.argv = ['f18.py', '--dir', data_dir]
            with open('/home/ubuntu/eval2/figure_scripts/f18.py') as f:
                code = f.read()
            exec(code, {'__name__': '__main__'})
        finally:
            sys.argv = old_argv

    intercept_plot_show(plot, output_path, format)
