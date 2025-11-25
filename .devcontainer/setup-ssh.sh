#!/bin/bash
# Setup SSH for Linux container (filter out macOS-specific options)
# This script is meant to be run on the HOST before mounting, not in container

HOST_SSH_DIR="$HOME/.ssh"
CONTAINER_SSH_DIR="$HOME/.ssh-container"

echo "🔧 Setting up SSH configuration for container compatibility..."

# Create container SSH directory if it doesn't exist
mkdir -p "$CONTAINER_SSH_DIR"
chmod 700 "$CONTAINER_SSH_DIR"

# Copy SSH keys (not config)
echo "📋 Copying SSH keys..."
for key in "$HOST_SSH_DIR"/id_*; do
    if [ -f "$key" ]; then
        filename=$(basename "$key")
        cp "$key" "$CONTAINER_SSH_DIR/$filename"
        chmod 600 "$CONTAINER_SSH_DIR/$filename"
        echo "  ✓ Copied $filename"
    fi
done

# Copy public keys
for key in "$HOST_SSH_DIR"/*.pub; do
    if [ -f "$key" ]; then
        filename=$(basename "$key")
        cp "$key" "$CONTAINER_SSH_DIR/$filename"
        chmod 644 "$CONTAINER_SSH_DIR/$filename"
        echo "  ✓ Copied $filename"
    fi
done

# Filter SSH config if it exists
if [ -f "$HOST_SSH_DIR/config" ]; then
    echo "📝 Filtering SSH config (removing macOS-specific options)..."
    # Remove UseKeychain lines (case-insensitive)
    grep -iv "usekeychain" "$HOST_SSH_DIR/config" > "$CONTAINER_SSH_DIR/config"
    chmod 600 "$CONTAINER_SSH_DIR/config"
    echo "  ✓ Config filtered"
else
    echo "ℹ️  No SSH config found, skipping"
fi

# Copy known_hosts if it exists
if [ -f "$HOST_SSH_DIR/known_hosts" ]; then
    cp "$HOST_SSH_DIR/known_hosts" "$CONTAINER_SSH_DIR/known_hosts"
    chmod 600 "$CONTAINER_SSH_DIR/known_hosts"
    echo "  ✓ Copied known_hosts"
fi

echo ""
echo "✅ SSH setup complete!"
echo ""
echo "Next steps:"
echo "1. Update docker-compose.yml to mount ~/.ssh-container instead of ~/.ssh"
echo "2. Rebuild your devcontainer"
