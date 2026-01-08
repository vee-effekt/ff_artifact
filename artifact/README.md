# Fail Faster - Artifact Evaluation

This artifact contains all code and scripts necessary to reproduce the experimental evaluation from the paper "Fail Faster: Staging and Fast Randomness for High-Performance PBT".

## Quick Start (Automated Reproduction)

### Prerequisites

- Docker 20.10+ installed
- ~100GB free disk space
- 4-6 hours for complete reproduction
- Internet connection (for Docker base image and package installation)

### One-Click Reproduction

From the `artifact` directory, run:

```bash
# Build the Docker image (~30-60 minutes)
docker build -t fail-faster-artifact .

# Run all experiments (~4-6 hours)
docker run -v $(pwd)/results:/artifact/results fail-faster-artifact \
  bash /artifact/scripts/reproduce_all.sh

# Results will be saved to ./results/
```

The reproduction script will:
1. Run OCaml performance benchmarks (Figure 14 data)
2. Run Scala performance benchmarks (Figure 16 data)
3. Run Etna bug-finding experiments (Figures 17-18 data)

All results are saved as CSV files in the `results/` directory.

## Scope of Artifact

### Experiments Included

This artifact reproduces the following experiments from the paper:

1. **Figure 14** - OCaml Generator Performance Microbenchmarks
   - Compares Base_quickcheck vs AllegrOCaml vs AllegrOCaml+CSplitMix
   - Benchmarks: BST (3 strategies), STLC (2 strategies), BoolList
   - Generator sizes: 10, 100, 1000, 10000

2. **Figure 16** - Scala Generator Performance Microbenchmarks
   - Compares ScalaCheck vs ScAllegro
   - Benchmarks: BST (single-pass), STLC, BoolList
   - Generator sizes: 10, 100, 1000, 10000

3. **Figures 17-18** - Etna Bug-Finding Speed
   - BST workload: 37 tasks × 30 random seeds
   - STLC workload: 20 tasks × 30 random seeds
   - Strategies: AllegrOCaml vs AllegrOCaml+CSplitMix

### Experiments Excluded

- **Figure 15** - bind/sample counting analysis (too complex to package reliably)

### Output Format

All experiments produce CSV files containing:
- Benchmark/task names
- Generator strategies tested
- Performance metrics (time, throughput, etc.)
- Statistical data for analysis

**Note:** This artifact produces the raw data as CSV files. Figure generation from these CSVs is not included but can be performed using your preferred plotting tools.

## Manual Reproduction (Step-by-Step)

If you prefer to run experiments individually or outside Docker:

### 1. Environment Setup

#### System Requirements

- Ubuntu 24.04 (or compatible Linux distribution)
- At least 16GB RAM (264GB recommended for full parallelism)
- ~100GB free disk space

#### Install Dependencies

```bash
# Install system packages
sudo apt-get update
sudo apt-get install -y build-essential git opam sbt openjdk-21-jdk wget curl m4 pkg-config libgmp-dev

# Initialize opam
opam init -y --disable-sandboxing --bare

# Create OCaml switch with BER MetaOCaml 4.14.1
opam switch create 4.14.1+BER ocaml-base-compiler.4.14.1
eval $(opam env --switch=4.14.1+BER)
opam install -y metaocaml

# Install OCaml packages
opam install -y dune core base_quickcheck splittable_random alcotest core_bench ppx_jane
```

### 2. Build Projects

```bash
cd artifact

# Build AllegrOCaml (staged-ocaml)
cd waffle-house/staged-ocaml
opam exec -- dune build
cd ../..

# Build ScAllegro (staged-scala)
cd waffle-house/staged-scala
sbt compile
cd ../..

# Build Etna platform
cd etna2
opam exec -- dune build
cd ..
```

### 3. Run Individual Experiments

#### Figure 14: OCaml Generator Performance

```bash
cd artifact
bash scripts/run_ocaml_benchmarks.sh

# Results: results/ocaml_benchmarks.csv
```

This script runs Core_bench benchmarks comparing:
- Base_quickcheck (baseline)
- AllegrOCaml with SplittableRandom
- AllegrOCaml with CSplitMix (C-based fast RNG)

Across 6 generator strategies and 4 sizes (10, 100, 1000, 10000).

#### Figure 16: Scala Generator Performance

```bash
cd artifact
bash scripts/run_scala_benchmarks.sh

# Results: results/scala_benchmarks.csv
```

This script runs JMH (Java Microbenchmark Harness) benchmarks comparing:
- ScalaCheck (baseline)
- ScAllegro (staged generators)

