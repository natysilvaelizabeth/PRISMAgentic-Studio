FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

# Metadata
LABEL maintainer="PRISMAgentic Studio Team"
LABEL description="Development container for PRISMAgentic Studio"

# Avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install additional OS packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Build tools
    build-essential \
    cmake \
    # Python dependencies
    python3-dev \
    python3-pip \
    python3-venv \
    # Node.js build tools
    g++ \
    make \
    # Database tools
    postgresql-client \
    # Network tools
    curl \
    wget \
    httpie \
    jq \
    # Git tools
    git-lfs \
    # Other utilities
    unzip \
    zip \
    vim \
    nano \
    htop \
    tree \
    && rm -rf /var/lib/apt/lists/*

# Install Azure Functions Core Tools
RUN curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg \
    && mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg \
    && sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-$(lsb_release -cs)-prod $(lsb_release -cs) main" > /etc/apt/sources.list.d/dotnetdev.list' \
    && apt-get update \
    && apt-get install -y azure-functions-core-tools-4 \
    && rm -rf /var/lib/apt/lists/*

# Install global Python packages
RUN pip3 install --no-cache-dir --upgrade pip setuptools wheel

# Install global Node.js packages
RUN npm install -g \
    npm@latest \
    yarn \
    pnpm \
    typescript \
    @azure/static-web-apps-cli

# Create workspace directory
RUN mkdir -p /workspace
WORKDIR /workspace

# Set up Python virtual environment location
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Default shell
SHELL ["/bin/bash", "-c"]

# Switch to non-root user
USER vscode