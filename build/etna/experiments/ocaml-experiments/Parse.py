import re
import os
import json

DATA_PATH = './oc3/'
OUTPUT_FILE = './experiments/ocaml-experiments/json.json'
APPEND = False # if false, will override the contents in OUTPUT_FILE
def parse(filename):
    print(f"Parsing {os.path.basename(filename)}")

    workload, strategy, mutant, prop = os.path.splitext(os.path.basename(filename))[0].split(',')

    with open(filename) as f:
        file = f.read()

    pattern_chunk = r'\[(\d+\.\d+) start \d+\]\s*\[(\d+\.\d+) exit (\d+|timeout|unexpectedly)\]'
    matches = re.findall(pattern_chunk, file)
    print(f"Matches found in {filename}: {matches}")  # Debugging line

    data = []
    for start, end, code in matches:
        s = float(end) - float(start)
        foundbug = code != "timeout"
        if code == "unexpectedly":
            raise ValueError(f"Unexpected failure in {filename}")

        run = {
            "workload": workload,
            "discards": -1,
            "foundbug": foundbug,
            "strategy": strategy,
            "mutant": mutant,
            "passed": -1,
            "property": prop,
            "time": s,
        }
        data.append(run)

    return data


def parse_dir(input_directory, output_file):
    fs = os.listdir(input_directory)
    fs = list(map(lambda f: os.path.join(input_directory, f), fs))
    parsed = [entry for f in fs for entry in parse(f)]

    with open(output_file, 'w') as f:
        json.dump(parsed, f, indent=4)

    print(f"Successfully parsed through {len(fs)} files with {len(parsed)} runs in {input_directory} directory")


def main():
    filenames = os.listdir(DATA_PATH)
    filenames = list(map(lambda s: DATA_PATH + s, filenames))
    parsed = [run for filename in filenames for run in parse(filename)]


    if APPEND and os.path.exists(OUTPUT_FILE):
        with open(OUTPUT_FILE, 'r') as file:
            existing_data = json.load(file)
        print(f"Appending {len(existing_data)} items from existing file.")
    else:
        existing_data = []


    with open(OUTPUT_FILE, 'w') as f:
        json.dump(existing_data + parsed, f, indent=4)

    print(f"Successfully parsed through {DATA_PATH} directory")


if __name__ == '__main__':
    main()