Across 3 workloads and 4 sizes.

#### Figures 17-18: Etna Bug-Finding Speed

```bash
cd artifact
bash scripts/run_etna_experiments.sh

# Results: results/etna_bst.csv, results/etna_stlc.csv
```

This script evaluates how quickly different generator strategies find bugs in mutated programs:
- BST workload: 37 buggy variants
- STLC workload: 20 buggy variants
- 30 random seeds per variant
- Timeout: 60 seconds per trial

**Warning:** This is the most time-consuming phase (~3-4 hours).

### 4. Verify Results

After running experiments, verify the output:

```bash
# Check that all CSV files were created
ls -lh results/

# Inspect CSV structure
head results/ocaml_benchmarks.csv
head results/scala_benchmarks.csv
head results/etna_bst.csv
head results/etna_stlc.csv
```

## Directory Structure

```
artifact/
├── Dockerfile                 # Docker container specification
├── README.md                  # This file
├── scripts/                   # Automation scripts
│   ├── run_ocaml_benchmarks.sh   # OCaml microbenchmarks runner
│   ├── run_scala_benchmarks.sh   # Scala microbenchmarks runner
│   ├── run_etna_experiments.sh   # Etna experiments runner
│   ├── run_etna.py               # Python helper for Etna
│   └── reproduce_all.sh          # Master one-click script
├── waffle-house/              # Main research codebase
│   ├── staged-ocaml/             # AllegrOCaml implementation
│   ├── staged-scala/             # ScAllegro implementation
│   ├── handwritten-*/            # Baseline implementations
│   └── paper/                    # LaTeX source for paper
└── etna2/                     # Etna bug-finding platform
    ├── workloads/OCaml/          # BST, STLC, RBT workloads
    └── experiments/              # Experiment infrastructure
```

## Expected Results

The paper claims the following performance improvements:

### Figure 14: OCaml Generator Performance

- **AllegrOCaml** (staged + SplittableRandom): 1.3-7× speedup over Base_quickcheck
- **AllegrOCaml+CSplitMix**: 2.1-9.8× speedup over Base_quickcheck

The speedups should increase with generator size, with the largest improvements at size 10000.

### Figure 16: Scala Generator Performance

- **ScAllegro**: 4.9-13.4× speedup over ScalaCheck

Similar to OCaml, speedups increase with generator size.

### Figures 17-18: Etna Bug-Finding Speed

- **AllegrOCaml alone**: 1.2-3.9× faster bug finding
- **AllegrOCaml+CSplitMix**: 2.4-3.9× faster bug finding

Speedups measured as geometric mean across all tasks.

## Notes on Reproducibility

### Hardware Differences

Performance numbers will vary based on hardware. The original experiments were run on:
- CPU: [Original hardware specs from paper]
- RAM: 264GB
- OS: Linux

Modern hardware may show different absolute performance but should demonstrate similar relative speedups.

### Variance

- Microbenchmarks may show 5-15% variance across runs
- Etna experiments use random seeds, so exact times will vary
- Geometric means should be stable across multiple runs

### Timeouts

If experiments are running too long:
- Reduce NUM_SEEDS in `scripts/run_etna.py` (currently 30)
- Reduce benchmark sizes or iterations
- Run a subset of strategies

## Troubleshooting

### Docker Build Fails

**Issue:** opam packages fail to install

**Solution:** The opam repository may have updated. Try:
```bash
opam update
opam upgrade
```

### Out of Memory

**Issue:** sbt compile or experiments crash with OOM

**Solution:**
- Increase Docker memory limit (Docker Desktop settings)
- For native builds, close other applications
- Reduce parallelism in Etna experiments

### Benchmarks Take Too Long

**Issue:** OCaml/Scala benchmarks exceed expected time

**Solution:** Reduce the benchmark duration in the scripts:
- OCaml: Change `--duration 5s` in `run_ocaml_benchmarks.sh`
- Scala: Modify JMH parameters in `build.sbt`

### Etna Experiments Fail

**Issue:** Etna workloads don't build or run

**Solution:** Verify opam environment:
```bash
opam switch
eval $(opam env --switch=4.14.1+BER)
```

## Contact

For questions or issues with this artifact:
- Open an issue on the artifact repository
- Contact the paper authors (see paper for emails)

## License

This artifact is distributed under the same license as the research code. See individual directories for specific license information.

## Citation

If you use this artifact in your research, please cite:

```bibtex
[Citation information from paper]
```
