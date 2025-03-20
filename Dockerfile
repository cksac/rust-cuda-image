ARG BUILDKIT_SBOM_SCAN_CONTEXT=true
ARG BUILDKIT_SBOM_SCAN_STAGE=true

ARG IMAGE_VERSION=25.02-py3
FROM nvcr.io/nvidia/pytorch:$IMAGE_VERSION

# Upgrade
RUN apt-get upgrade -y

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git-lfs \
    ssh \
    && rm -rf /etc/ssh/ssh_host_*

# Install dumb-init
RUN apt-get install -y dumb-init

# Upgrade pip
RUN pip install --no-cache-dir --upgrade pip

# Set up git to support LFS, and to cache credentials; useful for Huggingface Hub
RUN git config --global credential.helper cache && git lfs install

# Install Huggingface tools
RUN pip install --no-cache-dir hf_transfer huggingface-hub[cli]

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain stable -y

ENV PATH=/root/.cargo/bin:$PATH

# Make port 22 available to the world outside this container
EXPOSE 22

# RunPod specific settings
COPY --chmod=755 runpod.sh /runpod.sh

RUN rm -rf /workspace/*

# Set the entry point
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD ["bash", "-c", "/runpod.sh"]