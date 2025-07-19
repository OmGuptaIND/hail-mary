# Start from the official Ubuntu 22.04 LTS image
FROM ubuntu:22.04

# Set environment variables to avoid interactive prompts and configure locale
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=UTC \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    PATH="/home/stack/.local/bin:/home/stack/.cargo/bin:${PATH}"

# Consolidate all system setup into a single RUN command to reduce image layers
RUN apt-get update && \
    # Install base dependencies and locale configuration
    apt-get install -y --no-install-recommends \
    software-properties-common \
    gpg-agent \
    gpg \
    ssh-client \
    git \
    build-essential \
    sudo \
    curl \
    ca-certificates \
    locales \
    && \
    # Generate the en_US.UTF-8 locale
    locale-gen en_US.UTF-8 && \
    # Add PPA and install Python 3.12
    add-apt-repository ppa:deadsnakes/ppa -y && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    python3.12 \
    python3.12-venv \
    python3.12-dev \
    && \
    # Clean up apt cache
    rm -rf /var/lib/apt/lists/*

# Update alternatives to make python3.12 the default python3 and python
# And ensure pip is up-to-date for the new python version
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.12 1 && \
    python3 -m pip install --no-cache-dir --upgrade pip

# Create a non-root user 'stack' with passwordless sudo
RUN useradd -m -s /bin/bash -G sudo stack && \
    echo "stack ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/stack

# Switch to the new non-root user for all subsequent commands
USER stack
WORKDIR /workspace

# Install the 'uv' package manager as the 'stack' user
RUN curl -LsSf https://astral.sh/uv/install.sh | sh