# Use official Ruby image as base
FROM ruby:3.4-slim

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV BUNDLE_PATH=/usr/local/bundle
ENV BUNDLE_BIN=/usr/local/bundle/bin
ENV GEM_HOME=/usr/local/bundle
ENV PATH=$BUNDLE_BIN:$PATH

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
    mysql-client \
    libmysqlclient-dev \
    sqlite3 \
    libsqlite3-dev \
    pkg-config \
    libssl-dev \
    libreadline-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /workspace

# Create a non-root user
RUN groupadd --gid 1000 developer \
    && useradd --uid 1000 --gid developer --shell /bin/bash --create-home developer \
    && mkdir -p /home/developer/.gem \
    && chown -R developer:developer /home/developer

# Set up gem configuration for the user
USER developer
RUN echo "gem: --no-document" > /home/developer/.gemrc

# Switch back to root for final setup
USER root

# Install latest bundler and rake
RUN gem update --system && \
    gem install bundler rake

# Copy gemfiles first for better caching
COPY Gemfile* crypt_keeper.gemspec ./
COPY lib/crypt_keeper/version.rb ./lib/crypt_keeper/

# Install dependencies
RUN bundle install

# Copy the rest of the application
COPY . .

# Set permissions
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
