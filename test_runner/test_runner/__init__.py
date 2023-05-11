import csv
import os
from pathlib import Path
from typing import Dict, List

def find_json_files(directory: str) -> List[str]:
    """
    Find JSON files in the specified directory and return a list of their file paths.

    Args:
        directory: The directory to search for JSON files.

    Returns:
        A list of file paths to JSON files.
    """
    json_files = []
    for root, _dirs, files in os.walk(directory):
        for file in files:
            if os.path.basename(file) == 'test.json':
                json_files.append(os.path.join(root, file))
    return json_files

def write_results_to_csv(results: List[Dict[str, str]], output_file: Path):
    """
    Write the results to a CSV file using csv.DictWriter.

    Args:
        results: A list of dictionaries representing the results.
        output_file: The path to the output CSV file.
    """
    # Extract all the keys from the dictionaries
    keys = set().union(*results)

    # Write the results to the CSV file
    with open(output_file, "w", newline="") as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=keys)
        writer.writeheader()
        writer.writerows(results)
