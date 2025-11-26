#!/bin/bash
# Quick fix for SSH config in current container (no rebuild needed)

echo "🔧 Quick Fix: Filtering SSH config for Linux compatibility..."

# Create a temporary SSH config without macOS-specific options
TEMP_SSH_CONFIG="/tmp/ssh_config_filtered"

if [ -f "/home/developer/.ssh/config" ]; then
    echo "📝 Creating filtered SSH config..."
    
    # Filter out UseKeychain (case-insensitive)
    grep -iv "usekeychain" /home/developer/.ssh/config > "$TEMP_SSH_CONFIG"
    
    echo "✅ Filtered config created at: $TEMP_SSH_CONFIG"
    echo ""
    
    # Add to shell profiles if not already there
    if ! grep -q "GIT_SSH_COMMAND.*$TEMP_SSH_CONFIG" ~/.bashrc 2>/dev/null; then
        echo "export GIT_SSH_COMMAND='ssh -F $TEMP_SSH_CONFIG'" >> ~/.bashrc
        echo "  ✓ Added to ~/.bashrc"
    fi
    
    if ! grep -q "GIT_SSH_COMMAND.*$TEMP_SSH_CONFIG" ~/.zshrc 2>/dev/null; then
        echo "export GIT_SSH_COMMAND='ssh -F $TEMP_SSH_CONFIG'" >> ~/.zshrc
        echo "  ✓ Added to ~/.zshrc"
    fi
    
    # Set it for the current shell
    export GIT_SSH_COMMAND="ssh -F $TEMP_SSH_CONFIG"
    echo ""
    echo "✅ GIT_SSH_COMMAND configured and active"
    echo "   You can now use git push, git pull, etc."
else
    echo "❌ No SSH config found at /home/developer/.ssh/config"
fi
