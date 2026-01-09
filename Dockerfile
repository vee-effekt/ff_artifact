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
RUN pip3 install --break-system-packages matplotlib numpy seaborn scipy

# OCaml setup - BER MetaOCaml 4.14.1
# Initialize opam for root user
RUN opam init -y --disable-sandboxing --bare

# Create switch with BER MetaOCaml
RUN opam switch create 4.14.1+BER ocaml-variants.4.14.1+BER

# Install OCaml dependencies
RUN opam install -y --switch=4.14.1+BER \
    base_quickcheck \
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
WORKDIR /ff_artifact

# Copy and extract tarballs (use --build-arg CACHEBUST=$(date +%s) to force refresh)
ARG CACHEBUST=1
COPY releases/*.tar.gz /tmp/
RUN mkdir -p artifact && cd artifact && \
    for tarball in /tmp/*.tar.gz; do tar -xzf "$tarball"; done && \
    rm /tmp/*.tar.gz

# Copy all scripts
COPY scripts/*.sh artifact/scripts/

# Make all scripts executable
RUN chmod +x artifact/scripts/*.sh

# Note: Build steps moved to artifact/build.sh script
# Run the script inside the container to build all components

# Create results directory
RUN mkdir -p artifact/results

CMD ["/bin/bash"]
