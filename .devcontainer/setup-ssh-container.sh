#!/bin/bash
# Setup SSH inside the container (copy from host mount and fix permissions)

HOST_SSH_MOUNT="/home/developer/.ssh-host"
CONTAINER_SSH_DIR="/home/developer/.ssh"

echo "🔧 Setting up SSH inside container..."

# Create SSH directory
mkdir -p "$CONTAINER_SSH_DIR"
chmod 700 "$CONTAINER_SSH_DIR"

# Copy SSH keys and files from host mount
if [ -d "$HOST_SSH_MOUNT" ]; then
    echo "📋 Copying SSH files from host..."
    
    # Copy all files
    cp -r "$HOST_SSH_MOUNT"/* "$CONTAINER_SSH_DIR/" 2>/dev/null || true
    
    # Filter out macOS-specific options from config if it exists
    if [ -f "$CONTAINER_SSH_DIR/config" ]; then
        echo "📝 Filtering SSH config (removing macOS-specific options)..."
        # Remove UseKeychain lines (case-insensitive)
        grep -iv "usekeychain" "$CONTAINER_SSH_DIR/config" > "$CONTAINER_SSH_DIR/config.tmp"
        mv "$CONTAINER_SSH_DIR/config.tmp" "$CONTAINER_SSH_DIR/config"
        chmod 600 "$CONTAINER_SSH_DIR/config"
        echo "  ✓ Config filtered"
    fi
    
    # Fix permissions
    chmod 700 "$CONTAINER_SSH_DIR"
    chmod 600 "$CONTAINER_SSH_DIR"/* 2>/dev/null || true
    chmod 644 "$CONTAINER_SSH_DIR"/*.pub 2>/dev/null || true
    
    echo "✅ SSH setup complete"
    
    # Set GIT_SSH_COMMAND in shell profiles for persistence
    FILTERED_CONFIG="$CONTAINER_SSH_DIR/config"
    echo "export GIT_SSH_COMMAND='ssh -F $FILTERED_CONFIG'" >> /home/developer/.bashrc
    echo "export GIT_SSH_COMMAND='ssh -F $FILTERED_CONFIG'" >> /home/developer/.zshrc
    echo "  ✓ GIT_SSH_COMMAND configured in shell profiles"
else
    echo "⚠️  No host SSH directory mounted at $HOST_SSH_MOUNT"
    echo "   Git operations may require manual SSH key setup"
fi
