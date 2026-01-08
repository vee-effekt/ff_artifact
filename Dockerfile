FROM ubuntu:24.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Base dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    opam \
    openjdk-21-jdk \
    wget \
    curl \
    m4 \
    pkg-config \
    libgmp-dev \
    python3 \
    python3-pip \
    python3-venv \
    gnupg \
    ca-certificates \
    apt-transport-https \
    && rm -rf /var/lib/apt/lists/*

# Install sbt (Scala Build Tool)
RUN echo "deb https://repo.scala-sbt.org/scalasbt/debian all main" | tee /etc/apt/sources.list.d/sbt.list && \
    echo "deb https://repo.scala-sbt.org/scalasbt/debian /" | tee /etc/apt/sources.list.d/sbt_old.list && \
    curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | apt-key add - && \
    apt-get update && \
    apt-get install -y sbt && \
    rm -rf /var/lib/apt/lists/*

# Install Python packages for analysis
RUN pip3 install --break-system-packages matplotlib numpy seaborn

# OCaml setup - BER MetaOCaml 4.14.1
# Initialize opam for root user
RUN opam init -y --disable-sandboxing --bare

# Create switch with BER MetaOCaml
RUN opam switch create 4.14.1+BER ocaml-variants.4.14.1+BER

# Install OCaml dependencies
RUN opam install -y --switch=4.14.1+BER \
    dune \
    core \
    base_quickcheck \
    splittable_random \
    alcotest \
    core_bench \
    ppx_jane \
    ppxlib \
    qcheck \
    crowbar \
    ocamlfind \
    ppx_deriving \
    ppx_assert

# Set up environment for OCaml (both interactive and non-interactive shells)
RUN echo 'eval $(opam env --switch=4.14.1+BER)' >> /root/.bashrc
ENV OPAM_SWITCH_PREFIX="/root/.opam/4.14.1+BER"
ENV CAML_LD_LIBRARY_PATH="/root/.opam/4.14.1+BER/lib/stublibs:/root/.opam/4.14.1+BER/lib/ocaml/stublibs:/root/.opam/4.14.1+BER/lib/ocaml"
ENV OCAML_TOPLEVEL_PATH="/root/.opam/4.14.1+BER/lib/toplevel"
ENV PATH="/root/.opam/4.14.1+BER/bin:${PATH}"

# Set working directory
WORKDIR /artifact

# Copy and extract tarballs
COPY releases/*.tar.gz /tmp/
RUN cd /artifact && \
    tar -xzf /tmp/etna-*.tar.gz && \
    tar -xzf /tmp/eval-*.tar.gz && \
    tar -xzf /tmp/waffle-house-*.tar.gz && \
    tar -xzf /tmp/analysis-*.tar.gz && \
    tar -xzf /tmp/unboxed-splitmix-*.tar.gz && \
    rm /tmp/*.tar.gz

# Install unboxed-splitmix library (required by handwritten-ocaml)
RUN cd /artifact/unboxed-splitmix && \
    dune build && \
    opam install . -y

# Install etna util library
RUN cd /artifact/etna/workloads/OCaml/util && \
    opam install . -y

# Build etna OCaml workloads
RUN cd /artifact/etna/workloads/OCaml/BST && dune build && \
    cd /artifact/etna/workloads/OCaml/STLC && dune build && \
    cd /artifact/etna/workloads/OCaml/RBT && dune build

# Build waffle-house projects (in dependency order)
# 1. Build staged-ocaml (creates fast_gen library)
RUN cd /artifact/waffle-house/staged-ocaml && \
    dune build && \
    opam install . -y

# 2. Build ppx_staged (depends on fast_gen)
RUN cd /artifact/waffle-house/ppx_staged && \
    dune build && \
    opam install . -y

# 3. Build handwritten-ocaml (depends on unboxed-splitmix)
RUN cd /artifact/waffle-house/handwritten-ocaml && dune build

# 4. Build staged-scala
RUN cd /artifact/waffle-house/staged-scala && sbt compile

# Install Python dependencies for etna
RUN cd /artifact/etna && \
    python3 -m pip install -r tool/requirements.txt && \
    python3 -m pip install -e tool

# Create results directory
RUN mkdir -p /artifact/results

CMD ["/bin/bash"]
