import os
import json
import re
from collections import defaultdict

def parse_file(filepath):
    with open(filepath, 'r') as f:
        durations = [float(m.group(1)) for line in f for m in [re.search(r'exit ok, ([0-9.]+) duration', line)] if m]
    return round(sum(durations) / len(durations), 6) if durations else "timeout" if any("exit timeout" in line for line in open(filepath)) else None

def process_files(directory):
    data = defaultdict(lambda: defaultdict(lambda: defaultdict(dict)))
    strategy_order = [
        "baseBespoke", "baseBespokestaged", "baseBespokestagedc", "baseBespokestagedcsr",
        "baseBespokesingle", "baseBespokesinglestaged", "baseBespokesinglestagedc", "baseBespokesinglestagedcsr",
        "baseType", "baseStaged", "baseStagedc", "baseStagedcsr"
    ]
    
    for filename in os.listdir(directory):
        parts = filename.split(',')
        if len(parts) != 4:
            continue
        workload, strategy, mutant, test = parts
        result = parse_file(os.path.join(directory, filename))
        if result is not None:
            data[mutant][test.strip()][workload][strategy] = result
    
    for mutant in data:
        for test in data[mutant]:
            for workload in data[mutant][test]:
                data[mutant][test][workload] = {k: data[mutant][test][workload][k] for k in strategy_order if k in data[mutant][test][workload]}
    
    return data

def main():
    with open("data.json", 'w') as f:
        json.dump(process_files("oc3"), f, indent=4)
    print("Data saved to data.json")

if __name__ == "__main__":
    main()