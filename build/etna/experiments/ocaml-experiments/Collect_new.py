import os
import json
import re
from collections import defaultdict

def parse_file(filepath):
    """Extracts runtime or timeout status from the given file."""
    with open(filepath, 'r') as f:
        lines = f.readlines()
    
    if len(lines) == 1:
        return None  # Only '[start]' present
    
    match = re.search(r'exit ok, ([0-9.]+) duration', lines[1])
    if match:
        return float(match.group(1))  # Return duration as a float
    
    if "exit timeout" in lines[1]:
        return "timeout"
    
    return None

def process_files(directory):
    """Processes all files in the given directory and structures the data accordingly."""
    data = defaultdict(lambda: defaultdict(lambda: defaultdict(dict)))
    strategy_order = [
        "baseBespoke", "baseBespokestaged", "baseBespokestagedc", "baseBespokestagedcsr",
        "baseBespokesingle", "baseBespokesinglestaged", "baseBespokesinglestagedc", "baseBespokesinglestagedcsr",
        "baseType", "baseStaged", "baseStagedc", "baseStagedcsr"
    ]
    
    for filename in os.listdir(directory):
        parts = filename.split(',')
        if len(parts) != 4:
            continue  # Skip unexpected filenames
        
        workload, strategy, mutant, test = parts
        test = test.strip()
        filepath = os.path.join(directory, filename)
        result = parse_file(filepath)
        
        if result is not None:
            data[mutant][test][workload][strategy] = result
    
    # Sort strategies based on hardcoded order within each workload
    for mutant in data:
        for test in data[mutant]:
            for workload in data[mutant][test]:
                data[mutant][test][workload] = {
                    k: data[mutant][test][workload][k]
                    for k in strategy_order if k in data[mutant][test][workload]
                }
    
    return data

def main():
    directory = "oc3"
    output_file = "data.json"
    
    structured_data = process_files(directory)
    
    with open(output_file, 'w') as f:
        json.dump(structured_data, f, indent=4)
    
    print(f"Data saved to {output_file}")

if __name__ == "__main__":
    main()
