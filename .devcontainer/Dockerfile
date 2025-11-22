# Use official Ruby image as base
# Using Ruby 3.4 for better gem compatibility
FROM ruby:3.4-slim

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    curl \
    wget \
    vim \
    less \
    postgresql-client \
    libpq-dev \
    mariadb-client \
    libmariadb-dev \
    libmariadb-dev-compat \
    sqlite3 \
    libsqlite3-dev \
    pkg-config \
    libssl-dev \
    libreadline-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /workspace

# Install latest bundler and rake first (as root)
RUN gem update --system && \
    gem install bundler rake

# Create a non-root user
RUN groupadd --gid 1000 developer \
    && useradd --uid 1000 --gid developer --shell /bin/bash --create-home developer

# Switch to developer user permanently for bundle setup
USER developer

# Set up bundle to install in user home directory
ENV BUNDLE_PATH=/home/developer/.bundle
ENV GEM_HOME=/home/developer/.gem
ENV PATH=/home/developer/.gem/bin:/home/developer/.bundle/bin:$PATH

# Set up gem configuration
RUN echo "gem: --no-document" > /home/developer/.gemrc

# Switch back to root temporarily for final setup
USER root

# Copy the application (will be mounted over by docker-compose)
COPY . .

# Make setup scripts executable
RUN chmod +x .devcontainer/*.sh 2>/dev/null || true

# Set permissions for developer user and bundle
RUN chown -R developer:developer /workspace

# Switch to developer user
USER developer

# Set working directory
WORKDIR /workspace

# Default command
CMD ["bash"]

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD ruby --version || exit 1

# Labels
LABEL maintainer="CryptKeeper Development Team"
LABEL description="Development environment for CryptKeeper Ruby gem"
LABEL version="1.0"
