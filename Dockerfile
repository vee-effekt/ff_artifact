FROM ubuntu:24.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Base dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    opam \
    sbt \
    openjdk-21-jdk \
    wget \
    curl \
    m4 \
    pkg-config \
    libgmp-dev \
    && rm -rf /var/lib/apt/lists/*

# OCaml setup - BER MetaOCaml 4.14.1
# Initialize opam for root user
RUN opam init -y --disable-sandboxing --bare

# Create OCaml switch with BER MetaOCaml 4.14.1
RUN opam switch create 4.14.1+BER ocaml-base-compiler.4.14.1 && \
    eval $(opam env --switch=4.14.1+BER) && \
    opam install -y metaocaml

# Install OCaml dependencies
RUN opam install -y --switch=4.14.1+BER \
    dune \
    core \
    base_quickcheck \
    splittable_random \
    alcotest \
    core_bench \
    ppx_jane

# Set up environment for OCaml
RUN echo 'eval $(opam env --switch=4.14.1+BER)' >> /root/.bashrc

# Set working directory
WORKDIR /artifact

# Copy codebase and artifact scripts
COPY waffle-house /artifact/waffle-house
COPY etna2 /artifact/etna2
COPY scripts /artifact/scripts

# Build OCaml projects
RUN eval $(opam env --switch=4.14.1+BER) && \
    cd /artifact/waffle-house/staged-ocaml && \
    opam exec -- dune build

# Build Scala project
RUN cd /artifact/waffle-house/staged-scala && \
    sbt compile

# Build Etna
RUN eval $(opam env --switch=4.14.1+BER) && \
    cd /artifact/etna2 && \
    opam exec -- dune build

# Create results directory
RUN mkdir -p /artifact/results

CMD ["/bin/bash"]
