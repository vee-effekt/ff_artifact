# Fail Faster: Staging and Fast Randomness for High-Performance Property-Based Testing

Hi! You've found the artifact for *Fail Faster: Staging and Fast Randomness for High-Performance Property-Based Testing*. If you're here to review it, I hope I can make your job relatively painless.

First, I'll tell you how to use the artifact we've made available on Zenodo. Then we'll get into how you might run this on your computer.

## Table of Contents

1. [Requirements](#requirements)
2. [Getting Started](#getting-started)
3. [Directory Structure](#directory-structure)
4. [Kick the Tires](#kick-the-tires)
5. [Regenerate the Data](#regenerate-the-data)
6. [Expected Outputs](#expected-outputs)
7. [Further Use](#further-use)
8. [Troubleshooting](#troubleshooting)

## Requirements
Nothing is *that* resource intensive here; I was able to run all the experiments inside the Docker container on my Apple M3 Pro with 18 GB of RAM, but I'm not sure how low you can go. You'll need Docker, and it might be nice to have the Dev Containers extension for VSCode. I'm using Docker version 28.4.0 on macOS.

You'll also need like 12 GB of Disk space. (Sorry.)

## Getting Started

First, clone this repository. I assume you know how to do this. This repository contains a bunch of tarballs of other repositories I didn't want you to have to worry about, plus some scripts. It also contains a `Dockerfile`, which is the first thing you'll need to run. You can do so using this command (from the `ff_artifact` directory):

```bash
sudo docker build -t ff-artifact:latest .
```

Now, you should run the container:

```bash
sudo docker run -it ff-artifact:latest
```

This will drop you into a bash shell inside the container at `/ff_artifact`. At this time, it may behoove you to attach your IDE to the container, but I'll leave that up to you. You *can* continue from the command line if you want.

Now, you'll want to run this series of commands: 

```bash
cd artifact/scripts
./build.sh
```

This will run the build script, which chooses the right opam switch (the one with MetaOCaml), and installs a bunch of local OCaml packages and builds the projects and some other stuff. It will tell you what it's doing as it does it.

At this point, the container is set up for experiments.

## Directory Structure

Inside the container (`/ff_artifact/artifact/`) the directory structure should look like this:

```
artifact/
├── scripts/                   # Pipeline scripts
│   ├── analyze_all.sh         # Analyze all precomputed data
│   ├── analyze_ocaml.sh       # Analyze precomputed OCaml data
│   ├── analyze_scala.sh       # Analyze precomputed Scala data
│   ├── analyze_etna.sh        # Analyze precomputed Etna data
│   ├── run_all.sh             # Run all experiments
│   ├── run_ocaml.sh           # Run OCaml benchmarks
│   ├── run_scala.sh           # Run Scala benchmarks
│   ├── run_etna.sh            # Run ETNA experiments
│   └── clean_fresh.sh         # Clean all generated data (in case you need to do that)
├── eval/
│   ├── 4.1_data_ocaml/        # Raw OCaml benchmark output
│   │   ├── precomputed/
│   │   └── fresh/
│   ├── 4.1_data_scala/        # Raw Scala benchmark output
│   │   ├── precomputed/
│   │   └── fresh/
│   ├── 4.2_data/              # Raw Etna benchmark output
│   │   ├── precomputed/
│   │   │   ├── bst-experiments/
│   │   │   └── stlc-experiments/
│   │   └── fresh/
│   ├── parsed_*/              # Parsed intermediate data (should initially be empty)
│   ├── figures/               # Generated figures (ditto)
│   │   ├── precomputed/
│   │   └── fresh/
│   ├── parsers/               # Data parsing scripts
│   ├── etna_data_processing/  # Etna-specific processing
│   └── figure_scripts/        # Figure generation scripts
├── etna/                      # Etna itself
├── waffle-house/              # This is Allegro; its development name was Waffle House
    ├── ... unimportant; ignore ... 
│   ├── staged-ocaml/          # AllegrOCaml 
│   ├── staged-scala/          # ScAllegro
│   └── ppx_staged/            # AllegrOCaml staged type-derived generators
└── build.sh                   # Initial build script
```

## Kick the Tires

Initially, let's just make sure the data analysis is working correctly using precomputed data. You can do this by running the following command:

```bash
./analyze_all.sh
```

This will generate figures for the OCaml microbenchmarks (Fig. 14), the Scala microbenchmarks (Fig. 16), and the Etna benchmarks (Fig. 17 and 18).

The precomputed data can be found in the `precomputed/` subdirectories of `ff_artifact/artifact/eval/4.1_data_ocaml`, `.../4.1_data_scala`, and `.../4.2_data`. This is what gets parsed, analyzed, and turned into graphs, which live in `.../figures/precomputed/...`.

You should see the following files:

- `fig14.png` - OCaml benchmark timing comparison
- `fig16.png` - Scala benchmark timing comparison
- `fig17.png` - Etna geo mean speedups
- `fig18.png` - Etna speedup distribution box plots

Notably, Fig. 15 is omitted. The reason for this is that it consists of a total of 8 datapoints, and so the process of creating it was not automated at all. As I recall, we altered the randomness library to increment a counter whenever it was called; then we counted the number of binds by analyzing the program in [`magic-trace`](https://github.com/janestreet/magic-trace). I really don't know how to begin automating this process; if I unexpectedly have the spare time before the artifact deadline maybe I'll come back to it, but if this text is still here... then I guess you know what happened. If you want to see the code for generating the figure itself, it's in `eval/figure_scripts/fig15.py`. Sorry!

Also, **if you want to generate results for a subset of the data**, there are bash scripts that go slightly more graular: `analyze_ocaml.sh`, `analyze_scala.sh`, and `analyze_etna.sh`.

### Regenerate the Data

To regenerate the data, you'll want the following command (from `/ff_artifact/artifact/scripts`):

```bash
./run_all.sh
```

How long this takes to run depends on the number of cores you have available. On the 64-core machine we used to do the eval, it was pretty fast---maybe an hour. On my 11-core Mac, takes... many hours, in the neighborhood of all night.

If you want less commitment, you can do `run_ocaml.sh`, `run_scala.sh`, or `run_etna.sh`, which do what you would expect. Once run, these will populate the `fresh/` directories of their respective subdirectories (`4.1_data_ocaml`, `4.1_data_scala`, and `4.2_data`) with raw data. This data will then be analyzed. You should be able to find the relevant figures in `/ff_artifact/artifact/eval/figures/fresh/`.

I have noticed that 

If you want, you can copy figures out of the container:
```bash
# From another terminal (outside the container)
sudo docker cp <container_id>:/ff_artifact/artifact/eval/figures/precomputed/ ./figures/
```

(To find your container ID: `sudo docker ps`.)

To remove all fresh data and start over:

```bash
cd ff_artifact/artifact/scripts
./clean_fresh.sh
```

## Expected Outputs

After evaluating, you should have eight figures: 4 using precomputed data and 4 using data you generated. I don't know exactly what the latter will look like, but the former should definitely look like this:

TODO: FIGGGGGGSSSSSS :-)

Something to note is that this is a performance evaluation inside a Docker container, which is not an ideal state of affairs. Docker introduces emulation overhead, and even aside from that, computers are complicated and sometimes do weird things. In particular, I have noticed that individual datapoints in the OCaml microbenchmarks occasionally take much longer than they're supposed to. I have done everything I can to prevent this from happening: the process is pinned to a single CPU core, and I force a full garbage collection between each workload. It still happens sometimes. If something looks "off," you can generate data for that individual workload (e.g., repeat-insert BST) using the commands in `./run_ocaml.sh`. Here's an example:

```bash
taskset -c 0 dune exec /ff_artifact/artifact/waffle-house/staged-ocaml/_build/default/test/bst_benchmark.exe > "$OUTPUT_DIR/results_bst.txt" 2>&1
```

## Further Use

Ooooooooffffff, do you really want to run this on your computer? I hope not. No-one who authored this paper was able to run this thing on their computer: we used an EC2 metal instance, since we all have Macs. This was both annoying and unnecessarily expensive, but MetaOCaml, the OCaml metaprogramming extension this whole thing is based on, only works on x86 (at least at time of development). 

I don't know if using MetaOCaml was the right choice. I think initially we were going to use [ppx_stage](https://github.com/stedolan/ppx_stage), but then we had some problems with that, and then we switched to MetaOCaml, which probably has worse problems if anything... but they emerged later, once we were already too committed.

Anyway. Running this on your computer.

TODO

## Contact

For questions or issues with this artifact, please open an issue on the repository. Or just [email me](mailto:lapwing@seas.upenn.edu), I guess; it might be faster.

