# Mac M1 SSH Configuration Fix

## Problem

On Mac M1, Git operations (push, pull, fetch) fail inside the devcontainer with SSH errors:

```text
/home/developer/.ssh/config: line X: Bad configuration option: usekeychain
/home/developer/.ssh/config: terminating, N bad configuration options
fatal: Could not read from remote repository.
```

## Root Cause

The issue occurs because:

1. **macOS-specific SSH options**: macOS SSH config uses `UseKeychain yes` to integrate with the macOS Keychain
2. **Linux SSH doesn't support this option**: The devcontainer runs Linux, where OpenSSH doesn't recognize `UseKeychain`
3. **Direct mount causes the issue**: The `.ssh` directory is mounted directly from the host, bringing the macOS-specific config into the Linux container

## Why It Works on Windows WSL2

Windows WSL2 doesn't have this issue because:

- Windows SSH configs typically don't use `UseKeychain` (it's macOS-specific)
- WSL2 users often have separate SSH configs for Linux anyway
- Windows users may use SSH agents or credential managers that are compatible with Linux

## Solution Overview

There are two approaches:

### Option 1: Quick Fix (Immediate, No Rebuild)

Use the provided fix script to filter the SSH config on-the-fly.

### Option 2: Permanent Fix (Requires Rebuild)

Configure the devcontainer to automatically filter SSH config on startup.

---

## Quick Fix (Current Container)

### Step 1: Run the Fix Script

```bash
./.devcontainer/fix-ssh-mac.sh
```

This will:

- Create a filtered SSH config at `/tmp/ssh_config_filtered` (without `UseKeychain`)
- Set `GIT_SSH_COMMAND` environment variable
- Add the setting to your shell profile (`.bashrc` and `.zshrc`)

### Step 2: Test Git Operations

```bash
git push
git pull
```

Should now work without errors! ✅

### What the Script Does

```bash
# Creates filtered config
grep -iv "usekeychain" ~/.ssh/config > /tmp/ssh_config_filtered

# Sets environment variable
export GIT_SSH_COMMAND='ssh -F /tmp/ssh_config_filtered'

# Persists to shell profiles
echo 'export GIT_SSH_COMMAND="ssh -F /tmp/ssh_config_filtered"' >> ~/.bashrc
echo 'export GIT_SSH_COMMAND="ssh -F /tmp/ssh_config_filtered"' >> ~/.zshrc
```

---

## Permanent Fix (Future Container Rebuilds)

The devcontainer has been updated to automatically handle this issue. After rebuilding:

### What's Changed

1. **`docker-compose.yml`**:

   - SSH directory mounted to `.ssh-host` instead of `.ssh`
   - Allows the container to create its own `.ssh` directory

2. **`setup-ssh-container.sh`**:

   - Runs during container creation
   - Copies SSH keys and config from `.ssh-host` to `.ssh`
   - Filters out `UseKeychain` lines
   - Sets `GIT_SSH_COMMAND` in shell profiles

3. **`devcontainer.json`**:
   - Updated `postCreateCommand` to run `setup-ssh-container.sh`

### How to Apply

1. **Rebuild the devcontainer**:

   - Command Palette (Ctrl+Shift+P / Cmd+Shift+P)
   - "Dev Containers: Rebuild Container"

2. **Verify it works**:
   ```bash
   git push
   # Should work without errors
   ```

---

## Manual Alternatives

### Option A: Set Environment Variable Per Session

```bash
export GIT_SSH_COMMAND='ssh -F /tmp/ssh_config_filtered'
git push
```

### Option B: Use Git Config

```bash
git config --global core.sshCommand "ssh -F /tmp/ssh_config_filtered"
```

### Option C: Create a Clean SSH Config

Create a minimal SSH config for the container:

```bash
cat > ~/.ssh/config.container << 'EOF'
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519
  AddKeysToAgent yes

Host *
  AddKeysToAgent yes
  IdentityFile ~/.ssh/id_rsa
EOF

export GIT_SSH_COMMAND='ssh -F ~/.ssh/config.container'
```

---

## Verification

### Check SSH Config is Filtered

```bash
# Original config (should have UseKeychain)
cat ~/.ssh/config | grep -i usekeychain

# Filtered config (should be empty)
cat /tmp/ssh_config_filtered | grep -i usekeychain
```

### Check Environment Variable

```bash
echo $GIT_SSH_COMMAND
# Should output: ssh -F /tmp/ssh_config_filtered
```

### Test SSH Connection

```bash
ssh -T git@github.com
# Should see: Hi <username>! You've successfully authenticated...
```

### Test Git Operations

```bash
git fetch
git pull
git push
```

---

## Files Changed

### New Files

1. **`.devcontainer/fix-ssh-mac.sh`**

   - Quick fix script for immediate resolution
   - Filters SSH config and sets environment variables

2. **`.devcontainer/setup-ssh-container.sh`**

   - Container startup script
   - Automatically filters SSH config on rebuild

3. **`documetation/MAC_M1_SSH_FIX.md`**
   - This documentation file

### Modified Files

1. **`.devcontainer/docker-compose.yml`**

   - Changed SSH mount from `~/.ssh` to `~/.ssh-host`

2. **`.devcontainer/devcontainer.json`**

   - Added `setup-ssh-container.sh` to `postCreateCommand`

3. **`.devcontainer/README.md`**
   - Added Mac M1 SSH troubleshooting section

---

## Why This Approach?

### ✅ Advantages

- **Non-invasive**: Doesn't modify your host SSH config
- **Automatic**: Works transparently after setup
- **Compatible**: Works on both Mac M1 and Windows WSL2
- **Secure**: Maintains proper SSH key permissions
- **Persistent**: Survives shell restarts

### ❌ Alternative Approaches Considered

1. **Edit host SSH config**: ❌ Would break macOS Keychain integration
2. **Use HTTPS instead of SSH**: ❌ Requires changing remote URLs and token management
3. **Disable SSH config**: ❌ Would lose other useful SSH settings
4. **Use Git credential helper**: ❌ Different workflow, not compatible with SSH keys

---

## Troubleshooting

### Issue: Environment variable not set after restart

**Solution**: Source your shell profile or run the fix script again

```bash
source ~/.bashrc  # or source ~/.zshrc
# or
./.devcontainer/fix-ssh-mac.sh
```

### Issue: Filtered config not found

**Solution**: Run the fix script to recreate it

```bash
./.devcontainer/fix-ssh-mac.sh
```

### Issue: Still getting UseKeychain errors

**Solution**: Check that GIT_SSH_COMMAND is set correctly

```bash
echo $GIT_SSH_COMMAND
# If empty, run:
export GIT_SSH_COMMAND='ssh -F /tmp/ssh_config_filtered'
```

### Issue: SSH key not found

**Solution**: Verify SSH keys are accessible

```bash
ls -la ~/.ssh/
# Should see your SSH keys (id_rsa, id_ed25519, etc.)
```

---

## References

- [OpenSSH Config File Options](https://www.ssh.com/academy/ssh/config)
- [Git SSH Configuration](https://git-scm.com/book/en/v2/Git-on-the-Server-Generating-Your-SSH-Public-Key)
- [macOS Keychain SSH Integration](https://developer.apple.com/library/archive/technotes/tn2449/_index.html)
- [Dev Containers Documentation](https://code.visualstudio.com/docs/devcontainers/containers)
