# ff_artifact

## Quick Start

### Step 1: Build the Docker image

```bash
cd /home/ubuntu/ff_artifact
sudo docker build -t ff-artifact:latest .
```

If you've modified the tarballs and need to force a refresh:

```bash
sudo docker build --build-arg CACHEBUST=$(date +%s) -t ff-artifact:latest .
```

### Step 2: Run the container

```bash
sudo docker run -it ff-artifact:latest
```

This drops you into a bash shell inside the container at `/ff_artifact`.

### Step 3: Run the build script

Inside the container:

```bash
./artifact/build.sh
```

This will:
1. Install ppx_show (missing OCaml dependency)
2. Install benchtool Python package
3. Build and install staged-ocaml
4. Build and install ppx_staged
5. Build and install etna util library
6. Build and install BST, STLC, and RBT workloads

Wait for the build to complete (takes several minutes).

### Step 4: Run the experiments

After the build completes, run the experiments:

```bash
cd /ff_artifact/artifact/etna
./bash-bst.sh      # BST experiments
./bash-stlc.sh     # STLC experiments (if available)
```

Results will be saved to a timestamped directory like `bst-experiments-YYYYMMDD-HHMMSS/`.

---

## Regenerating Tarballs

If you modify source files in `/home/ubuntu/ff_artifact/repos/`, you need to regenerate the tarballs:

```bash
cd /home/ubuntu/ff_artifact
./scripts/make-tarballs.sh
```

Then rebuild the Docker image with cache bust:

```bash
sudo docker build --build-arg CACHEBUST=$(date +%s) -t ff-artifact:latest .
```

---

## Directory Structure

```
ff_artifact/
├── Dockerfile           # Docker build configuration
├── releases/            # Generated tarballs (copied into container)
├── repos/               # Source repositories
│   ├── etna/           # Etna benchmarking framework
│   ├── waffle-house/   # Staged OCaml libraries
│   └── ...
├── scripts/
│   ├── build.sh        # Build script (runs inside container)
│   └── make-tarballs.sh # Regenerates release tarballs
└── artifact/            # (empty on host, populated in container)
```

Inside the container:

```
/ff_artifact/
└── artifact/
    ├── build.sh         # Build script
    ├── etna/            # Extracted etna
    ├── waffle-house/    # Extracted waffle-house
    ├── eval/            # Evaluation scripts
    └── results/         # Output directory
```

---

## Troubleshooting

### "No module named 'benchtool'"
You forgot to run the build script. Run `./artifact/build.sh` first.

### "Unbound module BST"
The BST library wasn't installed properly. Ensure step 3 completed without errors.

### Docker caching old tarballs
Use `--build-arg CACHEBUST=$(date +%s)` when building to force refresh.

---

## Skipped Components

- **unboxed-splitmix**: Requires OxCaml (not BER MetaOCaml)
- **staged-scala**: Can be built separately with:
  ```bash
  cd /ff_artifact/artifact/waffle-house/staged-scala && sbt compile
  ```
