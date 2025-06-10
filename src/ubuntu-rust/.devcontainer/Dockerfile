FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/root/.cargo/bin:$PATH"

# Minimal tools just for rustup to succeed
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    build-essential \
 && apt-get clean

# Install Rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y && \
    . "$HOME/.cargo/env" && \
    rustup component add rustfmt clippy

# Working directory
WORKDIR /workspace

CMD ["sleep", "infinity"]
