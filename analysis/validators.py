"""Data validation functions."""

import os
import json
from config import REQUIRED_FILES


class ValidationError(Exception):
    """Raised when data validation fails."""
    pass


def validate_data(figure_type, data_dir, verbose=False):
    """Validate data directory for a specific figure type.

    Args:
        figure_type: One of 'ocaml', 'scala', or 'etna'
        data_dir: Path to directory containing JSON data files
        verbose: If True, print detailed validation information

    Raises:
        ValidationError: If validation fails (missing or invalid files)
    """
    if figure_type not in REQUIRED_FILES:
        raise ValidationError(f"Unknown figure type: {figure_type}. Must be one of: {list(REQUIRED_FILES.keys())}")

    required = REQUIRED_FILES[figure_type]
    missing = []
    invalid = []

    for filename in required:
        filepath = os.path.join(data_dir, filename)

        # Check file exists
        if not os.path.exists(filepath):
            missing.append(filename)
            continue

        # Check valid JSON
        try:
            with open(filepath, 'r') as f:
                data = json.load(f)

            # Basic structure validation
            if not isinstance(data, dict):
                invalid.append(f"{filename} (not a JSON object)")

        except json.JSONDecodeError as e:
            invalid.append(f"{filename} ({str(e)})")
        except Exception as e:
            invalid.append(f"{filename} (error: {str(e)})")

    # Report errors
    if missing or invalid:
        error_parts = []
        if missing:
            error_parts.append("Missing files:\n  - " + "\n  - ".join(missing))
        if invalid:
            error_parts.append("Invalid JSON files:\n  - " + "\n  - ".join(invalid))

        raise ValidationError('\n\n'.join(error_parts))

    if verbose:
        print(f"✓ All {len(required)} required files validated for {figure_type} in {data_dir}")
