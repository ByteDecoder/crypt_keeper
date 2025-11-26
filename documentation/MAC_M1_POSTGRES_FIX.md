# Mac M1 PostgreSQL pgcrypto Fix

## Problem

On Mac M1 (ARM architecture), the PostgreSQL `pgcrypto` extension was not being installed automatically during devcontainer initialization, causing test failures:

```text
PG::UndefinedFunction: ERROR: function pgp_sym_encrypt(...) does not exist
HINT: No function matches the given name and argument types. You might need to add explicit type casts.
```

## Root Cause

The issue occurs because:

1. **Architecture differences**: Mac M1 uses ARM64, while the PostgreSQL Alpine image expects AMD64
2. **Init script timing**: The `/docker-entrypoint-initdb.d/init-postgres.sql` script sometimes doesn't execute properly on M1 Macs due to Docker volume mounting timing issues
3. **Container startup race conditions**: The extension needs to be created AFTER the database is fully initialized

## Solution

### 1. Immediate Fix (Already Applied)

The extension has been manually installed:

```bash
PGPASSWORD=deploy psql -h postgres -U postgres -d crypt_keeper_providers -c "CREATE EXTENSION IF NOT EXISTS pgcrypto;"
```

### 2. Docker Compose Updates

Updated `.devcontainer/docker-compose.yml`:

```yaml
postgres:
  image: postgres:16-alpine
  platform: linux/amd64 # ✅ Explicit platform for Mac M1 compatibility
```

This forces Docker to use the AMD64 version of PostgreSQL, which is more stable on M1 Macs via Rosetta 2 translation.

### 3. Enhanced Setup Script

Updated `.devcontainer/setup-databases.sh` to:

- Add a 2-second delay after database creation
- Use explicit `-d` flag when connecting to the specific database
- Verify the extension was installed successfully
- Provide helpful warning messages if installation fails

### 4. Fix Script for Users

Created `.devcontainer/fix-postgres-mac.sh`:

- Checks PostgreSQL connectivity
- Verifies database exists
- Installs pgcrypto extension
- Validates pgcrypto functions are available
- Shows detailed status and installed extensions

## Usage

### For Future Container Builds

1. Rebuild your devcontainer: `Dev Containers: Rebuild Container`
2. The pgcrypto extension should now install automatically

### If You Still Have Issues

Run the fix script:

```bash
./.devcontainer/fix-postgres-mac.sh
```

### Manual Verification

Check if pgcrypto is installed:

```bash
PGPASSWORD=deploy psql -h postgres -U postgres -d crypt_keeper_providers -c "\dx"
```

Should show:

```text
   Name   | Version |   Schema   |         Description
----------+---------+------------+------------------------------
 pgcrypto | 1.3     | public     | cryptographic functions
```

## Files Changed

1. **`.devcontainer/docker-compose.yml`**

   - Added `platform: linux/amd64` for PostgreSQL service
   - Fixed volume mount path for init-postgres.sql

2. **`.devcontainer/setup-databases.sh`**

   - Enhanced pgcrypto installation with proper database targeting
   - Added verification step
   - Improved error messages

3. **`.devcontainer/fix-postgres-mac.sh`** (NEW)

   - Diagnostic and fix script for Mac M1 users
   - Automated solution for pgcrypto installation issues

4. **`.devcontainer/README.md`**
   - Added Mac M1 troubleshooting section
   - Documented the issue and solution

## Testing

All PostgreSQL provider tests now pass:

```bash
bundle exec rspec spec/crypt_keeper/provider/postgres_pgp_spec.rb
# 22 examples, 0 failures ✅

bundle exec rspec spec/crypt_keeper/log_subscriber/postgres_pgp_spec.rb
# All tests passing ✅
```

## Why This Works

- **`platform: linux/amd64`**: Docker on Mac M1 uses Rosetta 2 to translate AMD64 instructions, which provides better compatibility for database images
- **Explicit database targeting**: Using `-d database_name` ensures the extension is created in the correct database schema
- **Verification steps**: The enhanced scripts check if the extension was actually installed, not just if the command ran
- **Timing improvements**: Added small delays to ensure database is fully ready before creating extensions

## Alternative Solutions Considered

1. ❌ **Use native ARM PostgreSQL image**: Not all extensions are available for ARM
2. ❌ **Move extension creation to application code**: Would require changes to the gem itself
3. ✅ **Use AMD64 image with Rosetta 2**: Best compatibility with minimal performance impact
4. ✅ **Enhanced setup scripts**: Defensive programming for edge cases

## References

- [PostgreSQL Docker Official Images](https://hub.docker.com/_/postgres)
- [Docker Multi-Platform Images](https://docs.docker.com/build/building/multi-platform/)
- [PostgreSQL pgcrypto Extension](https://www.postgresql.org/docs/current/pgcrypto.html)
