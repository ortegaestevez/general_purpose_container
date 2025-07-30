# Use Ubuntu as base image
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    wget \
    unzip \
    build-essential \
    python3 \
    python3-pip \
    python3-venv \
    openjdk-17-jdk \
    ca-certificates \
    pkg-config \
    libtool \
    libtool-bin \
    autoconf \
    automake \
    cmake \
    g++ \
    gettext \
    libevent-dev \
    libncurses5-dev \
    libncursesw5-dev \
    libmsgpack-dev \
    libtermkey-dev \
    libvterm-dev \
    libunibilium-dev \
    ninja-build \
    software-properties-common \
    checkinstall \
    xz-utils \
    sudo \
    graphviz \
    && apt-get clean

# Install PlantUML (latest release JAR)
RUN curl -L -o /usr/local/bin/plantuml.jar \
    https://github.com/plantuml/plantuml/releases/latest/download/plantuml.jar

# Wrapper for PlantUML use
RUN echo '#!/bin/bash\njava -jar /usr/local/bin/plantuml.jar "$@"' > /usr/local/bin/plantuml \
    && chmod +x /usr/local/bin/plantuml

# Install Rust via rustup
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Install latest Neovim from source
RUN git clone https://github.com/neovim/neovim.git /opt/neovim && \
    cd /opt/neovim && \
    git checkout stable && \
    make CMAKE_BUILD_TYPE=Release && \
    make install

ENV PATH="/usr/local/bin:${PATH}"

# Create user after install
RUN useradd -ms /bin/bash dev
USER dev
WORKDIR /home/dev
