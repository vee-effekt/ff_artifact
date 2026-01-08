"""Helper utilities."""

import matplotlib.pyplot as plt
from config import OUTPUT_FORMATS


def intercept_plot_show(plot_function, output_path=None, format='png'):
    """Execute plotting function and intercept plt.show() for saving.

    Args:
        plot_function: Function that generates the plot and calls plt.show()
        output_path: Path to save figure (if None, uses interactive display)
        format: Output format ('png', 'pdf', or 'svg')
    """
    original_show = plt.show

    try:
        if output_path:
            # Replace plt.show with save function
            def save_instead():
                plt.savefig(output_path, **OUTPUT_FORMATS[format])
                plt.close()
                print(f"Figure saved to: {output_path}")

            plt.show = save_instead

        # Execute the plotting function
        plot_function()

    finally:
        # Restore original show function
        plt.show = original_show
