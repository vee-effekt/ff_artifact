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
        "baseBespokesingle", "baseBespokesinglec", "baseBespokesinglestaged", "baseBespokesinglestagedc", "baseBespokesinglestagedcsr",
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

def compute_relative_speedup(data):
    """Computes relative speedup for each strategy based on the slowest in each category."""
    relative_data = defaultdict(lambda: defaultdict(lambda: defaultdict(dict)))
    
    for mutant in data:
        for test in data[mutant]:
            for workload in data[mutant][test]:
                strategies = data[mutant][test][workload]
                
                # Identify slowest for each category, ignoring "timeout"
                slowest = {
                    "baseBespoke": max((strategies.get(s) for s in ["baseBespoke", "baseBespokestaged", "baseBespokestagedc", "baseBespokestagedcsr"] if isinstance(strategies.get(s), float)), default=None),
                    "baseBespokesingle": max((strategies.get(s) for s in ["baseBespokesingle", "baseBespokesinglec", "baseBespokesinglestaged", "baseBespokesinglestagedc", "baseBespokesinglestagedcsr"] if isinstance(strategies.get(s), float)), default=None),
                    "baseType": max((strategies.get(s) for s in ["baseType", "baseStaged", "baseStagedc", "baseStagedcsr"] if isinstance(strategies.get(s), float)), default=None)
                }
                
                # Compute relative speedup
                for strategy, time in strategies.items():
                    if isinstance(time, float):
                        category = "baseBespoke" if strategy.startswith("baseBespoke") and "single" not in strategy else \
                                   "baseBespokesingle" if strategy.startswith("baseBespokesingle") else "baseType"
                        
                        if slowest[category] is not None:
                            relative_data[mutant][test][workload][strategy] = slowest[category] / time
                        else:
                            relative_data[mutant][test][workload][strategy] = None
                    else:
                        relative_data[mutant][test][workload][strategy] = time  # Keep "timeout" as is
    
    return relative_data

def main():
    directory = "oc3"
    output_file = "data.json"
    relative_output_file = "relative_data.json"
    
    structured_data = process_files(directory)
    relative_data = compute_relative_speedup(structured_data)
    
    with open(output_file, 'w') as f:
        json.dump(structured_data, f, indent=4)
    
    with open(relative_output_file, 'w') as f:
        json.dump(relative_data, f, indent=4)
    
    print(f"Data saved to {output_file}")
    print(f"Relative speedup data saved to {relative_output_file}")

if __name__ == "__main__":
    main()